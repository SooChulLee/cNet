<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"system_stat","")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "시스템별통계");

	db = new Db(true);

	// get parameter
	String sort_idx = CommonUtil.getParameter("sort_idx", "system_name,rec_date");
	String sort_dir = CommonUtil.getParameter("sort_dir", "up,down");
	String rec_date1 = CommonUtil.getParameter("rec_date1");
	String rec_date2 = CommonUtil.getParameter("rec_date2");
	String rec_hour1 = CommonUtil.getParameter("rec_hour1");
	String rec_hour2 = CommonUtil.getParameter("rec_hour2");
	String system_code = CommonUtil.getParameter("system_code");
	String date_type = CommonUtil.getParameter("date_type", "DD");

	//sort_idx = ("v_rec_date".equals(sort_idx)) ? "rec_date" : sort_idx;
	//sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

	StringBuffer sb = new StringBuffer();


	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>시스템명</td>");
	sb.append("<td class=th>녹취일자</td>");
	sb.append("<td class=th>총콜수</td>");
	sb.append("<td class=th>총통화시간</td>");
	sb.append("<td class=th>IN</td>");
	sb.append("<td class=th>OUT</td>");
	sb.append("<td class=th>내선</td>");
	sb.append("</tr>");

	// search
	Map<String, Object> argMap = new HashMap<String, Object>();
	Map<String, Object> ordmap = new HashMap();
	Map<String, Object> parmap = new HashMap();

	argMap.put("rec_date1",rec_date1.replace("-", ""));
	argMap.put("rec_date2",rec_date2.replace("-", ""));
	argMap.put("rec_hour1",rec_hour1);
	argMap.put("rec_hour2",rec_hour2);
	argMap.put("system_code",system_code);
	argMap.put("date_type",date_type);
	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);

	// order map
	String ordarr[] = sort_idx.split(",");
	String dirarr[] = sort_dir.split(",");

	if(ordarr.length>0) {
		for(int i=0;i<ordarr.length;i++) {
			ordmap.put(("v_rec_date".equals(ordarr[i])) ? "rec_date" : ordarr[i], ("down".equals(dirarr[i])) ? "desc" : "asc");
		}
	}

	parmap.put("s", argMap);
	parmap.put("o", ordmap);

	List<Map<String, Object>> list = db.selectList("stat_system.selectList", parmap);

	// 2016.12.27 현원희 추가 -다운로드 이력
	//=========================================================================
	Map<String, Object> selmap2 = new HashMap();

	selmap2.put("excel_id", _LOGIN_ID);
	selmap2.put("excel_menu", "시스템별통계");
	selmap2.put("excel_name", _LOGIN_NAME);
	selmap2.put("excel_ip",request.getRemoteAddr());

	int ins_cnt = db.insert("hist_excel.insertExcelHist", selmap2);
	//=========================================================================

	int sum_tot_cnt = 0;
	int sum_tot_call_time = 0;
	int sum_in_cnt = 0;
	int sum_out_cnt = 0;
	int sum_local_cnt = 0;
	for(Map<String, Object> item : list) {
		// 총계 저장
		sum_tot_cnt += ((Integer) item.get("tot_cnt")).intValue();
		sum_tot_call_time += ((Integer) item.get("tot_call_time")).intValue();
		sum_in_cnt += ((Integer) item.get("in_cnt")).intValue();
		sum_out_cnt += ((Integer) item.get("out_cnt")).intValue();
		sum_local_cnt += ((Integer) item.get("local_cnt")).intValue();

		sb.append("<tr>");
		sb.append("<td>" + item.get("system_name") + "</td>");
		sb.append("<td>" + item.get("v_rec_date") + "</td>");
		sb.append("<td>" + item.get("tot_cnt") + "</td>");
		sb.append("<td>" + DateUtil.getHmsToSec((Integer) item.get("tot_call_time")) + "</td>");
		sb.append("<td>" + item.get("in_cnt") + "</td>");
		sb.append("<td>" + item.get("out_cnt") + "</td>");
		sb.append("<td>" + item.get("local_cnt") + "</td>");
		sb.append("</tr>");
	}

	if(list.size()>0) {
		sb.append("<tr>");
		sb.append("<td class=th><b>총계</b></td>");
		sb.append("<td class=th></td>");
		sb.append("<td class=th>" + sum_tot_cnt + "</td>");
		sb.append("<td class=th>" + DateUtil.getHmsToSec(sum_tot_call_time) + "</td>");
		sb.append("<td class=th>" + sum_in_cnt + "</td>");
		sb.append("<td class=th>" + sum_out_cnt + "</td>");
		sb.append("<td class=th>" + sum_local_cnt + "</td>");
		sb.append("</tr>");
	}

	sb.append("</table>");
	out.print(sb.toString());
} catch(Exception e) {
	logger.error(e.getMessage());
} finally {
	if(db!=null) db.close();
}
%>
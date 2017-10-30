<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"abort_hist","")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "필수중단이력");

	db = new Db(true);

	// get parameter
	String sort_idx = CommonUtil.getParameter("sort_idx", "abort_datm");
	String sort_dir = CommonUtil.getParameter("sort_dir", "down");

	String abort_date1 = CommonUtil.getParameter("abort_date1");
	String abort_date2 = CommonUtil.getParameter("abort_date2");

	String login_id = CommonUtil.getParameter("login_id");
	String login_name = CommonUtil.getParameter("login_name");
	String start_rec_date = CommonUtil.getParameter("start_rec_date","");
	String end_rec_date = CommonUtil.getParameter("ebd_rec_date","");


	sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

	StringBuffer sb = new StringBuffer();


	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>등록일시</td>");

	sb.append("<td class=th>필수중단 시작 일시</td>");
	sb.append("<td class=th>필수중단 종료 일시</td>");

	sb.append("<td class=th>대분류</td>");
	sb.append("<td class=th>중분류</td>");
	sb.append("<td class=th>소분류</td>");

	sb.append("<td class=th>로그인ID</td>");
	sb.append("<td class=th>로그인명</td>");
	sb.append("<td class=th>로그인IP</td>");
	sb.append("</tr>");

	// search
	Map<String, Object> argMap = new HashMap<String, Object>();

	argMap.put("abort_date1",abort_date1);
	argMap.put("abort_date2",abort_date2);

	argMap.put("abort_id",login_id);
	argMap.put("abort_name",login_name);

	argMap.put("start_rec_date",start_rec_date);
	argMap.put("end_rec_date",end_rec_date);

	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);

	List<Map<String, Object>> list = db.selectList("hist_abort.selectListAll", argMap);

	// 2016.12.27 현원희 추가 -다운로드 이력
	//=========================================================================
	Map<String, Object> selmap2 = new HashMap();

	selmap2.put("excel_id", _LOGIN_ID);
	selmap2.put("excel_menu", "필수중단이력");
	selmap2.put("excel_name", _LOGIN_NAME);
	selmap2.put("excel_ip",request.getRemoteAddr());

	int ins_cnt = db.insert("hist_excel.insertExcelHist", selmap2);
	//=========================================================================

	if(list.size()>0) {
		for(Map<String, Object> item : list) {
			sb.append("<tr>");
			sb.append("<td>" + item.get("abort_datm") + "</td>");
			sb.append("<td>" + item.get("start_rec_datm") + "</td>");
			sb.append("<td>" + item.get("end_rec_datm") + "</td>");


			sb.append("<td>" + item.get("bpart_name") + "</td>");
			sb.append("<td>" + item.get("mpart_name") + "</td>");
			sb.append("<td>" + item.get("spart_name") + "</td>");


			sb.append("<td>" + item.get("abort_id") + "</td>");
			sb.append("<td>" + item.get("abort_name") + "</td>");
			sb.append("<td>" + item.get("abort_ip") + "</td>");

			sb.append("</tr>");
		}
	}

	sb.append("</table>");
	out.print(sb.toString());
} catch(Exception e) {
	logger.error(e.getMessage());
} finally {
	if(db!=null) db.close();
}
%>
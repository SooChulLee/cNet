<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"down_hist","")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "다운로드이력");

	db = new Db(true);

	// get parameter
	String sort_idx = CommonUtil.getParameter("sort_idx", "down_datm");
	String sort_dir = CommonUtil.getParameter("sort_dir", "down");

	String down_date1 = CommonUtil.getParameter("down_date1");
	String down_date2 = CommonUtil.getParameter("down_date2");
	String login_id = CommonUtil.getParameter("login_id");
	String login_name = CommonUtil.getParameter("login_name");
	String rec_date1 = CommonUtil.getParameter("rec_date1","");
	String rec_date2 = CommonUtil.getParameter("rec_date2","");
	String user_id = CommonUtil.getParameter("user_id");
	String user_name = CommonUtil.getParameter("user_name");
	String reason_code = CommonUtil.getParameter("reason_code");
	String down_src = CommonUtil.getParameter("down_src");

	sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

	StringBuffer sb = new StringBuffer();

	//sb.append("<meta http-equiv='Content-Type' content='application/vnd.ms-excel;charset=euc-kr'>");

	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>다운일시</td>");

	sb.append("<td class=th>대분류</td>");
	sb.append("<td class=th>중분류</td>");
	sb.append("<td class=th>소분류</td>");

	sb.append("<td class=th>로그인ID</td>");
	sb.append("<td class=th>로그인명</td>");
	sb.append("<td class=th>로그인IP</td>");
	sb.append("<td class=th>녹취일시</td>");
	sb.append("<td class=th>상담사ID</td>");
	sb.append("<td class=th>상담사명</td>");
	sb.append("<td class=th>녹취파일명</td>");
	//청취/다운 사유입력이 존재하는 경우
	if(Finals.isExistPlayDownReason){
		sb.append("<td class=th>TA</td>");
		sb.append("<td class=th>다운사유</td>");
		sb.append("<td class=th>기타사유</td>");
	}
	sb.append("</tr>");

	// search
	Map<String, Object> argMap = new HashMap<String, Object>();

	argMap.put("down_date1",down_date1);
	argMap.put("down_date2",down_date2);
	argMap.put("down_id",login_id);
	argMap.put("down_name",login_name);
	argMap.put("rec_date1",rec_date1);
	argMap.put("rec_date2",rec_date2);
	argMap.put("user_id",user_id);
	argMap.put("user_name",user_name);
	argMap.put("reason_code",reason_code);
	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);
	argMap.put("down_src",down_src);

	List<Map<String, Object>> list = db.selectList("hist_down.selectListAll", argMap);

	// 2016.12.27 현원희 추가 -다운로드 이력
	//=========================================================================
	Map<String, Object> selmap2 = new HashMap();

	selmap2.put("excel_id", _LOGIN_ID);
	selmap2.put("excel_menu", "다운로드이력");
	selmap2.put("excel_name", _LOGIN_NAME);
	selmap2.put("excel_ip",request.getRemoteAddr());

	int ins_cnt = db.insert("hist_excel.insertExcelHist", selmap2);
	//=========================================================================

	if(list.size()>0) {
		for(Map<String, Object> item : list) {
			sb.append("<tr>");
			sb.append("<td>" + item.get("down_datm") + "</td>");

			sb.append("<td>" + ComLib.toNN(item.get("bpart_name")) + "</td>");
			sb.append("<td>" + ComLib.toNN(item.get("mpart_name")) + "</td>");
			sb.append("<td>" + ComLib.toNN(item.get("spart_name")) + "</td>");

			sb.append("<td>" + item.get("down_id") + "</td>");
			sb.append("<td>" + item.get("down_name") + "</td>");
			sb.append("<td>" + item.get("down_ip") + "</td>");
			sb.append("<td>" + item.get("rec_datm") + "</td>");
			sb.append("<td>" + item.get("user_id") + "</td>");
			sb.append("<td>" + item.get("user_name") + "</td>");
			sb.append("<td>" + item.get("rec_filename") + "</td>");
			if(Finals.isExistPlayDownReason){
				sb.append("<td>" + item.get("down_src") + "</td>");
				sb.append("<td>" + item.get("reason_code_desc") + "</td>");
				sb.append("<td>" + item.get("reason_text") + "</td>");
			}
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
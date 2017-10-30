<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"excel_hist","")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "Excel저장이력");

	db = new Db(true);

	// get parameter
	String sort_idx = CommonUtil.getParameter("sort_idx", "excel_datm");
	String sort_dir = CommonUtil.getParameter("sort_dir", "down");

	String excel_date1 = CommonUtil.getParameter("excel_date1");
	String excel_date2 = CommonUtil.getParameter("excel_date2");

	String excel_state = CommonUtil.getParameter("excel_state");

	String login_id = CommonUtil.getParameter("login_id");
	String login_name = CommonUtil.getParameter("login_name");

	sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

	StringBuffer sb = new StringBuffer();


	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>저장일시</td>");

	sb.append("<td class=th>다운로드 메뉴</td>");

	sb.append("<td class=th>대분류</td>");
	sb.append("<td class=th>중분류</td>");
	sb.append("<td class=th>소분류</td>");

	sb.append("<td class=th>로그인ID</td>");
	sb.append("<td class=th>로그인명</td>");
	sb.append("<td class=th>로그인IP</td>");
	sb.append("</tr>");

	// search
	Map<String, Object> argMap = new HashMap<String, Object>();

	argMap.put("excel_date1",excel_date1);
	argMap.put("excel_date2",excel_date2);

	argMap.put("excel_id",login_id);
	argMap.put("excel_name",login_name);

	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);

	List<Map<String, Object>> list = db.selectList("hist_excel.selectListAll", argMap);

	// 2016.12.27 현원희 추가 -다운로드 이력
	//=========================================================================
	Map<String, Object> selmap2 = new HashMap();

	selmap2.put("excel_id", _LOGIN_ID);
	selmap2.put("excel_menu", "excel저장이력");
	selmap2.put("excel_name", _LOGIN_NAME);
	selmap2.put("excel_ip",request.getRemoteAddr());

	int ins_cnt = db.insert("hist_excel.insertExcelHist", selmap2);
	//=========================================================================

	if(list.size()>0) {
		for(Map<String, Object> item : list) {
			sb.append("<tr>");
			sb.append("<td>" + item.get("excel_datm") + "</td>");
			sb.append("<td>" + item.get("excel_menu") + "</td>");

			sb.append("<td>" + item.get("bpart_name") + "</td>");
			sb.append("<td>" + item.get("mpart_name") + "</td>");
			sb.append("<td>" + item.get("spart_name") + "</td>");


			sb.append("<td>" + item.get("excel_id") + "</td>");
			sb.append("<td>" + item.get("excel_name") + "</td>");
			sb.append("<td>" + item.get("excel_ip") + "</td>");

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
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"login_hist","")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "로그인이력");

	db = new Db(true);

	// get parameter
	String sort_idx = CommonUtil.getParameter("sort_idx", "login_datm");
	String sort_dir = CommonUtil.getParameter("sort_dir", "down");

	String login_date1 = CommonUtil.getParameter("login_date1");
	String login_date2 = CommonUtil.getParameter("login_date2");
	String login_id = CommonUtil.getParameter("login_id");
	String login_name = CommonUtil.getParameter("login_name");
	String login_type = CommonUtil.getParameter("login_type");
	String login_result = CommonUtil.getParameter("login_result");

	sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

	StringBuffer sb = new StringBuffer();


	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>구분</td>");
	sb.append("<td class=th>로그인일시</td>");
	sb.append("<td class=th>로그인ID</td>");
	sb.append("<td class=th>로그인명</td>");
	sb.append("<td class=th>로그인IP</td>");
	sb.append("<td class=th>결과</td>");
	sb.append("</tr>");

	// search
	Map<String, Object> argMap = new HashMap<String, Object>();

	argMap.put("login_date1",login_date1);
	argMap.put("login_date2",login_date2);
	argMap.put("login_id",login_id);
	argMap.put("login_name",login_name);
	argMap.put("login_type",login_type);
	argMap.put("login_result",login_result);
	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);

	List<Map<String, Object>> list = db.selectList("hist_login.selectListAll", argMap);

	// 2016.12.27 현원희 추가 -다운로드 이력
	//=========================================================================
	Map<String, Object> selmap2 = new HashMap();

	selmap2.put("excel_id", _LOGIN_ID);
	selmap2.put("excel_menu", "로그인이력");
	selmap2.put("excel_name", _LOGIN_NAME);
	selmap2.put("excel_ip",request.getRemoteAddr());

	int ins_cnt = db.insert("hist_excel.insertExcelHist", selmap2);
	//=========================================================================

	if(list.size()>0) {
		for(Map<String, Object> item : list) {
			sb.append("<tr>");
			sb.append("<td>" + item.get("v_login_type") + "</td>");
			sb.append("<td>" + item.get("login_datm") + "</td>");
			sb.append("<td>" + item.get("login_id") + "</td>");
			sb.append("<td>" + item.get("login_name") + "</td>");
			sb.append("<td>" + item.get("login_ip") + "</td>");
			sb.append("<td>" + item.get("v_login_result") + "</td>");
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
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"user_change_hist","")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "계정변경이력");

	db = new Db(true);

	// get parameter
	String sort_idx = CommonUtil.getParameter("sort_idx", "change_datm");
	String sort_dir = CommonUtil.getParameter("sort_dir", "down");

	String change_date1 = CommonUtil.getParameter("change_date1");
	String change_date2 = CommonUtil.getParameter("change_date2");
	String login_id = CommonUtil.getParameter("login_id");
	String login_name = CommonUtil.getParameter("login_name");
	String user_id = CommonUtil.getParameter("user_id");
	String user_name = CommonUtil.getParameter("user_name");

	sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

	StringBuffer sb = new StringBuffer();


	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>변경일시</td>");
	sb.append("<td class=th>구분</td>");
	sb.append("<td class=th>로그인ID</td>");
	sb.append("<td class=th>로그인명</td>");
	sb.append("<td class=th>로그인IP</td>");
	sb.append("<td class=th>상담원ID</td>");
	sb.append("<td class=th>상담사명</td>");
	sb.append("<td class=th>기존등급</td>");
	sb.append("<td class=th>변경등급</td>");
	sb.append("</tr>");

	// search
	Map<String, Object> argMap = new HashMap<String, Object>();

	argMap.put("change_date1",change_date1);
	argMap.put("change_date2",change_date2);
	argMap.put("change_id",login_id);
	argMap.put("change_name",login_name);
	argMap.put("user_id",user_id);
	argMap.put("user_name",user_name);
	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);

	List<Map<String, Object>> list = db.selectList("hist_user_change.selectListAll", argMap);

	// 2016.12.27 현원희 추가 -다운로드 이력
	//=========================================================================
	Map<String, Object> selmap2 = new HashMap();

	selmap2.put("excel_id", _LOGIN_ID);
	selmap2.put("excel_menu", "계정변경이력");
	selmap2.put("excel_name", _LOGIN_NAME);
	selmap2.put("excel_ip",request.getRemoteAddr());

	int ins_cnt = db.insert("hist_excel.insertExcelHist", selmap2);
	//=========================================================================

	if(list.size()>0) {
		for(Map<String, Object> item : list) {
			sb.append("<tr>");
			sb.append("<td>" + item.get("change_datm") + "</td>");
			sb.append("<td>" + item.get("v_change_type") + "</td>");
			sb.append("<td>" + item.get("change_id") + "</td>");
			sb.append("<td>" + item.get("change_name") + "</td>");
			sb.append("<td>" + item.get("change_ip") + "</td>");
			sb.append("<td>" + item.get("user_id") + "</td>");
			sb.append("<td>" + item.get("user_name") + "</td>");
			sb.append("<td>" + item.get("origin_level_desc") + "</td>");
			sb.append("<td>" + item.get("change_level_desc") + "</td>");
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
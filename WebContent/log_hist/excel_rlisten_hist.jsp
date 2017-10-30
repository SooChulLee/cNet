<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"rlisten_hist","")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "감청이력");

	db = new Db(true);

	// get parameter
	String sort_idx = CommonUtil.getParameter("sort_idx", "rlisten_datm");
	String sort_dir = CommonUtil.getParameter("sort_dir", "down");

	String rlisten_date1 = CommonUtil.getParameter("rlisten_date1");
	String rlisten_date2 = CommonUtil.getParameter("rlisten_date2");
	String login_id = CommonUtil.getParameter("login_id");
	String login_name = CommonUtil.getParameter("login_name");
	String local_no = CommonUtil.getParameter("local_no","");
	String user_id = CommonUtil.getParameter("user_id");
	String user_name = CommonUtil.getParameter("user_name");

	sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

	StringBuffer sb = new StringBuffer();


	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>감청일시</td>");
	sb.append("<td class=th>로그인ID</td>");
	sb.append("<td class=th>로그인명</td>");
	sb.append("<td class=th>로그인IP</td>");
	sb.append("<td class=th>시스템명</td>");
	sb.append("<td class=th>채널번호</td>");
	sb.append("<td class=th>내선번호</td>");
	sb.append("<td class=th>상담원ID</td>");
	sb.append("<td class=th>상담사명</td>");
	sb.append("</tr>");

	// search
	Map<String, Object> argMap = new HashMap<String, Object>();

	argMap.put("rlisten_date1",rlisten_date1);
	argMap.put("rlisten_date2",rlisten_date2);
	argMap.put("rlisten_id",login_id);
	argMap.put("rlisten_name",login_name);
	argMap.put("local_no",local_no);
	argMap.put("user_id",user_id);
	argMap.put("user_name",user_name);
	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);

	List<Map<String, Object>> list = db.selectList("hist_rlisten.selectListAll", argMap);

	// 2016.12.27 현원희 추가 -다운로드 이력
	//=========================================================================
	Map<String, Object> selmap2 = new HashMap();

	selmap2.put("excel_id", _LOGIN_ID);
	selmap2.put("excel_menu", "감청이력");
	selmap2.put("excel_name", _LOGIN_NAME);
	selmap2.put("excel_ip",request.getRemoteAddr());

	int ins_cnt = db.insert("hist_excel.insertExcelHist", selmap2);
	//=========================================================================

	if(list.size()>0) {
		for(Map<String, Object> item : list) {
			sb.append("<tr>");
			sb.append("<td>" + item.get("rlisten_datm") + "</td>");
			sb.append("<td>" + item.get("rlisten_id") + "</td>");
			sb.append("<td>" + item.get("rlisten_name") + "</td>");
			sb.append("<td>" + item.get("rlisten_ip") + "</td>");
			sb.append("<td>" + item.get("system_name") + "</td>");
			sb.append("<td>" + item.get("channel_no") + "</td>");
			sb.append("<td>" + item.get("local_no") + "</td>");
			sb.append("<td>" + item.get("user_id") + "</td>");
			sb.append("<td>" + item.get("user_name") + "</td>");
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
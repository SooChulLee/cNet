<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
// DB Connection Object
Db db = null;

try {
	Site.setExcelHeader(response, out, "관제히스토리");

	// DB Connection
	db = new Db(true);

	// get parameter
	String log_date1 = CommonUtil.getParameter("log_date1", DateUtil.getToday("yyyy-MM-dd"));
	String log_date2 = CommonUtil.getParameter("log_date2", DateUtil.getToday("yyyy-MM-dd"));
	String mon_system = CommonUtil.getParameter("mon_system");
	String mon_flag = CommonUtil.getParameter("mon_flag");

	//
	StringBuffer sb = new StringBuffer();

	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>날짜</td>");
	sb.append("<td class=th>시간</td>");
	sb.append("<td class=th>대상</td>");
	sb.append("<td class=th>내용</td>");
	sb.append("<td class=th>장애등급</td>");
	sb.append("</tr>");

	//
	Map<String, Object> argMap = new HashMap<String, Object>();

	argMap.put("log_date1",log_date1.replace("-", ""));
	argMap.put("log_date2",log_date2.replace("-", ""));
	argMap.put("mon_system",mon_system);
	argMap.put("mon_alram",mon_flag);

	// hist list
	List<Map<String, Object>> list = db.selectList("dashboard.selectLogListAll", argMap);

	if(list.size()>0) {
		for(Map<String, Object> item : list) {
			String mon_date = item.get("mon_date").toString();
			String mon_time = item.get("mon_time").toString();

			mon_date = mon_date.substring(0, 4) + "-" + mon_date.substring(4, 6) + "-" + mon_date.substring(6, 8);
			mon_time = mon_time.substring(0, 2) + ":" + mon_time.substring(2, 4) + ":" + mon_time.substring(4, 6);

			sb.append("<tr>");
			sb.append("<td>" + mon_date + "</td>");
			sb.append("<td>" + mon_time + "</td>");
			sb.append("<td>" + item.get("mon_name") + "</td>");
			sb.append("<td>" + item.get("mon_alram") + "</td>");
			sb.append("<td>" + item.get("flag_desc") + "</td>");
			sb.append("</tr>");
		}
	}

	//
	sb.append("</table>");
	out.print(sb.toString());
} catch(Exception e) {
	logger.error(e.getMessage());
} finally {
	if(db!=null) db.close();
}
%>
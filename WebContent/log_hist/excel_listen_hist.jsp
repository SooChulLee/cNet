<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"listen_hist","")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "청취이력");

	db = new Db(true);

	// get parameter
	String sort_idx = CommonUtil.getParameter("sort_idx", "listen_datm");
	String sort_dir = CommonUtil.getParameter("sort_dir", "down");

	String listen_date1 = CommonUtil.getParameter("listen_date1");
	String listen_date2 = CommonUtil.getParameter("listen_date2");
	String login_id = CommonUtil.getParameter("login_id");
	String login_name = CommonUtil.getParameter("login_name");
	String rec_date1 = CommonUtil.getParameter("rec_date1","");
	String rec_date2 = CommonUtil.getParameter("rec_date2","");
	String user_id = CommonUtil.getParameter("user_id");
	String user_name = CommonUtil.getParameter("user_name");
	String reason_code = CommonUtil.getParameter("reason_code");

	sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

	StringBuffer sb = new StringBuffer();


	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>청취일시</td>");

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
	if(Finals.isExistPlayDownReason){
		sb.append("<td class=th>청취사유</td>");
		sb.append("<td class=th>기타사유</td>");
	}
	sb.append("</tr>");

	// search
	Map<String, Object> argMap = new HashMap<String, Object>();

	argMap.put("listen_date1",listen_date1);
	argMap.put("listen_date2",listen_date2);
	argMap.put("listen_id",login_id);
	argMap.put("listen_name",login_name);
	argMap.put("rec_date1",rec_date1);
	argMap.put("rec_date2",rec_date2);
	argMap.put("user_id",user_id);
	argMap.put("user_name",user_name);
	argMap.put("reason_code",reason_code);
	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);


	List<Map<String, Object>> list = db.selectList("hist_listen.selectListAll", argMap);

	// 2016.12.27 현원희 추가 -다운로드 이력
	//=========================================================================
	Map<String, Object> selmap2 = new HashMap();

	selmap2.put("excel_id", _LOGIN_ID);
	selmap2.put("excel_menu", "청취이력");
	selmap2.put("excel_name", _LOGIN_NAME);
	selmap2.put("excel_ip",request.getRemoteAddr());

	int ins_cnt = db.insert("hist_excel.insertExcelHist", selmap2);
	//=========================================================================

	if(list.size()>0) {
		for(Map<String, Object> item : list) {
			sb.append("<tr>");
			sb.append("<td>" + item.get("listen_datm") + "</td>");

			sb.append("<td>" + ComLib.toNN(item.get("bpart_name")) + "</td>");
			sb.append("<td>" + ComLib.toNN(item.get("mpart_name")) + "</td>");
			sb.append("<td>" + ComLib.toNN(item.get("spart_name")) + "</td>");

			sb.append("<td>" + item.get("listen_id") + "</td>");
			sb.append("<td>" + item.get("listen_name") + "</td>");
			sb.append("<td>" + item.get("listen_ip") + "</td>");
			sb.append("<td>" + item.get("rec_datm") + "</td>");
			sb.append("<td>" + item.get("user_id") + "</td>");
			sb.append("<td>" + item.get("user_name") + "</td>");
			sb.append("<td>" + item.get("rec_filename") + "</td>");
			if(Finals.isExistPlayDownReason){
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
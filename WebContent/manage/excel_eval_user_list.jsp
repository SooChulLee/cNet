<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"eval_user_list","")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "평가자");

	db = new Db(true);

	// get parameter
	String regi_date1 = CommonUtil.getParameter("regi_date1", "");
	String regi_date2 = CommonUtil.getParameter("regi_date2", "");
	String user_id = CommonUtil.getParameter("user_id", "");
	String user_name = CommonUtil.getParameter("user_name", "");
	String sort_idx = CommonUtil.getParameter("sort_idx", "regi_datm");
	String sort_dir = CommonUtil.getParameter("sort_dir", "down");

	sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

	StringBuffer sb = new StringBuffer();


	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>업무 명</td>");
	sb.append("<td class=th>상담원 ID</td>");
	sb.append("<td class=th>상담원 명</td>");
	sb.append("<td class=th>등급</td>");
	sb.append("<td class=th>비밀번호 사용기간</td>");
	sb.append("<td class=th>비밀번호 만료일자</td>");
	sb.append("<td class=th>비밀번호 변경일자</td>");
	sb.append("<td class=th>퇴사 여부</td>");
	sb.append("<td class=th>사용 여부</td>");
	sb.append("<td class=th>등록일자</td>");
	sb.append("</tr>");

	Map<String, Object> argMap = new HashMap<String, Object>();

	argMap.put("regi_date1", regi_date1);
	argMap.put("regi_date2", regi_date2);
	argMap.put("user_id", user_id);
	argMap.put("user_name", user_name);
	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);

	List<Map<String, Object>> list = db.selectList("user.selectEvalListAll", argMap);

	if(list.size()>0) {
		for(Map<String, Object> item : list) {
			sb.append("<tr>");
			sb.append("<td>" + item.get("business_name") + "</td>");
			sb.append("<td>" + item.get("user_id") + "</td>");
			sb.append("<td>" + item.get("user_name") + "</td>");
			sb.append("<td>" + item.get("user_level_desc") + "</td>");
			sb.append("<td>" + item.get("pass_chg_term_desc") + "</td>");
			sb.append("<td>" + item.get("pass_expire_date") + "</td>");
			sb.append("<td>" + item.get("pass_upd_date") + "</td>");
			sb.append("<td>" + item.get("resign_yn_desc") + "</td>");
			sb.append("<td>" + Finals.getValue(Finals.hUsedCode,item.get("use_yn")) + "</td>");
			sb.append("<td>" + item.get("regi_datm") + "</td>");
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
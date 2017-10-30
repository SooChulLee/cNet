<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"channel_mgmt","")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "채널");

	db = new Db(true);

	// get parameter
	String search = CommonUtil.getParameter("search", "");
	String sort_idx = CommonUtil.getParameter("sort_idx", ("1".equals(search)) ? "phone_num" : "channel");
	String sort_dir = CommonUtil.getParameter("sort_dir", "up");
	String system_code = CommonUtil.getParameter("system_code", "");
	String phone_num = CommonUtil.getParameter("phone_num", "");
	String phone_ip = CommonUtil.getParameter("phone_ip", "");

	sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

	// system_code
	if(CommonUtil.hasText(system_code)) {
		system_code = CommonUtil.rightString(system_code, 2);
	}

	StringBuffer sb = new StringBuffer();


	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>시스템 명</td>");
	sb.append("<td class=th>채널 번호</td>");
	sb.append("<td class=th>내선 번호</td>");
	sb.append("<td class=th>아이피</td>");
	sb.append("<td class=th>교환기 번호</td>");
	sb.append("</tr>");

	Map<String, Object> argMap = new HashMap<String, Object>();
	List<Map<String, Object>> list = null;

	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);

	if("1".equals(search)) {
		argMap.put("phone_num", phone_num);
		argMap.put("phone_ip", phone_ip);

			list = db.selectList("channel.selectSearchList", argMap);
	} else {
		argMap.put("system_code", system_code);

			list = db.selectList("channel.selectList", argMap);
	}

	// 2016.12.27 현원희 추가 -다운로드 이력
	//=========================================================================
	Map<String, Object> selmap2 = new HashMap();

	selmap2.put("excel_id", _LOGIN_ID);
	selmap2.put("excel_menu", "채널");
	selmap2.put("excel_name", _LOGIN_NAME);
	selmap2.put("excel_ip",request.getRemoteAddr());

	int ins_cnt = db.insert("hist_excel.insertExcelHist", selmap2);
	//=========================================================================

	if(list.size()>0) {
		for(Map<String, Object> item : list) {
			sb.append("<tr>");
			sb.append("<td>" + item.get("system_name") + "</td>");
			sb.append("<td>" + item.get("channel") + "</td>");
			sb.append("<td>" + item.get("phone_num") + "</td>");
			sb.append("<td>" + item.get("phone_ip") + "</td>");
			sb.append("<td>" + item.get("tn_num") + "</td>");
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
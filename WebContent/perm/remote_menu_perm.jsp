<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"menu_perm","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		JSONObject json = new JSONObject();

		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("business_code", _BUSINESS_CODE);
		argMap.put("user_level", _LOGIN_LEVEL);
		argMap.put("menu_depth", "2");

		List<Map<String, Object>> list = db.selectList("menu.selectList", argMap);

		json.put("totalRecords", list.size());

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
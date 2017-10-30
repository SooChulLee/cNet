<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"system_mgmt","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		JSONObject json = new JSONObject();

		Map<String, Object> argMap = new HashMap<String, Object>();

		List<Map<String, Object>> list = db.selectList("system.selectList", argMap);

		json.put("totalRecords", list.size());

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
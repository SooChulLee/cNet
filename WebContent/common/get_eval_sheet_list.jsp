<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String use_yn = CommonUtil.getParameter("use_yn", "1");

		JSONObject json = new JSONObject();

		Map<String,Object> argMap = new HashMap();
		argMap.put("use_yn",use_yn);

		List<Map<String,Object>> list = db.selectList("sheet.selectCodeList", argMap);

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
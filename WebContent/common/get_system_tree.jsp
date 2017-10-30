<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String business_code = CommonUtil.getParameter("business_code");
		String system_rec = CommonUtil.getParameter("system_rec", "1");

		JSONArray jsonarr = new JSONArray();

		Map<String,Object> argMap = new HashMap();
		argMap.put("business_code",business_code);
		argMap.put("system_rec",system_rec);

		// tree select
		List<Map<String, Object>> list = db.selectList("layout.selectSystemTree", argMap);

		out.print(jsonarr.toJSONString(list));
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
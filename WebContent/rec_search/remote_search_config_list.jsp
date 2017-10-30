<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"rec_search","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String conf_type = CommonUtil.getParameter("conf_type", "S");

		JSONObject json = new JSONObject();

		Map<String, Object> confmap = new HashMap();

		// config (session value mapping)
		confmap.put("business_code", _BUSINESS_CODE);
		confmap.put("user_id", _LOGIN_ID);
		confmap.put("user_level", _LOGIN_LEVEL);

		// config select
		String query = "S".equals(conf_type) ? "rec_search.selectSearchConfig" : "rec_search.selectResultConfig";
		List<Map<String, Object>> conf_list = db.selectList(query, confmap);
		/*
		// 리스트 설정에서 hidden 개념 삭제
		Iterator<Map<String, Object>> iter = conf_list.iterator();

		while(iter.hasNext()) {
			Map<String, Object> tmpmap = iter.next();

			// 리스트 설정에서 hidden value 삭제
			if("R".equals(conf_type) && tmpmap.get("result_value").equals("hidden")) {
				iter.remove();
			}
		}
		*/

		json.put("data", conf_list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
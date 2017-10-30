<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"item","json")) return;

	Db db = null;

	try {
		// get parameter
		String cate_code = CommonUtil.getParameter("cate_code");
		String parent_code = CommonUtil.getParameter("parent_code");
		String item_depth = CommonUtil.getParameter("item_depth");

		// 파라미터 체크
		if(!CommonUtil.hasText(cate_code) || !CommonUtil.hasText(parent_code) || !CommonUtil.hasText(item_depth)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		db = new Db(true);

		JSONObject json = new JSONObject();

		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("cate_code", cate_code);
		argMap.put("parent_code", parent_code);
		argMap.put("item_depth", item_depth);

		List<Map<String, Object>> list = db.selectList("item.selectList", argMap);

		json.put("totalRecords", list.size());

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
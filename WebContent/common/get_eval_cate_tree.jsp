<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String cate_codes = CommonUtil.getParameter("cate_codes");
		String use_yn = CommonUtil.getParameter("use_yn");

		JSONArray jsonarr = new JSONArray();

		if(CommonUtil.hasText(cate_codes)) {
			cate_codes = "'" + cate_codes.replace(",", "','") + "'";
		}

		Map<String,Object> argMap = new HashMap();
		argMap.put("cate_codes",cate_codes);
		argMap.put("use_yn",use_yn);

		// tree select
		List<Map<String, Object>> list = db.selectList("cate.selectCateTree", argMap);

		out.print(jsonarr.toJSONString(list));
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
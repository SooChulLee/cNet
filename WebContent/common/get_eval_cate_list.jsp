<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String parent_code = CommonUtil.getParameter("parent_code");
		String cate_depth = CommonUtil.getParameter("cate_depth");

		// 파라미터 체크
		if(!CommonUtil.hasText(cate_depth)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		JSONObject json = new JSONObject();

		Map<String,Object> argMap = new HashMap();
		argMap.put("parent_code",parent_code);
		argMap.put("cate_depth",cate_depth);
		argMap.put("use_yn","1");

		List<Map<String,Object>> list = db.selectList("cate.selectCateList", argMap);

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
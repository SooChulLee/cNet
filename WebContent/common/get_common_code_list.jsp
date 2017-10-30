<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	// if(!Site.isPmss(out,"","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String parent_code = CommonUtil.getParameter("parent_code");
		String code_depth = CommonUtil.getParameter("code_depth");

		// 파라미터 체크
		if(!CommonUtil.hasText(code_depth)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		JSONObject json = new JSONObject();

		Map<String,Object> argMap = new HashMap();
		argMap.put("parent_code",parent_code);
		argMap.put("code_depth",code_depth);
		argMap.put("use_yn","1");

		List<Map<String,Object>> list = db.selectList("code.selectList", argMap);

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
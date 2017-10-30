<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String select_user = CommonUtil.getParameter("select_user", "0");
		String business_code = CommonUtil.getParameter("business_code");

		JSONArray jsonarr = new JSONArray();

		Map<String,Object> argMap = new HashMap();
		argMap.put("business_code",business_code);

		// 사용자 권한에 따른 조직도 조회
		argMap.put("_user_id",_LOGIN_ID);
		argMap.put("_user_level",_LOGIN_LEVEL);
		argMap.put("_bpart_code",_BPART_CODE);
		argMap.put("_mpart_code",_MPART_CODE);
		argMap.put("_spart_code",_SPART_CODE);
		argMap.put("_default_code",_PART_DEFAULT_CODE);

		String tree_query = "1".equals(select_user) ? "layout.selectUserGroupTree" : "layout.selectExceptUserGroupTree";

		// tree select
		List<Map<String, Object>> list = db.selectList(tree_query, argMap);

		out.print(jsonarr.toJSONString(list));
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	// cross domain 설정
	//response.addHeader("Access-Control-Allow-Origin", "*");
	//response.setHeader("Access-Control-Allow-Headers", "origin, x-requested-with, content-type, accept");

	if(!Site.isPmss(out,"","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String business_code = CommonUtil.getParameter("business_code", _BUSINESS_CODE);
		String bpart_code = CommonUtil.getParameter("bpart_code");
		String mpart_code = CommonUtil.getParameter("mpart_code");
		String spart_code = CommonUtil.getParameter("spart_code");
		String part_depth = CommonUtil.getParameter("part_depth");
		String perm_check = CommonUtil.getParameter("perm_check");

		// 파라미터 체크
		if(!CommonUtil.hasText(business_code) || !CommonUtil.hasText(part_depth)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		JSONObject json = new JSONObject();

		Map<String,Object> argMap = new HashMap();
		argMap.put("business_code",business_code);
		argMap.put("bpart_code",bpart_code);
		argMap.put("mpart_code",mpart_code);
		argMap.put("part_depth",part_depth);

		// 사용자 권한에 따른 조직도 조회
		if("1".equals(perm_check)) {
			argMap.put("_user_level", _LOGIN_LEVEL);
			argMap.put("_bpart_code",_BPART_CODE);
			argMap.put("_mpart_code",_MPART_CODE);
			argMap.put("_spart_code",_SPART_CODE);
			argMap.put("_default_code",_PART_DEFAULT_CODE);
		}
		List<Map<String,Object>> list = db.selectList("user_group.selectList", argMap);

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
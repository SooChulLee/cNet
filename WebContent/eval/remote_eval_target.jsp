<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"eval_target","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String eval_user_id = CommonUtil.getParameter("eval_user_id", "");
		String bpart_code = CommonUtil.getParameter("bpart_code", "");
		String mpart_code = CommonUtil.getParameter("mpart_code", "");
		String spart_code = CommonUtil.getParameter("spart_code", "");

		// 파라미터 체크
		if(!CommonUtil.hasText(eval_user_id)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		JSONObject json = new JSONObject();

		Map<String, Object> argMap = new HashMap<String, Object>();

		// 가용 상담원
		argMap.put("eval_user_id", eval_user_id);
		argMap.put("bpart_code", bpart_code);
		argMap.put("mpart_code", mpart_code);
		argMap.put("spart_code", spart_code);


		List<Map<String, Object>> target_list = db.selectList("eval_target.selectAvailList", argMap);
		json.put("target", target_list);

		// 배정 상담원
		argMap = new HashMap();
		argMap.put("eval_user_id", eval_user_id);

		List<Map<String, Object>> assign_list = db.selectList("eval_target.selectAssignList", argMap);

		json.put("assign", assign_list);

		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
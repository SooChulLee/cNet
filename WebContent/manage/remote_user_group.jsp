<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_mgmt","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String type = CommonUtil.getParameter("type");
		String parent_code = CommonUtil.getParameter("parent_code");

		logger.debug("parent_code : " + parent_code);

		// 파라미터 체크
		if(!CommonUtil.hasText(type) || !CommonUtil.hasText(parent_code)) {
			//Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// part_code
		String business_code = CommonUtil.leftString(parent_code, 2);
		int part_depth = Integer.parseInt(CommonUtil.rightString(type, 1)) + 1;

		//String bpart_code = (part_depth>1) ? parent_code.substring(2, 7) : "";
		//String mpart_code = (part_depth>2) ? parent_code.substring(7, 12) : "";
		String bpart_code = (part_depth>1) ? parent_code.substring(2, 2+(_PART_CODE_SIZE*1)) : "";
		String mpart_code = (part_depth>2) ? parent_code.substring(2+(_PART_CODE_SIZE*1), 2+(_PART_CODE_SIZE*2)) : "";

		JSONObject json = new JSONObject();

		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("business_code", business_code);
		argMap.put("bpart_code", bpart_code);
		argMap.put("mpart_code", mpart_code);
		argMap.put("part_depth", Integer.toString(part_depth));
		argMap.put("_default_code",_PART_DEFAULT_CODE);

		List<Map<String, Object>> list = db.selectList("user_group.selectList", argMap);

		json.put("totalRecords", list.size());
		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
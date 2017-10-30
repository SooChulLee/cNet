<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String system_code = CommonUtil.getParameter("system_code");

		// 파라미터 체크
		if(!CommonUtil.hasText(system_code)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		JSONObject json = new JSONObject();

		List<Map<String,Object>> list = db.selectList("channel.selectUsableChannelList", system_code);

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
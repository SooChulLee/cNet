<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"channel_mgmt","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String search = CommonUtil.getParameter("search", "");
		String sort_idx = CommonUtil.getParameter("sort_idx", ("1".equals(search)) ? "phone_num" : "channel");
		String sort_dir = CommonUtil.getParameter("sort_dir", "up");
		String system_code = CommonUtil.getParameter("system_code", "");
		String phone_num = CommonUtil.getParameter("phone_num", "");
		String phone_ip = CommonUtil.getParameter("phone_ip", "");

		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		// system_code
		if(CommonUtil.hasText(system_code)) {
			system_code = CommonUtil.rightString(system_code, 2);
		}

		JSONObject json = new JSONObject();

		Map<String, Object> argMap = new HashMap<String, Object>();
		List<Map<String, Object>> list = null;

		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);

		if("1".equals(search)) {
			argMap.put("phone_num", phone_num);
			argMap.put("phone_ip", phone_ip);

				list = db.selectList("channel.selectSearchList", argMap);
		} else {
			argMap.put("system_code", system_code);

				list = db.selectList("channel.selectList", argMap);
		}

		json.put("totalRecords", list.size());

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
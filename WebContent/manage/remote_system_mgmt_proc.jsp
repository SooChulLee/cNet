<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"system_mgmt","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("insert".equals(step)) {
			// get parameter
			String business_code = CommonUtil.getParameter("business_code");
			String system_code = CommonUtil.getParameter("system_code");
			String system_name = CommonUtil.getParameter("system_name");
			String system_ip = CommonUtil.getParameter("system_ip");
			String backup_ip = CommonUtil.getParameter("backup_ip");
			String license_cnt = CommonUtil.getParameter("license_cnt");
			String system_rec = CommonUtil.getParameter("system_rec");

				argMap.put("business_code",business_code);
			argMap.put("system_code",system_code);
			argMap.put("system_name",system_name);
			argMap.put("system_ip",system_ip);
			argMap.put("backup_ip",backup_ip);
			argMap.put("license_cnt",license_cnt);
			argMap.put("system_rec",system_rec);

				int ins_cnt = db.insert("system.insertSystem", argMap);
			if(ins_cnt<1) {
				Site.writeJsonResult(out, false, "등록에 실패했습니다.");
				return;
			}
		} else if("update".equals(step)) {
			// get parameter
			String data_list = CommonUtil.getParameter("data_list");

			// 파라미터 체크
			if(!CommonUtil.hasText(data_list)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// &quot; -> " 로 replace
			data_list = "{\"data_list\":" + CommonUtil.toTextJSON(data_list) + "}";

				JSONParser jsonParser = new JSONParser();

				JSONObject jsonObj = (JSONObject) jsonParser.parse(data_list);

			JSONArray jsonArr = (JSONArray) jsonObj.get("data_list");
			Iterator<Object> iterator = jsonArr.iterator();

			int upd_cnt = 0;
			while (iterator.hasNext()) {
				JSONObject jsonItem = (JSONObject) iterator.next();

						argMap.clear();
				argMap.put("system_code",jsonItem.get("system_code"));
				argMap.put("system_name",jsonItem.get("system_name"));
				argMap.put("system_ip",jsonItem.get("system_ip"));
				argMap.put("backup_ip",jsonItem.get("backup_ip"));
				argMap.put("license_cnt",jsonItem.get("license_cnt"));
				argMap.put("system_rec",jsonItem.get("system_rec"));

						upd_cnt += db.update("system.updateSystem", argMap);
			}

			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
				return;
			}
		} else if("delete".equals(step)) {
			// get parameter
			String system_code = CommonUtil.getParameter("row_id");

			// 파라미터 체크
			if(!CommonUtil.hasText(system_code)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				int del_cnt = db.delete("system.deleteSystem", system_code);
			if(del_cnt<1) {
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}
		} else {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		Site.writeJsonResult(out,true);
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
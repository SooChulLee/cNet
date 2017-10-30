<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"business_code","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("insert".equals(step)) {
			// get parameter
			String business_code = CommonUtil.getParameter("business_code");
			String conf_name = CommonUtil.getParameter("conf_name");
			String conf_field = CommonUtil.getParameter("conf_field");
			String conf_value = CommonUtil.getParameter("conf_value");
			String user_level = CommonUtil.getParameter("user_level");
			String default_used = CommonUtil.getParameter("default_used");
			String order_used = CommonUtil.getParameter("order_used");
			String conf_etc = CommonUtil.getParameter("conf_etc");
			String use_yn = CommonUtil.getParameter("use_yn");

				argMap.put("conf_type","S");
			argMap.put("business_code",business_code);
			argMap.put("conf_name",conf_name);
			argMap.put("conf_field",conf_field);
			argMap.put("conf_value",conf_value);
			argMap.put("user_level",user_level);
			argMap.put("default_used",default_used);
			argMap.put("order_used",order_used);
			argMap.put("conf_etc",conf_etc);
			argMap.put("use_yn",use_yn);

				int ins_cnt = db.insert("search_config.insertSearchConfig", argMap);
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
				argMap.put("conf_type","S");
				argMap.put("business_code",jsonItem.get("business_code"));
				argMap.put("conf_code",jsonItem.get("conf_code"));
				argMap.put("conf_name",jsonItem.get("conf_name"));
				argMap.put("conf_field",jsonItem.get("conf_field"));
				argMap.put("conf_value",jsonItem.get("conf_value"));
				argMap.put("user_level",jsonItem.get("user_level"));
				argMap.put("default_used",jsonItem.get("default_used"));
				argMap.put("order_used",jsonItem.get("order_used"));
				argMap.put("order_no",jsonItem.get("order_no"));
				argMap.put("conf_etc",jsonItem.get("conf_etc"));
				argMap.put("use_yn",jsonItem.get("use_yn"));

						upd_cnt += db.update("search_config.updateSearchConfig", argMap);
			}

			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
				return;
			}
		} else if("delete".equals(step)) {
			// get parameter
			String row_id = CommonUtil.getParameter("row_id");

			// 파라미터 체크
			if(!CommonUtil.hasText(row_id)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				argMap.put("business_code", CommonUtil.leftString(row_id, 2));
			argMap.put("conf_code", CommonUtil.rightString(row_id, 4));
			argMap.put("conf_type", "S");

				int del_cnt = db.delete("search_config.deleteSearchConfig", argMap);
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
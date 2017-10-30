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
			String menu_name = CommonUtil.getParameter("menu_name");
			String parent_code = CommonUtil.getParameter("parent_code");
			String menu_url = CommonUtil.toTextHTML(CommonUtil.getParameter("menu_url"));
			String menu_icon = CommonUtil.getParameter("menu_icon");
			String menu_etc = CommonUtil.getParameter("menu_etc");
			String user_level = CommonUtil.getParameter("user_level");
			String use_yn = CommonUtil.getParameter("use_yn");

				argMap.put("business_code",business_code);
			argMap.put("menu_name",menu_name);
			argMap.put("parent_code",parent_code);
			argMap.put("menu_url",menu_url);
			argMap.put("menu_icon",menu_icon);
			argMap.put("menu_etc",menu_etc);
			argMap.put("user_level",user_level);
			argMap.put("use_yn",use_yn);

				int ins_cnt = db.insert("menu.insertMenu", argMap);
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
				argMap.put("business_code",jsonItem.get("business_code"));
				argMap.put("menu_code",jsonItem.get("menu_code"));
				argMap.put("menu_name",jsonItem.get("menu_name"));
				argMap.put("menu_url",CommonUtil.toTextHTML(jsonItem.get("menu_url").toString()));
				argMap.put("menu_icon",jsonItem.get("menu_icon"));
				argMap.put("menu_etc",jsonItem.get("menu_etc"));
				argMap.put("user_level",jsonItem.get("user_level"));
				argMap.put("order_no",jsonItem.get("order_no"));
				argMap.put("use_yn",jsonItem.get("use_yn"));

						upd_cnt += db.update("menu.updateMenu", argMap);
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
			argMap.put("menu_code", CommonUtil.rightString(row_id, 4));

				int del_cnt = db.delete("menu.deleteMenu", argMap);
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
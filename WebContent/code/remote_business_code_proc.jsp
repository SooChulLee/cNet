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
			String business_name = CommonUtil.getParameter("business_name");

				argMap.put("business_name",business_name);
			argMap.put("use_yn","1");

				int ins_cnt = db.insert("business.insertCode", argMap);
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
				argMap.put("business_name",jsonItem.get("business_name"));

						upd_cnt += db.update("business.updateCode", argMap);
			}

			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
				return;
			}
		} else if("delete".equals(step)) {
			// get parameter
			String business_code = CommonUtil.getParameter("row_id");

			// 파라미터 체크
			if(!CommonUtil.hasText(business_code)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				int del_cnt = db.delete("business.deleteCode", business_code);
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
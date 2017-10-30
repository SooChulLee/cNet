<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"sheet","json")) return;

	Db db = null;

	try {
		db = new Db();

		// get parameter
		String step = CommonUtil.getParameter("step");

		String client_ip = request.getRemoteAddr();

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("update".equals(step)) {
			// get parameter
			String data_list = CommonUtil.getParameter("data_list");

			// 파라미터 체크
			if(!CommonUtil.hasText(data_list)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// &quot; -> " 로 replace
			data_list = "{\"data_list\":" + CommonUtil.toTextHTML(data_list) + "}";

			JSONParser jsonParser = new JSONParser();
			JSONObject jsonObj = (JSONObject) jsonParser.parse(data_list);

			JSONArray jsonArr = (JSONArray) jsonObj.get("data_list");
			Iterator<JSONObject> iterator = jsonArr.iterator();
			int upd_cnt = 0;
			while (iterator.hasNext()) {
				JSONObject jsonItem = iterator.next();
				argMap.clear();
				argMap.put("sheet_name",jsonItem.get("sheet_name"));
				argMap.put("use_yn",jsonItem.get("use_yn"));
				argMap.put("upd_ip",client_ip);
				argMap.put("upd_id",_LOGIN_ID);
				argMap.put("sheet_code",jsonItem.get("sheet_code"));

				upd_cnt += db.update("sheet.updateSheet", argMap);
			}

			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
				return;
			}
		} else if("delete".equals(step)) {
			// get parameter
			String sheet_code = CommonUtil.getParameter("row_id");

			// 파라미터 체크
			if(!CommonUtil.hasText(sheet_code)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// 시트 삭제
			int del_cnt = db.delete("sheet.deleteSheet", sheet_code);
			if(del_cnt<1) {
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.\\n\\n이벤트에 등록된 시트가 아닌지 확인 하세요.\\n\\n이벤트에 등록된 시트는 삭제 하실 수 없습니다.");
				return;
			}

			// 시트 평가항목 삭제
			int del_item_cnt = db.delete("sheet.deleteSheetItem", sheet_code);
			if(del_item_cnt<1) {
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}
		} else if("copy".equals(step)) {
			//시트복사
			String sheet_code = CommonUtil.getParameter("sheet_code");
			argMap.put("sheet_code", sheet_code);
			int cnt  = db.insert("sheet.copySheet_sheet", argMap);
			cnt = db.insert("sheet.copySheet_item", argMap);
		} else {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}
		db.commit();
		Site.writeJsonResult(out,true);

	} catch(Exception e) {
		// rollback
		if(db!=null) db.rollback();
		logger.error(e.getMessage());
		Site.writeJsonResult(out,e);
	} finally {
		if(db!=null) db.close();
	}
%>
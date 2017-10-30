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
			String comm_code = CommonUtil.getParameter("comm_code");
			String code_name = CommonUtil.getParameter("code_name");
			String parent_code = CommonUtil.getParameter("parent_code");
			String code_etc = CommonUtil.getParameter("code_etc");
			String use_yn = CommonUtil.getParameter("use_yn");

				argMap.put("comm_code",comm_code);
			argMap.put("code_name",code_name);
			argMap.put("parent_code",parent_code);
			argMap.put("code_etc",code_etc);
			argMap.put("use_yn",use_yn);

				int ins_cnt = db.insert("code.insertCode", argMap);
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
				argMap.put("comm_code",jsonItem.get("comm_code"));
				argMap.put("parent_code",jsonItem.get("parent_code"));
				argMap.put("code_name",jsonItem.get("code_name"));
				argMap.put("code_etc",jsonItem.get("code_etc"));
				argMap.put("order_no",jsonItem.get("order_no"));
				argMap.put("use_yn",jsonItem.get("use_yn"));

						upd_cnt += db.update("code.updateCode", argMap);
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

				String[] rows = row_id.split("\\^");

			argMap.put("comm_code", rows[0]);
			argMap.put("parent_code", rows[1]);

				int del_cnt = db.delete("code.deleteCode", argMap);
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
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_mgmt","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("insert".equals(step)) {
			// get parameter
			String type = CommonUtil.getParameter("type");
			String parent_code = CommonUtil.getParameter("parent_code");
			String part_code = CommonUtil.getParameter("part_code");
			String part_name = CommonUtil.getParameter("part_name");
			String delete_day = CommonUtil.getParameter("delete_day");

			// 파라미터 체크
			if(!CommonUtil.hasText(type) || !CommonUtil.hasText(parent_code) || !CommonUtil.hasText(part_code) || !CommonUtil.hasText(part_name)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			String business_code = CommonUtil.leftString(parent_code, 2);
			int part_depth = Integer.parseInt(CommonUtil.rightString(type, 1)) + 1;

			//String bpart_code = (part_depth>1) ? parent_code.substring(2, 7) : "";
			//String mpart_code = (part_depth>2) ? parent_code.substring(7, 12) : "";
			String bpart_code = (part_depth>1) ? parent_code.substring(2, 2+(_PART_CODE_SIZE*1)) : "";
			String mpart_code = (part_depth>2) ? parent_code.substring(2+(_PART_CODE_SIZE*1), 2+(_PART_CODE_SIZE*2)) : "";

				argMap.put("business_code",business_code);
			argMap.put("part_depth",Integer.toString(part_depth));
			argMap.put("bpart_code",bpart_code);
			argMap.put("mpart_code",mpart_code);
			argMap.put("part_code",part_code);
			argMap.put("part_name",part_name);
			argMap.put("delete_day",delete_day);
			argMap.put("_default_code",_PART_DEFAULT_CODE);

				int ins_cnt = db.insert("user_group.insertUserGroup", argMap);
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
				argMap.put("bpart_code",jsonItem.get("bpart_code"));
				argMap.put("mpart_code",jsonItem.get("mpart_code"));
				argMap.put("spart_code",jsonItem.get("spart_code"));
				argMap.put("part_name",jsonItem.get("part_name"));
				argMap.put("delete_day",jsonItem.get("delete_day"));

						upd_cnt += db.update("user_group.updateUserGroup", argMap);
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

				//argMap.put("bpart_code", row_id.substring(0,5));
			//argMap.put("mpart_code", row_id.substring(5,10));
			//argMap.put("spart_code", row_id.substring(10,15));
			argMap.put("bpart_code", row_id.substring(0,(_PART_CODE_SIZE*1)));
			argMap.put("mpart_code", row_id.substring((_PART_CODE_SIZE*1),(_PART_CODE_SIZE*2)));
			argMap.put("spart_code", row_id.substring((_PART_CODE_SIZE*2),(_PART_CODE_SIZE*3)));
			argMap.put("_default_code",_PART_DEFAULT_CODE);

			// 연관되는 그룹 또는 사용자가 존재하는지 여부 체크
			int re_cnt = db.selectOne("user_group.selectRelationUserGroup", argMap);

			if(re_cnt>0) {
				Site.writeJsonResult(out, false, "하위 데이터가 존재하여 삭제 하실 수 없습니다.");
				return;
			}

				int del_cnt = db.delete("user_group.deleteUserGroup", argMap);
			if(del_cnt<1) {
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}
		} else {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		out.print("{\"code\":\"OK\", \"tree\": {\"refresh\":\"true\"}, \"msg\":\"\"}");
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
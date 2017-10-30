<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%
	if(!Site.isPmss(out,"channel_mgmt","json")) return;

	Db db = null;

	try {
		// DB Connection (transaction)
		db = new Db();

		// get parameter
		String step = CommonUtil.getParameter("step");

		String add_msg = "";
		String client_ip = request.getRemoteAddr();

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("insert".equals(step)) {
			// get parameter
			String system_code = CommonUtil.getParameter("system_code");
			String phone_num = CommonUtil.getParameter("phone_num");
			String phone_ip = CommonUtil.getParameter("phone_ip", "");
			String channel = CommonUtil.getParameter("channel", "");
			String tn_num = CommonUtil.getParameter("tn_num", "");
			String mac = CommonUtil.getParameter("mac", "");

			// 파라미터 체크
			if(!CommonUtil.hasText(system_code) || !CommonUtil.hasText(phone_num) || !CommonUtil.hasText(phone_ip) || !CommonUtil.hasText(channel)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				system_code = CommonUtil.rightString(system_code, 2);

			// duplicate check
			argMap.put("phone_num",phone_num);
			argMap.put("ori_phone_num","");
			argMap.put("phone_ip",phone_ip);

			String result_code = db.selectOne("channel.selectDuplicateCheck", argMap);
			if(!"OK".equals(result_code)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg(result_code));
				return;
			}

				argMap.clear();
			argMap.put("system_code",system_code);
			argMap.put("phone_num",phone_num);
			argMap.put("phone_ip",phone_ip);
			argMap.put("channel",channel);
			argMap.put("mac",mac);
			argMap.put("tn_num",tn_num);
			argMap.put("backup_code","");

			int ins_cnt = db.insert("channel.insertChannel", argMap);
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

			int target_cnt = jsonArr.size();
			int upd_cnt = 0;
			int fail_cnt = 0;
			while (iterator.hasNext()) {
				JSONObject jsonItem = (JSONObject) iterator.next();

				// duplicate check
				argMap.clear();
				argMap.put("phone_num",jsonItem.get("phone_num"));
				argMap.put("ori_phone_num",jsonItem.get("ori_phone_num"));
				argMap.put("phone_ip",jsonItem.get("phone_ip"));

				// 중복시 다음 루프 실행
				String result_code = db.selectOne("channel.selectDuplicateCheck", argMap);

				if(!"OK".equals(result_code)) {
					fail_cnt++;
					continue;
				}

						argMap.clear();
				int tmp_upd_cnt = 0;

				if("I".equals(jsonItem.get("act_type").toString())) {
					argMap.put("system_code",jsonItem.get("system_code"));
					argMap.put("phone_num",jsonItem.get("phone_num"));
					argMap.put("phone_ip",jsonItem.get("phone_ip"));
					argMap.put("channel",jsonItem.get("channel"));
					argMap.put("mac",jsonItem.get("mac"));
					argMap.put("tn_num",jsonItem.get("tn_num"));
					argMap.put("backup_code","");

					tmp_upd_cnt = db.insert("channel.insertChannel", argMap);

				} else {
					argMap.put("ori_phone_num",jsonItem.get("ori_phone_num"));
					argMap.put("phone_num",jsonItem.get("phone_num"));
					argMap.put("phone_ip",jsonItem.get("phone_ip"));
					argMap.put("mac",jsonItem.get("mac"));
					argMap.put("tn_num",jsonItem.get("tn_num"));

					tmp_upd_cnt = db.update("channel.updateChannel", argMap);

				}

						upd_cnt += tmp_upd_cnt;
			}

			// 일부 실패했을 경우
			if(fail_cnt>0) {
				add_msg = "업데이트 대상 [" + Integer.toString(target_cnt) + "]건 중 [" + Integer.toString(fail_cnt) + "]건이 실패하였습니다.";
			}

			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
				return;
			}
		} else if("delete".equals(step)) {
			// get parameter
			String phone_num = CommonUtil.getParameter("row_id");

			// 파라미터 체크
			if(!CommonUtil.hasText(phone_num)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				int del_cnt = db.delete("channel.deleteChannel", phone_num);
			if(del_cnt<1) {
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}

		} else {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// commit
		db.commit();

		out.print("{\"code\":\"OK\", \"tree\": {\"refresh\":\"false\"}, \"msg\":\"" + add_msg + "\"}");
	} catch(Exception e) {
		// rollback
		if(db!=null) db.rollback();

		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
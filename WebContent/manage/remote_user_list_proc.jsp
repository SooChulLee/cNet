<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%
	if(!Site.isPmss(out,"user_mgmt","json")) return;

	Db db = null;

	try {
		// DB Connection (transaction)
		db = new Db();

		// get parameter
		String step = CommonUtil.getParameter("step");

		String client_ip = request.getRemoteAddr();

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("insert".equals(step)) {
			// get parameter
			String part_code = CommonUtil.getParameter("part_code");
			String user_id = CommonUtil.getParameter("user_id", "");
			String user_pass = CommonUtil.ifNull(request.getParameter("user_pass"));
			String user_name = CommonUtil.getParameter("user_name", "");
			String local_no = CommonUtil.getParameter("local_no", "");
			String channel_no = CommonUtil.getParameter("channel_no", "");
			String system_code = CommonUtil.getParameter("system_code", "");
			String user_level = CommonUtil.getParameter("user_level", "E");
			//String pass_chg_term = CommonUtil.getParameter("pass_chg_term", "90");
			String pass_chg_term = CommonUtil.getParameter("pass_chg_term", "0");
			String user_ip = CommonUtil.getParameter("user_ip", "");
			String eval_yn = CommonUtil.getParameter("eval_yn", "");//평가자여부

			// 파라미터 체크
			if(!CommonUtil.hasText(part_code) || !CommonUtil.hasText(user_id) || !CommonUtil.hasText(user_pass) || !CommonUtil.hasText(user_name) || !CommonUtil.hasText(local_no)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// 비밀번호 유효성 체크
			String _check_passwd = CommonUtil.checkPasswd(user_pass, user_id, "json");
			if(CommonUtil.hasText(_check_passwd)) {
				out.print(_check_passwd);
				return;
			}

				String business_code = CommonUtil.leftString(part_code, 2);
			//String bpart_code = part_code.substring(2, 7);
			//String mpart_code = part_code.substring(7, 12);
			//String spart_code = part_code.substring(12, 17);
			String bpart_code = part_code.substring(2, 2+(_PART_CODE_SIZE*1));
			String mpart_code = part_code.substring(2+(_PART_CODE_SIZE*1), 2+(_PART_CODE_SIZE*2));
			String spart_code = part_code.substring(2+(_PART_CODE_SIZE*2), 2+(_PART_CODE_SIZE*3));

			// 비밀번호 암호화
			CNCrypto sha256 = new CNCrypto("HASH",CommonUtil.getEncKey());
			String enc_user_pass = sha256.Encrypt(user_pass);

				argMap.put("user_id",user_id);
			argMap.put("user_pass",enc_user_pass);
			argMap.put("user_name",user_name);
			argMap.put("business_code",business_code);
			argMap.put("bpart_code",bpart_code);
			argMap.put("mpart_code",mpart_code);
			argMap.put("spart_code",spart_code);
			argMap.put("user_level",user_level);
			argMap.put("local_no",local_no);
			argMap.put("channel_no",channel_no);
			argMap.put("system_code",system_code);
			argMap.put("pass_chg_term",pass_chg_term);
			argMap.put("user_ip",user_ip);
			argMap.put("regi_ip",client_ip);
			argMap.put("regi_id",_LOGIN_ID);
			argMap.put("eval_yn",eval_yn);//평가자여부

				int ins_cnt = db.insert("user.insertUser", argMap);
			if(ins_cnt<1) {
				Site.writeJsonResult(out, false, "등록에 실패했습니다.");
				return;
			}

			// crec_user_info
			/*
			ins_cnt = db.insert("user.insertCrecUser", argMap);
			if(ins_cnt<1) {
				Site.writeJsonResult(out, false, "등록에 실패했습니다.");
				return;
			}
			*/

			// 등록 이력 저장
			argMap.clear();
			argMap.put("user_id", user_id);
			argMap.put("user_name", user_name);
			argMap.put("change_type", "I");
			argMap.put("change_id", _LOGIN_ID);
			argMap.put("change_name", _LOGIN_NAME);
			argMap.put("change_ip", client_ip);
			argMap.put("origin_level", user_level);
			argMap.put("change_level", "");

			db.insert("hist_user_change.insertUserChangeHist", argMap);
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

			// 비밀번호 암호화
			CNCrypto sha256 = new CNCrypto("HASH",CommonUtil.getEncKey());

				JSONParser jsonParser = new JSONParser();

				JSONObject jsonObj = (JSONObject) jsonParser.parse(data_list);

			JSONArray jsonArr = (JSONArray) jsonObj.get("data_list");
			Iterator<Object> iterator = jsonArr.iterator();

			int upd_cnt = 0;
			while (iterator.hasNext()) {
				JSONObject jsonItem = (JSONObject) iterator.next();

						argMap.clear();
				argMap.put("user_id",jsonItem.get("user_id"));
				if(!"".equals(jsonItem.get("user_pass"))) {
					// 비밀번호 유효성 체크
					String _check_passwd = CommonUtil.checkPasswd(jsonItem.get("user_pass").toString(), jsonItem.get("user_id").toString(), "json");
					if(CommonUtil.hasText(_check_passwd)) {
						continue;
					}

					argMap.put("user_pass",sha256.Encrypt(jsonItem.get("user_pass").toString()));
				}
				argMap.put("user_name",jsonItem.get("user_name"));
				argMap.put("user_level",jsonItem.get("user_level"));
				argMap.put("local_no",jsonItem.get("local_no"));
				argMap.put("channel_no",jsonItem.get("channel_no"));
				argMap.put("system_code",jsonItem.get("system_code"));
				//argMap.put("pass_chg_term",jsonItem.get("pass_chg_term").toString());
				argMap.put("pass_chg_term","0");
				argMap.put("user_ip",jsonItem.get("user_ip"));
				argMap.put("resign_yn",jsonItem.get("resign_yn"));
				argMap.put("use_yn",jsonItem.get("use_yn"));
				argMap.put("upd_ip",client_ip);
				argMap.put("upd_id",_LOGIN_ID);
				argMap.put("eval_yn",jsonItem.get("eval_yn"));//평가자여부

						int tmp_upd_cnt = db.update("user.updateUser", argMap);
				upd_cnt += tmp_upd_cnt;

				// crec_user_info
				//tmp_upd_cnt = db.update("user.updateCrecUser", argMap);

				if(tmp_upd_cnt>0) {
					// 수정 이력 저장
					argMap.clear();
					argMap.put("user_id", jsonItem.get("user_id"));
					argMap.put("user_name", jsonItem.get("user_name"));
					argMap.put("change_type", "U");
					argMap.put("change_id", _LOGIN_ID);
					argMap.put("change_name", _LOGIN_NAME);
					argMap.put("change_ip", client_ip);
					// 등급변경
					if(!jsonItem.get("origin_level").equals(jsonItem.get("user_level"))) {
						argMap.put("origin_level", jsonItem.get("origin_level"));
						argMap.put("change_level", jsonItem.get("user_level"));
					} else {
						argMap.put("origin_level", "");
						argMap.put("change_level", "");
					}

					db.insert("hist_user_change.insertUserChangeHist", argMap);

					// 비밀번호 변경이력 저장
					if(!"".equals(jsonItem.get("user_pass"))) {
						argMap.clear();
						argMap.put("change_pass", sha256.Encrypt(jsonItem.get("user_pass").toString()));
						argMap.put("user_id", jsonItem.get("user_id"));
						argMap.put("user_name", jsonItem.get("user_name"));
						argMap.put("change_id", _LOGIN_ID);
						argMap.put("change_name", _LOGIN_NAME);
						argMap.put("change_ip", client_ip);

						db.insert("hist_pass_change.insertPassChangeHist", argMap);
					}
				}
			}

			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
				return;
			}
		} else if("delete".equals(step)) {
			// get parameter
			String user_id = CommonUtil.getParameter("row_id");

			// 파라미터 체크
			if(!CommonUtil.hasText(user_id)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// 사용자 정보 조회
			Map<String, Object> data = db.selectOne("user.selectItem", user_id);
			if(data==null) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_DATA"));
				return;
			}

				int del_cnt = db.delete("user.deleteUser", user_id);
			if(del_cnt<1) {
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}

			// crec_user_info
			/*
			del_cnt = db.delete("user.deleteCrecUser", user_id);
			if(del_cnt<1) {
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}
			*/

			// 삭제 이력 저장
			argMap.put("user_id", user_id);
			argMap.put("user_name", data.get("user_name").toString());
			argMap.put("change_type", "D");
			argMap.put("change_id", _LOGIN_ID);
			argMap.put("change_name", _LOGIN_NAME);
			argMap.put("change_ip", client_ip);
			argMap.put("origin_level", data.get("user_level").toString());
			argMap.put("change_level", "");

			db.insert("hist_user_change.insertUserChangeHist", argMap);
		} else if("unlock".equals(step)) {
			// get parameter
			String user_id = CommonUtil.getParameter("row_id");

			// 파라미터 체크
			if(!CommonUtil.hasText(user_id)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// 사용자 정보 조회
			Map<String, Object> data = db.selectOne("user.selectItem", user_id);
			if(data==null) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_DATA"));
				return;
			}

			// login result reset
			db.delete("user.unlockLoginResult", user_id);

			argMap.put("user_id",user_id);
			argMap.put("lock_yn","0");
			argMap.put("upd_ip",client_ip);
			argMap.put("upd_id",_LOGIN_ID);

			int upd_cnt = db.update("user.updateUser", argMap);
			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "잠금해제에 실패했습니다.");
				return;
			}

			// 수정 이력 저장
			argMap.clear();
			argMap.put("user_id", user_id);
			argMap.put("user_name", data.get("user_name").toString());
			argMap.put("change_type", "U");
			argMap.put("change_id", _LOGIN_ID);
			argMap.put("change_name", _LOGIN_NAME);
			argMap.put("change_ip", client_ip);
			argMap.put("origin_level", "");
			argMap.put("change_level", "");

			db.insert("hist_user_change.insertUserChangeHist", argMap);
		} else {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// commit
		db.commit();

		out.print("{\"code\":\"OK\", \"tree\": {\"refresh\":\"false\"}, \"msg\":\"\"}");
	} catch(Exception e) {
		// rollback
		if(db!=null) db.rollback();

		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
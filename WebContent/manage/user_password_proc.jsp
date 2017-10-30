<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%

	// DB Connection Object
	Db db = null;

	try {
		// DB Connection (transaction)
		db = new Db();

		// get parameter
		String step = CommonUtil.getParameter("step");

		//
		String client_ip = request.getRemoteAddr();

		//
		Map<String, Object> argMap = new HashMap<String, Object>();

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

		//
		JSONParser jsonParser = new JSONParser();

		//
		JSONObject jsonObj = (JSONObject) jsonParser.parse(data_list);

		JSONArray jsonArr = (JSONArray) jsonObj.get("data_list");
		Iterator<Object> iterator = jsonArr.iterator();

		int upd_cnt = 0;
		while (iterator.hasNext()) {
			JSONObject jsonItem = (JSONObject) iterator.next();

			//
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
			argMap.put("pass_chg_term",jsonItem.get("pass_chg_term").toString());
			argMap.put("user_ip",jsonItem.get("user_ip"));
			argMap.put("resign_yn",jsonItem.get("resign_yn"));
			argMap.put("use_yn",jsonItem.get("use_yn"));
			argMap.put("upd_ip",client_ip);
			argMap.put("upd_id",_LOGIN_ID);

			//
			int tmp_upd_cnt = db.update("user.updateUser", argMap);
			upd_cnt += tmp_upd_cnt;
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
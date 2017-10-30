<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="javax.servlet.http.Cookie"%>
<%@ page import="wfm.com.util.AES256Cipher"%>
<%@ page import="com.cnet.crec.util.SessionListener"%>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%
	// DB Connection Object
	Db db = null;

	try {

		// get parameter
		String info_enc = request.getParameter("info");
		String login_ip = request.getRemoteAddr();

		// 파라미터 체크
		if(!CommonUtil.hasText(info_enc)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}

		// parameter decrypt
		AES256Cipher a256 = AES256Cipher.getInstance(CommonUtil.getWfmEncKey());
		String info_dec = a256.decrypt(info_enc);

		//System.out.println(a256.encrypt("987654321|cnet2580!|20170214181759000"));
		//System.out.println(info_dec);
		//System.out.println(a256.decrypt("aDPmIRS/Uyx8nZ0GvbjJxm3wLZnLHEcL5uWuKaqGV3zlOu3l5XT5GWBTZonLCfCx"));
		//aDPmIRS/Uyx8nZ0GvbjJxm3wLZnLHEcL5uWuKaqGV3whAsQXptLvc8o+138Xza6w

		//System.out.println(request.getRemoteAddr());

		//상담원ID|시간(yyyyMMddHHmmssSSS 17자리)|패스워드
		String[] tmp_arr = info_dec.split("\\|");
		String user_id = tmp_arr[0];


		// 파라미터의 시간과 현재 시간의 차이를 구함
		Date conn_datm = DateUtil.getDate(DateUtil.getDateFormatByIntVal(tmp_arr[2], "yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");
		Date now_datm = DateUtil.getDate(DateUtil.getToday("yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");

		int diff = DateUtil.getDateDiff(conn_datm, now_datm, "M");

		// 5분 이상 차이가 날 경우 로그인 실패 처리
		if(diff>5) {
			out.print(CommonUtil.getPopupMsg("접근가능 시간이 만료되었습니다.","","close"));
			return;
		}

		// DB Connection
		db = new Db(true);

					// 비밀번호 암호화
					CNCrypto sha256 = new CNCrypto("HASH",CommonUtil.getEncKey());
					String enc_user_pass = sha256.Encrypt(tmp_arr[1]);

					//
					Map<String, Object> argMap = new HashMap<String, Object>();
					argMap.put("login_id", user_id);
					//argMap.put("login_pass", enc_user_pass);

					// 사용자 아이디, 비밀번호 체크
					Map<String, Object> data = db.selectOne("login.selectUserPWD", argMap);

					if(data==null) {
						Site.writeJsonResult(out, false, "해당하는 사용자가 없습니다.");
						return;
					}

					// 비밀번호 업데이트
					argMap.clear();
					argMap.put("user_id", user_id);
					argMap.put("user_pass", enc_user_pass);

					int upd_cnt = db.update("user.updatePasswd", argMap);
					if(upd_cnt<1) {
						Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
						return;
					}

					// 비밀번호 변경 로그 저장
					String user_name = data.get("user_name").toString();



					argMap.clear();
					argMap.put("change_pass", enc_user_pass);
					argMap.put("user_id", user_id);
					argMap.put("user_name", user_name);
					argMap.put("origin_pass", "");
					argMap.put("change_id", "WFMS");
					argMap.put("change_name", "WFMS");
					argMap.put("change_ip", request.getRemoteAddr());

					int ins_cnt = db.insert("hist_pass_change.insertPassChangeHist", argMap);


					if(ins_cnt<1) {
						Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
						return;
					}



	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="javax.servlet.http.Cookie"%>
<%@ page import="wfm.com.util.AES256Cipher"%>
<%@ page import="com.cnet.crec.util.SessionListener"%>
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

		String[] tmp_arr = info_dec.split("\\|");
		String login_id = tmp_arr[0];

		// 파라미터의 시간과 현재 시간의 차이를 구함
		Date conn_datm = DateUtil.getDate(DateUtil.getDateFormatByIntVal(tmp_arr[1], "yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");
		Date now_datm = DateUtil.getDate(DateUtil.getToday("yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");

		int diff = DateUtil.getDateDiff(conn_datm, now_datm, "M");

		// 5분 이상 차이가 날 경우 로그인 실패 처리
		if(diff>5) {
			out.print(CommonUtil.getPopupMsg("접근가능 시간이 만료되었습니다.","","close"));
			return;
		}

		// DB Connection
		db = new Db(true);

		// 1. 해당 아이디 잠금여부 체크
		/* int lock_cnt = db.selectOne("login.selectLockCheck", login_id);
		if(lock_cnt>0) {
			out.print(CommonUtil.getPopupMsg("해당 아이디는 잠금 처리되어 로그인 하실 수 없습니다.","","close"));
			return;
		} */

		// 2. 로그인 결과 신규 등록
		int rslt_cnt = db.selectOne("login.selectCountLoginResult", login_id);
		if(rslt_cnt<1) {
			db.insert("login.insertLoginResult", login_id);
		}

		//
		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("login_id", login_id);
		argMap.put("login_name", "");
		argMap.put("login_ip", login_ip);
		argMap.put("login_type", "I");
		argMap.put("login_result", "");

		// 3. 사용자 아이디, 비밀번호 체크
		Map<String, Object> data  = db.selectOne("login.selectAutoLoginUser", argMap);
		if(data==null) {
			// 4. 로그인 실패 결과 업데이트
			argMap.put("login_result", "0");
			db.update("login.updateLoginResult", argMap);

			// 5. 로그인 실패 이력 저장
			db.insert("hist_login.insertLoginHist", argMap);

			// 6. 금일  5회 이상 로그인 실패시 해당 아이디 잠금 처리
			/* lock_cnt = db.selectOne("login.selectLockCheck", login_id);
			if(lock_cnt>0) {
				// lock_yn='1' 업데이트
				argMap.put("user_id", login_id);
				argMap.put("lock_yn", "1");
				argMap.put("upd_id", login_id);
				argMap.put("upd_ip", login_ip);
				db.update("user.updateUser", argMap);
			} */

			//
			out.print(CommonUtil.getPopupMsg("로그인에 실패했습니다.","","close"));
			return;
		}

		// 7. 장기간 로그인하지 않은 사용자 잠금 처리
		/* int login_check_day = Integer.parseInt(data.get("login_check_day").toString());

		if(_LOGIN_CHECK_TERM<login_check_day) {
			// lock_yn='1' 업데이트
			argMap.put("user_id", login_id);
			argMap.put("lock_yn", "1");
			argMap.put("upd_id", login_id);
			argMap.put("upd_ip", login_ip);
			db.update("user.updateUser", argMap);

			Site.writeJsonResult(out, false, "장기간 로그인하지 않아 잠금 처리되었습니다.");
			return;
		} */

		// 8~9. 비밀번호 변경 이력이 없는 경우, 비밀번호 만료 제외

		// 10. 로그인 세션 생성
		session.setAttribute("login_id", login_id.toLowerCase());
		session.setAttribute("login_name", data.get("user_name").toString());
		session.setAttribute("login_level", data.get("user_level").toString());
		session.setAttribute("login_level_name", data.get("level_name").toString());
		session.setAttribute("login_business_code", data.get("business_code").toString());
		session.setAttribute("login_bpart", data.get("bpart_code").toString());
		session.setAttribute("login_mpart", data.get("mpart_code").toString());
		session.setAttribute("login_spart", data.get("spart_code").toString());
		session.setAttribute("login_ip", login_ip);
		session.setAttribute("down_ip", data.get("down_ip").toString());
		session.setAttribute("login_datm", data.get("login_datm").toString());

		// 11. 메뉴 권한 세션 생성
		argMap.put("business_code", data.get("business_code").toString());
		argMap.put("user_level", data.get("user_level").toString());

		List<Map<String, Object>> menulist = db.selectList("menu.selectMenuPerm", argMap);
		if(menulist.size()<1) {
			out.print(CommonUtil.getPopupMsg("접근 가능한 메뉴가 없습니다.","","close"));
			return;
		}
		Map<String,String> tmpmap = new LinkedHashMap();
		for(int i=0;i<menulist.size();i++) {
			tmpmap.put(menulist.get(i).get("menu_code").toString(), CommonUtil.getFilenameNoExt(menulist.get(i).get("menu_url").toString()));
		}
		session.setAttribute("menu_perm", tmpmap);

		// 12. 중복 로그인 방지
		SessionListener sl = new SessionListener();

		// set session data to activeUsers
		sl.setLoginSession(request, session);

		// duplicate login check ==> 중복일 경우 기존 세션 삭제
		sl.checkDuplicateLogin(request, session);

		// 13. 로그인 성공 결과 업데이트
		argMap.put("login_result", "1");
		db.update("login.updateLoginResult", argMap);

		// 14. 로그인 성공 이력 저장
		argMap.put("login_name", data.get("user_name").toString());
		db.insert("hist_login.insertLoginHist", argMap);

		// 15. 로그인 일시, 아이피 업데이트
		argMap.put("user_id", login_id);
		argMap.put("login_yn", "1");
		argMap.put("login_ip", login_ip);
		argMap.put("upd_id", login_id);
		argMap.put("upd_ip", login_ip);
		db.update("user.updateUser", argMap);

		// 16. template color cookie expire date 업데이트
		if(!"".equals(CommonUtil.getCookieValue("ck_template_color"))) {
			Cookie cook = new Cookie("ck_template_color", CommonUtil.getCookieValue("ck_template_color"));
			cook.setPath("/");
			cook.setMaxAge(60*60*24*7);

			response.addCookie(cook);
		}

		// 조회 페이지로 이동
		response.sendRedirect("/rec_search/rec_search.jsp");
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>

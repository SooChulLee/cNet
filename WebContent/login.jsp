<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="javax.servlet.http.Cookie"%>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%@ page import="com.cnet.crec.util.SessionListener"%>

<%@ page import="com.cnet.crec.util.RSA"%>
<%@ page import="java.security.PrivateKey"%>

<%

	// DB Connection Object
	Db db = null;

	try {

		String login_id = CommonUtil.getParameter("login_id", "");
		String login_pass = CommonUtil.ifNull(request.getParameter("login_pass"));

// 		2016.11.15 현원희 추가
		PrivateKey pKey = (PrivateKey) request.getSession().getAttribute("__rsaPrivateKey__");
		//로그인 아이디 대소문자 구분없이 DB에서 조회 된다. (모두 대문자로 변경)
		login_id = RSA.decryptRsa(pKey, login_id).toUpperCase();
		login_pass = RSA.decryptRsa(pKey, login_pass);


		String id_save = CommonUtil.getParameter("id_save", "");
		String login_ip = request.getRemoteAddr();

		// 파라미터 체크
		if(!CommonUtil.hasText(login_id) || !CommonUtil.hasText(login_pass)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// DB Connection
		db = new Db(true);

		// 1. 해당 아이디 잠금여부 체크
		/* int lock_cnt = db.selectOne("login.selectLockCheck", login_id);
		if(lock_cnt>0) {
			Site.writeJsonResult(out, false, "해당 아이디는 잠금 처리되어 로그인 하실 수 없습니다.");
			return;
		} */

		// 비밀번호 암호화
		CNCrypto sha256 = new CNCrypto("HASH",CommonUtil.getEncKey());
		String enc_login_pass = sha256.Encrypt(login_pass);

		// 2. 로그인 결과 신규 등록
		int rslt_cnt = db.selectOne("login.selectCountLoginResult", login_id);
		if(rslt_cnt<1) {
			db.insert("login.insertLoginResult", login_id);
		}

		//
		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("login_id", login_id);
		argMap.put("login_name", "");
		argMap.put("login_pass", enc_login_pass);
		argMap.put("login_ip", login_ip);
		argMap.put("login_type", "I");
		argMap.put("login_result", "");

		// 3. 사용자 아이디, 비밀번호 체크
		Map<String, Object> data  = db.selectOne("login.selectLoginUser", argMap);

		if(data==null) {

			// 4. 로그인 실패 결과 업데이트
			argMap.put("login_result", "0");
			db.update("login.updateLoginResult", argMap);

			// 5. 로그인 실패 이력 저장
			db.insert("hist_login.insertLoginHist", argMap);

			// 6. 금일 5회 이상 로그인 실패시 해당 아이디 잠금 처리
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
			Site.writeJsonResult(out, false, "로그인에 실패했습니다.");
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
		}

		//
		String pass_upd_date = data.get("pass_upd_date").toString();
		//String pass_expire_date = data.get("pass_expire_date").toString();
		//int pass_check_day = DateUtil.getDateDiff(DateUtil.getToday(), DateUtil.getDate(pass_expire_date, "yyyy-MM-dd"), "D");
		int pass_check_day = Integer.parseInt(data.get("pass_check_day").toString()); */

		// 8. 비밀번호 변경 이력이 없는 경우
		/* if(!CommonUtil.hasText(pass_upd_date)) {
			out.print("{\"code\":\"PASS\", \"msg\":\"최초 로그인하시는 경우 비밀번호 변경 후 로그인이 가능합니다.\"}");
			return;
		} */

		// 9. 비밀번호 만료
		/* if(pass_check_day<0) {
			out.print("{\"code\":\"PASS\", \"msg\":\"비밀번호 사용일자를 초과하였습니다.\"}");
			return;
		} */

		// 10. 로그인 세션 생성
		//session.setAttribute("login_id", login_id.toLowerCase());
		session.setAttribute("login_id", login_id);
		session.setAttribute("login_name", data.get("user_name"));
		session.setAttribute("login_level", data.get("user_level"));
		session.setAttribute("login_level_name", data.get("level_name"));
		session.setAttribute("login_business_code", data.get("business_code"));
		session.setAttribute("login_bpart", data.get("bpart_code"));
		session.setAttribute("login_mpart", data.get("mpart_code"));
		session.setAttribute("login_spart", data.get("spart_code"));
		session.setAttribute("login_ip", login_ip);
		session.setAttribute("down_ip", data.get("down_ip"));
		session.setAttribute("login_datm", data.get("login_datm"));
		session.setAttribute("eval_yn", data.get("eval_yn"));

		// 11. 메뉴 권한 세션 생성
		argMap.put("business_code", data.get("business_code").toString());
		argMap.put("user_level", data.get("user_level").toString());

		List<Map<String, Object>> menulist = db.selectList("menu.selectMenuPerm", argMap);
		if(menulist.size()<1) {
			Site.writeJsonResult(out, false, "접근 가능한 메뉴가 없습니다.");
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

		// 17. 아이디 저장 클릭 시 로그인 아이디 쿠키 생성
		Cookie cook_login_id = null;

		if("1".equals(id_save)) {
			cook_login_id = new Cookie("ck_login_id", login_id.toLowerCase());
			cook_login_id.setPath("/");
			cook_login_id.setMaxAge(60*60*24*7);
		} else {
			cook_login_id = new Cookie("ck_login_id", null);
			cook_login_id.setPath("/");
			cook_login_id.setMaxAge(0);
		}
		response.addCookie(cook_login_id);

		if(Finals.isDev){session.setMaxInactiveInterval(60*60*24);}//초단위(24시간)

		//Finals.setApplicationVariable();//변수 로딩
		if(login_id.equals("admin")) Finals.setApplicationVariable(true);//강제로 변수 리로드
		else						 Finals.setApplicationVariable();

		Site.writeJsonResult(out,true);
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
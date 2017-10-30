<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%
	// U = 로그인 후 수정, X = 비밀번호 사용 만료에 따른 수정
	String type = CommonUtil.getParameter("type", "U");

	// 메뉴 접근권한 체크 (수정일 경우만 체크, 만료일 경우 체크 안함)
	if("U".equals(type)) {
		if(!Site.isPmss(out,"","json")) return;
	}

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");

		if("update".equals(step)) {
			// get parameter
			String user_id = CommonUtil.getParameter("user_id");
			String user_pass = CommonUtil.ifNull(request.getParameter("user_pass"));
			String new_pass = CommonUtil.ifNull(request.getParameter("new_pass"));

			// 파라미터 체크
			if(!CommonUtil.hasText(user_id) || !CommonUtil.hasText(user_pass) || !CommonUtil.hasText(new_pass)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// 로그인 아이디와 입력된 아이디 비교
			if("U".equals(type) && !_LOGIN_ID.equals(user_id)) {
				Site.writeJsonResult(out, false, "로그인 아이디와 입력된 아이디가 일치하지 않습니다.");
				return;
			}

			// 비밀번호 유효성 체크
			String _check_passwd = CommonUtil.checkPasswd(new_pass, user_id, "json");
			if(CommonUtil.hasText(_check_passwd)) {
				out.print(_check_passwd);
				return;
			}

			// 비밀번호 암호화
			CNCrypto sha256 = new CNCrypto("HASH",CommonUtil.getEncKey());
			String enc_user_pass = sha256.Encrypt(user_pass);
			String enc_new_pass = sha256.Encrypt(new_pass);

				if(enc_user_pass.equals(enc_new_pass)) {
				Site.writeJsonResult(out, false, "현재 비밀번호와 동일한 비밀번호 입니다.");
				return;
			}

				Map<String, Object> argMap = new HashMap<String, Object>();
			argMap.put("login_id", user_id);
			argMap.put("login_pass", enc_user_pass);

			// 사용자 아이디, 비밀번호 체크
			Map<String, Object> data  = db.selectOne("login.selectLoginUser", argMap);
			if(data==null) {
				Site.writeJsonResult(out, false, "해당하는 사용자가 없습니다.");
				return;
			}

			// 비밀번호 사용횟수 조회
			argMap.clear();
			argMap.put("user_id", user_id);
			argMap.put("change_pass", enc_new_pass);

			int used_cnt = db.selectOne("hist_pass_change.selectPasswdUsedCnt", argMap);

			if(used_cnt>=3) {
				Site.writeJsonResult(out, false, "이미 3회 이상 사용한 비밀번호 입니다.");
				return;
			}

			// 직전 사용한 비밀번호 사용금지
			String prev_pass = db.selectOne("hist_pass_change.selectPrevPasswd", user_id);
			if(prev_pass!=null && prev_pass.equals(enc_new_pass)) {
				Site.writeJsonResult(out, false, "바로 직전에 사용한 비밀번호 입니다.");
				return;
			}

			// 비밀번호 업데이트
			argMap.clear();
			argMap.put("user_id", user_id);
			argMap.put("user_pass", enc_new_pass);

			int upd_cnt = db.update("user.updatePasswd", argMap);
			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
				return;
			}

			// 비밀번호 변경 로그 저장
			String user_name = data.get("user_name").toString();

			argMap.clear();
			argMap.put("change_pass", enc_new_pass);
			argMap.put("user_id", user_id);
			argMap.put("user_name", user_name);
			//argMap.put("origin_pass", enc_user_pass);
			argMap.put("change_id", user_id);
			argMap.put("change_name", user_name);
			argMap.put("change_ip", request.getRemoteAddr());

			int ins_cnt = db.insert("hist_pass_change.insertPassChangeHist", argMap);
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
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	// DB Connection Object
	Db db = null;

	try {
		// DB Connection
		db = new Db(true);

		if(_LOGIN_ID!=null && !"".equals(_LOGIN_ID)) {
			// 로그아웃 이력 저장
			Map<String, Object> argMap = new HashMap<String, Object>();
			argMap.put("login_id", _LOGIN_ID);
			argMap.put("login_name", _LOGIN_NAME);
			argMap.put("login_ip", request.getRemoteAddr());
			argMap.put("login_type", "O");
			argMap.put("login_result", "1");

			db.insert("hist_login.insertLoginHist", argMap);
		}

		// 세션 삭제
		session.invalidate();

		// 페이지 이동
		ComLib.script(out,"top.location.replace('/index.jsp')");
		//out.print(CommonUtil.getPopupMsg("로그아웃 되었습니다.","index.jsp","url"));
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
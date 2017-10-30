<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	// DB Connection Object
	Db db = null;

	try {
		// DB Connection
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");

		//
		Map<String, Object> argMap = new HashMap<String, Object>();

		if("reset".equals(step)) {
			//
			int upd_cnt = db.update("dashboard.updateReset", argMap);
			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "초기화에 실패했습니다.");
				return;
			}
		} else {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		//
		Site.writeJsonResult(out,true);
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
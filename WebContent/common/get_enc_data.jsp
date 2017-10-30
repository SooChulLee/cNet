<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%
	try {
		// get parameter
		String info = CommonUtil.ifNull(request.getParameter("info"));
		String flag = CommonUtil.getParameter("flag", "1");

		// 파라미터 체크
		if(!CommonUtil.hasText(info)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// 요청일시 추가
		if("1".equals(flag)) {
			info = DateUtil.getToday("yyyyMMddHHmmss") + "|" + info;
		}

		// 파라미터 암호화
		CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());
		info = aes.Encrypt(info);

		//
		out.print("{\"code\":\"OK\", \"data\":\"" + info + "\"}");
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {

	}
%>
<%@ page
	language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
	trimDirectiveWhitespaces="true"
	import=" org.apache.log4j.Logger
		, org.json.simple.*
		, org.json.simple.parser.*
		, com.cnet.crec.common.*
		, com.cnet.crec.util.CommonUtil
		, com.cnet.crec.util.DateUtil
		, java.util.*"
%><%
	// no cache
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
	response.setHeader("Expires", "0");
	// encoding
	request.setCharacterEncoding("UTF-8");

	// set request
	CommonUtil.setReqest(request);
	
	// session 변수 선언
	String _LOGIN_ID 		= ComLib.getSessionValue(session, "login_id");
	String _LOGIN_NAME 		= ComLib.getSessionValue(session, "login_name");
	String _LOGIN_LEVEL 	= ComLib.getSessionValue(session, "login_level");
	String _BUSINESS_CODE 	= ComLib.getSessionValue(session, "login_business_code");
	String _BPART_CODE 		= ComLib.getSessionValue(session, "login_bpart");
	String _MPART_CODE 		= ComLib.getSessionValue(session, "login_mpart");
	String _SPART_CODE 		= ComLib.getSessionValue(session, "login_spart");

	// part_code 자릿수 설정
	String _PART_DEFAULT_CODE = "000000";
	int _PART_CODE_SIZE = _PART_DEFAULT_CODE.length();

	// 장기간 미사용 체크 일수
	int _LOGIN_CHECK_TERM = 31;
	String page_id = ComLib.getFileNameNoExt(request);
	
	Logger logger = Logger.getLogger(ComLib.getFileName(request));
%>

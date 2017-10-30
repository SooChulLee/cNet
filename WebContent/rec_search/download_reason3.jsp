<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"rec_search","close")) return;

	try {
		// get parameter
		String info = CommonUtil.ifNull(request.getParameter("info"));

		// 파라미터 체크
		if(!CommonUtil.hasText(info)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="-1" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>다운로드 사유 등록</title>
<link href="../css/bootstrap.css" rel="stylesheet">
<link href="../css/font-awesome.css" rel="stylesheet">
<link href="../css/animate.css" rel="stylesheet">
<link href="../css/style.css" rel="stylesheet">

<script type="text/javascript" src="../js/jquery-1.11.0.min.js"></script>
<script type="text/javascript" src="../js/jquery-ui-1.10.4.custom.min.js"></script>
<script type="text/javascript" src="../js/bootstrap.js"></script>
<script type="text/javascript" src="../js/common.js"></script>
<script type="text/javascript">
$(function(){
	// 등록 버튼 클릭
	$("button[name=modal_regi]").click(function(){
		if(reasonFormChk()) {
			$("#reason_regi").attr("action", "download_part.jsp");
			$("#reason_regi").attr("target", "hiddenFrame");
			$("#reason_regi").submit();
		}
	});
});
</script>
</head>

<body class="white-bg">
<div id="container" style="width: 556px">
	<div class="memo-body">
		<form id="reason_regi" method="post">
			<input type="hidden" name="info" value="<%=info %>"/>

			<jsp:include page="/include/reason_inc.jsp" flush="false"/>
		</form>
	</div>
</div>
<iframe name="hiddenFrame" id="hiddenFrame" style="display: none;"></iframe>
</body>
</html>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {

	}
%>
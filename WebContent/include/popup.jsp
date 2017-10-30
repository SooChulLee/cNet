<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%@ include file="/common/common.jsp" %><%
String _TEMPLATE_COLOR	= CommonUtil.getCookieValue("ck_template_color");

%>
<!DOCTYPE html>
<html>
<head>
	<link rel="icon" href="../img/icon/main.ico" type="image/x-icon" />
	<link rel="shortcut icon" href="../img/icon/main.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="-1" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />

	<link href="../css/bootstrap.css" rel="stylesheet" />
	<link href="../css/font-awesome.css" rel="stylesheet" />
	<link href="../css/animate.css" rel="stylesheet">
	<link href="../css/style<%=(!"".equals(_TEMPLATE_COLOR)) ? "_" + _TEMPLATE_COLOR : "" %>.css" rel="stylesheet" />

	<script type="text/javascript" src="../js/jquery-1.11.0.min.js"></script>
	<script type="text/javascript" src="../js/jquery-ui-1.10.4.custom.min.js"></script>
	<script type="text/javascript" src="../js/bootstrap.js"></script>
	<script type="text/javascript" src="../js/site.js"></script>
	<script type="text/javascript" src="../js/common.js"></script>
	<script type="text/javascript" src="../js/commItemz.js"></script>
	<script type="text/javascript" src="../js/finals.js"></script>
</head>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="com.cnet.crec.util.RSA"%>
<%
RSA rsa = RSA.getEncKey();

String publicKeyModulus = rsa.getPublicKeyModulus();
String publicKeyExponent = rsa.getPublicKeyExponent();
session.setAttribute("__rsaPrivateKey__", rsa.getPrivateKey());
%>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<title>녹취관리 시스템</title>

	<link href="./css/bootstrap.css" rel="stylesheet" />
	<link href="./css/font-awesome.css" rel="stylesheet" />
	<link href="./css/animate.css" rel="stylesheet">
	<link href="./css/smoothness/jquery-ui-1.10.4.custom.min.css" rel="stylesheet" />
	<link href="./css/style.css" rel="stylesheet" />

	<script type="text/javascript" src="./js/jquery-1.11.0.min.js"></script>
	<script type="text/javascript" src="./js/jquery-ui-1.10.4.custom.min.js"></script>
	<script type="text/javascript" src="./js/jquery.cookie.js"></script>
	<script type="text/javascript" src="./js/bootstrap.js"></script>
	<script type="text/javascript" src="./js/site.js"></script>
	<script type="text/javascript" src="./js/common.js"></script>
		<!-- rsa -->
	<!--   2016.11.15 현원희 추가 -->
	<script src="./js/rsa/jsbn.js"></script>
	<script src="./js/rsa/jsbn2.js"></script>
	<script src="./js/rsa/prng4.js"></script>
	<script src="./js/rsa/rng.js"></script>
	<script src="./js/rsa/rsa.js"></script>
	<script src="./js/rsa/rsa2.js"></script>
	<!--// rsa -->
</head>

<body>
<script type="text/javascript">
	$(function () {
		$("#login").submit(function(){
			var login_id = $("input[name=login_id]");
			var login_pass = $("input[name=login_pass]");
		var id_save = $("input[name=id_save]");
		var id_save_c = "";

		var rsaPublicKeyModulus = $("input[name=rsaPublicKeyModulus]");
		var rsaPublicKeyExponent = $("input[name=rsaPublicKeyExponent]");

			if(login_id.val()==""){
				alert("아이디를 입력하셔야 합니다.");
				login_id.focus();
				return false;
			}
			if(login_pass.val()==""){
				alert("비밀번호를 입력하셔야 합니다.");
				login_pass.focus();
				return false;
			}
// 		2016.11.15 현원희 추가
		var publickey = "<%=publicKeyModulus%>";

		var rsakey = new RSAKey();
		rsakey.setPublic(publickey, '10001');

		var enc_login_id = rsakey.encrypt(login_id.val());
		var enc_login_pass = rsakey.encrypt(login_pass.val());

			$.ajax({
				type: "POST",
				url: "login.jsp",
				async: false,
				//data: $("#login").serialize(),
				data: "login_id="+enc_login_id+"&login_pass="+enc_login_pass+"&id_save="+id_save_c,
				dataType: "json",
				success:function(data){
					if(data.code=="OK") {
						location.replace("./rec_search/rec_search.jsp");
					} else if(data.code=="PASS") {
						alert(data.msg);
						// 아이디 셋팅
						$("#passwdUpd input[name=user_id]").val($("#login input[name=login_id]").val());
						$("#passwdUpd input[name=user_id]").prop("readonly", "readonly");
						$("#passwdUpd input[name=user_pass]").focus();
						// 비밀번호 변경 레이어 팝업 노출
						$("#modalPasswdForm").modal("toggle");
					} else {
						alert(data.msg);
						return false;
					}
				},
				error:function(req,status,err){
					alertJsonErr(req,status,err);
					return false;
				}
			});
		});

		// 비밀번호 재발급 버튼 클릭
		$(".btn_passwd_reissue").click(function() {
			$("#modalPasswdReissue").modal("toggle");
		});

		// 비밀번호 변경 버튼 클릭
		$(".btn_passwd_change").click(function() {
			$("#modalPasswdForm").modal("toggle");
		});

		// 저장된 아이디 셋팅
		var ck_login_id = $.cookie("ck_login_id");
		if(ck_login_id!=undefined && ck_login_id!="") {
			$("input[name=login_id]").val(ck_login_id);
			$("input[name=id_save]").attr("checked", true);
			$("input[name=login_pass]").focus();
		} else {
			$("input[name=login_id]").focus();
		}
	});
</script>

<div class="loginColumns">
	<div class="loginRadius1">녹취관리 시스템 <span style="float:right; font-size: 14px;"><%=Finals.MAIN_TITLE_LOGIN%></span></div>
	<div class="loginRadius2">
		<div class="form-box1">
			<img alt="image" src="img/login_visual.png" />
		</div>
		<div class="form-box2">
			<form id="login" class="form-horizontal" method="post" onsubmit="return false;">
				<div class="space01">ID 로그인</div>
				<div class="space02">
					<!--ID-->
					<div class="form-group space04">
						<div class="col-md-12">
							<div class="input-group">
								<span class="input-group-addon"><img alt="image" src="img/icon/id_icon.png" /></span>
								<input type="username" class="form-control" id="login_id" name="login_id" placeholder="Username">
							</div>
						</div>
					</div>
					<!--ID 끝-->
					<!--Password-->
					<div class="form-group">
						<div class="col-md-12">
							<div class="input-group">
								<span class="input-group-addon"><img alt="image" src="img/icon/pw_icon.png" /></span>
								<input type="password" class="form-control" id="login_pass" name="login_pass" placeholder="Password">
							</div>
						</div>
					</div>
					<!--Password 끝-->
					<!--아이디 저장-->
				  	<div class="checkbox">
						<label>
					  		<input type="checkbox" id="id_save" name="id_save" value="1"> 아이디 저장
						</label>
				  	</div>
				  	<p class="text-center" style="margin-top: 7px;">
				  		<a href="#" class="btn_passwd_reissue" style="padding-right: 20px;"><u>비밀번호 재발급</u></a>
				  		<a href="#" class="btn_passwd_change"><u>비밀번호 변경</u></a>
				  	</p>
				</div>
				<div class="space03">
					<button type="submit" class="btn btn-login block "><i class="fa fa-lock" style="font-size: 22px;"></i><br/>Login</button>
				</div>
			</form>
		</div>
	</div>
</div>
<!--비밀번호 재발급 띄우기-->
<div class="modal inmodal" id="modalPasswdReissue" tabindex="-1" role="dialog"  aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content animated fadeIn">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
				<h4 class="modal-title">비밀번호 재발급</h4>
			</div>
			<div class="modal-body">
				<h5>담당자 연락처 :</h5>
				<p><strong>홍길동 대리 / 운영팀</strong></p>
				<p><strong>Phone :</strong> +82-2-1234-5678<br/>
					<strong>Mail :</strong> lottehome@lotte.com<br/>
				</p>
			</div>
			<div class="modal-footer">
				<button type="button" name="modal_ok" class="btn btn-primary btn-sm" data-dismiss="modal"><i class="fa fa-check"></i> 확인</button>
			</div>
		</div>
	</div>
</div>
<!--비밀번호 재발급 끝-->
<!--비밀번호 팝업창 띄우기-->
<div class="modal inmodal" id="modalPasswdForm" tabindex="-1" role="dialog"  aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content animated fadeIn">
			<form id="passwdUpd" method="post">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
					<h4 class="modal-title">비밀번호 변경</h4>
				</div>
				<div class="modal-body">
					<!--table-->
					<table class="table top-line1 table-bordered2">
						<thead>
						<tr>
							<td style="width:40%;" class="table-td">상담원ID <span class="required">*</span></td>
							<td style="width:60%;"><input type="text" name="user_id" class="form-control" placeholder=""></td>
						</tr>
						</thead>
						<tr>
							<td class="table-td">현재 비밀번호 <span class="required">*</span></td>
							<td><input type="password" class="form-control" name="user_pass" placeholder=""></td>
						</tr>
						<tr>
							<td class="table-td">변경 비밀번호 <span class="required">*</span></td>
							<td><input type="password" class="form-control" name="new_pass" placeholder=""></td>
						</tr>
						<tr>
							<td class="table-td">변경 비밀번호 (재확인) <span class="required">*</span></td>
							<td><input type="password" class="form-control" name="new_pass_re" placeholder=""></td>
						</tr>
					</table>
					<!--table 끝-->
				</div>
				<div class="modal-footer">
					<button type="button" name="modal_regi" class="btn btn-primary btn-sm" prop="X"><i class="fa fa-pencil"></i> 저장</button>
					<button type="button" name="modal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>
				</div>
			</form>
		</div>
	</div>
</div>
<!--비밀번호 팝업창 띄우기 끝-->
</body>
</html>
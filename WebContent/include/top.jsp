<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%@ include file="/common/common.jsp" %><%
if(!Site.isPmss(out,"","")) return;

// cookie 변수 선언
String _TEMPLATE_COLOR	= CommonUtil.getCookieValue("ck_template_color");

Db db = null;

try {
	String url_path = request.getServletPath();
	String this_menu_id = CommonUtil.getLastUrlDir(url_path);
	String this_smenu_id = CommonUtil.getFilenameNoExt(url_path);

	if("perm".equals(this_menu_id) || "code".equals(this_menu_id)) {
		this_menu_id = "manage";
	}

	if("search_perm".equals(this_smenu_id) || "result_perm".equals(this_smenu_id)) {
		this_smenu_id = "menu_perm";
	}

	if("menu_code".equals(this_smenu_id) || "search_code".equals(this_smenu_id) || "result_code".equals(this_smenu_id) || "common_code".equals(this_smenu_id)) {
		this_smenu_id = "business_code";
	}

	db = new Db();

	Map<String, Object> argMap = new HashMap<String, Object>();
	argMap.put("business_code", _BUSINESS_CODE);
	argMap.put("user_level", _LOGIN_LEVEL);
	List<Map<String, Object>> menulist = db.selectList("menu.selectMenuPerm", argMap);

	// 1depth 메뉴
	Map<String, Map<String, Object>> mainmenu = new LinkedHashMap();
	// 2depth 메뉴
	Map<String, List<Map<String, Object>>> submenu = new LinkedHashMap();

	if(menulist.size()>0) {
		List tmplist = null;
		for(Map<String, Object> item : menulist) {
			if("1".equals(item.get("menu_depth").toString())) {
				mainmenu.put(item.get("menu_code").toString(), item);
				tmplist = new ArrayList<Map<String, Object>>();
			} else {
				tmplist.add(item);
				submenu.put(item.get("parent_code").toString(), tmplist);
			}
		}
	}
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
	<title>녹취관리 시스템</title>

	<link href="../css/smoothness/jquery-ui-1.10.4.custom.min.css" rel="stylesheet" />
	<link href="../css/bootstrap.css" rel="stylesheet" />
	<link href="../css/font-awesome.css" rel="stylesheet" />
	<link href="../css/animate.css" rel="stylesheet">
	<link href="../css/grid/pqgrid.min.css" rel="stylesheet" />
	<link href="../css/grid/office/pqgrid.css" rel="stylesheet" />
	<link href="../css/style<%=(!"".equals(_TEMPLATE_COLOR)) ? "_" + _TEMPLATE_COLOR : "" %>.css" rel="stylesheet" />

	<script type="text/javascript" src="../js/jquery-1.11.0.min.js"></script>
	<script type="text/javascript" src="../js/jquery.number.min.js"></script>
	<script type="text/javascript" src="../js/jquery.cookie.js"></script>
	<script type="text/javascript" src="../js/jquery.resize.js"></script>
	<script type="text/javascript" src="../js/bootstrap.js"></script>
	<script type="text/javascript" src="../js/jquery-ui-1.10.4.custom.min.js"></script>
	<!-- 왼쪽메뉴 하위메뉴 접혀지고 펼쳐지는 소스 -->
	<script type="text/javascript" src="../js/plugins/metisMenu/metisMenu.js"></script>
	<!-- 왼쪽메뉴 부드럽게 접히는 소스 -->
	<script type="text/javascript" src="../js/plugins/pace/pace.min.js"></script>
	<script type="text/javascript" src="../js/plugins/grid/pqgrid.min.js"></script>
	<script type="text/javascript" src="../js/site.js"></script>
	<script type="text/javascript" src="../js/common.js"></script>
	<script type="text/javascript" src="../js/commItemz.js"></script>
	<script type="text/javascript" src="../js/finals.js"></script>

	<!-- jquery 실행하는 함수 -->
	<script type="text/javascript" src="../js/total.js"></script>
</head>
<script>
var isDev = <%=Finals.isDev%>;
</script>

<body style="overflow-y: scroll;">
<!--wrapper 시작-->
<div id="wrapper">
	<!-- 왼쪽 네비게이션-->
	<nav class="navbar-default navbar-static-side" role="navigation">
		<div class="sidebar-collapse">
			<ul class="nav" id="side-menu" style="display:block;">
				<li class="nav-header">
					<div class="profile-element">녹취관리<span class="titleText">시스템</span>
					<a class="navbar-minimalize" href="#"><i class="fa fa-bars" style="float:right;padding-top:3px;"></i> </a>
					</div>
					<div class="logo-element">
					   <a class="navbar-minimalize" href="#"><i class="fa fa-bars"></i> </a>
					</div>
				</li>
			<%
			for(String key : mainmenu.keySet()) {
				String parent_code = (String) mainmenu.get(key).get("parent_code");
				String menu_name = (String) mainmenu.get(key).get("menu_name");
				String menu_icon = (String) mainmenu.get(key).get("menu_icon");
				String menu_url = (String) mainmenu.get(key).get("menu_url");

				String menu_id = CommonUtil.getLastUrlDir(menu_url);

				out.print("<li class='navBorder "+((this_menu_id.equals(menu_id)) ? "active":"")+"'>");
				out.print("<a href='#'><i class='fa "+menu_icon+" logo-element2'></i><span class='nav-span menuLabel'>"+menu_name+"</span><span class='fa arrow'></span></a>");
				out.print("<ul class='nav nav-second-level'>");

				if(submenu.get(parent_code)!=null) {
					for(int i=0;i<submenu.get(parent_code).size();i++) {
						String smenu_name = (String) submenu.get(parent_code).get(i).get("menu_name");
						String smenu_url = (String) submenu.get(parent_code).get(i).get("menu_url");
						String smenu_icon = (String) submenu.get(parent_code).get(i).get("menu_icon");

						String smenu_id = CommonUtil.getFilenameNoExt(smenu_url);
						if(!Site.isEvaluator(request) && smenu_url.indexOf(Finals.EVAL_PROGRAM)>=0){}//평가자가 아니면 평가수행 메뉴는 보이지 않게 한다.
						else out.print("<li class='"+((this_smenu_id.equals(smenu_id)) ? "active":"")+"'><a href='../"+smenu_url+"'><i class='fa "+smenu_icon+"'></i>"+smenu_name+"</a></li>");
					}

				}

				out.print("	</ul>");
				out.print("</li>");
			}
			%>
			</ul>
		</div>
	</nav>
	<!-- 왼쪽 네비게이션 끝-->

	<!--page-wrapper 컨텐츠영역-->
	<div id="page-wrapper" class="white-bg" >
		<!--top영역-->
		<div class="row topWrapper">
			<div class="topLeft" style='padding:2px 0 2px 6px'><%=Finals.MAIN_TITLE_TOP%></div>
			<div class="topRight">
				<div class="dropdown">
						<a data-toggle="dropdown" class="dropdown-toggle" href="#">
						<span class="text-muted2"><%=_LOGIN_NAME %> [<%=session.getAttribute("login_level_name") %>] 님<b class="caret"></b></span></a>
						<ul class="dropdown-menu animated fadeInRight m-t-xs" style="width: 190px;">
							<li>최종 로그인 정보</li>
							<li>일시 : <span style="color:#4f7cbd;"><%=session.getAttribute("login_datm") %></span></li>
							<li>아이피 : <span style="color:#4f7cbd;"><%=session.getAttribute("login_ip") %></span></li>
							<li class="divider"></li>
							<!--<span><a href="#none" data-toggle="modal" data-target="#modalPasswdForm"><i class="fa fa-user"></i> 비밀번호 변경</a>
								<!--비밀번호 팝업창 띄우기-->
								<!--<div class="modal inmodal" id="modalPasswdForm" tabindex="-1" role="dialog"  aria-hidden="true">
									<div class="modal-dialog">
										<div class="modal-content animated fadeIn">
											<form id="passwdUpd">
												<div class="modal-header">
													<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
													<h4 class="modal-title">비밀번호 변경</h4>
												</div>
												<div class="modal-body">
													<!--table-->
													<!--<table class="table top-line1 table-bordered2">
														<thead>
														<tr>
															<td style="width:40%;" class="table-td">상담원ID <span class="required">*</span></td>
															<td style="width:60%;"><input type="text" name="user_id" class="form-control" placeholder="" value="<%=_LOGIN_ID%>" readonly="readonly"></td>
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
													<!--<p class="bg-info" style="padding: 10px;">
														1. ID를 PW로 사용금지<br/>
														2. 10자리 이상<br/>
														3. 특정 특수문자 사용금지 [ " % ' : ; < = >]<br/>
														4. 연속된 동일문자(숫자) 사용금지<br/>
														5. 영문/숫자/특수문자 중 2가지 이상 조합<br/>
														6. 직전 패스워드 사용금지<br/>
													</p>
												</div>
												<div class="modal-footer">
													<button type="button" name="modal_regi" class="btn btn-primary btn-sm" prop="U"><i class="fa fa-pencil"></i> 저장</button>
													<button type="button" name="modal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>
												</div>
											</form>
										</div>
									</div>
								</div>
								<!--비밀번호 팝업창 띄우기 끝-->
							<!--</span>-->
							<span style="padding-left:10px;"><a href="../logout.jsp"><i class="fa fa-sign-out"></i> Logout</a></span>
						</ul>
					</div>
			</div>
		</div>
		<!--top영역 끝-->
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
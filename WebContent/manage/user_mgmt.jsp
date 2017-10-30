<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_mgmt","")) return;
%>
<jsp:include page="../include/top.jsp" flush="false"/>
<link rel="stylesheet" href="../css/tree/default/style.css" />
<script type="text/javascript" src="../js/plugins/tree/jstree.min.js"></script>
<script type="text/javascript">
$(function () {
	//tree
	var tree = $("#tree").jstree({
		"core" : {
			"data" : {
				"url": "../common/get_user_group_tree.jsp",
				"dataType": "json",
			},
			"themes" : {
				"variant" : "small"
			}
		},
		"types" : {
			"depth0" : {
				"icon" : "../img/tree_root.gif",
			},
			"depth1" : {
				"icon" : "../img/tree_depth1_close.gif"
			},
			"depth2" : {
				"icon" : "../img/tree_depth2_close.gif"
			},
			"depth3" : {
				"icon" : "../img/tree_depth3_close.gif"
			}
		},
		"plugins" : ["types"]
	});

	tree.bind("loaded.jstree", function() {
		tree.jstree("open_all");
		tree.jstree("select_node", "ul>li:first-child");
	});

	// tree 클릭 시
	tree.bind("select_node.jstree", function(obj, data) {
		//tree node를 클릭하면 해당하는 grid load
		var url = "";
		var param = { type: data.node.type, part_code: data.node.id };
		switch(data.node.type) {
			case "depth0":
			case "depth1":
			case "depth2":
				url = "user_group.jsp";
				break;
			case "depth3":
				url = "user_list.jsp";
				break;
		}

		$("#outer_grid").load(url, param, function(response, status, xhr){
			if(status=="error") {
				$(this).html("데이터를 가져오는데 실패했습니다. [" + xhr.status + " : " + xhr.statusText + "]");
			}
		});
	});
/*
	// 조직도 관리 클릭 시 최초 데이터 로드 (첫번째 업무코드에 해당하는 대분류 조회)
	$("#outer_grid").load("user_group.jsp", {}, function(response, status, xhr){
		if(status=="error") {
			$(this).html("데이터를 가져오는데 실패했습니다. [" + xhr.status + " : " + xhr.statusText + "]");
		}
	});
*/
	// 상담원 조회
	$("#outer_search button[name=btn_search]").click(function(){
		var param = {};
		param.user_id = $("#outer_search input[name=user_id]").val();
		param.user_name = $("#outer_search input[name=user_name]").val();
		param.local_no = $("#outer_search input[name=local_no]").val();

		if(getJsonValCnt(param)<1) {
			alert("조회 조건을 하나 이상 입력해 주십시오.");
			return false;
		}

		$("#outer_grid").load("user_list.jsp", param, function(response, status, xhr){
			if(status=="error") {
				$(this).html("데이터를 가져오는데 실패했습니다. [" + xhr.status + " : " + xhr.statusText + "]");
			}
		});
	});
});
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>조직도 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 관리</a></li>
			 <li class="active"><strong>조직도 관리</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->

	<!--wrapper-content영역-->
	<div class="wrapper-content" style="overflow: auto;">
		<!--class contentArea 시작-->
		<div class="contentArea">
			<!--treeDiv1 시작-->
			<div id="treeDiv1">
				<!--ibox 시작-->
				<div class="ibox">
					<form id="outer_search">
						<!--검색조건 영역-->
						<div class="ibox-content contentRadius1">
							<div id="selectDiv1">
								<div id="labelDiv">
									<label class="simple_tag">상담원ID</label><input type="text" class="form-control input_form1" name="user_id" placeholder="">
								</div>
								<div id="labelDiv">
									<label class="simple_tag">상담사명</label><input type="text" class="form-control input_form1" name="user_name" placeholder="">
								</div>
								<div id="labelDiv">
									<label class="simple_tag">내선번호</label><input type="text" class="form-control input_form1" name="local_no" placeholder="">
								</div>
							 </div>
						</div>
						<!--검색조건 영역 끝-->
						<!--유틸리티 버튼 영역-->
						<div class="contentRadius2">
							<!--ibox 접히기, 설정버튼 영역-->
							<div class="ibox-tools">
								<a class="collapse-link">
									<button type="button" class="btn btn-default btn-sm"><i class="fa fa-chevron-up"></i></button>
								</a>
							</div>
							<!--ibox 접히기, 설정버튼 영역 끝-->
							<div style="float:right">
								<!--<button type="button" name="btn_excel_regi" class="btn btn-success btn-sm"><i class="fa fa-file-excel-o"></i> 엑셀등록</button>-->
								<button type="button" name="btn_search" class="btn btn-primary btn-sm"><i class="fa fa-search"></i> 조회</button>
							</div>
						</div>
						<!--유틸리티 버튼 영역 끝-->
					</form>
				</div>
				<!--ibox 끝-->
				<!--업무 구분-->
				<div class="selectRadius1">조직도</div>
				<div class="selectRadius2" style="background-color: #FFF;">
					<!-- 사용자 그룹 tree -->
					<div id="tree"></div>
					<!-- 사용자 그룹 끝 -->
				</div>
				<!--업무 구분 끝-->
			</div>
			<!--treeDiv1 끝-->
			<!--Data table 영역-->
			<div id="treeDiv2">
				<!--grid 영역-->
				<div id="outer_grid"></div>
				<!--grid 영역 끝-->
			</div>
			<!--Data table 영역 끝-->
		</div>
		<!--class contentArea 끝-->
	</div>
	<!--wrapper-content영역 끝-->

<%@ include file="../include/bottom.jsp" %>

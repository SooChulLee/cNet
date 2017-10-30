<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"item","")) return;

	try {
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<link rel="stylesheet" href="../css/tree/default/style.css" />
<script type="text/javascript" src="../js/plugins/tree/jstree.min.js"></script>
<script type="text/javascript">
$(function () {
	//tree
	var tree = $("#tree").jstree({
		"core" : {
			"data" : {
				"url": "/common/get_eval_cate_tree.jsp",
				"data": "use_yn=1",
				"dataType": "json",
			},
			"themes" : {
				"variant" : "medium"
			}
		},
		"types" : {
			"depth1" : {
				"icon" : "../img/tree_depth1_close.gif"
			},
			"depth2" : {
				"icon" : "jstree-file"
			}
		},
		"plugins" : ["types"]
	});

	tree.bind("loaded.jstree", function() {
		tree.jstree("open_all");
		tree.jstree("select_node", "ul>li:first-child ul>li:first-child");
	});

	// tree 클릭 시
	var selected_cate_code = "";
	tree.bind("select_node.jstree", function(obj, data) {
		//tree node를 클릭하면 해당하는 grid load
		if(data.node.type!="depth1") {
			var obj = $("#outer_list");

			var cate_code = data.node.id;
			var selected_index = (selected_cate_code!=cate_code) ? "0" : obj.attr("idx");
			var selected_code = (selected_cate_code!=cate_code) ? "" : obj.attr("prop");

			var url = "item_list.jsp";
			var param = { cate_code: cate_code, selected_index: selected_index, selected_code: selected_code };

			// 바로 직전에 선택한 카테고리 코드 저장
			selected_cate_code = cate_code;

			$("#outer_list").load(url, param, function(response, status, xhr){
				if(status=="error") {
					$(this).html("데이터를 가져오는데 실패했습니다. [" + xhr.status + " : " + xhr.statusText + "]");
				}
			});
		}
	});
});
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>항목 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 시트 관리</a></li>
			 <li class="active"><strong>항목 관리</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->

	<!--wrapper-content영역-->
	<div class="wrapper-content">
		<!--class conSize 시작-->
		<div class="conSize">
			<!--평가 카테고리 트리메뉴 시작-->
			<div id="frameDiv1">
				<div class="categoryFrame1">
				<h5>평가 카테고리</h5>
				</div>
				<div class="categoryFrame2">
					<!-- 카테고리 tree -->
					<div id="tree"></div>
					<!-- 카테고리 tree 끝 -->
				</div>
			</div>
			<!--평가 카테고리 트리메뉴 끝-->

			<!--컨텐츠 영역 시작-->
			<div id="frameDiv3">
				<!--리스트 영역-->
				<div id="outer_list" idx="0" prop=""></div>
				<!--리스트 영역 끝-->
			</div>
			<!--컨텐츠 영역 끝-->

		</div>
		<!--class conSize 끝-->

	</div>
	<!--wrapper-content영역 끝-->

<jsp:include page="/include/bottom.jsp"/>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {

	}
%>

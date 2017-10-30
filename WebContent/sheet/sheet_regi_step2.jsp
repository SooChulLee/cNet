<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"sheet","")) return;

	try {
		// 세션 데이터
		String _SHEET_REGI_DATA = (String) session.getAttribute("sheet_regi_data");

		if(!CommonUtil.hasText(_SHEET_REGI_DATA)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("ERR_WRONG"),"sheet_regi_step1.jsp","url"));
		}

		// 1단계에서 선택한 카테고리 코드목록 추출
		JSONParser jsonParser = new JSONParser();
		JSONObject jsonObj = (JSONObject) jsonParser.parse(_SHEET_REGI_DATA);
		JSONArray jsonArr = (JSONArray) jsonObj.get("cate");
		JSONArray jsonItemArr = (JSONArray) jsonObj.get("item");

		// 선택된 카테고리가 없다면 에러 처리
		if(jsonArr==null) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("ERR_WRONG"),"sheet_regi_step1.jsp","url"));
		}

		// 선택된 카테고리 코드 리스트 변수 생성
		String cate_codes = "";
		for(int i=0; i<jsonArr.size(); i++){
			JSONObject jsonItem = (JSONObject) jsonArr.get(i);

			cate_codes += "," + jsonItem.get("code");
		}
		cate_codes = cate_codes.substring(1);

		// 등록된 평가 항목 건수
		int regi_item_cnt = (jsonItemArr!=null) ? jsonItemArr.size() : 0;
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<link rel="stylesheet" href="../css/tree/default/style.css" />
<script type="text/javascript" src="../js/plugins/tree/jstree.min.js"></script>
<script type="text/javascript">
var tree;
// 평가항목 등록건수
var regi_item_cnt = <%=regi_item_cnt%>;

$(function () {
	//tree
	tree = $("#tree").jstree({
		"core" : {
			"data" : {
				"url": "/common/get_eval_cate_tree.jsp",
				"data": "cate_codes=<%=cate_codes%>&use_yn=1",
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

	// tree checkbox 선택/해제 시
	tree.bind("select_node.jstree", function(obj, data) {
		if(data.node.type!="depth1") {
			var cate_code = data.node.id;

			// 초기화
			$("#item_list").html("<tr><td colspan=\"2\">등록된 평가 항목이 없습니다.</td></tr>");
			$("#selected_item_list").html("<tr><td colspan=\"3\">선택된 평가 항목이 없습니다.</td></tr>");

			// 카테고리 코드 설정
			$("#item_list").attr("cate_code", cate_code);

			$.ajax({
				type: "POST",
				url: "remote_sheet_regi.jsp",
				async: false,
				data: "step=step2&cate_code="+cate_code+"&item_depth=1",
				dataType: "json",
				success:function(dataJSON){
					if(dataJSON.code=="ERR") {
						alert(dataJSON.msg);
						return false;
					} else {
						// 카테고리별 평가항목 목록
						var html = "";
						if(dataJSON.item!=undefined && dataJSON.item.length>0) {
							var odd = "";
							for(var i=0;i<dataJSON.item.length;i++) {
								odd = (i%2==1) ? " odd" : "";
								html += "<tr class=\"item_row"+odd+"\">";
								html += "	<td><input type=\"checkbox\" name=\"item_code\" value=\""+dataJSON.item[i].item_code+"\" checked=\"checked\"></td>";
								html += "	<td class=\"t-left\"><span class=\"txt_item_name\">"+dataJSON.item[i].item_name+"</span></td>";
								html += "</tr>";
							}
							$("#item_list").html(html);
						}

						// 선택한 평가항목 목록
						html = "";
						if(dataJSON.selitem!=undefined && dataJSON.selitem.length>0) {
							var odd = "";
							for(var i=0;i<dataJSON.selitem.length;i++) {
								if(dataJSON.selitem[i].cate_code==cate_code) {
									odd = (i%2==1) ? " odd" : "";
									html += "<tr class=\"selected_item_row"+odd+"\">";
									html += "	<td><input type=\"checkbox\" name=\"selected_item_code\" value=\""+dataJSON.selitem[i].code+"\" checked=\"checked\"></td>";
									html += "	<td class=\"t-left\"><span class=\"txt_selected_item_name\">"+dataJSON.selitem[i].name+"</span></td>";
									html += " 	<td><a href=\"#none\" onclick=\"checkItem('delete','"+dataJSON.selitem[i].code+"');\"><i class=\"fa fa-trash-o fontIcon\"></i></a></td>";
									html += "</tr>";
								}
							}

							if(html!="") {
								$("#selected_item_list").html(html);
							}
						}
					}
				},
				error:function(req,status,err){
					alertJsonErr(req,status,err);
					return false;
				}
			});
		}
	});

	// 이전 버튼 클릭
	$("#regi button[name=btn_prev]").click(function() {
		location.replace("sheet_regi_step1.jsp");
	});

	// 다음 버튼 클릭
	$("#regi button[name=btn_next]").click(function() {
		if(regi_item_cnt<1) {
			alert("평가 항목을 하나 이상 선택해 주십시오.");
			return;
		}
		location.replace("sheet_regi_step3.jsp");
	});

	// 전체 선택
	$("button[name=btn_check_all]").click(function() {
		checkObject($("#regi input[name=item_code]"), true);
	});

	// 전체 선택해제
	$("button[name=btn_uncheck_all]").click(function() {
		checkObject($("#regi input[name=selected_item_code]"), true);
	});

	// 전체선택,선택,전체선택해제,선택해제 버튼 클릭
	$("button[name=btn_check_all], button[name=btn_check], button[name=btn_uncheck_all], button[name=btn_uncheck]").click(function() {
		var step = ($(this).attr("name").indexOf("uncheck")>-1) ? "delete" : "insert";

		checkItem(step, "");
	});

	// 취소버튼 클릭
	$("button[name=btn_cancel]").click(function() {
		checkItem("reset", "");
	});
});

var checkItem = function(proc, item_code) {
	var item_list = [];
	var cate_code = $("#item_list").attr("cate_code");

	if(proc!="reset") {
		var prefix = (proc!="insert") ? "selected_" : "";

		if(item_code!="") {
			item_list.push({
				cate_code: cate_code,
				code: item_code,
				name: ""
			});
		} else {
			$("#regi input[name="+prefix+"item_code]").each(function(idx){
				if($(this).prop("checked")) {
					var tmp = {
						cate_code: cate_code,
						code: $(this).val(),
						name: $(".txt_"+prefix+"item_name").eq(idx).html()
					};
					item_list.push(tmp);
				}
			});
		}

		if(item_list.length<1) {
			alert("평가 항목을 하나 이상 선택해 주십시오.");
			return;
		}

		if(proc=="insert") {
			regi_item_cnt += item_list.length;
		} else {
			regi_item_cnt -= item_list.length;
		}
	} else {
		regi_item_cnt = 0;
	}

	$.ajax({
		type: "POST",
		url: "remote_sheet_regi_proc.jsp",
		async: false,
		data: "step=step2&proc="+proc+"&item_list="+JSON.stringify(item_list),
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code=="OK") {
				// data reload
				tree.jstree("deselect_all");
				tree.jstree("select_node", cate_code);
				return true;
			} else {
				alert(dataJSON.msg);
				return false;
			}
		},
		error:function(req,status,err){
			alertJsonErr(req,status,err);
			return false;
		}
	});
};
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>시트 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 시트 관리</a></li>
			 <li>시트 관리</li>
			 <li>시트 등록</li>
			 <li class="active"><strong>단계 2</strong></li>
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
				<form id="regi">
					<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">평가 항목 등록</h5>
					<!--table-->
					<table class="table top-line1 table-bordered tt">
						<thead>
							<tr>
								<th style="width:60px;">선택</th>
								<th>평가 항목</th>
							</tr>
						</thead>
						<tbody id="item_list" cate_code="">
						</tbody>
					</table>
					<!--table 끝-->

					<!--버튼들-->
					<ul class="buttonDiv4 colCenter">
						<li><button type="button" name="btn_check_all" class="btn btn-default btn-sm"><i class="fa fa-angle-double-down"></i></button></li>
						<li><button type="button" name="btn_check" class="btn btn-default btn-sm r-space"><i class="fa fa-angle-down"></i></button></li>
						<li><button type="button" name="btn_uncheck_all" class="btn btn-default btn-sm"><i class="fa fa-angle-double-up"></i></button></li>
						<li><button type="button" name="btn_uncheck" class="btn btn-default btn-sm"><i class="fa fa-angle-up"></i></button></li>
					</ul>
					<!--버튼들 끝-->

					<!--table-->
					<table class="table top-line1 table-bordered tt">
						<thead>
							<tr>
								<th style="width:60px;">선택</th>
								<th>평가 항목</th>
								<th style="width:60px;">삭제</th>
							</tr>
						</thead>
						<tbody id="selected_item_list">
							<tr>
								<td colspan="3">선택된 평가 항목이 없습니다.</td>
							</tr>
						</tbody>
					</table>
					<!--table 끝-->
					<div class="colLeft">
						<button type="button" name="btn_prev" class="btn btn-default btn-sm"><i class="fa fa-caret-left"></i> 이전</button>
						<button type="button" name="btn_next" class="btn btn-search btn-sm"><i class="fa fa-caret-right"></i> 다음</button>
					</div>
					<div class="colRight">
						<button type="button" name="btn_cancel" class="btn btn-default btn-sm"><i class="fa fa-times"></i> 취소</button>
					</div>
				</form>
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

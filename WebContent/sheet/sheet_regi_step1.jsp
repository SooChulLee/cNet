<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"sheet","")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String sheet_code = CommonUtil.getParameter("sheet_code", CommonUtil.ifNull((String) session.getAttribute("sheet_sheet_code")));
		String proc = "";

		if(!"".equals(sheet_code)) {
			// 수정
			proc = "update";

			int used_cnt = db.selectOne("event.selectUsedSheetCnt", sheet_code);
			if(used_cnt>0) {
				out.print(CommonUtil.getPopupMsg("해당 시트를 사용하는 이벤트가 있습니다. 수정하실 수 없습니다.","sheet.jsp","url"));
			}
		} else {
			// 신규 등록
			proc = "insert";
			// 입력 데이터 세션 삭제
			session.removeAttribute("sheet_sheet_code");
			session.removeAttribute("sheet_regi_data");
		}
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<link rel="stylesheet" href="../css/tree/default/style.css" />
<script type="text/javascript" src="../js/plugins/tree/jstree.min.js"></script>
<script type="text/javascript">
var tree;
var proc = "<%=proc%>";
var sheet_code = "<%=sheet_code%>";

$(function () {
	//tree
	tree = $("#tree").jstree({
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
		"checkbox" : {
			  "keep_selected_style" : false,
			  "tie_selection" : false,
			  "three_state" : true
		},
		"types" : {
			"depth1" : {
				"icon" : "../img/tree_depth1_close.gif"
			},
			"depth2" : {
				"icon" : "jstree-file"
			}
		},
		"plugins" : ["checkbox","types"]
	});

	tree.bind("loaded.jstree", function() {
		tree.jstree("open_all");
	});

	// tree checkbox 선택/해제 시
	tree.bind("check_node.jstree check_all.jstree uncheck_node.jstree uncheck_all.jstree", function(obj, data) {
		var chkData = tree.jstree("get_checked", true);
		var html = "";

		// 초기화
		$("#cate_list").html("");

		if(chkData.length>0) {
			var odd = "";
			var n = 0;
			for(var i=0;i<chkData.length;i++) {
				if(chkData[i].parent!="#") {
					odd = (n%2==1) ? " odd" : "";

					html += "<tr class=\"cate_row"+odd+"\" prop=\"" + chkData[i].id + "\">";
					html += "<td><input type=\"checkbox\" name=\"cate_code\" value=\"" + chkData[i].id + "\" checked=\"checked\" /></td>";
					html += "<td class=\"t-left\">" + $("#tree #" + chkData[i].parent + "_anchor").text() + " > " + chkData[i].text + "</td>";
					html += "<td><a href=\"#none\" onclick=\"uncheckCate('" + chkData[i].id + "');\"><i class=\"fa fa-trash-o fontIcon\"></i></a></td>";
					html += "</tr>";

					n++;
				}
			}
		} else {
			html = "<tr><td colspan=\"3\">선택된 평가 카테고리가 없습니다.</td></tr>";
		}

		$("#cate_list").html(html);
	});

	// 다음 버튼 클릭
	$("#regi button[name=btn_next]").click(function() {
		if(!$("input[name=sheet_name]").val().trim()) {
			alert("시트 명을 입력해 주십시오.");
			$("input[name=sheet_name]").focus();
			return false;
		}
		if(!getCheckedValue($("#regi input[name=cate_code]"))) {
			alert("카테고리를 선택해 주십시오.");
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_sheet_regi_proc.jsp",
			async: false,
			data: "step=step1&cate_codes="+getCheckedValue($("#regi input[name=cate_code]"))+"&"+$("#regi").serialize(),
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					location.replace("sheet_regi_step2.jsp");
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
	});

	// 전체선택 버튼 클릭
	$("button[name=btn_check_all]").click(function() {
		checkAllCate();
	});

	// 취소 버튼, 전체 선택해제 버튼 클릭
	$("#regi button[name=btn_cancel], button[name=btn_uncheck_all]").click(function() {
		uncheckAllCate();
	});

	// 기존 데이터 로딩
	loadData(proc);
});

// 기존 데이터 로딩
var loadData = function(proc) {
	if(proc=="update") {
		$.ajax({
			type: "POST",
			url: "remote_sheet_regi.jsp",
			async: false,
			data: "step=step1&sheet_code="+sheet_code,
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code=="ERR") {
					alert(dataJSON.msg);
					return false;
				} else {
					if(dataJSON.cate_code!="") {
						tree.bind("loaded.jstree", function() {
							tree.jstree(true).check_node(dataJSON.cate_code);
						});
					}
					$("#regi input[name=sheet_name]").val(dataJSON.sheet_name);
					$("#regi select[name=use_yn]").val(dataJSON.use_yn);
				}
			},
			error:function(req,status,err){
				alertJsonErr(req,status,err);
				return false;
			}
		});
	}
}

// 체크해제
var uncheckCate = function(cate_id) {
	tree.jstree("uncheck_node", cate_id);
};

//전체 선택
var checkAllCate = function() {
	tree.jstree("check_all");
};

// 전체 체크해제
var uncheckAllCate = function() {
	tree.jstree("uncheck_all");
};
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>시트 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 시트 관리</a></li>
			 <li>시트 관리</li>
			 <li>시트 등록</li>
			 <li class="active"><strong>단계 1</strong></li>
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

			<!--버튼들-->
			<ul class="buttonDiv1">
				<li><button type="button" name="btn_check_all" class="btn btn-default btn-sm b-t"><i class="fa fa-angle-double-right"></i> </button></li>
				<li><button type="button" name="btn_uncheck_all" class="btn btn-default btn-sm b-t"><i class="fa fa-angle-double-left"></i> </button></li>
			</ul>
			<!--버튼들 끝-->

			<!--컨텐츠 영역 시작-->
			<div id="frameDiv4">
				<form id="regi">
					<!--평가 카테고리 등록-->
					<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">평가 카테고리 등록</h5>
					<div class="tableRadius4 t-space">
						<div id="listDiv3">
							<div id="labelDiv">
								<label class="simple_tag">시트 명</label><input type="text" class="form-control list_form1" id="" name="sheet_name" placeholder="">
							</div>
						</div>

						<div id="listDiv4">
							<div id="labelDiv">
								<label class="simple_tag">사용 여부</label>
								<select class="form-control list_form2" name="use_yn">
									<option value="1">사용</option>
									<option value="0">사용안함</option>
								</select>
							</div>
						</div>
					</div>
					<!--평가 카테고리 등록 끝-->

					<!--table-->
					<table class="table top-line1 table-bordered tt">
						<thead>
							<tr>
								<th style="width:60px;">선택</th>
								<th>평가 카테고리</th>
								<th style="width:60px;">삭제</th>
							</tr>
						</thead>
						<tbody id="cate_list">
							<tr>
								<td colspan="3">선택된 평가 카테고리가 없습니다.</td>
							</tr>
						</tbody>
					</table>
					<!--table 끝-->
					<div class="colRight">
						<button type="button" name="btn_next" class="btn btn-search btn-sm"><i class="fa fa-caret-right"></i> 다음</button>
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
		if(db!=null) db.close();
	}
%>

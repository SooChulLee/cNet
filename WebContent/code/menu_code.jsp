<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"business_code","")) return;

	Db db = null;

	try {
		db = new Db(true);

		// user_level list
		String _parent_code = "USER_LEVEL";

		List<Map<String, Object>> user_level_list = db.selectList("code.selectCodeList", _parent_code);
		String col_user_level = "";

		if(user_level_list.size()>0) {
			for(Map<String, Object> item : user_level_list) {
				col_user_level += ",{'" + item.get("comm_code") + "':'" + item.get("code_name") + "'}";
			}
			col_user_level = col_user_level.substring(1);
		}
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
$(function () {
	var colModel = [
		{ title: "업무구분", width: 100, dataIndx: "business_name", editable: false },
		{ title: "메뉴코드", width: 100, dataIndx: "menu_code", editable: false,
			render: function(ui) {
				return ((ui.rowData["menu_depth"]=="2") ? "----- " : "") + ui.rowData["menu_code"];
			},
		},
		{ title: "메뉴명", width: 150, dataIndx: "menu_name",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			],
		},
		{ title: "상위메뉴", width: 100, dataIndx: "parent_name", editable: false },
		{ title: "URL", width: 200, dataIndx: "menu_url",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			],
		},
		{ title: "아이콘", width: 100, dataIndx: "menu_icon" },
		{ title: "비고", width: 200, dataIndx: "menu_etc" },
		{ title: "등급", width: 100, dataIndx: "user_level",
			editor: {
				type: 'select',
				options: [<%=col_user_level%>]
			},
			render: function(ui) {

				var options = ui.column.editor.options,
					cellData = ui.cellData;
				for (var i = 0; i < options.length; i++) {
					var option = options[i];
					if (option[cellData]) {
						return option[cellData];
					}
				}

			},
		},
		{ title: "노출순서", width: 80, dataIndx: "order_no",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
				{ type: "regexp", value: /^[0-9]*$/, msg: "숫자로만 입력 가능합니다." },
			],
		},
		{ title: "사용여부", width: 80, dataIndx: "use_yn",
			editor: {
				type: 'select',
				options: fn.usedCode.colModel
			},
			render: function(ui) {

				var options = ui.column.editor.options,
					cellData = ui.cellData;
				for (var i = 0; i < options.length; i++) {
					var option = options[i];
					if (option[cellData]) {
						return option[cellData];
					}
				}

			},
		},
		{ title: "삭제", width: 40, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_delete.png' class='btn_delete'/>";
			}
		}
	];

	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		sorting: "local",
		//sortIndx: ["business_name", "order_no"],
		//sortDir: ["down","up"],
		recIndx: "row_id"
	});

 	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("menu_code", "N", "N", "Y", "Y");
	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		scrollModel: { autoFit: true },
		numberCell:{resizable:true, title:"#"},
	});

	$grid = $("#grid").pqGrid(obj);

	// 메뉴코드 등록폼 오픈시
	$("#modalRegiForm").on("show.bs.modal", function(e) {
		// 업무 구분
		$.ajax({
			type: "POST",
			url: "/common/get_business_code_list.jsp",
			async: false,
			dataType: "json",
			success:function(dataJSON){
				$("#regi select[name=business_code]").html("");

				if(dataJSON.code!="ERR") {
					if(dataJSON.data.length>0) {
						var html = "";
						for(var i=0;i<dataJSON.data.length;i++) {
							html += "<option value='" + dataJSON.data[i].business_code + "'>" + dataJSON.data[i].business_name + "</option>";
						}
						$("#regi select[name=business_code]").append(html);

						// 1번째 업무코드에 해당하는 상위메뉴 조회
						getParentMenu(dataJSON.data[0].business_code);
					} else {
						alert("업무 구분 데이터가 없습니다.");
						return false;
					}
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
<%
		//사용자 등급
		String opt_user_level = "";
		for(Map<String, Object> item : user_level_list) {
			opt_user_level += "<option value='" + item.get("comm_code") + "'>" + item.get("code_name") + "</option>";
		}
%>
		$("#regi select[name=user_level]").html("");
		$("#regi select[name=user_level]").append("<%=opt_user_level%>");
	});

	// 업무구분 변경 시 해당 업무에 해당하는 상위메뉴 조회
	$("#regi select[name=business_code]").change(function(){
		getParentMenu($(this).val());
	});

	// 상위메뉴 조회 함수
	var getParentMenu = function(business_code) {
		$.ajax({
			type: "POST",
			url: "/common/get_menu_code_list.jsp",
			data: "business_code="+business_code+"&menu_depth=1",
			async: false,
			dataType: "json",
			success:function(dataJSON){
				$("#regi select[name=parent_code]").html("<option value='_parent'>상위메뉴 없음</option>");

				if(dataJSON.code!="ERR") {
					if(dataJSON.data.length>0) {
						var html = "";
						for(var i=0;i<dataJSON.data.length;i++) {
							html += "<option value='" + dataJSON.data[i].menu_code + "'>" + dataJSON.data[i].menu_name + "</option>";
						}
						$("#regi select[name=parent_code]").append(html);
					} else {
						alert("상위메뉴 데이터가 없습니다.");
						return false;
					}
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

	// 메뉴 등록 저장
	$("#regi button[name=modal_regi]").click(function() {
		if(!$("input[name=menu_name]").val().trim()) {
			alert("메뉴명을 입력해 주십시오.");
			$("input[name=menu_name]").focus();
			return false;
		}
		if(!$("input[name=menu_url]").val().trim()) {
			alert("메뉴 URL을 입력해 주십시오.");
			$("input[name=menu_url]").focus();
			return false;
		}
		if(!$("input[name=menu_icon]").val().trim()) {
			alert("메뉴 아이콘을 입력해 주십시오.");
			$("input[name=menu_icon]").focus();
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_menu_code_proc.jsp",
			async: false,
			data: "step=insert&"+$("#regi").serialize(),
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					alert("정상적으로 등록되었습니다.");
					$("#modalRegiForm").modal("hide");
					$grid.pqGrid("refreshDataAndView");
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
});
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>공통코드 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 관리</a></li>
			 <li><a href="#none">공통코드 관리</a></li>
			 <li class="active"><strong>메뉴 코드</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->

	<!--wrapper-content영역-->
	<div class="wrapper-content">
		<!--탭 메뉴 영역 -->
		<div class="panel blank-panel conSize">
			<div class="panel-heading">
				<div class="panel-options">
					<ul class="nav nav-tabs">
						<li class=""><a href="business_code.jsp">업무 코드</a></li>
						<li class="active"><a href="menu_code.jsp">메뉴 코드</a></li>
						<li class=""><a href="search_code.jsp">조회 코드</a></li>
						<li class=""><a href="result_code.jsp">리스트 코드</a></li>
						<li class=""><a href="common_code.jsp">일반 코드</a></li>
					</ul>
				</div>
			</div>
		</div>
		<!--탭 메뉴 영역 끝 -->

		<!--Data table 영역-->
		<div class="contentArea" style="padding-top: 10px;">
			<!--grid 영역-->
			<div id="grid"></div>
			<!--grid 영역 끝-->
			<!--팝업창 띠우기-->
			<div class="modal inmodal" id="modalRegiForm" tabindex="-1" role="dialog"  aria-hidden="true">
				<div class="modal-dialog">
					<div class="modal-content animated fadeIn">
						<form id="regi">
							<div class="modal-header">
								<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
								<h4 class="modal-title">메뉴 코드 등록</h4>
							</div>
							<div class="modal-body" >
								<!--메뉴 코드 영역 table-->
								<table class="table top-line1 table-bordered2">
									<thead>
									<tr>
										<td style="width:40%;" class="table-td">업무 구분 <span class="required">*</span></td>
										<td style="width:60%;">
											<select class="form-control" name="business_code">
											</select>
										</td>
									</tr>
									</thead>
									<tr>
										<td class="table-td">메뉴 명 <span class="required">*</span></td>
										<td><input type="text" class="form-control" name="menu_name" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">상위 메뉴 <span class="required">*</span></td>
										<td>
											<select class="form-control" name="parent_code">
											</select>
										</td>
									</tr>
									<tr>
										<td class="table-td">메뉴 URL <span class="required">*</span></td>
										<td><input type="text" class="form-control" name="menu_url" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">메뉴 아이콘 <span class="required">*</span></td>
										<td><input type="text" class="form-control" name="menu_icon" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">비고</td>
										<td><input type="text" class="form-control" name="menu_etc" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">등급 <span class="required">*</span></td>
										<td>
											<select class="form-control" name="user_level">
											</select>
										</td>
									</tr>
									<tr>
										<td class="table-td">사용 여부 <span class="required">*</span></td>
										<td>
											<select class="form-control" name="use_yn">
												<option value="1">사용</option>
												<option value="0">사용안함</option>
											</select>
										</td>
									</tr>
								</table>
								<!--메뉴 코드 영역 table 끝-->
							</div>
							<div class="modal-footer">
								<button type="button" name="modal_regi" class="btn btn-primary btn-sm"><i class="fa fa-pencil"></i> 등록</button>
								<button type="button" name="modal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>
							</div>
						</form>
					</div>
				</div>
			</div>
			<!--팝업창 띠우기 끝-->
		</div>
		<!--Data table 영역 끝-->
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

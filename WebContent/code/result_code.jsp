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
		{ title: "코드", width: 100, dataIndx: "conf_code", editable: false	},
		{ title: "코드명", width: 120, dataIndx: "conf_name",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			],
		},
		{ title: "필드명", width: 120, dataIndx: "conf_field",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			],
		},
		{ title: "필드값", width: 120, dataIndx: "conf_value",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			],
		},
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
		{ title: "디폴트", width: 80, dataIndx: "default_used",
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
		{ title: "정렬", width: 80, dataIndx: "order_used",
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
		{ title: "비고", width: 100, dataIndx: "conf_etc" },
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
		sorting:"local",
		//sortIndx: ["business_name", "order_no"],
		//sortDir: ["down","up"],
		recIndx: "row_id"
	});

 	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("result_code", "N", "N", "Y", "Y");
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

	// 메뉴 등록 저장
	$("#regi button[name=modal_regi]").click(function() {
		if(!$("input[name=conf_name]").val().trim()) {
			alert("코드명을 입력해 주십시오.");
			$("input[name=conf_name]").focus();
			return false;
		}
		if(!$("input[name=conf_field]").val().trim()) {
			alert("필드 명을 입력해 주십시오.");
			$("input[name=conf_field]").focus();
			return false;
		}
		if(!$("input[name=conf_value]").val().trim()) {
			alert("필드 값을 입력해 주십시오.");
			$("input[name=conf_value]").focus();
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_result_code_proc.jsp",
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
			 <li class="active"><strong>리스트 코드</strong></li>
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
						<li class=""><a href="menu_code.jsp">메뉴 코드</a></li>
						<li class=""><a href="search_code.jsp">조회 코드</a></li>
						<li class="active"><a href="result_code.jsp">리스트 코드</a></li>
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
								<h4 class="modal-title">리스트 코드 등록</h4>
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
										<td class="table-td">코드 명 <span class="required">*</span></td>
										<td><input type="text" class="form-control" name="conf_name" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">필드 명 <span class="required">*</span></td>
										<td><input type="text" class="form-control" name="conf_field" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">필드 값 <span class="required">*</span></td>
										<td><input type="text" class="form-control" name="conf_value" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">등급 <span class="required">*</span></td>
										<td>
											<select class="form-control" name="user_level">
											</select>
										</td>
									</tr>
									<tr>
										<td class="table-td">디폴트 여부 <span class="required">*</span></td>
										<td>
											<select class="form-control" name="default_used">
												<option value="1">사용</option>
												<option value="0">사용안함</option>
											</select>
										</td>
									</tr>
									<tr>
										<td class="table-td">정렬 사용여부 <span class="required">*</span></td>
										<td>
											<select class="form-control" name="order_used">
												<option value="1">사용</option>
												<option value="0">사용안함</option>
											</select>
										</td>
									</tr>
									<tr>
										<td class="table-td">비고</td>
										<td><input type="text" class="form-control" name="conf_etc" placeholder=""></td>
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

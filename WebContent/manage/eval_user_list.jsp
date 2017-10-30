<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"eval_user_list","")) return;

	Db db = null;

	try {
		db = new Db(true);

		// business_code list
		List<Map<String, Object>> business_code_list = db.selectList("business.selectList");

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
<jsp:include page="../include/top.jsp" flush="false"/>
<script type="text/javascript">
$(function () {
	var colModel = [
		{ title: "순번", width: 60, dataIndx: "idx", editable: false, sortable: false },
		{ title: "업무명", width: 80, dataIndx: "business_name", editable: false },

		{ title: "대분류", width: 100, dataIndx: "bpart_name", editable: false },
		{ title: "중분류", width: 100, dataIndx: "mpart_name", editable: false },
		{ title: "소분류", width: 100, dataIndx: "spart_name", editable: false },

		{ title: "평가자 ID", width: 80, dataIndx: "user_id", editable: false },
		{ title: "비밀번호", width: 80, dataIndx: "user_pass",
			validations: [
				{ type: function(ui) {
					var msg = checkPasswd(ui.rowData["user_id"], ui.value, true);
					if(msg!="") {
						ui.msg = msg;
						return false;
					}
				}}
			],
			editor: {
				type: "textbox", attr: "type='password'"
			}
		},
		{ title: "평가자 명", width: 80, dataIndx: "user_name",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			]
		},
		{ title: "등급", width: 80, dataIndx: "user_level",
			editor: {
				type: 'select',
				options: [<%=col_user_level%>]
			},
			render: function(ui) {
				return ui.rowData["user_level_desc"];
			},
		},
		/*
		{ title: "비밀번호 사용기간", width: 80, dataIndx: "pass_chg_term",
			editor: {
				type: 'select',
				options: [{'30':'30일'}, {'60':'60일'}, {'90':'90일'}, {'0':'제한없음'}]
			},
			render: function(ui) {
				return ui.rowData["pass_chg_term_desc"];
			},
		},
		*/
		//{ title: "비밀번호 만료일자", width: 80, dataIndx: "pass_expire_date", editable: false },
		//{ title: "비밀번호 변경일자", width: 80, dataIndx: "pass_upd_date", editable: false },
		/*
		{ title: "퇴사 여부", width: 80, dataIndx: "resign_yn",
			editor: {
				type: 'select',
				options: [{'1':'퇴사'}, {'0':'재직'}]
			},
			render: function(ui) {
				return ui.rowData["resign_yn_desc"];
			},
		},
		*/
		{ title: "사용 여부", width: 80, dataIndx: "use_yn",
			editor: {
				type: 'select',
				options: fn.usedCode.colModel
			},
			render: function(ui) {
				return fn.getValue("usedCode",ui.rowData["use_yn"]);
			},
		}
		/*
		{ title: "등록일자", width: 80, dataIndx: "regi_datm", editable: false,
			render: function (ui) {
				return ui.rowData["regi_datm"].substring(0,10);
			}
		},
		*/
		/*
		{ title: "잠금해제", width: 80, editable: false, sortable: false,
			render: function (ui) {
				if(ui.rowData["lock_yn"]=="1") {
					return "<img src='../img/icon/ico_unlock.png' class='btn_unlock'/>";
				} else {
					return "";
				}
			}
		},
		*/
		/*
		{ title: "삭제", width: 40, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_delete.png' class='btn_delete'/>";
			}
		}
		*/
	];

	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		//sortIndx: "regi_datm",
		sortDir: "down",
		recIndx: "user_id"
	});

	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("eval_user_list", "Y", "Y", "Y", "Y");
	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		scrollModel: { autoFit: true },
	});

	$grid = $("#grid").pqGrid(obj);

	// 상담원 등록폼 오픈시
	$("#modalRegiForm").on("show.bs.modal", function(e) {
<%
		//업무코드
		String opt_business_code = "";
		if(business_code_list.size()>0) {
			for(Map<String, Object> item : business_code_list) {
				opt_business_code += "<option value='" + item.get("business_code") + "'>" + item.get("business_name") + "</option>";
			}
		}
%>
		$("#regi select[name=business_code]").html("");
		$("#regi select[name=business_code]").append("<%=opt_business_code%>");
<%
		//사용자 등급
		String opt_user_level = "";
		if(user_level_list.size()>0) {
			for(Map<String, Object> item : user_level_list) {
				opt_user_level += "<option value='" + item.get("comm_code") + "'>" + item.get("code_name") + "</option>";
			}
		}
%>
		$("#regi select[name=user_level]").html("");
		$("#regi select[name=user_level]").append("<%=opt_user_level%>");
	});

	// 상담원 등록 저장
	$("#regi button[name=modal_regi]").click(function() {
		if(!$("#regi input[name=user_id]").val().trim()) {
			alert("평가자 ID를 입력해 주십시오.");
			$("#regi input[name=user_id]").focus();
			return false;
		}
		if(!$("#regi input[name=user_pass]").val().trim()) {
			alert("비밀번호를 입력해 주십시오.");
			$("#regi input[name=user_pass]").focus();
			return false;
		}
		if(!checkPasswd($("#regi input[name=user_id]").val().trim(), $("#regi input[name=user_pass]").val().trim(), false)) {
			$("#regi input[name=user_pass]").focus();
			return false;
		}
		if(!$("#regi input[name=user_name]").val().trim()) {
			alert("평가자 명을 입력해 주십시오.");
			$("#regi input[name=user_name]").focus();
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_eval_user_list_proc.jsp",
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

	// 잠금해제 실행
	$grid.on("pqgridrefresh", function(event, ui) {
		$grid.find(".btn_unlock")
		.unbind("click")
		.bind("click", function (evt) {
			if (confirm("정말로 잠금해제 하시겠습니까?")) {
				var $tr = $(this).closest("tr");
				var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;
				var recIndx = $grid.pqGrid("getRecId", { rowIndx: rowIndx });

				$.ajax({
					type: "POST",
					url: "remote_eval_user_list_proc.jsp",
					async: false,
					data: "step=unlock&row_id="+recIndx,
					dataType: "json",
					success:function(dataJSON){
						if(dataJSON.code=="OK") {
							alert("정상적으로 잠금해제 되었습니다.");
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
			}
		});
	});
});
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>평가자 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 관리</a></li>
			 <li class="active"><strong>평가자 관리</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->

	<!--wrapper-content영역-->
	<div class="wrapper-content">
		<!--ibox 시작-->
		<div class="ibox">
		<form id="search">
			<!--검색조건 영역-->
			<div class="ibox-content contentRadius1 conSize">
				<div class="evaDiv1">
					<div id="labelDiv">
						<label class="simple_tag">일자</label>
						<!-- 달력 팝업 위치 시작-->
						<div class="input-group" style="display:inline-block;">
							<input type="text" name="regi_date1" class="form-control result_form1 datepicker" value="">
							<div class="input-group-btn">
								<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
							</div>
						</div>
						<!-- 달력 팝업 위치 끝-->
						<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
						<!-- 달력 팝업 위치 시작-->
						<div class="input-group" style="display:inline-block;">
							<input type="text" name="regi_date2" class="form-control result_form1 datepicker" value="">
							<div class="input-group-btn">
								<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
							</div>
						</div>
						<!-- 달력 팝업 위치 끝-->
					</div>
				</div>

				<div class="evaDiv2">
					<div id="labelDiv">
						<label class="simple_tag">평가자 ID</label><input type="text" name="user_id" class="form-control eva_form2" id="" placeholder="">
					</div>
				</div>

				<div class="evaDiv3">
					<div id="label_Div">
						<label class="simple_tag">평가자 명</label><input type="text" name="user_name" class="form-control eva_form3" id="" placeholder="">
				 	</div>
				</div>
			</div>
			<!--검색조건 영역 끝-->

			<!--유틸리티 버튼 영역-->
			<div class="contentRadius2 conSize">
				<!--ibox 접히기, 설정버튼 영역-->
				<div class="ibox-tools">
					<a class="collapse-link">
						<button type="button" class="btn btn-default"><i class="fa fa-chevron-up"></i></button>
					</a>
				</div>
				<!--ibox 접히기, 설정버튼 영역 끝-->
				<div style="float:right">
					<button type="button" name="btn_search" class="btn btn-primary btn-sm"><i class="fa fa-search"></i> 조회</button>
					<button type="button" name="btn_cancel" class="btn btn-default btn-sm"><i class="fa fa-times"></i> 취소</button>
				</div>
			</div>
			<!--유틸리티 버튼 영역 끝-->
		</form>
		</div>
		<!--ibox 끝-->

		<!--class contentArea 시작-->
		<div class="contentArea">
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
								<h4 class="modal-title">평가자 등록</h4>
							</div>
							<div class="modal-body" >
								<!--업무코드 table-->
								<table class="table top-line1 table-bordered2">
									<thead>
									<tr>
										<td style="width:40%;" class="table-td">업무 구분</td>
										<td style="width:60%; padding: 6px 9px;">
											<select class="form-control" name="business_code">
											</select>
										</td>
									</tr>
									</thead>
									<tr>
										<td class="table-td">평가자 ID</td>
										<td>
											<input type="text" name="user_id" class="form-control" id="" placeholder="">
										</td>
									</tr>
									<tr>
										<td class="table-td">비밀번호</td>
										<td>
											<input type="password" name="user_pass" class="form-control" id="" placeholder="">
										</td>
									</tr>
									<tr>
										<td class="table-td">평가자 명</td>
										<td>
											<input type="text" name="user_name" class="form-control" id="" placeholder="">
										</td>
									</tr>
									<tr>
										<td class="table-td">등급</td>
										<td>
											<select class="form-control" name="user_level">
											</select>
										</td>
									</tr>
									<tr>
										<td class="table-td">비밀번호 사용기간</td>
										<td>
											<select class="form-control" name="pass_chg_term">
												<option value="90">90일</option>
												<option value="60">60일</option>
												<option value="30">30일</option>
												<option value="0">제한없음</option>
											</select>
										</td>
									</tr>
								</table>
								<!--업무코드 table 끝-->
							</div>
							<div class="modal-footer">
								<button type="button" name="modal_regi" class="btn btn-register btn-sm"><i class="fa fa-pencil"></i> 등록</button>
								<button type="button" name="modal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>
							</div>
						</form>
					</div>
				</div>
			</div>
			<!--팝업창 띠우기 끝-->
		</div>
		<!--class contentArea 끝-->
	</div>
	<!--wrapper-content영역 끝-->

<%@ include file="../include/bottom.jsp" %>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>

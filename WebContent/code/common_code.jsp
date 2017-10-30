<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"business_code","")) return;

	Db db = null;

	try {
		db = new Db(true);
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
$(function () {
	var colModel = [
		{ title: "코드", width: 100, dataIndx: "comm_code", editable: false,
			render: function(ui) {
				return ((ui.rowData["code_depth"]=="2") ? "----- " : "") + ui.rowData["comm_code"];
			},
		},
		{ title: "코드명", width: 150, dataIndx: "code_name",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			],
		},
		{ title: "상위코드", dataIndx: "parent_code", hidden: true },
		{ title: "상위코드", width: 100, dataIndx: "parent_name", editable: false },
		{ title: "비고", width: 200, dataIndx: "code_etc" },
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
		//sortIndx: "order_no",
		//sortDir: "up",
		recIndx: "row_id"
	});

 	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("common_code", "N", "N", "Y", "Y");
	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		scrollModel: { autoFit: true },
		numberCell:{resizable:true, title:"#"},
	});

	$grid = $("#grid").pqGrid(obj);

	// 코드 등록폼 오픈시
	$("#modalRegiForm").on("show.bs.modal", function(e) {
		// 업무 구분
		$.ajax({
			type: "POST",
			url: "/common/get_common_code_list.jsp",
			data: "code_depth=1",
			async: false,
			dataType: "json",
			success:function(dataJSON){
				$("#regi select[name=parent_code]").html("<option value='_parent'>상위코드 없음</option>");

				if(dataJSON.code!="ERR") {
					if(dataJSON.data.length>0) {
						var html = "";
						for(var i=0;i<dataJSON.data.length;i++) {
							html += "<option value='" + dataJSON.data[i].comm_code + "'>" + dataJSON.data[i].code_name + "</option>";
						}
						$("#regi select[name=parent_code]").append(html);
					} else {
						alert("상위코드 데이터가 없습니다.");
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
	});

	// 코드 등록 저장
	$("#regi button[name=modal_regi]").click(function() {
		if(!$("input[name=comm_code]").val().trim()) {
			alert("코드를 입력해 주십시오.");
			$("input[name=comm_code]").focus();
			return false;
		}
		if(!$("input[name=code_name]").val().trim()) {
			alert("코드 명을 입력해 주십시오.");
			$("input[name=code_name]").focus();
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_common_code_proc.jsp",
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
			 <li class="active"><strong>일반 코드</strong></li>
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
						<li class=""><a href="result_code.jsp">리스트 코드</a></li>
						<li class="active"><a href="common_code.jsp">일반 코드</a></li>
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
								<h4 class="modal-title">일반 코드 등록</h4>
							</div>
							<div class="modal-body" >
								<!--메뉴 코드 영역 table-->
								<table class="table top-line1 table-bordered2">
									<thead>
									<tr>
										<td style="width:40%;" class="table-td">코드 <span class="required">*</span></td>
										<td style="width:60%;">
											<input type="text" class="form-control" name="comm_code" placeholder="">
										</td>
									</tr>
									</thead>
									<tr>
										<td class="table-td">코드 명 <span class="required">*</span></td>
										<td><input type="text" class="form-control" name="code_name" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">상위 코드 <span class="required">*</span></td>
										<td>
											<select class="form-control" name="parent_code">
											</select>
										</td>
									</tr>
									<tr>
										<td class="table-td">비고</td>
										<td><input type="text" class="form-control" name="code_etc" placeholder=""></td>
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

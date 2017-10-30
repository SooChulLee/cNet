<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"sheet","")) return;

	try {
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
$(function () {
	var colModel = [
		{ title: "순번", width: 60, dataIndx: "idx", editable: false, sortable: false },
		{ title: "시트 코드", width: 80, dataIndx: "sheet_code", editable: false },
		{ title: "시트 명", width: 150, dataIndx: "sheet_name",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			]
		},
		{ title: "항목 수", width: 80, dataIndx: "item_cnt", editable: false },
		{ title: "총점", width: 80, dataIndx: "tot_score", editable: false },
		{ title: "가중치", width: 80, dataIndx: "add_score", editable: false },
		{ title: "사용 여부", width: 80, dataIndx: "use_yn",
			editor: {
				type: 'select',
				options: fn.usedCode.colModel
			},
			render: function(ui) {
				return fn.getValue("usedCode",ui.rowData["use_yn"]);
			},
		},
		{ title: "등록일자", width: 80, dataIndx: "regi_datm", editable: false,
			render: function (ui) {
				return ui.rowData["regi_datm"].substring(0,10);
			}
		},
		{ title: "시트 보기", width: 60, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_view.png' class='btn_sheet_view' onclick='popSheetView(this);' style='cursor: pointer;'/>";
			}
		},
		{ title: "시트 수정", width: 60, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_edit.png' class='btn_sheet_edit' onclick='goSheetRegi(this);' style='cursor: pointer;'/>";
			}
		},
		{ title: "시트 복사", width: 60, editable: false, sortable: false, render: function (ui) {
			return "<img src='../img/icon/ico_print.png' class='btn_sheet_copy' onclick='goSheetCopy(this);' style='cursor: pointer;'/>";
			}
		},
		{ title: "엑셀", width: 40, editable: false, sortable: false, render: function (ui) {
			return "<img src='../img/icon/ico_excel.png' class='btn_excel' onclick='toExcel(this);' style='cursor: pointer;'/>";
			}
		},
		{ title: "삭제", width: 40, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_delete.png' class='btn_delete'/>";
			}
		}
	];

	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		//sortIndx: "regi_datm",
		sortDir: "down",
		recIndx: "sheet_code"
	});

	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("sheet", "Y", "N", "N", "Y");
	// toolbar button add
	baseObj.toolbar.items.push(
		{ type: "button", icon: "ui-icon-pencil", label: "시트 등록", style: "float: right; margin-right: 5px;", listeners: [{
	 			"click": function () {
	 				location.href = "sheet_regi_step1.jsp";
	 			}
			}]
		}
	);

	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		scrollModel: { autoFit: true },
	});

	$grid = $("#grid").pqGrid(obj);
});

// 시트 보기 팝업 오픈
function popSheetView(obj) {
	var $tr = $(obj).closest("tr");
	var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;
	var recIndx = $grid.pqGrid("getRecId", { rowIndx: rowIndx });
	if(recIndx!=null) {
		openPopup("sheet_view.jsp?sheet_code="+recIndx,"_sheet_view","900","600","yes","center");
	}
};

// 시트 등록페이지 이동
function goSheetRegi(obj) {
	var $tr = $(obj).closest("tr");
	var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;
	var recIndx = $grid.pqGrid("getRecId", { rowIndx: rowIndx });
	if(recIndx!=null) {
		location.href = "sheet_regi_step1.jsp?sheet_code="+recIndx;
	}
}
function goSheetCopy(obj) {
	var $tr = $(obj).closest("tr");
	var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;
	var recIndx = $grid.pqGrid("getRecId", { rowIndx: rowIndx });

	if(recIndx!=null) {
		var yn = confirm("해당시트를 복사하시겠습니까?");
		if(yn){
			$.ajax({
				type: "POST",
				url: "remote_sheet_proc.jsp",
				async: false,
				data: "step=copy&sheet_code="+recIndx,
				dataType: "json",
				success:function(dataJSON){
					if(dataJSON.code=="OK") {
						alert("복사 되었습니다.");
						search.reset();
						// 1페이지로 가야 하기 때문에 조회버튼 클릭하기
						$("#search button[name=btn_search]").click();
						//$grid.pqGrid("refreshDataAndView");;
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
	}
}
//시트 엑셀다운로드
function toExcel(obj) {
	var $tr = $(obj).closest("tr");
	var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;
	var recIndx = $grid.pqGrid("getRecId", { rowIndx: rowIndx });
	if(recIndx!=null) {
		// 엑셀 다운로드
		$("#hiddenFrame").prop("src", "excel_sheet.jsp?sheet_code="+recIndx);
	}

};
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>시트 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 시트 관리</a></li>
			 <li class="active"><strong>시트 관리</strong></li>
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
						<label class="simple_tag">시트 코드</label><input type="text" name="sheet_code" class="form-control eva_form2" id="" placeholder="">
					</div>
				</div>

				<div class="evaDiv3">
					<div id="label_Div">
						<label class="simple_tag">시트 명</label><input type="text" name="sheet_name" class="form-control eva_form3" id="" placeholder="">
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
		</div>
		<!--class contentArea 끝-->
	</div>
	<!--wrapper-content영역 끝-->

<jsp:include page="/include/bottom.jsp"/>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {

	}
%>

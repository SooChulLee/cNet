<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
// 메뉴 접근권한 체크
if(!Site.isPmss(out,"event","")) return;
try {

%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
var eval_order_max = <%=Finals.EVAL_ORDER_MAX%>;

$(function () {
	var dateEditor = function (ui) {
		var $cell = ui.$cell,
			rowData = ui.rowData,
			dataIndx = ui.dataIndx,
			cls = ui.cls,
			dc = $.trim(rowData[dataIndx]);
		$cell.css("padding", "0");

		var $inp = $("<input type='text' name='" + dataIndx + "' class='" + cls + " form-control pq-date-editor' />")
		.appendTo($cell)
		.val(dc).datepicker($.extend(dp_option, {
				dateFormat: "yymmdd",
		  		onClose: function () {
					$inp.focus();
				}
			})
		);
	}
	var orderMaxOptions = new Object();
	for(var i=1; i<=eval_order_max; i++){
		orderMaxOptions[i] = i+"차";
	}
	var colModel = [
		{ title: "순번", width: 60, dataIndx: "idx", editable: false, sortable: false },
		{ title: "이벤트 명", width: 150, dataIndx: "event_name",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			]
		},
		{ title: "시작일자", width: 100, dataIndx: "event_sdate",
			editor: {
				type: dateEditor
			},
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			]
		},
		{ title: "종료일자", width: 100, dataIndx: "event_edate",
			editor: {
				type: dateEditor
			},
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			]
		},
		{ title: "시트 명", width: 150, dataIndx: "sheet_name", editable: false },
		{ title: "내용", width: 200, dataIndx: "event_desc" },
		{ title: "평가차수", width: 80, dataIndx: "eval_order_max",
			editor: {
				type: "select",
				options: [orderMaxOptions]
			},
			render: function(ui) {
				return ui.rowData["eval_order_max"]+"차";
			},
		},
		{ title: "상태", width: 80, dataIndx: "event_status",
			editor: {
				type: 'select',
				options: fn.event_status.colModel
			},
			render: function(ui) {
				return fn.getValue("event_status",ui.rowData["event_status"]);
			},
		},
		{ title: "시트 보기", width: 70, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_view.png' class='btn_sheet_view' onclick='popSheetView("+ui.rowIndx+");' style='cursor: pointer;'/>";
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
		recIndx: "event_code"
	});

	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("event", "Y", "N", "Y", "Y");
	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		scrollModel: { autoFit: true },
	});

	$grid = $("#grid").pqGrid(obj);

	// 상담원 등록폼 오픈시
	$("#modalRegiForm").on("show.bs.modal", function(e) {
		// 시트코드 목록조회
		var arr_sheet = [];
		$.ajax({
			type: "POST",
			url: "/common/get_eval_sheet_list.jsp",
			data: "use_yn=1",
			async: false,
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code!="ERR") {
					if(dataJSON.data.length>0) {
						for(var i=0;i<dataJSON.data.length;i++) {
							var tmp = {};
							tmp[dataJSON.data[i].sheet_code] = dataJSON.data[i].sheet_name;
							arr_sheet.push(tmp);
						}
					}
				}
			},
			error:function(req,status,err){
				return;
			}
		});

		// 시트명
		var html = "<option value=''></option>";

		$.each(arr_sheet, function(idx, data) {
			$.each(data, function(key, val) {
				html += "<option value='" + key + "'>" + val + "</option>";
			});
		});

		$("#regi select[name=sheet_code]").html(html);
	});

	// 상담원 등록 저장
	$("#regi button[name=modal_regi]").click(function() {
		if(!$("#regi input[name=event_name]").val().trim()) {
			alert("이벤트 명을 입력해 주십시오.");
			$("#regi input[name=event_name]").focus();
			return false;
		}
		if(!$("#regi input[name=event_sdate]").val().trim()) {
			alert("이벤트 시작일자를 입력해 주십시오.");
			$("#regi input[name=event_sdate]").focus();
			return false;
		}
		if(!$("#regi input[name=event_edate]").val().trim()) {
			alert("이벤트 종료일자를 입력해 주십시오.");
			$("#regi input[name=event_edate]").focus();
			return false;
		}
		if(!$("#regi select[name=sheet_code]").val().trim()) {
			alert("시트 명을 선택해 주십시오.");
			$("#regi select[name=sheet_code]").focus();
			return false;
		}
		if(!$("#regi select[name=eval_order_max]").val().trim()) {
			alert("평가차수를 선택해 주십시오.");
			$("#regi select[name=eval_order_max]").focus();
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_event_proc.jsp",
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

//시트 보기 팝업 오픈
function popSheetView(rowIndx) {
	var rowData = $grid.pqGrid("getRowData", { rowIndxPage: rowIndx });

	if(rowData["sheet_code"]!=null) {
		openPopup("../sheet/sheet_view.jsp?sheet_code="+rowData["sheet_code"],"_sheet_view","900","600","yes","center");
	}
};
</script>

<!--title 영역 -->
<div class="row titleBar border-bottom2">
	<div style="float:left;"><h4>이벤트 관리</h4></div>
	<ol class="breadcrumb" style="float:right;">
		 <li><a href="#none"><i class="fa fa-home"></i> 평가 관리</a></li>
		 <li class="active"><strong>이벤트 관리</strong></li>
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
					<label class="simple_tag">진행중일자</label>
					<!-- 달력 팝업 위치 시작-->
					<div class="input-group" style="display:inline-block;">
						<input type="text" name="event_date" class="form-control result_form1 datepicker" value="">
						<div class="input-group-btn">
							<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
						</div>
					</div>
					<!-- 달력 팝업 위치 끝-->
				</div>
			</div>

			<div class="evaDiv2">
				<div id="labelDiv">
					<label class="simple_tag">이벤트 명</label><input type="text" name="event_name" class="form-control eva_form2" id="" placeholder="">
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

		<!--팝업창 띠우기-->
		<div class="modal inmodal" id="modalRegiForm" tabindex="-1" role="dialog"  aria-hidden="true">
			<div class="modal-dialog">
				<div class="modal-content animated fadeIn">
					<form id="regi">
						<div class="modal-header">
							<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
							<h4 class="modal-title">이벤트 등록</h4>
						</div>
						<div class="modal-body" >
							<!--이벤트 등록 table-->
							<table class="table top-line1 table-bordered2">
								<thead>
									<tr>
										<td style="width:25%;" class="table-td">이벤트 명</td>
										<td style="width:75%;"><input type="text" name="event_name" class="form-control" id="" placeholder=""></td>
									</tr>
								</thead>

								<tr>
									<td class="table-td">이벤트 기간</td>
									<td>
										<!-- 달력 팝업 위치 시작-->
										<div class="input-group" style="display:inline-block;">
											<input type="text" name="event_sdate" class="form-control result_form1 datepicker" value="" style="z-index: 99999;">
											<div class="input-group-btn"><button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button></div>
										</div>
										<!-- 달력 팝업 위치 끝-->
										<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
										<!-- 달력 팝업 위치 시작-->
										<div class="input-group" style="display:inline-block;">
											<input type="text" name="event_edate" class="form-control result_form1 datepicker" value="" style="z-index: 99999;">
											<div class="input-group-btn"><button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button></div>
										</div>
										<!-- 달력 팝업 위치 끝-->
									</td>
								</tr>
								<tr>
									<td class="table-td">시트 명</td>
									<td>
										<select class="form-control" name="sheet_code">
										</select>
									</td>
								</tr>
								<tr><td class="table-td">평가 차수</td>
									<td><!--input type="text" name="eval_order_max" class="form-control" id="" placeholder="" maxlength="2" style=width:100px;ime-mode:disabled; onKeyDown=chkPlusNumber(this);-->
										<select name="eval_order_max" class="form-control">
											<option value='' selected></option>
											<script>
											for(var i=1; i<=eval_order_max; i++){
												document.writeln("<option value='"+i+"'>"+i+"차</option>");
											}
											</script>
										</select>
									</td>
								</tr>
								<tr><td class="table-td">내용</td>
									<td>
										<input type="text" name="event_desc" class="form-control" id="" placeholder="" maxlength="100">
									</td>
								</tr>
							</table>
							<!--이벤트 등록 table 끝-->
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

<jsp:include page="/include/bottom.jsp"/>
<%
} catch(Exception e) {
	logger.error(e.getMessage());
} finally {

}
%>

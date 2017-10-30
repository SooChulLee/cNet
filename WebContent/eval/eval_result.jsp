<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
// 메뉴 접근권한 체크
if(!Site.isPmss(out,"eval_result","")) return;

try {
	Map<String, Object> argMap = new HashMap<String, Object>();

	//이벤트 콤보박스
	String htm_event_list = Site.getEventComboHtml("2N5");//진행중 + 마감
	if(htm_event_list.equals("")) {
		out.print(CommonUtil.getPopupMsg("진행중인 이벤트가 없습니다.","","back"));
		return;
	}

	//평가자 콤보박스
	String htm_eval_user_list = (Site.getDepthByUserLevel(_LOGIN_LEVEL)==-1) ? "" : Site.getEvaluatorComboHtml(session, true);
	String evalUserIdDisabled = (Site.getDepthByUserLevel(_LOGIN_LEVEL)==-1) ? "disabled" : "";
	//대분류 콤보박스
	String htm_bpart_list = Site.getMyPartCodeComboHtml(session, 1);
	String htm_mpart_list = Site.getMyPartCodeComboHtml(session, 2);
	String htm_spart_list = Site.getMyPartCodeComboHtml(session, 3);

	String user_name = "", user_id="", userInfoReadOnly="";
	//일반 상담원 인 경우 검색조건중 상담원 정보 자신의 정보로 홀딩

	if(_LOGIN_LEVEL.equals("E")){
		user_name = _LOGIN_NAME;
		user_id = _LOGIN_ID;
		userInfoReadOnly = "readonly";
	}

	int userViewDepth = Site.getDepthByUserLevel(_LOGIN_LEVEL);

%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
//청취/다운 사유입력 유무
var isExistPlayDownReason = <%=Finals.isExistPlayDownReason%>;
var userViewDepth = <%=userViewDepth%>;

$(function () {
	var colModel = [
		{ title: "순번", width: 80, dataIndx: "idx", sortable: false },
		{ title: "결과 순번", dataIndx: "result_seq", hidden: true },
	 	{ title: "이벤트명", width: 150, dataIndx: "event_name", sortable: false },
	 	{ title: "평가차수", width: 50, dataIndx: "eval_order_desc", sortable: false },
		<%if(userViewDepth>-1) {//사용자 권한이 조장 이상일 경우만%>
		 	{ title: "평가자명", width: 80, dataIndx: "eval_user_name" },
		<%}%>
	 	{ title: "소분류", width: 100, dataIndx: "spart_name" },
		{ title: "상담원명", width: 80, dataIndx: "user_name" },
		{ title: "평가일자", width: 100, dataIndx: "eval_date" },
	 	{ title: "녹취일시", width: 100, dataIndx: "rec_datm", sortable: false },
	 	{ title: "점수/배점", width: 80, dataIndx: "eval_score_tot_score", sortable: false,
			render: function(ui) {
				return ui.rowData["eval_score"] + "/" + ui.rowData["tot_score"];
			},
	 	},
	 	{ title: "평가상태", width: 40, dataIndx: "eval_status_desc", sortable: false,
			render: function(ui) {
				return fn.getValue("eval_status_htm",ui.rowData["eval_status"]);
			},
	 	},
		{ title: "평가", width: 40, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_view.png' class='btn_view' onclick='popEvalForm(\"regi\", "+ui.rowIndx+");' style='cursor: pointer;'/>";
			}
		},
		{ title: "듣기", width: 40, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_player.png' class='btn_player' onclick=\"playRecFile('"+ui.rowData["rec_datm"]+"', '"+ui.rowData["local_no"]+"', '"+ui.rowData["rec_filename"]+"', '"+ui.rowData["rec_keycode"]+"');\" style='cursor: pointer;'/>";
			}
		},
		{ title: "프린트", width: 40, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_print.png' class='btn_print' onclick='popEvalForm(\"print\", "+ui.rowIndx+");' style='cursor: pointer;'/>";
			}
		},
		{ title: "엑셀", width: 40, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_excel.png' class='btn_excel' onclick='excelEvalForm("+ui.rowIndx+");' style='cursor: pointer;'/>";
			}
		},
		<%if(userViewDepth>=3) {//사용자 권한이 관리자 이상일 경우만 삭제 가능%>
		{ title: "삭제", width: 40, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_delete.png' class='btn_delete' onclick='deleteEval("+ui.rowIndx+");'/>";
			}
		}
		<%}%>
	];

	//검색조건 콤보박스 수정시 자동 조회 한다.
	$("#search select").change(function(){
		$("#search button[name=btn_search]").click();
	});

	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		//sortIndx: "regi_datm",
		sortDir: "down",
		//recIndx: "result_seq"
	});

	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("eval_result", "Y", "Y", "N", "N");
	// toolbar button add
	baseObj.toolbar.items.push(
		{type:"button", icon:"ui-icon-gear", label:"등록상태 일괄 완료처리", style:"float:right; margin-right:5px;", attr:"data-toggle='modal'",  listeners:[{	"click":function() {chg2to9();}}]}
	);

	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		scrollModel: { autoFit: true },
		editable: false
	});

	obj.refresh = function (evt, ui) {
		//alert(objToStr(evt))
	}

	$grid = $("#grid").pqGrid(obj);
});

var goChg2to9 = function() {
	var param = {
		step : "chg2to9",
		event_code : $("#search select[name=event_code]").val()
	};

	$.ajax({
		type: "POST",
		url: "remote_eval_result_proc.jsp",
		data: param,
		async: false,
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code!="ERR") {
				$grid.pqGrid("refreshDataAndView");
				alert("총 "+dataJSON.cnt+"개의 평가가 등록상태에서 완료상태로 변경 되었습니다.");
			}
			else{
				alert(dataJSON.msg);
			}
		}
	});
}

//평가결과조회 팝업 오픈
function popEvalForm(step, rowIndx) {
	var rowData = $grid.pqGrid("getRowData", { rowIndxPage: rowIndx });
	if(!isPmssViewEval(rowData)) return;
	var result_seq = rowData["result_seq"];
	var event_code = rowData["event_code"];
	var eval_user_id = rowData["eval_user_id"];
	var rec_seq = rowData["rec_seq"];
	var rec_datm = rowData["rec_datm"];
	var user_id = rowData["user_id"];
	// 팝업 오픈
	var popupHeight = parseInt(screen.height)-110;
	openPopup("eval_form.jsp?step="+step+"&result_seq="+result_seq+"&event_code="+event_code+"&eval_user_id="+eval_user_id+"&rec_seq="+rec_seq+"&rec_datm="+rec_datm+"&user_id="+user_id,"_eval_form","900",popupHeight,"yes","center");
};

//평가결과조회 엑셀다운로드
function excelEvalForm(rowIndx) {
	var rowData = $grid.pqGrid("getRowData", { rowIndxPage: rowIndx });
	if(!isPmssViewEval(rowData)) return;

	var event_code = rowData["event_code"];
	var sheet_code = rowData["sheet_code"];
	var result_seq = rowData["result_seq"];

	// 엑셀 다운로드
	$("#hiddenFrame").prop("src", "excel_eval_form.jsp?event_code="+event_code+"&sheet_code="+sheet_code+"&result_seq="+result_seq);
};

// 평가결과 삭제
function deleteEval(rowIndx) {
	deleteRowByData("eval_result", rowIndx);
}
function chg2to9(){
	if($("#search select[name=event_code]").val()==""){
		alert("일괄 완료처리는 이벤트를 반드시 선택하셔야 합니다.");
		$("#search select[name=event_code]").focus();
		return;
	};
	var yn = confirm("현재 검색된 평과결과중 '등록' 상태를 모두 '완료' 처리 하시겠습니까?");
	if(yn) goChg2to9();
}
function isPmssViewEval(rowData){
	//평가상태가 완료 이하(진행/등록) 이고 일반상담원 인 경우 평가내용 볼 권한 없음;
	if(rowData["eval_status"]<"9" && userViewDepth==-1){
		alert("완료가 된 평가가 아니면 볼 권한이 없습니다!");
		return false;
	}
	return true;
}
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>평가 결과 조회</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 평가 관리</a></li>
			 <li class="active"><strong>평가 결과 조회</strong></li>
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
				<div id="resultDiv1">
					<div id="labelDiv">
						<label class="simple_tag">이벤트 명</label>
						<select class="form-control result_form3" name="event_code">
							<!-- option value="">이벤트 선택</option -->
							<%=htm_event_list%>
						</select>
					</div>
				</div>

				<div id="resultDiv2">
					<div id="labelDiv">
						<label class="simple_tag">평가일자</label>
						<!-- 달력 팝업 위치 시작-->
						<div class="input-group" style="display:inline-block;">
							<input type="text" name="eval_date1" class="form-control result_form1 datepicker">
							<div class="input-group-btn">
								<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
							</div>
						</div>
						<!-- 달력 팝업 위치 끝-->
						<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
						<!-- 달력 팝업 위치 시작-->
						<div class="input-group" style="display:inline-block;">
							<input type="text" name="eval_date2" class="form-control result_form1 datepicker">
							<div class="input-group-btn">
								<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
							</div>
						</div>
						<!-- 달력 팝업 위치 끝-->
					</div>
				</div>

				<div id="resultDiv2">
					<div id="label_Div">
						<label class="simple_tag">평가자 명</label>
						<select class="form-control result_form3" name="eval_user_id" <%=evalUserIdDisabled%>>
							<option value="">평가자 선택</option>
							<%=htm_eval_user_list%>
						</select>
				 	</div>
				</div>
				<!--1행 끝-->

				<!--2행 시작-->
				<div id="resultDiv1">
					<div id="labelDiv">
						<label class="simple_tag">조직도</label>
						<select class="form-control result_form2" name="bpart_code">
							<%=htm_bpart_list%>
						</select> :
						<select class="form-control result_form2" name="mpart_code">
							<%=htm_mpart_list%>
						</select> :
						<select class="form-control result_form2" name="spart_code">
							<%=htm_spart_list%>
						</select>
					</div>
				</div>

				<div id="resultDiv2">
					<div id="labelDiv">
						<label class="simple_tag">상담원 명</label>
						<input type="text" name="user_name" value="<%=user_name%>" class="form-control result_form3" id="" placeholder="" <%=userInfoReadOnly%>>
						<input type="hidden" name="user_id" value="<%=user_id%>">
					</div>
				</div>

				<div id="resultDiv2">
					<div id="label_Div">
						<label class="simple_tag">평가 상태</label>
						<select class="form-control result_form3" name="eval_status">
							<option value="">평가상태 선택</option>
							<%if(userViewDepth>-1) {//일반상담원은 완료이상만 볼 수 있다.%>
							<option value="1">진행중</option>
							<option value="2">등록</option>
							<%}%>
							<option value="9">완료</option>
							<option value="a">이의대기</option>
							<option value="d">이의신청</option>
						</select>
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

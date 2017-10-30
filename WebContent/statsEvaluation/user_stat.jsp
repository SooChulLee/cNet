<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
// 메뉴 접근권한 체크
if(!Site.isPmss(out,"user_stat","")) return;

Db db = null;

try {
	// DB Connection
	db = new Db(true);

	Map<String, Object> argMap = new HashMap<String, Object>();

	// 이벤트 콤보박스
	String htm_event_list = Site.getEventComboHtml("5", "eval_order_max");//2:진행중, 5:마감, 9:종료

	// 시트 콤보박스
	String htmSheetList = Site.getSheetComboHtml(argMap);

	//조직도 콤보박스
	String htm_bpart_list = Site.getMyPartCodeComboHtml(session, 1);
	String htm_mpart_list = Site.getMyPartCodeComboHtml(session, 2);
	String htm_spart_list = Site.getMyPartCodeComboHtml(session, 3);

%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
var dataModel;
var colModel = [
	{ title: "부서", width: 200, dataIndx: "part_name", render: function(ui) {
		return (ui.rowData["part_name"]) ? ui.rowData["part_name"] : ui.rowData["bpart_name"]+"<font color=gray> > </font>"+ui.rowData["mpart_name"]+"<font color=gray> > </font>"+ui.rowData["spart_name"];},
	},
	{ title: "상담원 ID", width: 100, dataIndx: "user_id" },
	{ title: "상담원 명", width: 100, dataIndx: "user_name" },
	//여기에 차수 정보 추가
	{ title: "평균점수", width: 66, align:"right", dataIndx: "avg_score", render: function(ui) {return (ui.rowData["tot_eval_cnt"]==0) ? 0 : round(ui.rowData["tot_eval_score"]/ui.rowData["tot_eval_cnt"],2);}},
	{ title: "평가수", width: 60, align:"right", dataIndx: "tot_eval_cnt", render: function(ui) {return $.number(ui.rowData["tot_eval_cnt"]);}},
	{ title: "총점", width: 40, align:"right", dataIndx: "tot_eval_score", render: function(ui) {return $.number(ui.rowData["tot_eval_score"]);}},
	{ title: "항목점수", width: 66, align:"right", dataIndx: "tot_exam_score", render: function(ui) {return $.number(ui.rowData["tot_exam_score"]);}},
	{ title: "가중치점수", width: 80, align:"right", dataIndx: "tot_add_score", render: function(ui) {return $.number(ui.rowData["tot_add_score"]);}},
	{ title: "베스트", width: 60, align:"right", dataIndx: "tot_best_cnt" },
	{ title: "워스트", width: 60, align:"right", dataIndx: "tot_worst_cnt" }
];

var evalOrderInputIdx = getIdxColModel(colModel,"user_name");

$(function () {
	var baseDataModel = getBaseGridDM("<%=page_id%>");
	dataModel = $.extend({}, baseDataModel, {
		sorting: "local",
		//sortIndx: "rec_date",
		sortDir: "up",
	});

	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("user_stat", "N", "Y", "N", "N");

	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		//dataModel: dataModel,
		scrollModel: { autoFit: true },
	});
	
	var $summary = "";
	obj.render = function (evt, ui) {
		$summary = $("<div class='pq-grid-summary'></div>")
		.prependTo($(".pq-grid-bottom", this));
	}

	obj.refresh = function (evt, ui) {
		var data = ui.dataModel.data;
		if(!data) return;

		var sum = {
				"part_name":"<b>총계</b>", "user_id":"-","user_name":"-","eval_user_name":""
				,avg_score:0,tot_eval_cnt:0,tot_eval_score:0,tot_exam_score:0,tot_add_score:0,tot_best_cnt:0,tot_worst_cnt:0
		};
		for(var i=1, len=$("#search input[name=eval_order_max]").val(); i <= len; i++){
			sum["cnt"+i]=0;
			sum["sum"+i]=0;
		}

		if(data!=undefined && data.length>0) {
			for(var i=0, len=data.length; i<len; i++) {
				var d = data[i];
				sum.tot_eval_cnt += parseInt(d.tot_eval_cnt);
				sum.tot_exam_score += parseInt(d.tot_exam_score);
				sum.tot_add_score += parseInt(d.tot_add_score);
				sum.tot_eval_score += parseInt(d.tot_eval_score);
				sum.tot_best_cnt += parseInt(d.tot_best_cnt);
				sum.tot_worst_cnt += parseInt(d.tot_worst_cnt);

				for(var ii=1, len2=$("#search input[name=eval_order_max]").val(); ii <= len2; ii++){
					sum["cnt"+ii] += d["cnt"+ii];
					sum["sum"+ii] += d["sum"+ii];
				}
			}
		}
		sum.avg_score = (sum.tot_eval_cnt==0) ? 0 : round(sum.tot_eval_score/sum.tot_eval_cnt,2);

		var o = { data: [sum], $cont: $summary };
		$(this).pqGrid("createTable", o);
	}

	$("#search select[name=event_code_combo]").change(function(){
		chgEventCode();
	});

	// grid
	if(search.event_code_combo.length==0){
		alert("마감된 이벤트가 없습니다.\n\n이벤트 마감부터 하세요");
	}
	else{
		var eventInfo = search.event_code_combo.value.split("/"); // event_code / eval_order_max
		search.event_code.value = eventInfo[0];
		$grid = $("#grid").pqGrid(obj);
		$("#grid").pqGrid("option", "dataModel", dataModel );
		setColModel(eventInfo[1]);
	}
});
//차수 컬럼 설정하기
function setColModel(evalOrderMax){
	$("#search input[name=eval_order_max]").val( (evalOrderMax) ? parseInt(evalOrderMax) : $("#search input[name=eval_order_max]").val() );//최대평가차수
	var colModelNew = clone(colModel);
	for(var i=1; i <= $("#search input[name=eval_order_max]").val(); i++){
		colModelNew.splice(evalOrderInputIdx+i,0,getEvalOrderTitle(i));
	}
	$("#grid").pqGrid("option", "colModel", colModelNew);
	$("#grid").pqGrid("refreshDataAndView");
}
//차수 컬럼 정보 HTML 구하기
function getEvalOrderTitle(order){
	return { title: order+"차", width: 40, align:"right", dataIndx: "avg_score"+order, render: function(ui) {return (!ui.rowData["cnt"+order]) ? "-" : round(ui.rowData["sum"+order]/ui.rowData["cnt"+order],2);}};
}
function beforeSearchFunc(){
	if(search.event_code_combo.length==0){
		alert("마감된 이벤트가 없습니다.\n\n이벤트 마감부터 하세요");
		return false;
	}
	return true;
}

function goStats(kind){
	if(kind=="score"){
		document.location = "<%=page_id%>.jsp";
	}
	else if(kind=="item"){
		document.location = "user_item_stat.jsp";
	}
}
function chgEventCode(){
	var obj = search.event_code_combo;
	if(obj.value=="") return;

	var eventInfo = obj.value.split("/"); // event_code / eval_order_max
	search.event_code.value = eventInfo[0];

	setColModel(eventInfo[1]);
}
</script>

<!--title 영역 -->
<div class="row titleBar border-bottom2">
	<div style="float:left;"><h4>상담원별 통계</h4></div>
	<ol class="breadcrumb" style="float:right;">
		<li><a href="#none"><i class="fa fa-home"></i> 평가 통계</a></li>
		<li class="active"><strong>상담원별 통계</strong></li>
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
					<li class="active"><a href="javascript:goStats('score')">평가점수</a></li>
					<li class=""><a href="javascript:goStats('item')">평가항목</a></li>
				</ul>
			</div>
		</div>
	</div>

	<!--ibox 시작-->
	<div class="ibox">
	<form id="search">
		<input type=hidden name=eval_order_max>
		<!--검색조건 영역-->
		<div class="ibox-content contentRadius1 conSize">
			<div id="resultDiv1">
				<div id="labelDiv">
					<label class="simple_tag">이벤트 명</label>
					<select class="form-control result_form3" name="event_code_combo"">
						<%=htm_event_list%>
					</select>
					<input type=hidden name=event_code>
					
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

			<!-- div id="resultDiv2">
				<div id="labelDiv">
					<label class="simple_tag">시트 명</label>
					<select class="form-control result_form3" name="sheet_code">
						<option value="">시트 선택</option>
						<%=htmSheetList%>
					</select>
				</div>
			</div -->

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
					<input type="text" name="user_name" class="form-control result_form3" id="" placeholder="">
				</div>
			</div>

			<div id="resultDiv2">
				<div id="label_Div">
					<label class="simple_tag">평가자 명</label>
					<input type="text" name="eval_user_name" class="form-control result_form3" id="" placeholder="">
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

	<!--Data table 영역-->
	<div class="contentArea">
		<!--grid 영역-->
		<div id="grid"></div>
		<!--grid 영역 끝-->
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
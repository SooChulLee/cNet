<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
// 메뉴 접근권한 체크
if(!Site.isPmss(out,"user_dept_stat","")) return;

Db db = null;

try {
	// DB Connection
	db = new Db(true);

	Map<String, Object> argMap = new HashMap<String, Object>();
	argMap.put("business_code", _BUSINESS_CODE);
	argMap.put("part_depth", "1");

	// 사용자 권한에 따른 조직도 조회
	argMap.put("_user_level", _LOGIN_LEVEL);
	argMap.put("_bpart_code",_BPART_CODE);
	argMap.put("_mpart_code",_MPART_CODE);
	argMap.put("_spart_code",_SPART_CODE);
	argMap.put("_default_code",_PART_DEFAULT_CODE);

	//조직도 콤보박스
	String htm_bpart_list = Site.getMyPartCodeComboHtml(session, 1);
	String htm_mpart_list = Site.getMyPartCodeComboHtml(session, 2);
	String htm_spart_list = Site.getMyPartCodeComboHtml(session, 3);
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<link rel="stylesheet" href="../js/plugins/chart/jquery.jqplot.min.css" />
<script type="text/javascript" src="../js/plugins/chart/jquery.jqplot.min.js"></script>
<script type="text/javascript" src="../js/plugins/chart/plugins/jqplot.highlighter.min.js"></script>
<script type="text/javascript" src="../js/plugins/chart/plugins/jqplot.cursor.min.js"></script>
<script type="text/javascript" src="../js/plugins/chart/plugins/jqplot.barRenderer.min.js"></script>
<script type="text/javascript" src="../js/plugins/chart/plugins/jqplot.categoryAxisRenderer.min.js"></script>
<script type="text/javascript" src="../js/plugins/chart/plugins/jqplot.pointLabels.min.js"></script>
<script type="text/javascript">
$(function () {
	var colModel = [
		{ title: "구분", width: 80, dataIndx: "user_name" },
		{ title: "녹취일자", width: 80, dataIndx: "v_rec_date" },
		{ title: "총콜수", width: 80, dataIndx: "tot_cnt",
			render: function(ui) {
				return $.number(ui.rowData["tot_cnt"]);
			},
		},
		{ title: "IN", width: 80, dataIndx: "in_cnt",
			render: function(ui) {
				return $.number(ui.rowData["in_cnt"]);
			},
		},
		{ title: "OUT", width: 80, dataIndx: "out_cnt",
			render: function(ui) {
				return $.number(ui.rowData["out_cnt"]);
			},
		},
		{ title: "내선", width: 80, dataIndx: "local_cnt",
			render: function(ui) {
				return $.number(ui.rowData["local_cnt"]);
			},
		},
		{ title: "총통화시간", width: 80, dataIndx: "tot_call_time" },
		{ title: "총통화 초", dataIndx: "tot_call_sec", hidden: true },
		{ title: "평균통화시간", width: 80, dataIndx: "avg_call_time" },
		{ title: "평균통화 초", dataIndx: "avg_call_sec", hidden: true },
		{ title: "1분미만", width: 80, dataIndx: "one_under_cnt",
			render: function(ui) {
				return $.number(ui.rowData["one_under_cnt"]);
			},
		},
		{ title: "1분이상~5분미만", width: 80, dataIndx: "one_five_cnt",
			render: function(ui) {
				return $.number(ui.rowData["one_five_cnt"]);
			},
		},
		{ title: "5분이상~10분미만", width: 80, dataIndx: "five_ten_cnt",
			render: function(ui) {
				return $.number(ui.rowData["five_ten_cnt"]);
			},
		},
		{ title: "10분이상", width: 80, dataIndx: "ten_over_cnt",
			render: function(ui) {
				return $.number(ui.rowData["ten_over_cnt"]);
			},
		}
	];

	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		sorting: "local",
		//sortIndx: "rec_date",
		sortDir: "up,down",
		//sortIndx: ["user_name", "rec_date"],
		//sortDir: ["up", "down"],
	});

	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("user_dept_stat", "N", "Y", "N", "N");
	// toolbar button add
	baseObj.toolbar.items.push(
			{ type: "button", icon: "ui-icon-graph", label: "그래프", style: "float: right; margin-right: 5px;", attr: "data-toggle='modal'",  listeners: [{
	 			"click": function () {
	 				popStatGraph();
	 			}
			}]
		}
	);

	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		scrollModel: { autoFit: true },
		/*sortable: false,
		load: function(evt, ui) {
			// 통계 총계 style 수정
			var data = ui.dataModel.data;

			if(data.length>0) {
				$grid.pqGrid("addClass", { rowIndx: data.length-1, cls: 'pq-row-enforce' });
			}
		},*/
	});

	var $summary = "";
	obj.render = function (evt, ui) {
		$summary = $("<div class='pq-grid-summary'></div>")
		.prependTo($(".pq-grid-bottom", this));
	}

	obj.refresh = function (evt, ui) {
		var data = ui.dataModel.data;
		var sum_tot_cnt = 0, sum_in_cnt = 0, sum_out_cnt = 0, sum_local_cnt = 0, sum_tot_call_sec = 0, sum_avg_call_sec = 0, sum_one_under_cnt = 0, sum_one_five_cnt = 0, sum_five_ten_cnt = 0, sum_ten_over_cnt = 0;

		if(data!=undefined && data.length>0) {
			for(var i=0;i<data.length;i++) {
				sum_tot_cnt += parseInt(data[i].tot_cnt);
				sum_in_cnt += parseInt(data[i].in_cnt);
				sum_out_cnt += parseInt(data[i].out_cnt);
				sum_local_cnt += parseInt(data[i].local_cnt);
				sum_tot_call_sec += parseInt(data[i].tot_call_sec);
				sum_avg_call_sec += parseInt(data[i].avg_call_sec);
				sum_one_under_cnt += parseInt(data[i].one_under_cnt);
				sum_one_five_cnt += parseInt(data[i].one_five_cnt);
				sum_five_ten_cnt += parseInt(data[i].five_ten_cnt);
				sum_ten_over_cnt += parseInt(data[i].ten_over_cnt);
			}
		}

		var sum = [{ "user_name":"<b>총계</b>","v_rec_date":""}];
		sum[0].tot_cnt = sum_tot_cnt;
		sum[0].in_cnt = sum_in_cnt;
		sum[0].out_cnt = sum_out_cnt;
		sum[0].local_cnt = sum_local_cnt;
		sum[0].tot_call_time = getHmsToSec(sum_tot_call_sec);
		sum[0].avg_call_time = getHmsToSec(sum_avg_call_sec);
		sum[0].one_under_cnt = sum_one_under_cnt;
		sum[0].one_five_cnt = sum_one_five_cnt;
		sum[0].five_ten_cnt = sum_five_ten_cnt;
		sum[0].ten_over_cnt = sum_ten_over_cnt;

		var obj = { data: sum, $cont: $summary };
		$(this).pqGrid("createTable", obj);

		// data refresh가 될 경우 그래프 내의 user_id select box 초기화
		$("#modalStatGraph select[name=user_id]").html("");
	}

	// grid
	$grid = $("#grid").pqGrid(obj);

	// graph open
	var popStatGraph = function () {
		var data = $grid.pqGrid("option", "dataModel.data");
		var chartTick = [], chartData = [];

		if(data!=undefined && data.length>0) {
			var data_user_id = {};
			var obj_user_id = $("#modalStatGraph select[name=user_id]");

			if(obj_user_id.html().trim()=="") {
				// user_id json 데이터 생성
				for(var i=0;i<data.length;i++) {
					data_user_id[data[i].user_id] = data[i].user_name;
				}

				// user_id select box 생성
				var html = "";
				$.each(data_user_id, function(key, val) {
					html += "<option value='" + key + "'>" + val + "</option>";
				});
				obj_user_id.html(html);
			}

			// 그래프 데이터 생성
			var baseField = $("#modalStatGraph select[name=data_type]").val();

			for(var i=0;i<data.length;i++) {
				if(obj_user_id.val()==data[i].user_id) {
					chartTick.push(data[i].v_rec_date);
					chartData.push(parseInt(eval("data[i]."+baseField)));
				}
			}
		} else {
			alert("데이터가 없습니다.");
			return;
		}

		// 상단 title 표시
		$("#modalStatGraph #rec_date1").html($("#search input[name=rec_date1]").val());
		$("#modalStatGraph #rec_date2").html($("#search input[name=rec_date2]").val());
		$("#modalStatGraph #date_type").html($("#search select[name=date_type] option:selected").text());

		$("#modalStatGraph").modal("show");

		// graph
		$("#chart").html("");
		barChart("chart", "", chartTick, chartData);
	};

	$("#modalStatGraph select[name=user_id], #modalStatGraph select[name=data_type]").change(function(){
		popStatGraph();
	});
});
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>상담원/부서별 통계</h4></div>
		<ol class="breadcrumb" style="float:right;">
			<li><a href="#none"><i class="fa fa-home"></i> 녹취 통계</a></li>
			<li class="active"><strong>상담원/부서별 통계</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->

	<!--wrapper-content영역-->
	<div class="wrapper-content">

		<!--ibox 시작-->
		<div class="ibox">
		<form id="search">
			<!--검색조건 영역-->
			<div class="ibox-content-util-buttons">
				<div class="ibox-content contentRadius1 conSize">
					<div id="deptDiv1">
						<div id="labelDiv">
							<label class="simple_tag">녹취일자</label>
							<!-- 달력 팝업 위치 시작-->
							<div class="input-group" style="display:inline-block;">
								<input type="text" name="rec_date1" class="form-control dept_form1 datepicker" value="<%=DateUtil.getToday("")%>" maxlength="10">
								<div class="input-group-btn">
									<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
								</div>
							</div>
							<!-- 달력 팝업 위치 끝-->
							<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
							<!-- 달력 팝업 위치 시작-->
							<div class="input-group" style="display:inline-block;">
								<input type="text" name="rec_date2" class="form-control dept_form1 datepicker" value="<%=DateUtil.getToday("")%>" maxlength="10">
								<div class="input-group-btn">
									<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
								</div>
							</div>
							<!-- 달력 팝업 위치 끝-->
						</div>
					</div>

					<div id="deptDiv2">
						<div id="labelDiv">
							<label class="simple_tag">녹취시간</label>
							<select class="form-control dept_form3" name="rec_hour1">
							<%
								for(int i=0;i<=23;i++) {
									String tmp_hour = CommonUtil.getFormatString(Integer.toString(i), "00");
									out.print("<option value='"+tmp_hour+"'>"+tmp_hour+"시</option>\n");
								}
							%>
							</select> ~
							<select class="form-control dept_form3" name="rec_hour2">
							<%
								for(int i=0;i<=23;i++) {
									String tmp_hour = CommonUtil.getFormatString(Integer.toString(i), "00");
									out.print("<option value='"+tmp_hour+"'"+((i==23) ? " selected='selected'" : "")+">"+tmp_hour+"시</option>\n");
								}
							%>
							</select>
						</div>
					</div>

					<div id="deptDiv3">
						<div id="label_Div">
							<label class="simple_tag">구분</label>
							<select class="form-control dept_form3" name="stat_type">
								<option value="US">상담사별</option>
								<option value="DE">부서별</option>
							</select>
					 	</div>
					</div>

					<div id="deptDiv1">
						<div id="label_div">
							<label class="simple_tag">일자구분</label>
							<select class="form-control dept_form2" name="date_type">
								<option value="DD">일자별</option>
								<option value="MM">월별</option>
								<option value="YY">년도별</option>
								<option value="HH">시간별</option>
								<option value="WD">요일별</option>
								<option value="WW">주간별</option>
							</select>
						</div>
					</div>

					<div id="deptDiv2">
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
							<input type="hidden" name="perm_check" value="1"/>
						</div>
					</div>

					<div id="deptDiv3">
						<div id="labelDiv">
							<label class="simple_tag">상담사명</label>
							<input type="text" class="form-control dept_form3" name="user_name" id="" placeholder="">
						</div>
					</div>
				</div>
				<!--검색조건 영역 끝-->

				<!--유틸리티 버튼 영역-->
				<div class="contentRadius2 conSize">
					<!--ibox 접히기, 설정버튼 영역 (사용안함)-->
					<div class="ibox-tools blank">
						<!--<a class="collapse-link">
							<button type="button" class="btn btn-default"><i class="fa fa-chevron-up"></i></button>
						</a>-->
					</div>
					<!--ibox 접히기, 설정버튼 영역 끝-->
					<div style="float:right">
						<button type="button" name="btn_search" class="btn btn-primary btn-sm"><i class="fa fa-search"></i> 조회</button>
						<button type="button" name="btn_cancel" class="btn btn-default btn-sm"><i class="fa fa-times"></i> 취소</button>
					</div>
				</div>
				<!--유틸리티 버튼 영역 끝-->
			</div>

			<!--ibox 접히기, 설정버튼 영역2-->
			<div class="ibox-tools2">
				<a class="collapse-link2">
					<div class="ibox-tools2-btn"><i class="fa fa-caret-up"></i></div>
				</a>
			</div>
			<!--ibox 접히기, 설정버튼 영역2 끝-->
		</form>
		</div>
		<!--ibox 끝-->

		<!--Data table 영역-->
		<div class="contentArea">
			<!--grid 영역-->
			<div id="grid"></div>
			<!--grid 영역 끝-->

			<!--그래프 보기 팝업창 띄우기-->
			<div class="modal inmodal" id="modalStatGraph" tabindex="-1" role="dialog" aria-hidden="true">
				<div class="modal-dialog2">
					<div class="modal-content animated fadeIn">
						<div class="modal-header">
							<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
							<h4 class="modal-title">그래프 보기</h4>
						</div>
						<div class="modal-body">
							<div class="colLeft bb">
								<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">조회 기준</h5>
							</div>

							<select class="form-control dept_form2 m-t" name="user_id">
							</select>

							<select class="form-control dept_form3 m-t" name="data_type">
								<option value="tot_cnt">총 콜수</option>
								<option value="in_cnt">IN</option>
								<option value="out_cnt">OUT</option>
								<option value="local_cnt">내선</option>
							</select>

							<div class="colRight"><span id="rec_date1"></span> ~ <span id="rec_date2"></span> <span id="date_type"></span> 조회</div>

							<div class="tableRadius conSize b-t" style="padding: 20px 20px 10px 20px;">
								<div id="chart" style="height: 400px;"></div>
							</div>
						</div>
						<div class="modal-footer">
						</div>
					</div>
				</div>
			</div>
			<!--그래프 보기 팝업창 띄우기 끝-->
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
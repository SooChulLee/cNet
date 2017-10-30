var _dash;
var _timer;
var _sec = 1;
var _svr_idx = 0;
var _svr_cnt = 0;
var _exec_cnt = 0;

$(function(){
	// 모니터링 시작/중지 버튼 클릭
	$("#btn_dash").click(function(){
		if($(this).prop("class").indexOf("warning")>-1) {
			// 중지버튼 클릭
			stopDash();
		} else {
			// 시작버튼 클릭
			startDash(_svr_idx);
		}
	});

	// 실행시간 변경
	$("#dash_sec").change(function(){
		if($("#btn_dash").prop("class").indexOf("warning")>-1) {
			stopDash();
			startDash(_svr_idx);
		}
	});

	// 초기화 버튼 클릭
	$("#btn_reset").click(function(){
		if(confirm("정말로 초기화 하시겠습니까?")) {
			$.ajax({
				type: "POST",
				url: "dash_reset.jsp",
				async: false,
				data: "step=reset",
				dataType: "json",
				success:function(dataJSON){
					if(dataJSON.code=="OK") {
						alert("정상적으로 초기화 되었습니다.");
						startDash(_svr_idx);
					} else {
						alert(dataJSON.msg);
					}
				},
				error:function(req,status,err){
					alertJsonErr(req,status,err);
					return;
				}
			});
		}
	});

	// 히스토리 버튼 클릭
	$("#btn_hist").click(function(){
		// 모니터링 중지
		stopDash();

		// 팝업 오픈
		openPopup("dash_hist.jsp","_dash_hist","960","650","yes","center");
	});

	// 자동 시작
	if($("#dash_sec").length>0) {
		if($.cookie("ck_dash_sec")!=undefined && $.cookie("ck_dash_sec")!="") {
			$("#dash_sec").val($.cookie("ck_dash_sec"));
		}

		startDash(0);
	}
});

// 모니터링 시작
function startDash(svr_idx) {
	getDashData(svr_idx, "N");

	// reload second cookie 생성
	if($.cookie("ck_dash_sec")==undefined || ($.cookie("ck_dash_sec")!=undefined && $.cookie("ck_dash_sec")!=$("#dash_sec").val())) {
		$.cookie("ck_dash_sec", $("#dash_sec").val(), { path: "/" });
	}

	//
	var interval = ($("#dash_sec").val()!="") ? $("#dash_sec").val() : 10;
	interval *= 1000;

	_dash = setInterval(function() {
		_sec = 0;
		getDashData(_svr_idx, "N");
	}, interval);

	startTimer();
	changeButton("N");
}

//모니터링 중지
function stopDash() {
	stopTimer();
	clearInterval(_dash);
	changeButton("Y");
}

// timer 시작
function startTimer() {
	_timer = setInterval(function() {
		++_sec;
		$("#dash_timer").html("(" + _sec +"초)");
	}, 1000);
}

// timer 중지
function stopTimer() {
	clearInterval(_timer);
	_sec = 1;
	$("#dash_timer").html("");
}

//모니터링 상태에 따른 버튼 스타일 변경
function changeButton(abort_flag) {
	if(abort_flag=="N") {
		// 모니터링 시작
		$("#btn_dash").removeClass("btn-primary");
		$("#btn_dash").addClass("btn-warning");
		$("#btn_dash").html("<i class=\"fa fa-ban\"></i> 중지");
		$("#dash_text").html("모니터링 중");
	} else {
		// 모니터링 중지
		$("#btn_dash").removeClass("btn-warning");
		$("#btn_dash").addClass("btn-primary");
		$("#btn_dash").html("<i class=\"fa fa-search\"></i> 시작");
		$("#dash_text").html("일시 중지");
	}
}

// 서버 정보 조회
function getDashSvrData(svr_idx) {
	stopDash();
	getDashData(svr_idx, "Y");
}

// get data
function getDashData(svr_idx, abort_flag) {
	// 전체 서버 수를 초과할 경우 페이지 reload
	if(abort_flag!="Y") {
		if(_exec_cnt>0 && _exec_cnt>=_svr_cnt) {
			location.reload();
			return;
		}
	}

	// 파라미터 셋팅
	var param = {};
	param.svr_idx = svr_idx;
	param.abort_flag = abort_flag;

	// global 변수 셋팅
	_svr_idx = svr_idx;

	$("#dash").load("dash.jsp", param, function(response, status, xhr){
		if(status=="error") {
			alert("데이터를 가져오는데 실패했습니다. [" + xhr.status + " : " + xhr.statusText + "]");
			return;
		}

		// 모니터링 서버 수 셋팅
		_svr_cnt = $("#frm input[name=svr_cnt]").val();

		// 서버 정보 차트 생성
		var svr_chart = $("#frm input[name=svr_chart]").val();
		var tmp_chart = svr_chart.split(",");
		if(tmp_chart.length>0) {
			var svr_chart_tick = [], svr_chart_data = [];

			for(var i=0;i<tmp_chart.length;i++) {
				var tmp_arr = tmp_chart[i].split(":");

				// x
				if(i>1) {
					svr_chart_tick.push("HDD [" + tmp_arr[0] + "]");
				} else {
					svr_chart_tick.push(tmp_arr[0]);
				}
				// y
				svr_chart_data.push(parseInt(tmp_arr[1]));
			}

			$("#svr_chart").html("");
			barChartDash("svr_chart", "", svr_chart_tick, svr_chart_data);
		}

		// error dialog
		createDialog();

		// 다음 실행할 서버 idx 설정
		_svr_idx++;
		if(_svr_cnt<=_svr_idx) {
			// 서버 idx 초기화
			_svr_idx = 0;
		}
	});

	// 실행 횟수 +1
	_exec_cnt++;
}

// error dialog open
function createDialog() {
	$("#error-message.ui-dialog-content").dialog("destroy").remove();

	var diag = $("#error-message").dialog({
		autoOpen: true,
		modal: true,
		buttons: [{
			text: "닫기",
			icons: {
				primary: "ui-icon-close"
			},
			click: function() {
				$(this).dialog("close");
			}
		}],
		minWidth: 768,
		height: 400
	});

	$("#tabs").tabs({
		event: "mouseover",
		//collapsible: true,
	});
}

// 서버정보 막대 그래프
function barChartDash(chartID, chartNm, chartTick, chartData) {
	$.jqplot(chartID, [chartData], {
		title: chartNm,
		animate: false,
		seriesDefaults: {
			renderer:$.jqplot.BarRenderer,
			rendererOptions: {
				varyBarColor: true,
				barMargin: 10
			},
			pointLabels: {
				show: true
			}
		},
		grid: {
			//background: "#FFFFFF",
			gridLineColor: "#BFBFBF",
			drawBorder: false
		},
		axes:{
			xaxis:{
				renderer:$.jqplot.CategoryAxisRenderer,
				ticks: chartTick,
				drawMajorGridlines: true,
				tickOptions:{
					textColor: "#FFFFFF",
					showMarker: false
				}
			},
			yaxis:{
				min: 0,
				drawMajorGridlines: true,
				tickOptions: {
					formatString: "%'d%",
					textColor: "#FFFFFF",
					showMarker: false
				}
			}
		}
	});
}

// paging
function goDashPage(frmName, type, curPage, totPage) {
	var obj = $("#"+frmName);
	var trgPage = 1;

	if(type=="first") {
		if(curPage<=1) {
			return;
		}
		trgPage = 1;
	} else if(type=="prev") {
		if(curPage<=1) {
			return;
		}
		trgPage = parseInt(curPage)-1;
	} else if(type=="next") {
		if(totPage<=curPage) {
			return;
		}
		trgPage = parseInt(curPage)+1;
	} else if(type=="last") {
		if(totPage<=curPage) {
			return;
		}
		trgPage = parseInt(totPage);
	} else {
		if(curPage<1 || curPage>totPage) {
			return;
		}
		trgPage = parseInt(curPage)
	}

	obj.find("input[name=cur_page]").val(trgPage);
	obj.submit();
}
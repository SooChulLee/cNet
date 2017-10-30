<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"mon_db_list","")) return;

	Db db = null;

	try {
		db = new Db(true);

		// 사용자 권한에 따른 조직도 대분류 조회
		String htm_bpart_list = Site.getMyPartCodeComboHtml(session, 1);
		String htm_spart_list = Site.getMyPartCodeComboHtml(session, 3);

		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("business_code", _BUSINESS_CODE);
		argMap.put("part_depth", "2");
		argMap.put("bpart_code", "WA1001");

		// 사용자 권한에 따른 조직도 조회
		argMap.put("_user_level", _LOGIN_LEVEL);
		argMap.put("_bpart_code",_BPART_CODE);
		argMap.put("_mpart_code",_MPART_CODE);
		argMap.put("_spart_code",_SPART_CODE);
		argMap.put("_default_code",_PART_DEFAULT_CODE);
		String htm_mpart_list = Site.getPartCodeComboHtml(argMap);
		// 서버 아이피 조회
		String server_ip = request.getServerName();
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
var mon = null;
var timer = null;
var sec = 1;

$(function () {
	// 모니터링 시작
	var startMon = function() {
		getMonData();

		var mon_sec = $("select[name=mon_sec]").val()*1000;
		mon = setInterval(function() {
			sec = 0;
			getMonData();
		}, mon_sec);

		startTimer();
		// 상태 표시
		$("input[name=mon_status]").val("시작");
	}

	// 모니터링 중지
	var stopMon = function() {
		clearInterval(mon);
		stopTimer();
		// 상태 표시
		$("input[name=mon_status]").val("중지");
	};

	// 모니터링 데이터 조회
	var getMonData = function() {
		var url = "remote_mon_db_list.jsp";
		var param = { bpart_code: $("select[name=bpart_code]").val()
						, mpart_code: $("select[name=mpart_code]").val()
						, spart_code: $("select[name=spart_code]").val()
						, local_no: $("input[name=local_no]").val()
		};

		$("#mon").load(url, param, function(response, status, xhr){
			if(status=="error") {
				$(this).html("데이터를 가져오는데 실패했습니다. [" + xhr.status + " : " + xhr.statusText + "]");
			}
		});
	};

	// timer 시작
	var startTimer = function() {
		timer = setInterval(function() {
			++sec;
			$("#timer").html(sec+"초");
		}, 1000);
	};

	// timer 중지
	var stopTimer = function() {
		clearInterval(timer);
		sec = 1;
		$("#timer").html("");
	};

	// 시작 버튼 클릭
	$("button[name=mon_start]").click(function(){
		// 기존 mon 중지 후 start
		stopMon();
		startMon();
	});

	// 중지 버튼 클릭
	$("button[name=mon_stop]").click(function(){
		stopMon();
	});

	// 조직도 변경 시 모니터링 재시작
	$("select[name=bpart_code], select[name=mpart_code], select[name=spart_code]").change(function() {
		// 기존 mon 중지 후 start
		stopMon();
		startMon();
	});

	// 조직도에서 첫번째 대분류 선택
	$("select[name=bpart_code] option:eq(1)").attr("selected", "selected");

	// 자동 시작
	startMon();
});

var playRlisten = function(status, ch_no, local_no, system_ip) {
	// 녹취상태일 경우만 감청 플레이어 오픈
	if(status=="1") {
		if(CNet.CheckMon("<%=server_ip%>")){
			CNet.PlayMon(system_ip+","+parseInt(ch_no)+","+local_no);
			//alert (system_ip+","+parseInt(ch_no)+","+local_no);
		}
	}
};
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>모니터링</h4></div>
		<ol class="breadcrumb" style="float:right;">
			<li><a href="#none"><i class="fa fa-home"></i> 조회</a></li>
			<li class="active"><strong>모니터링</strong></li>
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
					<!--1행 시작-->
					<div id="recDiv3">
						<div id="labelDiv">
							<label class="simple_tag">조직도</label>
							<select class="form-control rec_form2" name="bpart_code">
								<%=htm_bpart_list%>
							</select> :
							<select class="form-control rec_form2" name="mpart_code">
								<option value="">중분류</option>
								<%=htm_mpart_list%>
							</select> :
							<select class="form-control result_form2" name="spart_code">
								<%=htm_spart_list%>
							</select>
							<input type="hidden" name="perm_check" value="1"/>
						</div>
					</div>

					<div id="recDiv3">
						<div id="labelDiv">
							<label class="simple_tag">내선번호</label>
							<input type="text" name="local_no" class="form-control rec_form5" value="">
						</div>
					</div>

					<div id="recDiv3">
						<div id="labelDiv">
							<label class="simple_tag">조회간격</label>
							<select class="form-control rec_form5" name="mon_sec">
								<option value="5">5초</option>
								<option value="10" selected="selected">10초</option>
								<option value="20">20초</option>
								<option value="30">30초</option>
								<option value="40">40초</option>
								<option value="50">50초</option>
								<option value="60">60초</option>
							</select>
						</div>
					</div>
					<!--1행 끝-->

					<!--2행 시작-->
					<div id="recDiv3">
						<div id="labelDiv">
							<label class="simple_tag">상태</label>
							<input type="text" name="mon_status" class="form-control rec_form5" value="시작" readonly="readonly">
							&nbsp; <span id="timer"></span>
						</div>
					</div>
					<!--2행 끝-->

				</div>
				<!--검색조건 영역 끝-->

				<!--유틸리티 버튼 영역-->
				<div class="contentRadius2 conSize">
					<!--ibox 접히기, 설정버튼 영역-->
					<div class="ibox-tools blank">
						<!--<a class="collapse-link">
							<button type="button" class="btn btn-default btn-sm"><i class="fa fa-chevron-up"></i> </button>
						</a>-->
					</div>
					<!--ibox 접히기, 설정버튼 영역 끝-->
					<div style="float:right">
						<button type="button" name="mon_start" class="btn btn-primary btn-sm"><i class="fa fa-play"></i> 시작</button>
						<button type="button" name="mon_stop" class="btn btn-danger btn-sm"><i class="fa fa-stop"></i> 중지</button>
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
			<!--mon 영역-->
			<div id="mon"></div>
			<!--mon 영역 끝-->
		</div>
		<!--Data table 영역 끝-->
	</div>
	<!--wrapper-content영역 끝-->

	<!--감청 플레이어 OCX-->
	<object id="CNet" classid="CLSID:CA177FAA-118C-4ACB-80F5-671E66766073" width="0" height="0" codebase="../Setup/CnetLauncher.CAB#version=1,0,0,93" hidden="true"></object>
<jsp:include page="/include/bottom.jsp"/>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"mon_list","")) return;

	Db db = null;

	try {
		db = new Db(true);

		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("system_rec", "1");

		List<Map<String, Object>> system_list = db.selectList("system.selectCodeList", argMap);

		// 서버 아이피 조회
		String server_ip = request.getLocalAddr();
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
		var url = "remote_mon_list.jsp";
		var param = { system_ip: $("select[name=system_ip]").val(), local_no: $("input[name=local_no]").val() };

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

	// 자동 시작
	startMon();
});

var playRlisten = function(status, ch_no, local_no, system_code, user_id, user_name) {
	// 녹취상태일 경우만 감청 플레이어 오픈
	if(status=="2") {
		//if(CNet.CheckMon("<%=server_ip%>")){
			CNet.PlayMon($("select[name=system_ip]").val()+","+parseInt(ch_no)+","+local_no);
		//}
	}




	$.ajax({
	   	type: "POST",
	   	url: "remote_mon_proc.jsp",
		async: false,
	   	data: "ch_no="+ch_no+"&local_no="+local_no+"&system_code="+system_code+"&user_id="+user_id+"&user_name="+user_name,
	   	dataType: "json",
	   	success:function(dataJSON){
			if(dataJSON.code=="OK") {
				//alert("정상적으로 등록되었습니다.");
				location.reload();
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
							<label class="simple_tag">시스템</label>
							<select class="form-control rec_form5" name="system_ip">
	<%
							if(system_list!=null) {
								for(Map<String, Object> system_item : system_list) {
									out.print("<option value='"+system_item.get("system_ip")+"'>"+system_item.get("system_name")+"</option>\n");
								}
							}
	%>
							</select>
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
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%@ include file="/common/common.jsp" %>
<%@ include file="/common/function.jsp" %>
<%
	// DB Connection Object
	Db db = null;

	try {
		// DB Connection
		db = new Db(true);

		// get parameter
		String info = CommonUtil.ifNull(request.getParameter("info"));
		int rec_seq = CommonUtil.getParameterInt("rec_seq", "-1");

		// 파라미터 체크
		if(!CommonUtil.hasText(info)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}

		// 파라미터 복호화
		//CNCrypto aes = new CNCrypto("AES",CommonUtil.getOZEncKey());
		//info = aes.Decrypt(info);

		// 요청시간|녹취일시|내선번호|CON ID|상담사ID
		String tmp_arr[] = info.split("\\|");

		String started = tmp_arr[1];
		//String station = tmp_arr[2];
		String ucid = tmp_arr[2];
		String user_id = tmp_arr[3];




		// 파라미터 복호화된 데이터 체크
		//if(!CommonUtil.hasText(started) || !CommonUtil.hasText(station) || !CommonUtil.hasText(ucid)) {
           if(!CommonUtil.hasText(started) || !CommonUtil.hasText(ucid)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}

		// 요청시간 비교
		Date req_datm = DateUtil.getDate(DateUtil.getDateFormatByIntVal(tmp_arr[0], "yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");
		Date now_datm = DateUtil.getDate(DateUtil.getToday("yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");

		// 경과시간 체크
		// date diff
		int min = DateUtil.getDateDiff(req_datm, now_datm, "M");

		if(min>5) {
			out.print(CommonUtil.getPopupMsg("요청시간이 초과하였습니다.","","close"));
			return;
		}

		//
		String date = started.substring(0,8);

		Map<String, Object> argMap = new HashMap<String, Object>();
		Map<String, Object> curdata = new HashMap();

		//
		argMap.clear();




		argMap.put("rec_date",date);
		argMap.put("rec_keycode",ucid);

		// 연관 녹취이력 조회
		List<Map<String, Object>> list = db.selectList("rec_search.selectRelationList", argMap);
		if(list.size()<1) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_DATA"),"","close"));
			return;
		}

		// 현재 클릭된 녹취이력 정보 별도 저장
		for(int i=0;i<list.size();i++) {
			if(list.get(i).get("rec_keycode").toString().equals(ucid)) {
				curdata = list.get(i);
				break;
			}
		}

		// 파일명이 일치하는 데이터가 없을 경우 첫번째 이력으로 데이터 셋팅
		if(curdata.size()<1) {
			curdata = list.get(0);
		}



		// 청취 URL 생성
		String file_url = getListenURL("LISTEN", curdata, logger);

		String fft_ext = ("88".equals(curdata.get("system_code").toString())) ? "nmf" : "fft";
		if(file_url==null || "".equals(file_url)) {
			out.print(CommonUtil.getPopupMsg("녹취파일 경로를 가져 오는데 실패했습니다.","","close"));
		}

		if("ERR".equals(file_url.substring(0,3))) {
			out.print(CommonUtil.getPopupMsg(file_url.substring(3),"","close"));
		}

		// 청취 이력 저장
		argMap.put("rec_seq","0");
		argMap.put("login_id",user_id);
		argMap.put("login_name",user_id);
		argMap.put("listen_ip",request.getRemoteAddr());
		argMap.put("rec_datm",date);
		argMap.put("rec_keycode",ucid);
		argMap.put("rec_filename",curdata.get("rec_filename").toString());
		argMap.put("user_id",curdata.get("user_id").toString());
		argMap.put("user_name",curdata.get("user_name").toString());
		//argMap.put("local_no",station);
		argMap.put("local_no",curdata.get("local_no").toString());
		argMap.put("listen_src","O");

		int ins_cnt = db.insert("hist_listen.insertListenHist", argMap);

		// 브라우저 체크
		String ua = request.getHeader("User-Agent");
		String profix = "mb";
		// IE8
		if(ua.toLowerCase().indexOf("trident/4.0")>0) {
			profix = "ie8";
		}

		// window media player 사용 설정
		profix = "ie8";

%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>청취 플레이어 </title>
<link href="../css/bootstrap.css" rel="stylesheet">
<link href="../css/font-awesome.css" rel="stylesheet">
<link href="../css/animate.css" rel="stylesheet">
<link href="../css/player_<%=profix%>.css" rel="stylesheet">
<link href="../css/player.css" rel="stylesheet">
<link href="../css/style.css" rel="stylesheet">

<script type="text/javascript" src="../js/jquery-1.11.0.min.js"></script>
<script type="text/javascript" src="../js/jquery-ui-1.10.4.custom.min.js"></script>
<script type="text/javascript" src="../js/bootstrap.js"></script>
<script type="text/javascript" src="../js/plugins/jplayer/jquery.jplayer.min.js"></script>
<script type="text/javascript" src="../js/plugins/wave/swfobject.js"></script>
<script type="text/javascript" src="../js/plugins/wave/wavesurfer.min.js"></script>
<script type="text/javascript" src="../js/plugins/wave/wavesurfer.swf.js"></script>
<script type="text/javascript" src="../js/common.js"></script>
<script type="text/javascript">
	var file_url = "<%=file_url%>";
	var fft_ext = "<%=fft_ext%>";
	var rec_datm = "<%=started%>";
	var local_no = "<%=curdata.get("local_no").toString()%>";
	var rec_filename = "<%=curdata.get("rec_filename").toString()%>";

	//var wave_type = "canvas";
	//var wave_type = "img2";
	var wave_type = "img2";
</script>
<script type="text/javascript" src="../js/player_<%=profix%>.js"></script>
<script type="text/javascript" src="../js/player_app.js"></script>
</head>

<body class="white-bg">
<div id="container" style="width: 556px">
	<div class="memo-body">
	<!--녹음파일 파형 영역 시작-->
		<div id="outer_waveform" class="p-frame1 tableSize4">
			<div id="waveform"></div>
			<p id="curtime"></p>
		</div>
		<!--녹음파일 파형 영역 끝-->
		<!--플레이어 영역-->
		<% if("mb".equals(profix)) { %>
			<jsp:include page="../rec_search/player_mb.jsp" flush="false"/>
		<% } else { %>
			<jsp:include page="../rec_search/player_ie8_2.jsp" flush="false"/>
		<% } %>
		<!--플레이어 영역 끝-->

		<!--ibox 시작-->
		<div class="ibox hidden" id="ui-marking">
			<!--마킹하기 팝업창 띄우기-->
			<div class="p-dialog">
				<div class="p-content">
					<div class="p-header">
						<button type="button" class="close"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
						<h4 class="p-title">마킹</h4>
					</div>
					<div class="p-body">
						<div class="cc">
							<form id="marking">
								<input type="hidden" name="rec_datm" value=""/>
								<input type="hidden" name="rec_filename" value=""/>
								<!-- <span>구분 &nbsp;</span>
								<input type="text" class="form-control play-form" id="" name="mk_name" placeholder=""> -->
								<span style="padding-right: 20px;"></span>
								<span>구간 &nbsp;</span>
								<input type="text" class="form-control play-form" id="" name="mk_stime" placeholder="00:00:00"></li> ~
								<input type="text" class="form-control play-form" id="" name="mk_etime" placeholder="00:00:00"></li>
								<button type="button" name="btn_marking" class="btn btn-primary btn-sm" onclick="regiMarking();">마킹</button>
							</form>
						</div>
					</div>
				</div>
			</div>
			<!--마킹하기 팝업창 끝-->
		</div>
		<!--ibox 끝-->

	</div>
</div>
</body>
</html>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
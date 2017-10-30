<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ include file="/common/function.jsp" %>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%
	if(!Site.isPmss(out,"rec_search","close")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String info = CommonUtil.ifNull(request.getParameter("info"));
		String reason_code = CommonUtil.getParameter("reason_code");
		String reason_text = CommonUtil.getParameter("reason_text");

		// 파라미터 체크
		if(!CommonUtil.hasText(info) || !CommonUtil.hasText(reason_code)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}

		// 파리미터 복호화
		CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());
		info = aes.Decrypt(info);

		String tmp_arr[] = info.split("\\|");
		String rec_datm = tmp_arr[1];
		String local_no = tmp_arr[2];
		String rec_filename = tmp_arr[3];
		String rec_keycode = tmp_arr[4];

		// 파라미터 체크
		if(!CommonUtil.hasText(rec_datm) || !CommonUtil.hasText(local_no) || !CommonUtil.hasText(rec_filename) || !CommonUtil.hasText(rec_keycode)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}

		// 요청일시와 현재 시간의 차이를 구함
		Date conn_datm = DateUtil.getDate(DateUtil.getDateFormatByIntVal(tmp_arr[0], "yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");
		Date now_datm = DateUtil.getDate(DateUtil.getToday("yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");

		int diff = DateUtil.getDateDiff(conn_datm, now_datm, "M");

		// 5분 이상 차이가 날 경우 로그인 실패 처리
		if(diff>5) {
			out.print(CommonUtil.getPopupMsg("요청가능 시간이 만료되었습니다.","","close"));
			return;
		}

		Map<String, Object> argMap = new HashMap<String, Object>();
		Map<String, Object> curdata = new HashMap();

		// 사용권한 체크
		argMap.put("conf_field","url");
		argMap.put("user_id",_LOGIN_ID);
		argMap.put("user_level",_LOGIN_LEVEL);

		if(!"1".equals(db.selectOne("search_config.selectResultPerm", argMap))) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("ERR_PERM"),"","close"));
			return;
		}

		// yyyyMMddHHmmssSSS -> yyyy-MM-dd
		//String rec_date = DateUtil.getDateFormatByIntVal(rec_datm, "yyyy-MM-dd");
		String rec_date = rec_datm.substring(0, 8);

		argMap.clear();
		argMap.put("dateStr", CommonUtil.getRecordTableNm(rec_datm));
		argMap.put("rec_date",rec_date);
		argMap.put("rec_keycode",rec_keycode);

		// 사용자 권한에 따른 녹취이력 조회
		argMap.put("_user_id", _LOGIN_ID);
		argMap.put("_user_level", _LOGIN_LEVEL);
		argMap.put("_bpart_code",_BPART_CODE);
		argMap.put("_mpart_code",_MPART_CODE);
		argMap.put("_spart_code",_SPART_CODE);

		// 연관 녹취이력 조회
		List<Map<String, Object>> list = db.selectList("rec_search.selectRelationList", argMap);
		if(list.size()<1) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_DATA"),"","close"));
			return;
		}

		// 현재 클릭된 녹취이력 정보 별도 저장
		for(int i=0;i<list.size();i++) {
			if(list.get(i).get("rec_filename").toString().equals(rec_filename)) {
				curdata = list.get(i);
				break;
			}
		}

		// 파일명이 일치하는 데이터가 없을 경우 첫번째 이력으로 데이터 셋팅
		if(curdata.size()<1) {
			curdata = list.get(0);
		}

		// 청취 URL 생성
		//String file_path = "20160519/16/20160519165750_1636.wav";
		//String file_path = "20160519/16/20160519165913_1112.wav";
		//String file_url = getListenURL("LISTEN", file_path, logger);
		String file_url = getListenURL("LISTEN", curdata, logger);
		String fft_ext = ("88".equals(curdata.get("system_code").toString())) ? "nmf" : "fft";

		if(file_url==null || "".equals(file_url)) {
			out.print(CommonUtil.getPopupMsg("녹취파일 경로를 가져 오는데 실패했습니다.","","close"));
			return;
		}

		if("ERR".equals(file_url.substring(0,3))) {
			out.print(CommonUtil.getPopupMsg(file_url.substring(3),"","close"));
			return;
		}

		// 청취 이력 저장
		argMap.put("login_id",_LOGIN_ID);
		argMap.put("login_name",_LOGIN_NAME);
		argMap.put("listen_ip",request.getRemoteAddr());
		argMap.put("rec_datm",curdata.get("rec_datm").toString());
		argMap.put("rec_keycode",curdata.get("rec_keycode").toString());
		argMap.put("rec_filename",curdata.get("rec_filename").toString());
		argMap.put("user_id",curdata.get("user_id").toString());
		argMap.put("user_name",curdata.get("user_name").toString());
		argMap.put("local_no",curdata.get("local_no").toString());
		argMap.put("reason_code",reason_code);
		argMap.put("reason_text",reason_text);
		argMap.put("listen_src","");

		int ins_cnt = db.insert("hist_listen.insertListenHist", argMap);

		// 브라우저 체크
		String ua = request.getHeader("User-Agent");
		String profix = "mb";
		// IE 체크
		if(ua.toLowerCase().indexOf("trident")>0) {
			profix = "ie8";
		}
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="-1" />
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
<script type="text/javascript" src="../js/plugins/wave/waveform.js"></script>
<% if("mb".equals(profix)) { %>
<script type="text/javascript" src="../js/plugins/jplayer/jquery.jplayer.min.js"></script>
<script type="text/javascript" src="../js/plugins/wave/swfobject.js"></script>
<script type="text/javascript" src="../js/plugins/wave/wavesurfer.min.js"></script>
<script type="text/javascript" src="../js/plugins/wave/wavesurfer.swf.js"></script>
<% } %>
<script type="text/javascript" src="../js/site.js"></script>
<script type="text/javascript" src="../js/common.js"></script>
<script type="text/javascript">
	var file_url = "<%=file_url%>";
	var fft_ext = "<%=fft_ext%>";
	var rec_datm = "<%=rec_datm%>";
	var local_no = "<%=local_no%>";
	var rec_filename = "<%=rec_filename%>";
	//var wave_type = "canvas";
	var wave_type = "img2";
	//var wave_type = "img";
</script>
<script type="text/javascript" src="../js/player_<%=profix%>.js"></script>
<script type="text/javascript" src="../js/player.js"></script>
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
			<jsp:include page="player_mb.jsp" flush="false"/>
		<% } else { %>
			<jsp:include page="player_ie8.jsp" flush="false"/>
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
								<input type="hidden" name="local_no" value=""/>
								<input type="hidden" name="rec_filename" value=""/>
								<span>구분 &nbsp;</span>
								<input type="text" class="form-control play-form" id="" name="mk_name" placeholder="">
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

		<!--마킹 이력 table-->
		<div id="marking_hist"></div>
		<!--마킹 이력 table 끝-->

		<!--녹취 이력 정보 table-->
		<div class="tableSize4 p-space">
			<h5 style="margin-top:0;">녹취이력 정보</h5>
			<table class="table top-line1 table-bordered2">
				<thead>
				<tr>
					<td style="width:35%;" class="table-td">녹취일시 (통화시간)</td>
					<td style="width:65%;"><%=curdata.get("rec_datm") %> (<%=curdata.get("rec_call_time") %>)</td>
				</tr>
				</thead>
				<tr>
					<td class="table-td">상담원ID</td>
					<td><%=curdata.get("user_id") %></td>
				</tr>
				<tr>
					<td class="table-td">상담사명</td>
					<td><%=curdata.get("user_name") %></td>
				</tr>
				<tr>
					<td class="table-td">내선번호</td>
					<td><%=curdata.get("local_no") %></td>
				</tr>
			</table>
		</div>
		<!--녹취 이력 정보 table 끝-->

<%
	if(list.size()>1) {
%>
		<!--연관 녹취 이력 table-->
		<div class="tableSize4 p-space">
			<h5 style="margin-top:0;">연관녹취 이력</h5>
			<table class="table top-line1 table-bordered">
				<thead>
					<tr>
						<th style="width:35%;">녹취일시</th>
						<th style="width:23%;">통화시간</th>
						<th style="width:22%;">상담사명</th>
						<th style="width:20%;">내선번호</th>
					</tr>
				</thead>
				<tbody>
<%
		for(Map<String, Object> item : list) {
			out.print("<tr class='" + (rec_filename.equals(item.get("rec_filename").toString()) ? "odd4" : "") + "'>");
			//out.print("	<td><a href='player_reason.jsp?rec_datm="+rec_datm+"&local_no="+item.get("local_no").toString()+"&rec_filename="+item.get("rec_filename").toString()+"&rec_keycode="+rec_keycode+"'><u>" + item.get("rec_datm") + "</u></a></td>");
			out.print("		<td><a href='#none' onclick='playRecFileLink(\""+item.get("rec_datm")+"\", \"" + item.get("local_no") + "\", \"" + item.get("rec_filename") + "\", \"" + rec_keycode + "\");'><u>" + item.get("rec_datm") + "</u></a></td>");
			out.print("		<td>" + item.get("rec_call_time") + "</td>");
			out.print("		<td>" + item.get("user_name") + "</td>");
			out.print("		<td>" + item.get("local_no") + "</td>");
			out.print("</tr>");
		}
%>
				</tbody>
			</table>
		</div>
		<!--연관 녹취 이력 table 끝-->
<%	} %>
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
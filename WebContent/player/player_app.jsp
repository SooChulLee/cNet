<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.URLDecoder"%>
<%@ page import="wfm.com.util.AES256Cipher"%>
<%@ include file="/common/common.jsp" %>
<%@ include file="/common/function.jsp" %>
<%
	// DB Connection Object
	Db db = null;

	try {
		// DB Connection
		db = new Db(true);

		// get parameter
		String rec_datm = CommonUtil.ifNull(request.getParameter("rec_datm"));
		String rec_keycode = CommonUtil.ifNull(request.getParameter("rec_keycode"));
		int rec_seq = CommonUtil.getParameterInt("rec_seq", "0");
		String user_id = CommonUtil.ifNull(request.getParameter("user_id"));
		String user_name = CommonUtil.ifNull(request.getParameter("user_nm"));
		String reason_code = CommonUtil.getParameter("reason_code");
		String reason_text = CommonUtil.getParameter("reason_text");




		// 파라미터 체크
		if(!CommonUtil.hasText(rec_datm) || !CommonUtil.hasText(rec_keycode) || !CommonUtil.hasText(reason_code)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}
		if("99".equals(reason_code) && !CommonUtil.hasText(reason_text)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}
		if(!CommonUtil.hasText(user_id) || !CommonUtil.hasText(user_name)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}

		// parameter decrypt
		AES256Cipher a256 = AES256Cipher.getInstance(CommonUtil.getWfmEncKey());

		String dec_rec_datm = a256.decrypt(rec_datm);
		String dec_rec_keycode = a256.decrypt(rec_keycode);
		String dec_user_id = a256.decrypt(user_id);
		String dec_user_name = a256.decrypt(user_name);

		//
		Map<String, Object> argMap = new HashMap<String, Object>();
		Map<String, Object> curdata = new HashMap();

		//
		String rec_date = dec_rec_datm.substring(0, 8);

		argMap.clear();
		argMap.put("dateStr",CommonUtil.getRecordTableNm(dec_rec_datm));
		argMap.put("rec_date",rec_date);
		argMap.put("rec_keycode",dec_rec_keycode);

		// 연관 녹취이력 조회
		List<Map<String, Object>> list = db.selectList("rec_search.selectRelationList", argMap);
		if(list.size()<1) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_DATA"),"","close"));
			return;
		}

		// 현재 클릭된 녹취이력 정보 별도 저장
		curdata = list.get(rec_seq);

		// 청취 URL 생성
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
		argMap.put("login_id",dec_user_id);
		argMap.put("login_name",dec_user_name);
		argMap.put("listen_ip",request.getRemoteAddr());
		argMap.put("rec_datm",curdata.get("rec_datm").toString());
		argMap.put("rec_keycode",curdata.get("rec_keycode").toString());
		argMap.put("rec_filename",curdata.get("rec_filename").toString());
		argMap.put("user_id",curdata.get("user_id").toString());
		argMap.put("user_name",curdata.get("user_name").toString());
		argMap.put("local_no",curdata.get("local_no").toString());
		argMap.put("reason_code",reason_code);
		argMap.put("reason_text",reason_text);
		argMap.put("listen_src","AP");

		String rec_datm2 = curdata.get("rec_datm").toString().replace("-","").replace(" ","").replace(":","");
		String local_no = curdata.get("local_no").toString();
		String rec_filename = curdata.get("rec_filename").toString();

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
	var rec_datm = "<%=rec_datm2%>";
	var local_no = "<%=local_no%>";
	var rec_filename = "<%=rec_filename%>";

	//var rec_datm = "";
	//var local_no = "";
	//var rec_filename = "";
	//var wave_type = "canvas";
	//var wave_type = "img";
	var wave_type = "img2";

	//$(function(){
		// 마킹 기능 remove
	//	$("button[name=btn_view_marking]").parent("div").remove();
	//});
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
			<jsp:include page="/rec_search/player_mb.jsp" flush="false"/>
		<% } else { %>
			<jsp:include page="/rec_search/player_ie8.jsp" flush="false"/>
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
		int seq=0;
		for(Map<String, Object> item : list) {
			out.print("<tr class='" + ((seq==rec_seq) ? "odd4" : "") + "'>");
			out.print("		<td><a href='player_rn.jsp?rec_datm="+java.net.URLEncoder.encode(rec_datm)+"&rec_keycode="+java.net.URLEncoder.encode(rec_keycode)+"&rec_seq="+seq+"&user_id="+java.net.URLEncoder.encode(user_id)+"&user_nm="+java.net.URLEncoder.encode(user_name)+"'><u>" + item.get("rec_datm") + "</u></a></td>");
			out.print("		<td>" + item.get("rec_call_time") + "</td>");
			out.print("		<td>" + item.get("user_name") + "</td>");
			out.print("		<td>" + item.get("local_no") + "</td>");
			out.print("</tr>");

			seq++;
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
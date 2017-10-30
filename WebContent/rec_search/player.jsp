<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ include file="/common/function.jsp" %>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%
// 메뉴 접근권한 체크
if(!Site.isPmss(out,"rec_search","close")) return;
//ComLib.writeParameters(request, out);

Db db = null;

try {
	// DB Connection
	db = new Db(true);

	// get parameter
	String loc = ComLib.getPSNN(request, "loc");
	String rec_seq = ComLib.getPSNN(request, "rec_seq");
	String info = CommonUtil.ifNull(request.getParameter("info"));
	int curRecIdx = ComLib.getPI(request, "curRecIdx", 0);//다중청취시 현재 인덱스
	String reason_code = CommonUtil.getParameter("reason_code");//사유입력에 사용
	String reason_text = CommonUtil.getParameter("reason_text");//사유입력에 사용
	String sType = CommonUtil.getParameter("setType");

	// 파라미터 체크
	if(rec_seq.equals("") && (!CommonUtil.hasText(info) || (Finals.isExistPlayDownReason && !CommonUtil.hasText(reason_code)))) {
		out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
		return;
	}

	// 파리미터 복호화
	CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());
	//out.println(info);
	//info = aes.Decrypt(info);

	Map<String, Object> argMap = new HashMap<String, Object>();

	// rec_seq를 넘겨서 청취하는 경우 --------------------------------
	if(!rec_seq.equals("")){
		info = "";
		String rec_seq_array[] = rec_seq.split("/");
		for(int i=0, len=rec_seq_array.length; i<len; i++){
			argMap.clear();
			argMap.put("rec_seq", rec_seq);
			Map<String, Object> recmap  = db.selectOne("eval_rec_search.selectItem", argMap);
			if(recmap==null) {
				out.print("해당 녹취본이 존재하지 않습니다. (rec_seq="+rec_seq+")");
				return;
			}
			info += "\t"+DateUtil.getToday("yyyyMMddHHmmss") + "|" + recmap.get("rec_datm").toString().replaceAll("-", "").replaceAll(":", "").replaceAll(" ", "") + "|" + recmap.get("local_no") + "|" + recmap.get("rec_filename") + "|" + recmap.get("rec_keycode");
		}
		info = info.substring(1);
	}
	//out.println(info+"<br>");
	//-----------------------------------------------------------

	//다중청취구분자 = "\t" , 필드구분자 : "|";
	String recRecord[] = (!rec_seq.equals("")) ? info.split("\t") : aes.Decrypt(info.split("\t"));//info = 암호화된 정보 + \t + 암호화된 정보 ...
	int recCnt=recRecord.length;
	String recField[][] = new String[recCnt][8];
	for(int i=0; i<recCnt; i++){
		// 다중청취외에는 최대길이가 5이기 때문에 8까지 미리 입력 , 다중청취는 길이 7임
		recField[i] = (recRecord[i]+"||| ").split("\\|");
	}
	String reqDate		= recField[curRecIdx][0];	//청취 요청일시
	String rec_datm		= recField[curRecIdx][1];	//녹취일시
	String local_no		= recField[curRecIdx][2];	//내선번호
	String rec_filename	= recField[curRecIdx][3];	//녹취파일명
	String rec_keycode	= recField[curRecIdx][4];	//녹취 CON ID
	String rec_call_time= recField[curRecIdx][5];	//통화시간
	String user_name	= recField[curRecIdx][6];	//상담원명

	// 파라미터 체크
	if(!CommonUtil.hasText(rec_datm) || !CommonUtil.hasText(local_no) || !CommonUtil.hasText(rec_filename) || !CommonUtil.hasText(rec_keycode)) {
		out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
		return;
	}

	// 요청일시와 현재 시간의 차이를 구함
	Date conn_datm = DateUtil.getDate(DateUtil.getDateFormatByIntVal(reqDate, "yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");
	Date now_datm = DateUtil.getDate(DateUtil.getToday("yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");

	int diff = DateUtil.getDateDiff(conn_datm, now_datm, "M");

	// 5분 이상 차이가 날 경우 로그인 실패 처리
	if(diff>10) {
		out.print(CommonUtil.getPopupMsg("요청가능 시간이 만료되었습니다.","","close"));
		return;
	}

	Map<String, Object> curRec = new HashMap<String, Object>();//현재녹취본

	// 사용권한 체크
	argMap.clear();
	argMap.put("conf_field","url");
	argMap.put("user_id",_LOGIN_ID);
	argMap.put("user_level",_LOGIN_LEVEL);

	if(!"1".equals(db.selectOne("search_config.selectResultPerm", argMap))) {
		out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("ERR_PERM"),"","close"));
		return;
	}

	// S : 다중청취 ===========================================
	String htmlMultiPlay = "";
	String dispMultiPlay = "";
	if(recCnt>1) {
		dispMultiPlay = "";
		for(int i=0; i<recCnt; i++) {
			String trClass = ((i==curRecIdx) ? "odd4" : "");
			htmlMultiPlay +=
				"<tr class='"+ trClass +"' id=mp"+i+">"+
					"<td><a href='#none' onclick='playMulti("+i+")'><u>"+ DateUtil.getDateFormatByIntVal(recField[i][1], "yyyy-MM-dd HH:mm:ss") +"</u></a></td>"+
					"<td>" + recField[i][5] + "</td>"+
					"<td>" + recField[i][6] + "</td>"+
					"<td>" + recField[i][2] + "</td>"+
				"</tr>";
		}
	}
	else{
		dispMultiPlay = "none";
	}
	// E : 다중청취 ===========================================

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
	List<Map<String, Object>> relateRecList = db.selectList("rec_search.selectRelationList", argMap);

	if(relateRecList.size()<1) {
		out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_DATA"),"","close"));
		return;
	}

	// 현재 클릭된 녹취이력 정보 별도 저장
	for(int i=0;i<relateRecList.size();i++) {
		if(relateRecList.get(i).get("rec_filename").toString().equals(rec_filename)) {
			curRec = relateRecList.get(i);
			break;
		}
	}

	// 파일명이 일치하는 데이터가 없을 경우 첫번째 이력으로 데이터 셋팅
	if(curRec.size()<1) {
		curRec = relateRecList.get(0);
	}

	// S : 연관녹취이력 ===========================================
	String htmlRelateRecord = "";
	String dispRelateRecord = "";
	if(relateRecList.size()>1) {
		dispRelateRecord = "";
		for(Map<String, Object> item : relateRecList) {
			htmlRelateRecord +=
				"<tr class='" + (rec_filename.equals(item.get("rec_filename").toString()) ? "odd4" : "") + "'>"+
					"<td><a href='#none' "+
						"onclick=\"playRecFileLink('"+item.get("rec_datm")+"', '" + item.get("local_no") + "', '" + item.get("rec_filename") + "', '" + rec_keycode + "','"+loc+"');\"><u>" + item.get("rec_datm") + "</u></a></td>"+
					"<td>" + item.get("rec_call_time") + "</td>"+
					"<td>" + item.get("user_name") + "</td>"+
					"<td>" + item.get("local_no") + "</td>"+
				"</tr>";
		}
	}
	else{
		dispRelateRecord = "none";
	}
	// E : 연관녹취이력 ===========================================

	// 청취 URL 생성
	String file_url = getListenURL2("LISTEN", curRec, logger, sType);
	if(Finals.isDev) file_url = "../test/wav/20161219142443_122139.wav"; //개발 : 이수철
	//if(Finals.isDev) file_url = "http://192.168.0.115:8889/20170712132127_7858.wav";
	//if(Finals.isDev) file_url = "http://192.168.0.115:8888/?refer=ZjPhCD9M55IRFodh0aYkZw/3dCsTdZRPdzB30xoe0ludKUEK7ydEhhUdQXOeh/7RHXYWgY+CF+V5/nH9rnXjIg==.wav";

	String fft_ext = ("88".equals(curRec.get("system_code").toString())) ? "nmf" : "fft";
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
	argMap.put("rec_datm",curRec.get("rec_datm").toString());
	argMap.put("rec_keycode",curRec.get("rec_keycode").toString());
	argMap.put("rec_filename",curRec.get("rec_filename").toString());
	argMap.put("user_id",curRec.get("user_id").toString());
	argMap.put("user_name",curRec.get("user_name").toString());
	argMap.put("local_no",curRec.get("local_no").toString());
	argMap.put("reason_code",reason_code);
	argMap.put("reason_text",reason_text);
	argMap.put("listen_src","");

	int ins_cnt = db.insert("hist_listen.insertListenHist", argMap);

	// 평가자이고, 녹취조회에서 호출 될 때만 평가하기 버튼 있음
	String dispEvalButton = (Site.isEvaluator(request) && loc.equals("rec")) ? "" : "none";

	// 평가하기 > 이벤트목록
	String eval_user_id = session.getAttribute("login_id").toString();//로그인자가 평가하기시 평가자가 됨
	List<Map<String, Object>> event_list;
	String htmEventCombo = "";
	if(dispEvalButton.equals("")){
		argMap.clear();
		argMap.put("eval_user_id", eval_user_id);		//평가자ID
		argMap.put("user_id", curRec.get("user_id"));	//상담원ID
		argMap.put("event_date", DateUtil.getToday("yyyyMMdd"));

		event_list = db.selectList("event.selectCanEvalEventList", argMap);
		htmEventCombo = "<option value=''>이벤트선택</option>";
		if(event_list.size()==0){
			htmEventCombo = "<option value=''>해당 녹취본에 평가 가능한 이벤트가 없습니다.</option>";
		}
		else{
			htmEventCombo = "<select name=event_code class='form-control eva_form2'>";
			for(Map<String, Object> item : event_list) {
				htmEventCombo += "<option value='"+item.get("event_code")+"'>"+item.get("event_name")+"</option>";
			}
			htmEventCombo += "</select><button type='button' name='btn_goEval' class='btn btn-primary btn-sm' onclick='goEvaluation();'>평가바로가기</button>";
		}
	}


	// 브라우저 체크
	String ua = request.getHeader("User-Agent");
	String profix = "mb";
	// IE 체크
	if(ua.toLowerCase().indexOf("trident")>0) {
		profix = "ie8";
	}
	String includePlayer = "player_"+profix+".jsp";
%>
<jsp:include page="/include/popup.jsp" flush="false"/>

<title>청취 플레이어 </title>

<style>
/* 부분청취 display */
.partRecord {display:<%=ComLib.getCssDisplayStr(Finals.isExistPartRecord)%> !important;}
</style>

<link href="../css/player_<%=profix%>.css" rel="stylesheet">
<link href="../css/player.css" rel="stylesheet">

<script type="text/javascript" src="../js/plugins/wave/waveform.js"></script>
<script type="text/javascript" src="../js/player_<%=profix%>.js"></script>
<script type="text/javascript" src="../js/player.js"></script>

<% if("mb".equals(profix)) { %>
	<script type="text/javascript" src="../js/plugins/jplayer/jquery.jplayer.min.js"></script>
	<script type="text/javascript" src="../js/plugins/wave/swfobject.js"></script>
	<script type="text/javascript" src="../js/plugins/wave/wavesurfer.min.js"></script>
	<script type="text/javascript" src="../js/plugins/wave/wavesurfer.swf.js"></script>
<% } %>
<script type="text/javascript" src="../js/common.js"></script>

<script type="text/javascript">

//청취/다운 사유입력 유무
var isExistPlayDownReason = <%=Finals.isExistPlayDownReason%>;
var recCnt = <%=recCnt%>;
var file_url = "<%=file_url%>";
var fft_ext = "<%=fft_ext%>";
var rec_datm = "<%=rec_datm%>";
var local_no = "<%=local_no%>";
var rec_filename = "<%=rec_filename%>";
//var wave_type = "canvas";
var wave_type = "img2";
//var wave_type = "img";

var info = "<%=info%>";
var reason_code = "<%=reason_code%>";
var reason_text = "<%=reason_text%>";

function playMulti(idx){
	if(idx>recCnt-1) return;//마지막 녹취파일이 재생이 끝나면 멈춘다.
	fMultiPlay.curRecIdx.value=idx;
	fMultiPlay.submit();
}
function goNextPlay(){
	playMulti(parseInt(fMultiPlay.curRecIdx.value)+1);
}
function showEvaluation(){
	//E("divBtnshowEval").style.display="none";
	$("#ui-evaluation").removeClass("hidden").addClass("show");
}
function goEvaluation(){
	// 새로운 팝업으로 평가하기 띄우기 , false 이면 현재창에 바로 띄우기
	var isNewPopup = true;

	var eventObj = $("#eval select[name=event_code]");
	if (eventObj.val()==""){
		alert("이벤트를 먼저 선택하세요!");
		eventObj.focus();
		return;
	}
	if(isNewPopup){
		//window.close();
		var recDatm = dateToStr(strToDate(rec_datm),"yyyy-MM-dd HH:mm:ss");
		var url = "../eval/eval_form.jsp?event_code="+eventObj.val()  +"&eval_user_id="+$("#eval input[name=eval_user_id]").val()  +"&rec_seq="+$("#eval input[name=rec_seq]").val()
				 +"&rec_datm="+recDatm  +"&user_id="+$("#eval input[name=user_id]").val();
		openPopup(url,"_eval_form","900","600","yes","center");
	}
	else{
		window.resizeTo(900,600);
		$("#eval").submit();
	}
}

window.onload = function(){
	try{
		// 평가자이면 평가하기 버튼 보이기
		E("divBtnshowEval").style.display = "<%=dispEvalButton%>";

		//다중청취 인 경우 해당 리스트로 자동 스크롤 함
		var curObjHeight = document.getElementById("mp" + fMultiPlay.curRecIdx.value).offsetTop;
		$('#divMultiPlayList').scrollTop(curObjHeight);
	}catch(e){}
}
</script>

<body class="white-bg">

<form name=fMultiPlay method=post>
<input type=hidden name=curRecIdx value=<%=curRecIdx%>>
<input type=hidden name=info value="<%=info%>">
</form>

<div id="container" style="width: 556px">
	<div class="memo-body">
		<!--녹음파일 파형 영역 시작-->
		<div id="outer_waveform" class="p-frame1 tableSize4">
			<div id="waveform"></div>
			<p id="curtime"></p>
		</div>
		<!--녹음파일 파형 영역 끝-->
		<!--플레이어 영역-->
			<jsp:include page="<%=includePlayer%>" flush="false">
			<jsp:param name="type" value="<%=sType%>" />
			</jsp:include>
		<!--플레이어 영역 끝-->

		<!--S:다중청취 table-->
		<div class="tableSize4 p-space" style=margin-top:0px;padding:0;height:75px;overflow-y:auto;display:<%=dispMultiPlay%> id=divMultiPlayList>
			<table class="table top-line1 table-bordered" style=margin:0>
				<thead>
					<tr>
						<th style="width:35%;">다중청취 녹취일시</th>
						<th style="width:23%;">통화시간</th>
						<th style="width:22%;">상담사명</th>
						<th style="width:20%;">내선번호</th>
					</tr>
				</thead>
				<tbody>
				<%=htmlMultiPlay%>
				</tbody>
			</table>
		</div>
		<!--E:다중청취 table-->

		<!--S : 평가하기 > 이벤트선택-->
		<div class="ibox hidden" id="ui-evaluation">
			<div class="p-dialog">
				<div class="p-content">
					<div class="p-header">
						<button type="button" class="close"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
						<h4 class="p-title">평가하기</h4>
					</div>
					<div class="p-body">
						<div class="cc">
							<form id="eval" name="eval" action="../eval/eval_form.jsp">
								<input type="hidden" name="eval_user_id" value="<%=eval_user_id%>"/>
								<input type="hidden" name="user_id" value="<%=curRec.get("user_id")%>"/>
								<input type="hidden" name="rec_seq" value="<%=curRec.get("rec_seq")%>"/>
								<input type="hidden" name="rec_date" value="<%=rec_date%>"/>
								<%=htmEventCombo%>
							</form>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!--E : 평가하기 > 이벤트선택-->

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
								<input type="text" class="form-control play-form" id="" name="mk_stime" placeholder="00:00:00"> ~
								<input type="text" class="form-control play-form" id="" name="mk_etime" placeholder="00:00:00">
								<button type="button" name="btn_marking" class="btn btn-primary btn-sm" onclick="regiMarking();">마킹</button>
							</form>
						</div>
					</div>
				</div>
			</div>
			<!--마킹하기 팝업창 끝-->
		</div>
		<!--ibox 끝-->

		<!--ibox 시작-->
		<div class="ibox hidden" id="ui-part">
			<!--부분녹취 팝업창 띄우기-->
			<div class="p-dialog">
				<div class="p-content partRecord">
					<div class="p-header">
						<button type="button" class="close"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
						<h4 class="p-title">부분녹취</h4>
					</div>
					<div class="p-body">
						<div class="cc">
							<form id="part">
								<input type="hidden" name="rec_datm" value=""/>
								<input type="hidden" name="local_no" value=""/>
								<input type="hidden" name="rec_filename" value=""/>

								<span>구간 &nbsp;</span>
								<input type="text" class="form-control play-form" id="" name="pa_stime" placeholder="00:00:00"> ~
								<input type="text" class="form-control play-form" id="" name="pa_etime" placeholder="00:00:00">
								<button type="button" name="btn_part" class="btn btn-primary btn-sm" onclick="regiPart();">추출</button>
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
					<td style="width:65%;"><%=curRec.get("rec_datm") %> (<%=curRec.get("rec_call_time") %>)</td>
				</tr>
				</thead>
				<tr>
					<td class="table-td">상담원ID</td>
					<td><%=curRec.get("user_id") %></td>
				</tr>
				<tr>
					<td class="table-td">상담사명</td>
					<td><%=curRec.get("user_name") %></td>
				</tr>
				<tr>
					<td class="table-td">내선번호</td>
					<td><%=curRec.get("local_no") %></td>
				</tr>
			</table>
		</div>
		<!--녹취 이력 정보 table 끝-->

		<!--연관 녹취 이력 table-->
		<div class="tableSize4 p-space" style=display:<%=dispRelateRecord%>>
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
				<%=htmlRelateRecord%>
				</tbody>
			</table>
		</div>
		<!--연관 녹취 이력 table 끝-->
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
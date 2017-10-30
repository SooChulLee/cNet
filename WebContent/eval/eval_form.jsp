<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
// 메뉴 접근권한 체크
if(!Site.isPmss(out,"eval","close")) return;
Db db = null;

try {
	// DB Connection
	db = new Db(true);

	int userViewDepth = Site.getDepthByUserLevel(_LOGIN_LEVEL);

	// get parameter
	String step = CommonUtil.getParameter("step", "regi");
	String event_code = CommonUtil.getParameter("event_code");
	String eval_order = CommonUtil.getParameter("eval_order","0");
	String eval_user_id = CommonUtil.getParameter("eval_user_id");
	String rec_seq = CommonUtil.getParameter("rec_seq");
	String rec_datm = CommonUtil.getParameter("rec_datm");
	String rec_date = rec_datm.replaceAll("-", "").substring(0,8);
	String user_id = CommonUtil.getParameter("user_id");
	String result_seq = CommonUtil.getParameter("result_seq");
	//ComLib.writeParameters(request,out);

	// 파라미터 체크
	if(!CommonUtil.hasText(event_code) || !CommonUtil.hasText(eval_user_id) || !CommonUtil.hasText(rec_seq) || !CommonUtil.hasText(rec_datm) || !CommonUtil.hasText(user_id)) {
		out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
		return;
	}

	Map<String,Object> argMap = null;

	//S : 이벤트 및 시트정보 조회 --------------------------------------------------------------
	String event_name = "", event_status = "", eval_order_max="", sheet_code = "", sheet_item_cnt = "", sheet_tot_score = "";
	argMap = new HashMap();
	argMap.put("event_code", event_code);

	Map<String, Object> evtmap  = db.selectOne("event.selectItem", argMap);

	if(evtmap!=null) {
		event_name = evtmap.get("event_name").toString();
		event_status = evtmap.get("event_status").toString();
		eval_order_max = evtmap.get("eval_order_max").toString();
		sheet_code = evtmap.get("sheet_code").toString();
		sheet_item_cnt = evtmap.get("item_cnt").toString();
		sheet_tot_score = evtmap.get("tot_score").toString();
	} else {
		out.print(CommonUtil.getPopupMsg("이벤트 데이터 조회에 실패했습니다.","","close"));
	}
	//E : 이벤트 및 시트정보 조회 --------------------------------------------------------------


	//S : 이벤트내 상담원 평가차수 정보 조회하여 콤보박스 만들기 -------------------------------------
	argMap.clear();
	argMap.put("event_code", event_code);//이벤트코드
	argMap.put("user_id", user_id);//상담원ID
	argMap.put("rec_seq", rec_seq);//녹취파일시퀀스

	List<Map<String, Object>> eval_order_list = db.selectList("eval_result.selectEvalOrder", argMap);
	String htmEvalOrder = "";
	//첫번째 : 현재평가된 평가차수 : eval_order
	int evalOrder = Integer.parseInt(eval_order_list.get(0).get("eval_order").toString());
	//2번째 : 최대평가차수(eval_order_max) 가 옴
	int evalOrderMax = Integer.parseInt(eval_order_list.get(1).get("eval_order").toString());
	String[] evalOrders = new String[evalOrderMax];
	for(int i=2, len=eval_order_list.size(); i<len; i++){
		int order = Integer.parseInt(eval_order_list.get(i).get("eval_order").toString());
		if(order > evalOrderMax){
			//이벤트 평가차수를 설정(5) 했다가 평가(5) 한 후에 이벤트 평가차수를 낮추는(4) 경우에 발생 가능
			ComLib.viewMessage(out,"이벤트 평가 최대차수("+evalOrderMax+") 보다 현재 기 평가된 평가차수("+order+")가 더 큰 것이 있습니다.\n\n평가관리 > 이벤트 관리 : 이벤트 평가차수를  확인 하세요!","window.close()");
			return;
		}
		evalOrders[Integer.parseInt(eval_order_list.get(i).get("eval_order").toString())-1] = "evaluated";//이미평가했음
	}
	for(int i=0, len=evalOrders.length; i<len; i++){
		htmEvalOrder += "<option value='" + (i+1) + "' "+((evalOrders[i]==null || evalOrder==(i+1)) ? "" : "disabled style=background-color:#eeeeee") +">" + (i+1) + "차</option>";
	}
	//E : 이벤트내 상담원 평가차수 정보 조회하여 콤보박스 만들기 -------------------------------------

	//S : 녹취정보 조회 : 상담원명, 검색어(고객명) 조회 -------------------------------------------
	String user_name="", cust_name="", cust_tel="", guideTel="";
	argMap.clear();
	argMap.put("rec_seq", rec_seq);
	//argMap.put("rec_date", rec_date);
	//argMap.put("user_id", user_id);

	Map<String, Object> recmap  = db.selectOne("eval_rec_search.selectItem", argMap);
	if(recmap!=null) {
		user_name	= ComLib.toNN(recmap.get("user_name"));
		cust_name	= ComLib.toNN(recmap.get("cust_name"));
		cust_tel	= (userViewDepth>-1) ? ComLib.toNN(recmap.get("cust_tel")) : "****";
		guideTel	= ComLib.toNN(recmap.get("guideTel"));//안내번호 : custom_fld_04
	} else {
		out.print(CommonUtil.getPopupMsg("녹취 데이터 조회에 실패했습니다.","","close"));
	}
	//S : 녹취정보 조회 : 상담원명, 검색어(고객명) 조회 -------------------------------------------

	//S : 평가코멘트 콤보박스  -----------------------------------------------------------------
	List<Map<String, Object>> eval_comment = db.selectList("code.selectCodeList", "EVAL_COMMENT");
	String htmEvalComment = "";
	for(Map<String, Object> item : eval_comment) {
		htmEvalComment += "<option value='" + item.get("code_name") + "'>" + item.get("code_name") + "</option>";
	}
	//E : 평가코멘트 콤보박스  -----------------------------------------------------------------

	//평가하기버튼(저장/완료) 보이기, 이의신청버튼 보이기
	String dispEvalButton="none";
	boolean isEvalButton=false;
	boolean isClaimButton=false;
	boolean isClaimRecvButton=false;
	//프린트가 아니고, 이벤트 상태가 진행중 이 아닌 경우 (마감/종료)
	if(!step.equals("print") && !event_status.equals("2")){
		step = "view";
	}
	else if(!step.equals("print") && event_status.equals("2")){
		//프린트 아니고 이벤트 진행중
		dispEvalButton	= "";
		isEvalButton 	= (Site.isEvaluator(request));//평가자
		isClaimButton	= (_LOGIN_ID.equals(user_id.toUpperCase()));//로그인자 상담원 일치
		isClaimRecvButton = (!isEvalButton && userViewDepth >= 1);//팀장급 이상(C/B/A/0)
		step = (!isEvalButton) ? "view" : step;
	}

	String loginPartCode =
			(userViewDepth==1) ? _BPART_CODE+"/"+_MPART_CODE : //팀장
			(userViewDepth>=2) ? _BPART_CODE : "_NOSEE";//센터장 이상
%>
<jsp:include page="/include/popup.jsp" flush="false"/>
<title>평가 수행</title>

<script type="text/javascript">
//청취/다운 사유입력 유무
var isExistPlayDownReason = <%=Finals.isExistPlayDownReason%>;
//평가 완료 버튼 유무
var isExistEvalFinish = <%=Finals.isExistEvalFinish%>;

var userViewDepth = <%=userViewDepth%>;
var isEvalButton  = <%=isEvalButton%>;
var isClaimButton = <%=isClaimButton%>;
var isClaimRecvButton = <%=isClaimRecvButton%>;
var loginPartCode = "<%=loginPartCode%>";
var eval_order = "<%=eval_order%>"; //부모창에서 의  차수 검색조건
var eval_status = "";//평가 조회하여 이값을 세팅한다.
var claimSeqs = new Array();

//라디오버튼 엘리먼트 명을 구해서 아래 배열에 집어 넣는다 : 완료버튼 클릭시 모든 항목 선택 했는지 체크 하기 위함
var examScoreNames = new Array();

$(function () {
	var sheetView = function(step) {
		step = toNN(step);
		var param = {
			event_code	: "<%=event_code%>",
			sheet_code	: "<%=sheet_code%>",
			rec_seq		: "<%=rec_seq%>",
			eval_user_id: "<%=eval_user_id%>",
			user_id		: "<%=user_id%>",
			result_seq	: "<%=result_seq%>"
		};

		$.ajax({
			type: "POST",
			url: "remote_eval_form.jsp",
			data: param,
			async: false,
			dataType: "json",
			success:function(dataJSON){
				//alert(objToStr(dataJSON))
				if(dataJSON.code!="ERR") {
					if(dataJSON.result!=null) {
						eval_status = dataJSON.result.eval_status;
						//로그인자가 상담원이고, 평가상태가 완료 이하의 값이면 볼 권한이 없다.
						if(userViewDepth==-1 && eval_status<'9'){
							alert("완료가 된 평가가 아니므로 상담원은 볼 권한이 없습니다!");
							window.close();
							return;
						}

						//alert("<%=_BPART_CODE%> : <%=_MPART_CODE%> : <%=_SPART_CODE%>")
						//alert(dataJSON.result.bpart_code+":"+dataJSON.result.mpart_code+":"+dataJSON.result.spart_code)

						//S : 버튼 display 속성 ------------------------
						if(eval_status!="9") {//완료 아니면 이의신청 버튼 없음
							isClaimButton = false;
						}
						E("btn_claim").style.display = (isClaimButton) ? "" : "none";

						if(isEvalButton){
							//1:진행, 2:등록, 9:완료, a:이의대기, d:이의신청
							if(eval_status<"9") {//1:진행, 2:등록
								E("btn_save").style.display = "";
								E("btn_finish").style.display = (isExistEvalFinish) ? "" : "none";
							}
							else if(eval_status=="9") {//9:완료
								//E("btn_finish").style.display = (isExistEvalFinish) ? "" : "none";
								E("btn_save").style.display = "";
							}
						}
						//S : 버튼 display 속성 ------------------------

						// print mode
						if(step.isIn("print","view")) {
							// input hide
							$("#regi select[name=eval_comment_select]").addClass("hidden");
							$("#regi textarea[name=eval_comment]").addClass("hidden");
							$("#regi textarea[name=eval_text]").addClass("hidden");
							$("#regi select[name=eval_rate_code]").addClass("hidden");
							$("#regi select[name=eval_order]").addClass("hidden");
							$("#regi input[name=eval_score]").addClass("hidden");

							// span show & value set
							$("#regi #txt_eval_comment").removeClass("hidden").html(dataJSON.result.eval_comment);
							$("#regi #txt_eval_text").removeClass("hidden").html(dataJSON.result.eval_text);
							$("#regi #txt_eval_rate_code").removeClass("hidden").html(dataJSON.result.eval_rate_code_desc);
							$("#regi #txt_eval_order").removeClass("hidden").html(dataJSON.result.eval_order+"차");
							$("#regi #txt_eval_score").removeClass("hidden").html(dataJSON.result.eval_score);
							if(step=="print")$("#divBasicButton").addClass("hidden");

						} else {
							$("#regi textarea[name=eval_comment]").val(dataJSON.result.eval_comment);
							$("#regi textarea[name=eval_text]").val(dataJSON.result.eval_text);
							$("#regi select[name=eval_rate_code]").val(dataJSON.result.eval_rate_code);
							$("#regi select[name=eval_order]").val(dataJSON.result.eval_order);
							$("#regi input[name=eval_score]").val(dataJSON.result.eval_score);
						}

						// 평가 데이터 표시
						$("#eval_date").html(dataJSON.result.regi_datm.substr(0,10));
						$("#eval_status_desc").html(fn.getValue("eval_status_htm",eval_status));
						$("#eval_rate_code_desc").html("(" + dataJSON.result.eval_rate_code_desc + ")");
						$("#eval_user_name").html((userViewDepth>-1) ? dataJSON.result.eval_user_name : "****");
						$("#eval_score").html(dataJSON.result.eval_score);

					} else {
						//S : 버튼 display 속성 ------------------------
						E("btn_claim").style.display = "none";
						if(isEvalButton){
							E("btn_save").style.display = "";
							E("btn_finish").style.display = (isExistEvalFinish) ? "" : "none";
						}
						//S : 버튼 display 속성 ------------------------

						// 평가상태/점수
						$("#eval_status_desc").html(fn.getValue("eval_status_htm","x"));//미평가
						$("#eval_score").html("0");
						//이전 부모창에서 선택된 차수가 Disabled(이미평가)가 아니면 그 차수를 기본으로 선택한다.
						if(getObjectByValue(regi.eval_order,eval_order).disabled){alert(eval_order+"차 평가는 이미 이루어 졌습니다.")}
						else{$("#regi select[name=eval_order]").val(eval_order);}

					}

					// result_item
					var html = "";
					var examScoreNamesIdx = 0;
					var examScoreName_old = "";
					if(dataJSON.data.length>0) {
						var cp_idx=0, ca_idx=0, it_idx=0, n=0, odd="";
						for(var i=0;i<dataJSON.data.length;i++) {
							html += "<tr>\n";

							if(cp_idx<1) {
								html += "<td class='t-left' rowspan='" + dataJSON.rs_pcate[dataJSON.data[i].cate_pcode] + "'>" + dataJSON.data[i].cate_pname + "</td>\n";
								cp_idx = parseInt(dataJSON.rs_pcate[dataJSON.data[i].cate_pcode])-1;
							} else {
								cp_idx--;
							}

							if(ca_idx<1) {
								html += "<td class='t-left' rowspan='" + dataJSON.rs_cate[dataJSON.data[i].cate_code] + "'>" + dataJSON.data[i].cate_name + "</td>\n";
								ca_idx = parseInt(dataJSON.rs_cate[dataJSON.data[i].cate_code])-1;
							} else {
								ca_idx--;
							}

							if(it_idx<1) {
								odd = (n%2==1) ? " odd3" : "";
								html += "<td class='t-left" + odd + "' rowspan='" + dataJSON.rs_item[dataJSON.data[i].item_code] + "'>" + dataJSON.data[i].item_name + "</td>\n";
								it_idx = parseInt(dataJSON.rs_item[dataJSON.data[i].item_code])-1;
								n++;
							} else {
								it_idx--;
							}

							html += "<td class='t-left" + odd + "'>" + dataJSON.data[i].exam_name + "</td>\n";

							// print mode
							if(step.isIn("print","view")) {
								html += "<td class='t-center" + odd + "'>" + ((dataJSON.data[i].get_add_score!="0") ? dataJSON.data[i].get_add_score : "") + "</td>\n";
								html += "<td class='t-center" + odd + "'>" + dataJSON.data[i].exam_score + "</td>\n";
								html += "<td class='t-center" + odd + "'>" + ((dataJSON.data[i].get_exam_score!=undefined) ? dataJSON.data[i].get_exam_score : "") + "</td>\n";
							}
							else {
								var addChkStr  = (dataJSON.data[i].get_add_score!=0) ? "checked=checked" : "";
								var examChkStr = (addChkStr=="" && (dataJSON.data[i].get_exam_score!=undefined || (!dataJSON.result && dataJSON.data[i].default_yn=='y'))) ? "checked=checked" : "";
								var examScoreVal = dataJSON.data[i].cate_code +":"+ dataJSON.data[i].item_code +":"+ dataJSON.data[i].exam_code +":"+ dataJSON.data[i].exam_score;
								var	examScoreName= "exam_score_"+ dataJSON.data[i].cate_code +""+ dataJSON.data[i].item_code;//라디오버튼 이름;
								html += "<td class='t-center" + odd + "'>" + ((dataJSON.data[i].add_score!=0) ? "<input type='radio' name='" + examScoreName + "' value='" +examScoreVal+":"+ dataJSON.data[i].add_score + "'" + addChkStr + " onclick=chgScore(this) />" : "") + "</td>\n";
								html += "<td class='t-center" + odd + "'>" + dataJSON.data[i].exam_score + "</td>\n";
								html += "<td class='t-center" + odd + "'><input type='radio' name='"+ examScoreName +"' value='"+ examScoreVal+":0'"+ examChkStr + " onclick=chgScore(this) /></td>\n";
								//평가항목 Elements Name 저장 : 평가완료시 평가항목 모두 평가했는지 체크하기 위함
								if(examScoreName!=examScoreName_old) examScoreNames[examScoreNamesIdx++] = examScoreName;
								examScoreName_old = examScoreName;
							}
							html += "</tr>\n";
						}
					} else {
						html = "<tr><td colspan='7'>시트 데이터가 없습니다.</td></tr>";
					}
					$("#sheet").html(html);

					//이의신청
					if(dataJSON.claimList.length>0) {
						var divClaimList = E("divClaimList");
						divClaimList.innerHTML = "";
						for(var i=0, len=dataJSON.claimList.length; i<len ;i++) {
							divClaimList.innerHTML += E("claimListTemp").innerHTML;
							var claim_datm		= Es("claim_datm")[i];
							var claim_user_name	= Es("claim_user_name")[i];
							var claim_contents	= Es("claim_contents")[i];
							var recv_datm		= Es("recv_datm")[i];
							var recv_user_name	= Es("recv_user_name")[i];
							var proc_datm		= Es("proc_datm")[i];
							var proc_user_name	= Es("proc_user_name")[i];
							var proc_contents	= Es("proc_contents_txt")[i];
							var claim_status	= Es("claim_status_txt")[i];

							var btn_claim_proc	= Es("btn_claim_proc")[i];
							var btn_claim_recv	= Es("btn_claim_recv")[i];
							claimSeqs[i] = dataJSON.claimList[i].claim_seq;

							claim_datm.innerHTML		= dataJSON.claimList[i].claim_datm;
							claim_user_name.innerHTML	= dataJSON.claimList[i].claim_user_name;
							claim_contents.innerHTML	= dataJSON.claimList[i].claim_contents;
							recv_datm.innerHTML			= toNN(dataJSON.claimList[i].recv_datm,"<font color=gray>-</font>");
							recv_user_name.innerHTML	= toNN(dataJSON.claimList[i].recv_user_name,"<font color=gray>-</font>");
							proc_datm.innerHTML			= toNN(dataJSON.claimList[i].proc_datm,"<font color=gray>-</font>");
							proc_user_name.innerHTML	= toNN(dataJSON.claimList[i].proc_user_name,"<font color=gray>-</font>");
							proc_contents.innerHTML		= toNN(dataJSON.claimList[i].proc_contents,"<font color=gray>-</font>");
							claim_status.innerHTML		= toNN(fn.claim_status[dataJSON.claimList[i].claim_status],dataJSON.claimList[i].claim_status);

							if(isEvalButton){
								if(dataJSON.claimList[i].claim_status.isIn("a","d")) {
									//평가자이면서 이의대기/이의신청 상태 이면 이의처리 할 수 있다
									btn_claim_proc.style.display="";
								}
							}
							else if(isClaimRecvButton && dataJSON.claimList[i].claim_status=="a"){
								//상담원 소속그룹(조직) 코드
								var userPartCode = dataJSON.result.bpart_code+"/"+dataJSON.result.mpart_code+"/"+dataJSON.result.spart_code;
								var isClaimRecv = (userPartCode.indexOf(loginPartCode)==0);
								if(isClaimRecv){
									btn_claim_recv.style.display="";
								}
								//여기에 조직도 팀장 이상의 상위 권한자이면 이의접수처리 가능하게 한다.
							}
						}
						$("#divClaim").removeClass("hidden").addClass("show");
					}

					// print mode
					if(step=="print") {
						self.focus();
						window.print();
					}
				}
			},
			error:function(req,status,err){
				alertJsonErr(req,status,err);
				return;
			}
		});
	};

	// 평가 저장/완료
	var evalProc = function(evalStatus) {
		var txt = "", type = "";

		if(evalStatus=="9") {
			//평가완료시 모든 항목 평가했는지 체크
			if(!isAllItemEvaluation()){
				alert("평가 완료를 하기 위해서는 모든 항목을 평가 하셔야 합니다.");
				return;
			}
			txt = "완료";
		} else {
			evalStatus = (!eval_status.isIn("1","2","")) ? "" : (!isAllItemEvaluation()) ? "1" : "2";// 완료(9) / 진행(1) / 등록(2)
			var radioSelVal = $("#regi input[type=radio]:checked").val();
			var checkSelVal	= $("#regi input[type=checkbox]:checked").val();
			if(radioSelVal==undefined && checkSelVal==undefined){
				alert("평가 저장을 하기 위해서는 적어도 하나 이상의 항목을 평가 하셔야 합니다.");
				return;
			}
			txt = "저장";
		}

		if(!$("#regi select[name=eval_order]").val()){
			alert("평가차수를 선택하셔야 합니다.");
			$("#regi select[name=eval_order]").focus();
			return;
		}

		$.ajax({
			type: "POST",
			url: "remote_eval_form_proc.jsp",
			async: false,
			data: "step=save&eval_status="+evalStatus+"&"+$("#regi").serialize(),
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					try{window.opener.$("#record_search button[name=btn_search]").click();}catch(e){}	//평가수행
					try{window.opener.$("#search button[name=btn_search]").click();}catch(e){}			//평가결과조회

					alert("정상적으로 " + txt + " 되었습니다.");

					if(evalStatus.isIn("1","2")) {
						//저장
						sheetView();
					} else {
						//완료
						self.close();
					}
					return true;
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

	// 평가 저장
	$("button[name=btn_save]").click(function() {
		evalProc();
	});

	// 평가 완료
	$("button[name=btn_finish]").click(function() {
		evalProc("9");
	});

	// 닫기 버튼 클릭
	$("button[name=btn_pop_close]").click(function() {
		self.close();
	});

	// 이의신청
	$("button[name=btn_claim]").click(function() {
		$("#modalClaim").modal("toggle");
		claim.claim_contents.focus();
	});

	//이의신청 > 이의신청 하기
	$("#modalClaim button[name=modal_regi]").click(function() {
		//$("#claim textarea[name=claim_contents]")
		if(trimObj(claim.claim_contents)==""){
			alert("이의 내용을 작성 하세요.");
			claim.claim_contents.focus();
			return;
		}
		var yn = confirm("작성하신 내용으로 이의신청 하시겠습니까?");
		if(!yn) return;

		var data = arrToJson($("#claim").serializeArray());
		data["act"]="claim";
		$.ajax({
			type: "POST",
			url: "remote_eval_form_claim_proc.jsp",
			async: false,
			dataType: "json",
			data: data,
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					try{window.opener.$("#record_search button[name=btn_search]").click();}catch(e){}	//평가수행
					try{window.opener.$("#search button[name=btn_search]").click();}catch(e){}			//평가결과조회
					$("#modalClaim").modal("hide");
					alert("이의신청이 완료 되었습니다.");
					//claim.reset();
					document.location.reload();
				} else {
					alert(dataJSON.msg);
				}
			},
			error:function(req,status,err){
				alert("에러가 발생하였습니다.	[" + req.responseText +	"]");
			}
		});
	});

	//이의접수
	$("#modalClaimRecv button[name=modal_regi]").click(function() {
		var claimStatus = $("#claimRecv input[name=claim_status]:checked").val();
		if(!claimStatus){
			alert("[접수여부]를 선택 하세요.");
			return;
		}
		if(claimStatus=='b' && trimObj(claimRecv.proc_contents)==""){
			alert("반려시 반드시 [사유]를 작성 하셔야 합니다.");
			claimRecv.proc_contents.focus();
			return;
		}
		var yn = confirm("작성하신 내용으로 이의접수를 처리 하시겠습니까?");
		if(!yn) return;

		//접수자 이의접수여부가 접수이면 사유는 없앤다.
		if(claimStatus=='d') claimRecv.proc_contents.value = "";

		var data = arrToJson($("#claimRecv").serializeArray());
		data["act"]="claimRecv";
		$.ajax({
			type: "POST",
			url: "remote_eval_form_claim_proc.jsp",
			async: false,
			dataType: "json",
			data: data,
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					try{window.opener.$("#record_search button[name=btn_search]").click();}catch(e){}	//평가수행
					try{window.opener.$("#search button[name=btn_search]").click();}catch(e){}			//평가결과조회
					$("#modalClaimProc").modal("hide");
					alert("이의처리가 완료 되었습니다.");
					document.location.reload();
				} else {
					alert(dataJSON.msg);
				}
			},
			error:function(req,status,err){
				alert("에러가 발생하였습니다.	[" + req.responseText +	"]");
			}
		});
	});

	//이의처리 하기
	$("#modalClaimProc button[name=modal_regi]").click(function() {
		var claimStatus = $("#claimProc input[name=claim_status]:checked").val();
		if(!claimStatus){
			alert("[접수여부]를 선택 하세요.");
			return;
		}
		if(claimStatus=='f' && trimObj(claimProc.proc_contents)==""){
			alert("반려시 반드시 [사유]를 작성 하셔야 합니다.");
			claimProc.proc_contents.focus();
			return;
		}
		var yn = confirm("작성하신 내용으로 이의신청을 처리 하시겠습니까?");
		if(!yn) return;

		var data = arrToJson($("#claimProc").serializeArray());
		data["act"]="claimProc";
		$.ajax({
			type: "POST",
			url: "remote_eval_form_claim_proc.jsp",
			async: false,
			dataType: "json",
			data: data,
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					try{window.opener.$("#record_search button[name=btn_search]").click();}catch(e){}	//평가수행
					try{window.opener.$("#search button[name=btn_search]").click();}catch(e){}			//평가결과조회
					$("#modalClaimProc").modal("hide");
					alert("이의처리가 완료 되었습니다.");
					document.location.reload();
				} else {
					alert(dataJSON.msg);
				}
			},
			error:function(req,status,err){
				alert("에러가 발생하였습니다.	[" + req.responseText +	"]");
			}
		});
	});

	sheetView("<%=step%>");
});

//평가코멘트 콤보박스에서 선택하면 자동 입력하기
function putEvalComment(obj){
	var evalVal = obj.value
	regi.eval_comment.focus();
	regi.eval_comment.value = evalVal;
	obj.value = "";
}
function isAllItemEvaluation(){
	for(var i=0;i<examScoreNames.length;i++){
		var val = $("#regi input[name="+examScoreNames[i]+"]:checked").val();
		if(val==undefined) return false;
	}
	return true;

}
function chgClaimRecvStatus(obj){
	//접수
	if(obj.value=='d'){
		E("divRecvProcContents").style.display = "none";
		$("#modalClaimRecv button[name=modal_regi]").click();
	}
	else{
		E("divRecvProcContents").style.display = "";
		claimRecv.proc_contents.focus();
	}
}
function chgClaimProcStatus(obj){
	claimProc.proc_contents.focus();
}
function goCraimRecv(obj){
	claimRecv.claim_seq.value = claimSeqs[getObjIndex(obj)];
	$("#modalClaimRecv").modal("toggle");

}
function goCraimProc(obj){
	claimProc.claim_seq.value = claimSeqs[getObjIndex(obj)];
	$("#modalClaimProc").modal("toggle");
}
function chgScore(obj){
	//alert(obj.name+" = "+obj.value);
	var score=0, totScore=0;
	for(var i=0;i<examScoreNames.length;i++){
		//alert(getSelectedRadioValue(Es(examScoreNames[i])));
		var scoreArray = (getSelectedRadioValue(Es(examScoreNames[i]))).split(":");
		score = (scoreArray.length==1) ? 0 : parseInt(scoreArray[3])+parseInt(scoreArray[4]);
		totScore += score;
	}
	$("#regi input[name=eval_score]").val(totScore);
}

document.body.onkeyup = function(){
	//F8 클릭시 청취창 호출
	//alert(event.keyCode)
	if(event.keyCode=='119') $("#linkPlay").click();
}
</script>

<style>
.evalButton {display:<%=dispEvalButton%>;}
</style>

<body class="white-bg">

<div id="container" style="width: 900px; padding: 2px;">
<form id="regi">
	<input type="hidden" name="event_code" value="<%=event_code%>"/>
	<input type="hidden" name="sheet_code" value="<%=sheet_code%>"/>
	<input type="hidden" name="rec_seq" value="<%=rec_seq%>"/>
	<input type="hidden" name="rec_date" value="<%=rec_date%>"/>
	<input type="hidden" name="eval_user_id" value="<%=eval_user_id%>"/>
	<input type="hidden" name="user_id" value="<%=user_id%>"/>
	<input type="hidden" name="result_seq" value="<%=result_seq%>"/>

	<div class="popup-header">
		<button type="button" name="btn_pop_close" class="close"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
		<h4 class="popup-title">평가 수행 / 결과 조회</h4>
	</div>
	<div class="memo-body tableRadius2" style="padding-top: 15px;">
		<!--기본 정보 영역-->
		<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">기본 정보</h5>
		<div class="tableRadius5 t-space">
			<div class="evaDiv2">
				<div id="labelDiv">
					<label class="simple_tag2">이벤트 명</label>
					<label class="i-space"><%=event_name%></label>
				</div>
			</div>

			<div class="evaDiv2">
				<div id="labelDiv">
					<label class="simple_tag2">평가 일자</label>
					<label class="i-space"><span id="eval_date"></span></label>
				</div>
			</div>

			<div class="evaDiv2">
				<div id="label_Div">
					<label class="simple_tag2">평가상태</label>
					<label class="i-space"><span id="eval_status_desc"></span> <span id="eval_rate_code_desc"></span></label>
				</div>
			</div>

			<div class="evaDiv2">
				<div id="labelDiv">
					<label class="simple_tag2">평가자 명</label>
					<label class="i-space"><span id="eval_user_name"></span></label>
				</div>
			</div>

			<div class="evaDiv2">
				<div id="labelDiv">
					<label class="simple_tag2">상담원 명</label>
					<label class="i-space"><%=user_name%></label>
				</div>
			</div>

			<div class="evaDiv2">
				<div id="labelDiv">
					<label class="simple_tag2">상담원 ID</label>
					<label class="i-space"><%=user_id%></label>
				</div>
			</div>

			<div class="evaDiv2">
				<div id="label_Div">
					<label class="simple_tag2">발신번호</label>
					<label class="i-space"><%=cust_tel%></label>
				</div>
			</div>

			<div class="evaDiv2">
				<div id="label_Div">
					<label class="simple_tag2">검색어</label>
					<label class="i-space"><%=cust_name%></label>
				</div>
			</div>

			<div class="evaDiv2">
				<div id="label_Div">
					<label class="simple_tag2">안내번호</label>
					<label class="i-space"><%=guideTel%></label>
				</div>
			</div>

			<div class="evaDiv2">
				<div id="label_Div">
					<label class="simple_tag2">총점/배점</label>
					<label class="i-space"><span id="eval_score"></span> / <%=sheet_tot_score%>점 (<%=sheet_item_cnt%>개)</label>
				</div>
			</div>

			<div class="evaDiv2">
				<div id="label_Div">
					<label class="simple_tag2">녹취 일시</label>
					<label class="i-space"><%=rec_datm%></label>
				</div>
			</div>

			<div class="evaDiv2">
				<div id="label_Div">
					<label class="simple_tag2">청취</label>
					<label class="i-space"><a href="#" onclick="playRecFileByRecSeq('<%=rec_seq%>')" id=linkPlay><i class="fa fa-headphones fontIcon"></i></a></label>
				</div>
			</div>

		</div>
		<!--기본 정보 영역 끝-->

		<!--table-->
		<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">평가 상세</h5>
		<table class="table top-line1 table-bordered tt">
			<thead>
				<tr>
					<th colspan="2" style="width:22%;">카테고리</th>
					<th>항목</th>
					<th style="width:30%;">보기</th>
					<th style="width:60px;">가중치</th>
					<th style="width:60px;">배점</th>
					<th style="width:60px;">채점</th>
				</tr>
			</thead>
			<tbody id="sheet">
			</tbody>
		</table>
		<!--table 끝-->

		<!--table-->
		<table class="table table-bordered tt">
			<tr><td style="width:12%;" class="table-td t-left">코멘트</td>
				<td class="t-left">
					<select name="eval_comment_select" onchange="putEvalComment(this)" class="form-control eva_form2" style=width:100%;margin-bottom:1px>
						<option value=''>평가코멘트 선택</option>
						<%=htmEvalComment%>
					</select>
					<textarea class="form-control message-input2" name="eval_comment" placeholder=""></textarea>
					<span id="txt_eval_comment" class="hidden"></span>
				</td>
				<td style="width:12%;" class="table-td t-left">총평</td>
				<td class="t-left">
					<textarea class="form-control message-input2" name="eval_text" placeholder="" style=height:63px></textarea>
					<span id="txt_eval_text" class="hidden"></span>
				</td>
			</tr>

			<tr>
				<td style="width:12%;" class="table-td t-left">베스트/워스트</td>
				<td class="t-left">
					<select class="form-control eva_form2" name="eval_rate_code">
						<option value="0">일반</option>
						<option value="1">베스트</option>
						<option value="2">워스트</option>
					</select>
					<span id="txt_eval_rate_code" class="hidden"></span>
				</td>
				<td style="width:12%;" class="table-td t-left">평가차수</td>
				<td class="t-left">
					<select class="form-control eva_form2" name="eval_order">
						<option value='' selected></option>
						<%=htmEvalOrder%>
					</select>
					<span id="txt_eval_order" class="hidden"></span>
				</td>
			<tr>
				<td style="width:12%;" class="table-td t-left">총점</td>
				<td class="t-left" colspan=3>
					<input type="text" class="form-control eva_form2" name="eval_score" placeholder="" readonly=readonly>
					<span id="txt_eval_score" class="hidden"></span>
				</td>
			</tr>
		</table>
		<!--table 끝-->

		<div style=margin-top:20px id=divClaim  class="hidden">
			<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">이의신청</h5>
			<div id=divClaimList>
			</div>
			<div id=claimListTemp style=display:none>
				<table class="table top-line1 table-bordered tt" style=margin-bottom:4px>
					<thead>
					<tr><th class="table-td" style=width:80px>신청일시</th>
						<td id=claim_datm name=claim_datm style=background-color:white></td>
						<th class="table-td" style=width:80px>신청자</th>
						<td id=claim_user_name name=claim_user_name style=background-color:white></td>
					</thead>
					<tr><th class="table-td" style=width:80px>신청사유</th>
						<td colspan=3 id=claim_contents name=claim_contents></td>
					<tr><th class="table-td" style=width:80px>접수일시</th>
						<td id=recv_datm name=recv_datm></td>
						<th class="table-td" style=width:80px>접수자</th>
						<td id=recv_user_name name=recv_user_name></td>
					<tr><th class="table-td" style=width:80px>처리일시</th>
						<td id=proc_datm name=proc_datm></td>
						<th class="table-td" style=width:80px>처리자</th>
						<td id=proc_user_name name=proc_user_name></td>
					<tr><th class="table-td" style=width:80px>처리메모</th>
						<td colspan=3 id=proc_contents_txt name=proc_contents_txt></td>
					<tr><th class="table-td" style=width:80px>처리상태</th>
						<td colspan=5 style=padding-right:3px>
							<table cellpadding=0 cellspcing=0 width=100%><tr>
							<td id=claim_status_txt name=claim_status_txt></td>
							<td align=right class=evalButton>
								<button type="button" name="btn_claim_recv" class="btn btn-done btn-sm" style='display:none;' onclick=goCraimRecv(this);><i class="fa fa-check-square-o"></i> 이의대기 접수 처리</button>
								<button type="button" name="btn_claim_proc" class="btn btn-done btn-sm" style='display:none;' onclick=goCraimProc(this);><i class="fa fa-check-square-o"></i> 이의처리</button></td>
							</tr>
							</table>
						</td>
					</tr>
				</table>
			</div>
		</div>

	</div>

	<div class="text-center evalButton" style="margin: 15px 0;" id=divBasicButton>
		<button type="button" name="btn_save" class="btn btn-register btn-sm" style=display:none><i class="fa fa-check"></i>  저장</button>
		<button type="button" name="btn_finish" class="btn btn-done btn-sm" style=display:none><i class="fa fa-check-square-o"></i> 완료</button>
		<button type="button" name="btn_claim" class="btn btn-register btn-sm" style=display:none><i class="fa fa-check"></i>  이의신청</button>
	</div>

</form>
</div>

<!-- S : 상담원 이의신청 -->
<div class="modal inmodal" id="modalClaim" tabindex="-1" role="dialog"  aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content animated fadeIn">
			<form id="claim">
				<input type="hidden" name="result_seq" value="<%=result_seq%>"/>
				<input type="hidden" name="claim_user_id" value="<%=_LOGIN_ID%>"/>
				<input type="hidden" name="user_id" value="<%=user_id%>"/>
				<input type="hidden" name="eval_status" value="a"/>
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
					<h4 class="modal-title">이의신청</h4>
				</div>
				<div class="modal-body">
					<table class="table top-line1 table-bordered2">
					<tr><td style="width:46px" class="table-td">이의<br>내용</td>
						<td style="padding: 6px 9px;"><textarea class="form-control message-input2" name="claim_contents" placeholder="" style=height:100px></textarea></td>
					</tr>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" name="modal_regi" class="btn btn-primary btn-sm" prop=""><i class="fa fa-pencil"></i> 이의신청하기</button>
					<button type="button" name="modal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>
				</div>
			</form>
		</div>
	</div>
</div>
<!-- E : 상담원 이의신청 -->

<!-- S : 접수자 이의접수 -->
<div class="modal inmodal" id="modalClaimRecv" tabindex="-1" role="dialog"  aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content animated fadeIn">
			<form id="claimRecv">
				<input type="hidden" name="result_seq" value="<%=result_seq%>"/>
				<input type="hidden" name="claim_seq"/>
				<input type="hidden" name="recv_user_id" value="<%=_LOGIN_ID%>"/>
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
					<h4 class="modal-title">이의대기 처리</h4>
				</div>
				<div class="modal-body">
					<table class="table top-line1 table-bordered2">
					<tr><td style="width:70px" class="table-td">접수여부</td>
						<td style="padding: 6px 9px;">
							<label style=cursor:pointer><input type=radio name=claim_status value='d' onclick=chgClaimRecvStatus(this)> 접수</label>
							<label style=cursor:pointer><input type=radio name=claim_status value='b' onclick=chgClaimRecvStatus(this)> 반려</label>
						</td>
					<tr id=divRecvProcContents style=display:none>
						<td style="width:70px" class="table-td">사유</td>
						<td style="padding: 6px 9px;"><textarea class="form-control message-input2" name="proc_contents" placeholder="" style=height:60px></textarea></td>
					</tr>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" name="modal_regi" class="btn btn-primary btn-sm" prop=""><i class="fa fa-pencil"></i> 이의대기 처리하기</button>
					<button type="button" name="modal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>
				</div>
			</form>
		</div>
	</div>
</div>
<!-- E : 접수자 이의접수 -->

<!-- S : 평가자 이의처리 -->
<div class="modal inmodal" id="modalClaimProc" tabindex="-1" role="dialog"  aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content animated fadeIn">
			<form id="claimProc">
				<input type="hidden" name="result_seq" value="<%=result_seq%>"/>
				<input type="hidden" name="claim_seq"/>
				<input type="hidden" name="proc_user_id" value="<%=_LOGIN_ID%>"/>
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
					<h4 class="modal-title">이의신청 처리</h4>
				</div>
				<div class="modal-body">
					<table class="table top-line1 table-bordered2">
					<tr><td style="width:70px" class="table-td">접수여부</td>
						<td style="padding: 6px 9px;">
							<label style=cursor:pointer><input type=radio name=claim_status value='g' onclick=chgClaimProcStatus(this)> 접수</label>
							<label style=cursor:pointer><input type=radio name=claim_status value='f' onclick=chgClaimProcStatus(this)> 반려</label>
						</td>
					<tr><td style="width:70px" class="table-td">사유</td>
						<td style="padding: 6px 9px;"><textarea class="form-control message-input2" name="proc_contents" placeholder="" style=height:60px></textarea></td>
					</tr>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" name="modal_regi" class="btn btn-primary btn-sm" prop=""><i class="fa fa-pencil"></i> 이의신청 처리하기</button>
					<button type="button" name="modal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>
				</div>
			</form>
		</div>
	</div>
</div>
<!-- E : 평가자 이의처리 -->

</body>

</html>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
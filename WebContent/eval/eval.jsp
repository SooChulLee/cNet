<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"eval","")) return;
	if(!Site.isEvaluator(request)){
		ComLib.viewMessage(out, "평가자가 아닙니다.","history.back()");
		return;
	}

	Db db = null;

	try {
		db = new Db(true);
		Map<String, Object> argMap = new HashMap<String, Object>();


		//이벤트 콤보박스
		String htm_event_list = Site.getEventComboHtml("2", "eval_order_max");
		if(htm_event_list.equals("")) {
			out.print(CommonUtil.getPopupMsg("진행중인 이벤트가 없습니다.","","back"));
			return;
		}

		//평가자 콤보박스
		String htm_eval_user_list = Site.getEvaluatorComboHtml(session, false);

%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
//청취/다운 사유입력 유무
var isExistPlayDownReason = <%=Finals.isExistPlayDownReason%>;
var isEvalUserChgFirst = true;

$(function () {
	E("divLeftListBox").style.height  = parseInt(document.body.offsetHeight)-360+"px";
	E("divRightListBox").style.height = parseInt(document.body.offsetHeight)-360-138+"px";
	
	// 평가자명 선택
	$("#search select[name=eval_user_id]").change(function(){
		getAgentList();
	});
	$("#search select[name=event_code_combo]").change(function(){
		chgEventCode(this);
	});
	$("#search select[name=eval_order]").change(function(){
		chgEventOrder(this);
	});

	// 첫번째 이벤트 선택
	$("#search select[name=event_code_combo] option:eq(0)").prop("selected", true).change();

	// 첫번째 평가자 선택
	//$("#search select[name=eval_user_id] option:eq(0)").prop("selected", true).change();

	// 평가수행 조회버튼 클릭
	$("#search button[name=btn_search1]").click(function() {
		getAgentList();
	});

	// 상담이력 조회버튼 클릭
	$("#record_search button[name=btn_search]").click(function() {
		getRecSearch();
	});

});

// 이벤트 선택
function chgEventCode(obj){
	if(obj.value=="") return;

	var eventInfo = obj.value.split("/");//event_code / eval_order_max
	$("#search input[name=event_code]").val(eventInfo[0]);
	//평가차수 설정하기
	search.eval_order.innerHTML = "";
	for(var i=1; i<=eventInfo[1]; i++){
		search.eval_order.innerHTML += "<option value="+i+">"+i+"차</option>";
	}
	chgEventOrder(this);

	//이벤트 상세정보 조회
	$.ajax({
		type: "POST",
		url: "/common/get_eval_event_data.jsp",
		data: "event_code="+$("#search input[name=event_code]").val(),
		async: false,
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code!="ERR") {
				// 이벤트 상세 정보
				if(dataJSON.data!="") {
					$("#event_info").find("#event_name").html(dataJSON.data.event_name);
					$("#event_info").find("#sheet_name").html(dataJSON.data.sheet_name);
					$("#event_info").find("#event_status_txt").html(fn.getValue("event_status",dataJSON.data.event_status));
					$("#event_info").find("#event_sdate").html(getDateToNum(dataJSON.data.event_sdate,"."));
					$("#event_info").find("#event_edate").html(getDateToNum(dataJSON.data.event_edate,"."));
					$("#event_info").find("#sheet_item_cnt").html(dataJSON.data.item_cnt);
					$("#event_info").find("#eval_order_max").html(dataJSON.data.eval_order_max);
					$("#event_info").find("#sheet_tot_score").html(dataJSON.data.tot_score);
				} else {
					alert("이벤트 데이터가 없습니다.");
					return false;
				}
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
}

function chgEventOrder(obj){
	getAgentList();
}
//평가대상자 조회 (평가자에 배정된 상담원 조회)
var getAgentList = function() {
	$("#record_list").html("");

	$("#search input[name=user_name]").val(trimObj(agentSearch.user_name));
	$.ajax({
		type: "POST",
		url: "remote_eval.jsp",
		data: "step=agent&"+$("#search").serialize(),
		async: false,
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code!="ERR") {
				$("#agent_list").html("");
				$("#record_search input[name=user_id]").val("");
				var html = "";

				// 평가 대상자
				if(dataJSON.data.length>0) {
					var odd = "";
					for(var i=0;i<dataJSON.data.length;i++) {
						odd = (i%2==1) ? " odd" : "";
						html +=	"<tr class='"+ odd +"'>\n"+
								"<td><input type='checkbox' name='user_id' value='" + dataJSON.data[i].user_id + "' onclick=\"clickRecSearch('" + i + "', '" + dataJSON.data[i].user_id + "')\"></td>\n"+
								"<td>" + dataJSON.data[i].bpart_name+"<font color=gray>></font>"+dataJSON.data[i].mpart_name+"<font color=gray>></font>"+dataJSON.data[i].spart_name + "</td>\n"+
								"<td>" + dataJSON.data[i].user_id + "</td>\n"+
								"<td>" + dataJSON.data[i].user_name + "</td>\n"+
								"<td>" + fn.getValue("eval_status_htm",dataJSON.data[i].eval_status) +"</td>";
								"</tr>\n";
					}
				} else {
					html = "<tr><td colspan=\"5\">평가 대상자가 없습니다.</td></tr>";
				}
				//alert(html)
				$("#agent_list").html(html);
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

// 선택한 대상자 상담이력 조회 (checkbox click)
var clickRecSearch = function(idx, user_id) {
	// 전체 선택해제
	checkObject($("#agent input[name=user_id]"), false);

	// 해당 체크박스 선택
	$("#agent input[name=user_id]").eq(idx).prop("checked", true);

	// 선택한 상담원 아이디 셋팅
	$("#record_search input[name=user_id]").val(user_id);

	// 상담이력 조회
	getRecSearch();
};

//상담이력 조회 리턴 json data
var recordJsonData;
//상담이력 조회
var getRecSearch = function() {
	var event_code = $("#search input[name=event_code]").val();
	var eval_user_id = $("#search select[name=eval_user_id]").val();

	if($("#record_search input[name=user_id]").val()=="") {
		alert("평가 대상자를 먼저 선택해 주십시오.");
		return;
	}

	$.ajax({
		type: "POST",
		url: "remote_eval.jsp",
		data: "step=record&event_code="+event_code+"&"+$("#record_search").serialize()+"&cur_page="+$("#record input[name=cur_page]").val()+"&top_cnt="+$("#record select[name=top_cnt]").val(),
		async: false,
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code!="ERR") {
				var html = "";
				$("#record_list").html("");

				// 상담 이력
				if(dataJSON.data.length>0) {
					recordJsonData = dataJSON.data;
					var odd = "";
					for(var i=0;i<dataJSON.data.length;i++) {
						odd = (i%2==1) ? " odd" : "";
						html += "<tr class=\"" + odd + "\">\n";
						html += "	<td><input type=\"checkbox\" name=\"rec_seq\" value=\"" + dataJSON.data[i].rec_seq + "\" onclick=\"popEvalForm('" + i + "', '" + dataJSON.data[i].rec_seq + "', '" + dataJSON.data[i].rec_datm + "', '" + dataJSON.data[i].user_id + "')\"></td>\n";
						html += "	<td>" + strToDateFormat(dataJSON.data[i].rec_date,"yyyy.MM.dd") + "</td>\n";
						html += "	<td>" + dataJSON.data[i].rec_start_time + "</td>\n";
						html += "	<td>" + dataJSON.data[i].rec_call_time + "</td>\n";
						html += "	<td>" + dataJSON.data[i].cust_name + "</td>\n";
						html += "	<td>" + toNN(dataJSON.data[i].custom_fld_04) + "</td>\n";
						html += "	<td><a href=\"#none\" onclick=\"playRecFile('" + dataJSON.data[i].rec_datm + "', '" + dataJSON.data[i].local_no + "', '" + dataJSON.data[i].rec_filename + "', '" + dataJSON.data[i].rec_keycode + "');\"><i class=\"fa fa-headphones fontIcon\"></i></a></td>\n";
						html += "	<td><img src='../img/icon/ico_down.png' onclick=\"downloadRecFileEval('" + i + "');\" style='margin-left: 5px; cursor: pointer;'/></td>\n";
						var order = (dataJSON.data[i].eval_order=="0") ? "" : dataJSON.data[i].eval_order + "차 ";//평가차수
						html += "<td>"+ order + fn.getValue("eval_status_htm",dataJSON.data[i].eval_status) +"</td>";
						html += "</tr>\n";
					}

					// paging
					setPaging("paging", dataJSON.curPage, dataJSON.totalPages, dataJSON.totalRecords, "getRecSearch");
				} else {
					html = "<tr><td colspan=\"9\">상담 이력이 없습니다.</td></tr>";
				}
				$("#record_list").html(html);
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

// 페이징
var setPaging = function(id, curPage, totPage, totCnt, funcName) {
	var obj = $("#"+id);
	var first = obj.find("[aria-label=First]").children("img");
	var last = obj.find("[aria-label=Last]").children("img");
	var prev = obj.find("[aria-label=Prev]").children("img");
	var next = obj.find("[aria-label=Next]").children("img");
	var cur_page = obj.find("input[name=cur_page]");
	var top_cnt = obj.find("select[name=top_cnt]");

	// 전체 페이지
	obj.find("#tot_page").html(totPage);

	// page direct
	cur_page.keyup(function(e) {
		if(e.keyCode==13) {
			eval(funcName+"();");
		}
	});

	// page per num change
	top_cnt.change(function() {
		eval(funcName+"();");
	});

	// first
	if(curPage!=1) {
		first.prop("src", "../img/button/paging_first.gif");
		first.click(function() {
			cur_page.val("1");
			eval(funcName+"();");
		});
	} else {
		first.prop("src", "../img/button/paging_first_dis.gif");
	}

	// prev
	if(curPage>1) {
		prev.prop("src", "../img/button/paging_prev.gif");
		prev.click(function() {
			cur_page.val(curPage-1);
			eval(funcName+"();");
		});
	} else {
		prev.prop("src", "../img/button/paging_prev_dis.gif");
	}

	// next
	if(curPage<totPage) {
		next.prop("src", "../img/button/paging_next.gif");
		next.click(function() {
			cur_page.val(curPage+1);
			eval(funcName+"();");
		});
	} else {
		next.prop("src", "../img/button/paging_next_dis.gif");
	}

	// last
	if(curPage!=totPage) {
		last.prop("src", "../img/button/paging_last.gif");
		last.click(function(){
			cur_page.val(totPage);
			eval(funcName+"();");
		});
	} else {
		last.prop("src", "../img/button/paging_last_dis.gif");
	}
};

// 평가 등록폼 오픈
var popEvalForm = function(idx, rec_seq, rec_datm, user_id) {
	// 전체 선택해제
	checkObject($("#record input[name=rec_seq]"), false);

	// 해당 체크박스 선택
	$("#record input[name=rec_seq]").eq(idx).prop("checked", true);

	var event_code = $("#search input[name=event_code]").val();
	var eval_user_id = $("#search select[name=eval_user_id]").val();
	var eval_order = $("#search select[name=eval_order]").val();
	// 팝업 오픈
	var popupHeight = parseInt(screen.height)-110;
	openPopup("eval_form.jsp?event_code="+event_code+"&eval_order="+eval_order+"&eval_user_id="+eval_user_id+"&rec_seq="+rec_seq+"&rec_datm="+rec_datm+"&user_id="+user_id,"_eval_form","900",popupHeight,"yes","center");
};

function goAgentSearch(){
	getAgentList();
	agentSearch.user_name.select();
	return false
}
function chgSortMethod(){
	$("#record_search button[name=btn_search]").click();
}
function downloadRecFileEval(idx){
	var rowData	= recordJsonData[idx];
	var rec_datm = rowData["rec_datm"].replace(/\s|-|:|\./gi,"");
	var info = getEncData(rec_datm + "|" + rowData["local_no"] + "|" + rowData["rec_filename"] + "|" + toNN(rowData["custom_fld_04"]), "1");

	if(isExistPlayDownReason){
		openPopup("../rec_search/download_reason.jsp?info="+encodeURIComponent(info),"_download","556","260","yes","center");
	}
	else{
		hiddenFrame.location = "../rec_search/download.jsp?info="+encodeURIComponent(info);
	}
}
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>평가 수행</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 평가 관리</a></li>
			 <li class="active"><strong>평가 수행</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->

	<!--wrapper-content영역-->
	<div class="wrapper-content">
		<!--ibox 시작-->
		<div class="ibox" style=margin-bottom:14px>
		<form id="search">
			<input type=hidden name=user_name>
			<!--검색조건 영역-->
			<div class="ibox-content contentRadius3 conSize">
				<table cellpadding=0 cellspacing=0 width=100%><tr>
				<td>
					<div class="evaDiv1">
						<div id="labelDiv">
							<label class="simple_tag">이벤트 명</label>
							<select class="form-control eva_form1" name="event_code_combo" style=width:200px>
								<%=htm_event_list%>
							</select>
							<input type=hidden name=event_code>
						</div>
					</div>

					<div class="evaDiv2">
						<div id="label_Div">
							<label class="simple_tag">평가자 명</label>
							<select class="form-control eva_form1" name="eval_user_id">
								<%=htm_eval_user_list%>
							</select>
					 	</div>
					</div>

					<div class="evaDiv3">
						<div id="label_Div">
							<label class="simple_tag">평가차수</label>
							<select class="form-control eva_form1" name="eval_order">
							</select>

					 	</div>
					</div>
					</td>
				<td align=right width=1 style=padding-right:10px;padding-bottom:5px><button type="button" name="btn_search1" class="btn btn-primary btn-sm"><i class="fa fa-search"></i> 조회</button></td>
				</tr>
				</table>
			</div>
			<!--검색조건 영역 끝-->
		</form>
		</div>
		<!--ibox 끝-->

		<div id="search_result" class="">
			<!--이벤트 상세 정보 영역-->
			<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">이벤트 상세 정보</h5>
			<div class="tableRadius5 conSize" id="event_info">
				<!--1행 시작-->
				<div class="evaDiv1">
					<div id="labelDiv">
						<label class="simple_tag2">이벤트 명</label>
						<label class="i-space"><span id="event_name"></span></label>
					</div>
				</div>

				<div class="evaDiv2">
					<div id="label_Div">
						<label class="simple_tag2">시트 명</label>
						<label class="i-space"><span id="sheet_name"></span></label>
					</div>
				</div>

				<div class="evaDiv3">
					<div id="label_Div">
						<label class="simple_tag2">상태</label>
						<label class="i-space"><span id="event_status_txt"></span></label>
					</div>
				</div>
				<!--1행 끝-->

				<!--2행 시작-->
				<div class="evaDiv1">
					<div id="labelDiv">
						<label class="simple_tag2">평가 기간</label>
						<label class="i-space"><span id="event_sdate"></span> ~ <span id="event_edate"></span></label>

					</div>
				</div>

				<div class="evaDiv2">
					<div id="label_Div">
						<label class="simple_tag2">항목/총점</label>
						<label class="i-space"><span id="sheet_item_cnt"></span>개 / <span id="sheet_tot_score"></span>점</label>
					</div>
				</div>

				<div class="evaDiv3">
					<div id="label_Div">
						<label class="simple_tag2">총 평가차수</label>
						<label class="i-space"><span id="eval_order_max"></span>차</label>
					</div>
				</div>
				<!--2행 끝-->
			</div>
			<!--이벤트 상세 정보 영역 끝-->

			<!-- a-space -->
			<div class="a-space conSize" style=padding:0;margin-top:14px>
				<!--left table-->
				<div class="colLeft tableSize2">
						<!--title 영역-->
						<div class="colLeft"><nobr>
							<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">평가 대상자</h5>
						</div>

						<div class="ibox-content contentRadius3" style=margin-bottom:4px>
							<form id="agentSearch" onsubmit='return goAgentSearch()'>
							<table cellpadding=0 cellspacing=0 width=100%><tr>
							<td>
								<div id="labelDiv">
									<label class="simple_tag">상담원명</label>
									<input type="text" name="user_name" class="form-control eva_form6" id="" placeholder="">
								</div>
							</td>
							<td align=right width=1 style=padding-right:10px;padding-bottom:5px><button type="submit" name="btn_search2" class="btn btn-primary btn-sm"><i class="fa fa-search"></i> 조회</button></td>
							</tr></table>
							</form>
						</div>

						<div id=divLeftListBox style='width:100%;height:500px;overflow-y:auto;'>
							<form id="agent">
							<table class="table top-line1 table-bordered">
								<thead>
									<tr>
										<th style="width:10%;">선택</th>
										<th>부서</th>
										<th>상담원ID</th>
										<th>상담원명</th>
										<th>평가상태</th>
									</tr>
								</thead>
								<tbody id="agent_list">
								</tbody>
							</table>
							</form>
						</div>
				</div>
				<!-- left table 끝-->

				<!--right table-->
				<div class="colRight tableSize3 t-space">
					<form id="record_search">
						<input type="hidden" name="user_id" value=""/>
						<!--title 영역-->
						<div class="colLeft">
							<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">상담 이력</h5>
						</div>
						<!-- 상담 이력 ibox 시작-->
						<div class="ibox" style=margin-bottom:4px>
							<!--검색조건 영역-->
							<div class="ibox-content contentRadius1">
								<!--1행 시작-->
								<div class="evaDiv4">
									<div id="labelDiv">
										<label class="simple_tag">녹취일자</label>
										<!-- 달력 팝업 위치 시작-->
										<div class="input-group" style="display:inline-block;">
											<input type="text" name="rec_date1" class="form-control eva_form4 datepicker" value="<%=DateUtil.getToday("")%>">
											<div class="input-group-btn">
												<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
											</div>
										</div>
										<!-- 달력 팝업 위치 끝-->
										<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
										<!-- 달력 팝업 위치 시작-->
										<div class="input-group" style="display:inline-block;">
											<input type="text" name="rec_date2" class="form-control eva_form4 datepicker" value="<%=DateUtil.getToday("")%>">
											<div class="input-group-btn">
												<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
											</div>
										</div>
										<!-- 달력 팝업 위치 끝-->
									</div>
								</div>

								<div class="evaDiv4">
									<div id="labelDiv">
										<label class="simple_tag">녹취시간</label>
										<select class="form-control" name="rec_start_hour1" style=width:54px>
											<script>
											for(var i=0; i<24; i++){
												var hour = fillLeft(i,"0",2);
												document.writeln("<option value='"+hour+"'>"+hour+"시</option>");
											}
											</script>
										</select
										><select class="form-control" name="rec_start_min1" style=width:54px>
											<script>
											for(var i=0; i<=55; i+=5){
												var min = fillLeft(i,"0",2);
												document.writeln("<option value='"+min+"'>"+min+"분</option>");
											}
											</script>
										</select> ~
										<select class="form-control" name="rec_start_hour2" style=width:54px>
											<script>
											for(var i=0; i<24; i++){
												var hour = fillLeft(i,"0",2);
												document.writeln("<option value='"+hour+"' "+((i==23) ? "selected='selected'" : "")+">"+hour+"시</option>");
											}
											</script>
										</select
										><select class="form-control" name="rec_start_min2" style=width:54px>
											<script>
											for(var i=0; i<=55; i+=5){
												var min = fillLeft(i,"0",2);
												document.writeln("<option value='"+min+"'>"+min+"분</option>");
											}
											</script>
											<option value='59' selected='selected'>59분</option>
										</select>
									</div>
								</div>
								<!--1행 끝-->
								<br>
								<!--2행 시작-->
								<div class="evaDiv4">
									<div id="labelDiv">
										<label class="simple_tag">통화시간</label>
										<select class="form-control eva_form5" name="rec_call_time1">
											<option value="0" selected="selected">0초</option>
											<script>
											for(var i=5; i<=59; i++){
												document.writeln("<option value='"+i+"'>"+i+"초</option>");
											}
											</script>
											<option value="60">1분</option>
											<option value="120">2분</option>
											<option value="180">3분</option>
											<option value="240">4분</option>
											<option value="300">5분</option>
											<option value="600">10분</option>
										</select> ~
										<select class="form-control eva_form5" name="rec_call_time2">
											<script>
											for(var i=5; i<=59; i++){
												document.writeln("<option value='"+i+"'>"+i+"초</option>");
											}
											</script>
											<option value="60">1분</option>
											<option value="120">2분</option>
											<option value="180">3분</option>
											<option value="240">4분</option>
											<option value="300">5분</option>
											<option value="600">10분</option>
											<option value="3600">60분</option>
											<option value="36000">60분 이상</option>
										</select>
									</div>
								</div>

								<div class="evaDiv4">
									<div id="labelDiv">
										<label class="simple_tag">검색어</label>
										<input type="text" name="cust_name" class="form-control eva_form6" id="" placeholder="">
									</div>
								</div>
								<!--2행 끝-->

								<br>
								<div class="evaDiv4">
									<div id="labelDiv">
										<label class="simple_tag">정렬</label>
										<div style=padding-top:2px>
										<label style=cursor:pointer><input type=radio name=sortMethod value='A.rec_datm desc' onclick=chgSortMethod(this) checked> 녹취일시▼</label>
										<label style=cursor:pointer><input type=radio name=sortMethod value='A.rec_datm asc' onclick=chgSortMethod(this)> 녹취일시▲</label> &nbsp;
										<label style=cursor:pointer><input type=radio name=sortMethod value='A.rec_call_time desc' onclick=chgSortMethod(this)> 녹음길이▼</label>
										<label style=cursor:pointer><input type=radio name=sortMethod value='A.rec_call_time asc' onclick=chgSortMethod(this)> 녹음길이▲</label> &nbsp;
										<label style=cursor:pointer><input type=radio name=sortMethod value='A.custom_fld_04 desc' onclick=chgSortMethod(this)> 안내번호▼</label>
										<label style=cursor:pointer><input type=radio name=sortMethod value='A.custom_fld_04 asc' onclick=chgSortMethod(this)> 안내번호▲</label>
										</div>
									</div>
								</div>

							</div>
							<!--검색조건 영역 끝-->

							<!--유틸리티 버튼 영역-->
							<div class="contentRadius2">
								<!--ibox 접히기, 설정버튼 영역-->
								<div class="ibox-tools">
									<a class="collapse-link">
										<button type="button" class="btn btn-default btn-sm"><i class="fa fa-chevron-up"></i> </button>
									</a>
								</div>
								<!--ibox 접히기, 설정버튼 영역 끝-->
								<div style="float:right">
									<button type="button" name="btn_search" class="btn btn-primary btn-sm"><i class="fa fa-search"></i> 조회</button>
								</div>
							</div>
							<!--유틸리티 버튼 영역 끝-->
						</div>
						<!--상담 이력 ibox 끝-->
					</form>
					<form id="record" onsubmit="return false;">
						<div id=divRightListBox style='width:100%;height:300px;overflow-y:auto;'>
							<table class="table top-line1 table-bordered">
								<thead>
									<tr>
										<th style="width:10%;">평가</th>
										<th>일자</th>
										<th>시작시간</th>
										<th>통화시간</th>
										<th>검색어</th>
										<th>안내번호</th>
										<th>듣기</th>
										<th>다운</th>
										<th>평가상태</th>
									</tr>
								</thead>
								<tbody id="record_list">
								</tbody>
								<tfoot>
									<tr>
										<td align="left" colspan="9">
											<!--pagination-->
											<ul id="paging" class="paging list-inline">
												<li><a href="#" aria-label="First"><img src="../img/button/paging_first_dis.gif" align="absmiddle" /></a></li>
												<li><a href="#" aria-label="Prev"><img src="../img/button/paging_prev_dis.gif" align="absmiddle" /></a></li>
												<li><span>Page <input type="text" name="cur_page" value="1" class="form-control" style="width: 35px;" id="" placeholder="" /> of <span id="tot_page">1</span></span></li>
												<li><a href="#" aria-label="Next"><img src="../img/button/paging_next_dis.gif" align="absmiddle" /></a></li>
												<li><a href="#" aria-label="Last"><img src="../img/button/paging_last_dis.gif" align="absmiddle" /></a></li>
											  	<li>
											  		<span>
												  		<select class="form-control" name="top_cnt">
												  			<option value="10">10</option>
												  			<option value="20" selected="selected">20</option>
												  			<option value="50">50</option>
												  			<option value="100">100</option>
														</select>
													</span>
											  	</li>
											</ul>
											<!--pagination 끝-->
										</td>
									</tr>
								</tfoot>
							</table>
						</div>
					</form>
				</div>
				<!-- right table 끝-->
			</div>
			<!-- a-space 끝-->
		</div>
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

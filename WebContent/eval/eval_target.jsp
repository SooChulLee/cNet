<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
// 메뉴 접근권한 체크
if(!Site.isPmss(out,"eval_target","")) return;

try {
	Map<String, Object> argMap = new HashMap<String, Object>();

	//평가자 콤보박스
	String htm_eval_user_list = Site.getEvaluatorComboHtml(session, true);

	//조직도 콤보박스
	String htm_bpart_list = Site.getMyPartCodeComboHtml(session, 1);
	String htm_mpart_list = Site.getMyPartCodeComboHtml(session, 2);
	String htm_spart_list = Site.getMyPartCodeComboHtml(session, 3);

%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
$(function () {
	E("divLeftListBox").style.height = parseInt(document.body.offsetHeight)-236+"px";
	E("divRightListBox").style.height = E("divLeftListBox").style.height;

	// 평가자명 선택
	$("#search select[name=eval_user_id]").change(function(){
		getAgentList();
	});

	// 가용 상담원 조회 버튼 클릭
	$("#target button[name=btn_target_search]").click(function() {
		getAgentList();
	});

	// 첫번째 이벤트 선택
	$("#search select[name=eval_user_id] option:eq(0)").prop("selected", true).change();

	// 전체 선택
	$("button[name=btn_check_all]").click(function() {
		checkObject($("#target input[name=target_user_id]"), true);
	});

	// 전체 선택해제
	$("button[name=btn_uncheck_all]").click(function() {
		checkObject($("#regi input[name=assign_user_id]"), true);
	});

	// 전체선택,선택,전체선택해제,선택해제 버튼 클릭
	$("button[name=btn_check_all], button[name=btn_check], button[name=btn_uncheck_all], button[name=btn_uncheck]").click(function() {
		var step = ($(this).attr("name").indexOf("uncheck")>-1) ? "delete" : "insert";

		checkUser(step, "");
	});

	$("#target select[name=bpart_code],	#target	select[name=mpart_code]").change(function(){chgPartCode($(this));});
});

// 가용/배정 상담원 조회
var getAgentList = function() {
	var eval_user_id = $("#search select[name=eval_user_id]").val();

	if(eval_user_id=="") {
		alert("평가자 명을 먼저 선택해 주십시오.");
		return;
	}

	var param = {
			eval_user_id: eval_user_id,
			bpart_code: $("#target select[name=bpart_code]").val(),
			mpart_code: $("#target select[name=mpart_code]").val(),
			spart_code: $("#target select[name=spart_code]").val()
	};

	$.ajax({
		type: "POST",
		url: "remote_eval_target.jsp",
		data: param,
		async: false,
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code!="ERR") {
				var html = "";
				$("#target_list").html("");
				$("#assign_list").html("");

				// 가용 상담원
				if(dataJSON.target.length>0) {
					for(var i=0;i<dataJSON.target.length;i++) {
						html += "<tr>\n";
						html += "	<td><input type=\"checkbox\" name=\"target_user_id\" value=\"" + dataJSON.target[i].user_id + "\" checked=checked></td>\n";
						html += "	<td>" + dataJSON.target[i].bpart_name + "</td>\n";
						html += "	<td>" + dataJSON.target[i].mpart_name + "</td>\n";
						html += "	<td>" + dataJSON.target[i].spart_name + "</td>\n";
						html += "	<td>" + dataJSON.target[i].user_id + "</td>\n";
						html += "	<td>" + dataJSON.target[i].user_name + "</td>\n";
						html += "</tr>\n";
					}
				} else {
					html = "<tr><td colspan=\"5\">가용한 상담원이 없습니다.</td></tr>";
				}
				$("#target_list").html(html);

				// 배정 상담원
				html = "";
				if(dataJSON.assign.length>0) {
					for(var i=0;i<dataJSON.assign.length;i++) {
						html += "<tr>\n";
						html += "	<td><input type=\"checkbox\" name=\"assign_user_id\" value=\"" + dataJSON.assign[i].user_id + "\" checked=checked></td>\n";
						html += "	<td>" + dataJSON.assign[i].bpart_name + "</td>\n";
						html += "	<td>" + dataJSON.assign[i].mpart_name + "</td>\n";
						html += "	<td>" + dataJSON.assign[i].spart_name + "</td>\n";
						html += "	<td>" + dataJSON.assign[i].user_id + "</td>\n";
						html += "	<td>" + dataJSON.assign[i].user_name + "</td>\n";
						html += "</tr>\n";
					}
				} else {
					html = "<tr><td colspan=\"6\">배정된 상담원이 없습니다.</td></tr>";
				}

				$("#assign_list").html(html);
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

// 배정 상담원 등록
var checkUser = function(proc, user_id) {
	var user_list = [];
	var field = ((proc=="insert") ? "target" : "assign") + "_user_id";
	var eval_user_id = $("#search select[name=eval_user_id]").val();
	var eval_user_name = $("#search select[name=eval_user_id] option:selected").text();

	if(user_id!="") {
		user_list.push({
			user_id: user_id
		});
	} else {
		$("input[name="+field+"]").each(function(idx){
			if($(this).prop("checked") && $(this).val()!="") {
				var tmp = {
					user_id: $(this).val(),
				};
				user_list.push(tmp);
			}
		});
	}

	if(user_list.length<1) {
		alert("상담원을 한명 이상 선택해 주십시오.");
		return;
	}

	$.ajax({
		type: "POST",
		url: "remote_eval_target_proc.jsp",
		async: false,
		data: "step="+proc+"&eval_user_id="+eval_user_id+"&eval_user_name="+eval_user_name+"&user_list="+JSON.stringify(user_list),
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code=="OK") {
				// data reload
				getAgentList();
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

// 전체 선택/전체 선택해제
var checkUserAll = function(type) {
	checkToggle($("input[name=" + type + "_user_id]"));
	//var flag = $("input[name=" + type + "_user_id]").eq(0).prop("checked");
};

</script>

<!--title 영역 -->
<div class="row titleBar border-bottom2">
	<div style="float:left;"><h4>평가 대상자 관리</h4></div>
	<ol class="breadcrumb" style="float:right;">
		 <li><a href="#none"><i class="fa fa-home"></i> 평가 관리</a></li>
		 <li class="active"><strong>평가 대상자 관리</strong></li>
	</ol>
</div>
<!--title 영역 끝 -->

<!--wrapper-content영역-->
<div class="wrapper-content">
	<!--ibox 시작-->
	<div class="ibox">
	<form id="search">
		<!--검색조건 영역-->
		<div class="ibox-content contentRadius3 conSize">
			<div class="evaDiv2">
				<div id="label_Div">
					<label class="simple_tag">평가자 명</label>
					<select class="form-control eva_form1" name="eval_user_id">
					<%=htm_eval_user_list%>
					</select>
			 	</div>
			</div>
		</div>
		<!--검색조건 영역 끝-->
	</form>
	</div>
	<!--ibox 끝-->

	<div id="search_result" class="">
		<!-- a-space -->
		<div class="a-space conSize" style=margin-top:0;padding-top:0>
			<!--left table-->
			<div class="colLeft tableSize2">
				<form id="target">
					<!--title 영역-->
					<div class="colLeft">
						<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">가용 상담원</h5>
					</div>
					<div class="colRight m-t">
						<select class="form-control result_form2" name="bpart_code">
							<%=htm_bpart_list%>
						</select> :
						<select class="form-control result_form2" name="mpart_code">
							<%=htm_mpart_list%>
						</select> :
						<select class="form-control result_form2" name="spart_code">
							<%=htm_spart_list%>
						</select>
						<button type="button" name="btn_target_search" class="btn btn-register btn-sm"><i class="fa fa-search"></i> 조회</button>
					</div>
					<!--title 영역 끝-->
					<div id=divLeftListBox style='width:100%;height:500px;overflow-y:auto'>
						<table class="table top-line1 table-bordered tt">
							<thead>
								<tr><th style="width:10%;"><input type="checkbox" name="target_user_id" value="" checked=checked onclick="checkUserAll('target');"/></th>
									<th>대분류</th>
									<th>중분류</th>
									<th>소분류</th>
									<th>상담원ID</th>
									<th>상담원명</th>
								</tr>
							</thead>
							<tbody id="target_list">
								<tr>
									<td colspan="5">평가자 명을 먼저 선택해 주십시오.</td>
								</tr>
							</tbody>
						</table>
					</div>
				</form>
			</div>
			<!-- left table 끝-->

			<!--버튼들-->
			<ul class="buttonDiv3">
				<li><button type="button" name="btn_check_all" class="btn btn-default btn-sm b-t"><i class="fa fa-angle-double-right"></i> </button></li>
				<li><button type="button" name="btn_check" class="btn btn-default btn-pp t-space"><i class="fa fa-angle-right"></i> </button></li>
				<li><button type="button" name="btn_uncheck_all" class="btn btn-default btn-sm b-t"><i class="fa fa-angle-double-left"></i> </button></li>
				<li><button type="button" name="btn_uncheck" class="btn btn-default btn-pp t-space"><i class="fa fa-angle-left"></i> </button></li>
			</ul>
			<!--버튼들 끝-->

			<!--right table-->
			<div class="colLeft tableSize2 t-space">
				<form id="regi">
					<!--title 영역-->
					<div class="colLeft">
						<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">배정 상담원</h5>
					</div>
					<div class="colRight m-t">
						<!--<button type="button" class="btn btn-register btn-sm"><i class="fa fa-check"></i> 저장</button>-->
					</div>
					<!--title 영역 끝-->
					<div id=divRightListBox style='width:100%;height:500px;overflow-y:auto'>
						<table class="table top-line1 table-bordered tt">
							<thead>
								<tr>
									<th style="width:10%;"><input type="checkbox" name="assign_user_id" value="" checked=checked onclick="checkUserAll('assign');"/></th>
									<th>대분류</th>
									<th>중분류</th>
									<th>소분류</th>
									<th>상담원ID</th>
									<th>상담원명</th>
								</tr>
							</thead>
							<tbody id="assign_list">
								<tr>
									<td colspan="6">평가자 명을 먼저 선택해 주십시오.</td>
								</tr>
							</tbody>
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
}
%>

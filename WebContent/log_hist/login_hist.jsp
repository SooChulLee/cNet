<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"login_hist","")) return;
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
$(function () {
	var colModel = [
		{ title: "순번", width: 80, dataIndx: "idx", sortable: false },
		{ title: "구분", width: 100, dataIndx: "v_login_type", sortable: false },
		{ title: "로그인일시", width: 200, dataIndx: "login_datm" },
		{ title: "로그인ID", width: 150, dataIndx: "login_id" },
		{ title: "로그인명", width: 150, dataIndx: "login_name" },
		{ title: "로그인IP", width: 150, dataIndx: "login_ip" },
		{ title: "결과", width: 100, dataIndx: "v_login_result", sortable: false }
	];

	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		//sortIndx: "login_datm",
		sortDir: "down",
	});

	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("login_hist", "Y", "Y", "N", "N");
	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		scrollModel: { autoFit: true },
	});

	$grid = $("#grid").pqGrid(obj);
});
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>로그인 이력</h4></div>
		<ol class="breadcrumb" style="float:right;">
			<li><a href="#none"><i class="fa fa-home"></i> 이력</a></li>
			<li class="active"><strong>로그인 이력</strong></li>
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
					<div id="logDiv1">
						<div id="labelDiv">
							<label class="simple_tag">일자</label>
							<!-- 달력 팝업 위치 시작-->
							<div class="input-group" style="display:inline-block;">
								<input type="text" name="login_date1" class="form-control log_form1 datepicker" value="<%=DateUtil.getToday("")%>" maxlength="10">
								<div class="input-group-btn">
									<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
								</div>
							</div>
							<!-- 달력 팝업 위치 끝-->
							<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
							<!-- 달력 팝업 위치 시작-->
							<div class="input-group" style="display:inline-block;">
								<input type="text" name="login_date2" class="form-control log_form1 datepicker" value="<%=DateUtil.getToday("")%>" maxlength="10">
								<div class="input-group-btn">
									<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
								</div>
							</div>
							<!-- 달력 팝업 위치 끝-->
						</div>
					</div>

					<div id="logDiv2">
						<div id="labelDiv">
							<label class="simple_tag">로그인ID</label><input type="text" name="login_id" class="form-control log_form2" id="" placeholder="">
						</div>
					</div>

					<div id="logDiv2">
						<div id="label_Div">
							<label class="simple_tag">로그인명</label><input type="text" name="login_name" class="form-control log_form2" id="" placeholder="">
					 	</div>
					</div>

					<div id="logDiv1">
						<div id="labelDiv">
							<label class="simple_tag">구분</label>
							<select class="form-control log_form3" name="login_type">
								<option value="">전체</option>
								<option value="I">로그인</option>
								<option value="O">로그아웃</option>
							</select>
						</div>
					</div>

					<div id="logDiv2">
						<div id="label_div">
							<label class="simple_tag">결과</label>
							<select class="form-control log_form2" name="login_result" >
								<option value="">전체</option>
								<option value="1">성공</option>
								<option value="0">실패</option>
							</select>
						</div>
					</div>
				</div>
				<!--검색조건 영역 끝-->

				<!--유틸리티 버튼 영역-->
				<div class="contentRadius2 conSize">
					<!--ibox 접히기, 설정버튼 영역 (사용안함)-->
					<div class="ibox-tools blank">
						<!--<a class="collapse-link">
							<button type="button" class="btn btn-default"><i class="fa fa-chevron-up"></i></button>
						</a>-->
					</div>
					<!--ibox 접히기, 설정버튼 영역 끝-->
					<div style="float:right">
						<button type="button" name="btn_search" class="btn btn-primary btn-sm"><i class="fa fa-search"></i> 조회</button>
						<button type="button" name="btn_cancel" class="btn btn-default btn-sm"><i class="fa fa-times"></i> 취소</button>
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
			<!--grid 영역-->
			<div id="grid"></div>
			<!--grid 영역 끝-->
		</div>
		<!--Data table 영역 끝-->
	</div>
	<!--wrapper-content영역 끝-->

<jsp:include page="/include/bottom.jsp"/>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"abort_hist","")) return;
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
$(function () {
	// 청취사유 조회
	getCommCodeToForm("LD_REASON", "search", "reason_code");

	var colModel = [
		{ title: "순번", width: 60, dataIndx: "idx", sortable: false },
		{ title: "등록일시", width: 130, dataIndx: "abort_datm" },
		{ title: "상태", width: 130, dataIndx: "abort_state" },
		{ title: "필수중단 시작 일시", width: 130, dataIndx: "start_rec_datm" },
		{ title: "필수중단 종료 일시", width: 130, dataIndx: "end_rec_datm" },
		{ title: "대분류", width: 80, dataIndx: "bpart_name" },
		{ title: "중분류", width: 80, dataIndx: "mpart_name" },
		{ title: "소분류", width: 80, dataIndx: "spart_name" },
		{ title: "로그인ID", width: 80, dataIndx: "abort_id" },
		{ title: "로그인명", width: 80, dataIndx: "abort_name" },
		{ title: "로그인IP", width: 100, dataIndx: "abort_ip" },
		{ title: "취소", width: 40, editable: false, sortable: false, render: function (ui) {

			return "<img src='../img/icon/ico_delete.png' class='btn_delete'/>";

			}
		}

	];

	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		//sortIndx: "abort_datm",
		sortDir: "down",
	});

 	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("abort_hist", "Y", "Y", "N", "N");
	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		scrollModel: { autoFit: true },
	});

	$grid = $("#grid").pqGrid(obj);

 // 잠금해제 실행
	$grid.on("pqgridrefresh", function(event, ui) {
		$grid.find(".btn_delete")
		.unbind("click")
		.bind("click", function (evt) {
			if (confirm("정말로 취소 하시겠습니까?")) {
				var $tr = $(this).closest("tr");
				var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;

				var rowData = $grid.pqGrid("getRowData", { rowIndxPage: rowIndx });
				var start_rec_datm = rowData["start_rec_datm"].replace(/\s|-|:|\./gi,"");
				var end_rec_datm = rowData["end_rec_datm"].replace(/\s|-|:|\./gi,"");

				var abort_state = rowData["abort_state"].replace(/\s|-|:|\./gi,"");

				if(abort_state=="취소"){
					alert("취소 된 건 입니다.");
					return false;
				}


				//cabort
				$.ajax({
					type: "POST",
					url: "remote_abort_hist_proc.jsp",
					async: false,
					data: "step=abort&start_rec_datm="+start_rec_datm+"&end_rec_datm="+end_rec_datm,
					dataType: "json",
					success:function(dataJSON){
						if(dataJSON.code=="OK") {
							alert("정상적으로 취소 되었습니다.");
							$grid.pqGrid("refreshDataAndView");
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
		});
	});


});
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>필수중단 이력</h4></div>
		<ol class="breadcrumb" style="float:right;">
			<li><a href="#none"><i class="fa fa-home"></i> 이력</a></li>
			<li class="active"><strong>필수중단 이력</strong>	</li>
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
					<div id="logDiv1">
						<div id="labelDiv">
							<label class="simple_tag">등록일자</label>
							<!-- 달력 팝업 위치 시작-->
							<div class="input-group" style="display:inline-block;">
								<input type="text" name="abort_date1" class="form-control log_form1 datepicker" value="<%=DateUtil.getToday("")%>" maxlength="10">
								<div class="input-group-btn">
									<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
								</div>
							</div>
							<!-- 달력 팝업 위치 끝-->
							<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
							<!-- 달력 팝업 위치 시작-->
							<div class="input-group" style="display:inline-block;">
								<input type="text" name="abort_date2" class="form-control log_form1 datepicker" value="<%=DateUtil.getToday("")%>" maxlength="10">
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
					<!--1행 끝-->

					<!--2행 시작-->
					<div id="logDiv1">
						<div id="labelDiv">
							<label class="simple_tag">녹취일자</label>
							<!-- 달력 팝업 위치 시작-->
							<div class="input-group" style="display:inline-block;">
								<input type="text" name="rec_date1" class="form-control log_form1 datepicker" value="">
								<div class="input-group-btn">
									<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
								</div>
							</div>
							<!-- 달력 팝업 위치 끝-->
							<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
							<!-- 달력 팝업 위치 시작-->
							<div class="input-group" style="display:inline-block;">
								<input type="text" name="rec_date2" class="form-control log_form1 datepicker" value="">
								<div class="input-group-btn">
									<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
								</div>
							</div>
							<!-- 달력 팝업 위치 끝-->
						</div>
					</div>

					<%-- <div id="recDiv2">
						<div id="labelDiv">
							<label class="simple_tag">녹취시간</label>
							<select class="form-control rec_form3" name="rec_start_hour1">
							<%
								for(int i=0;i<=23;i++) {
									String tmp_hour = CommonUtil.getFormatString(Integer.toString(i), "00");
									out.print("<option value='"+tmp_hour+"'>"+tmp_hour+"시</option>\n");
								}
							%>
							</select> ~
							<select class="form-control rec_form3" name="rec_start_hour2">
							<%
								for(int i=0;i<=24;i++) {
									String tmp_hour = CommonUtil.getFormatString(Integer.toString(i), "00");
									out.print("<option value='"+tmp_hour+"'"+((i==24) ? " selected='selected'" : "")+">"+tmp_hour+"시</option>\n");
								}
							%>
							</select>
						</div>
					</div> --%>



					<!--2행 끝-->


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

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"channel_mgmt","")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String search = CommonUtil.getParameter("search", "");
		String system_code = CommonUtil.getParameter("system_code", "");
		String system_name = CommonUtil.getParameter("system_name", "");
		String phone_num = CommonUtil.getParameter("phone_num", "");
		String phone_ip = CommonUtil.getParameter("phone_ip", "");

		// 첫번째 업무코드 조회
		if(!CommonUtil.hasText(system_code)) {
			Map<String, Object> resmap = db.selectOne("system.selectFirstItem");
			if(resmap!=null) {
				system_code = resmap.get("business_code").toString()+""+resmap.get("system_code").toString();
				system_name = resmap.get("system_name").toString();
			}
		}

		String sub_title = ("1".equals(search)) ? "채널 조회" : system_name;
%>
<script type="text/javascript">
$(function () {
	var colModel = [
		{ title: "시스템명", width: 150, dataIndx: "system_name", editable: false, sortable: false },
		{ title: "시스템코드", dataIndx: "system_code", hidden: true },
		{ title: "채널번호", width: 100, dataIndx: "channel", editable: false },
		{ title: "내선번호", width: 150, dataIndx: "phone_num",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			]
		},
		{ title: "기존 내선번호", dataIndx: "ori_phone_num", hidden: true },
		{ title: "아이피", width: 150, dataIndx: "phone_ip",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			]
		},
		{ title: "교환기번호", width: 100, dataIndx: "tn_num", sortable: false },
		{ title: "MAC", dataIndx: "mac", hidden: true, sortable: false },
		{ title: "등록/수정", dataIndx: "act_type", hidden: true },
		{ title: "삭제", width: 40, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_delete.png' class='btn_delete'/>";
			}
		}
	];

	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		sorting: "local",
		//sortIndx: "<%=("1".equals(search)) ? "phone_num" : "channel" %>",
		sortDir: "up",
		recIndx: "phone_num"
	});

	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("channel_list", "N", "Y", "Y", "Y");
	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		pageModel: {type: "local", rPP:100, strRpp:"{0}", strDisplay:"{0} to {1} of {2}"},
		scrollModel: { autoFit: true },
		numberCell:{resizable:true, title:"#"},
	});

	$grid = $("#grid").pqGrid(obj);

	// 채널 등록폼 오픈시
	$("#modalRegiForm").on("show.bs.modal", function(e) {
		var system_code = $("#regi input[name=system_code]").val();

		if(system_code=="") {
			alert("시스템 정보가 없습니다.");
			return false;
		}

		// 사용 가능한 채널 목록 조회
		$.ajax({
			type: "POST",
			url: "../common/get_usable_channel_list.jsp",
			data: "system_code="+system_code.substring(2),
			async: false,
			dataType: "json",
			success:function(dataJSON){
				$("#regi select[name=channel]").html("");

				if(dataJSON.code!="ERR") {
					if(dataJSON.data.length>0) {
						var html = "";
						for(var i=0;i<dataJSON.data.length;i++) {
							html += "<option value='" + dataJSON.data[i].channel + "'>" + dataJSON.data[i].channel + "</option>";
						}
						$("#regi select[name=channel]").append(html);
					} else {
						alert("사용 가능한 채널이 없습니다.");
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
	});

	// 채널 등록 저장
	$("#regi button[name=modal_regi]").click(function() {
		if(!$("#regi input[name=phone_num]").val().trim()) {
			alert("내선번호를 입력해 주십시오.");
			$("#regi input[name=phone_num]").focus();
			return false;
		}
		if(!$("#regi input[name=phone_ip]").val().trim()) {
			alert("아이피를 입력해 주십시오.");
			$("#regi input[name=phone_ip]").focus();
			return false;
		}
		if(!$("#regi select[name=channel]").val().trim()) {
			alert("채널번호를 선택해 주십시오.");
			$("#regi select[name=channel]").focus();
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_channel_list_proc.jsp",
			async: false,
			data: "step=insert&"+$("#regi").serialize(),
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					alert("정상적으로 등록되었습니다.");
					$("#modalRegiForm").modal("hide");
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
	});
});
</script>
	<div class="bullet"><i class="fa fa-angle-right"></i></div>
	<h5 class="table-title3"><%=sub_title%></h5>
	<div class="hr2" style="margin-bottom: 12px;"></div>
	<form id="search">
		<input type="hidden" name="search" value="<%=search%>"/>
		<input type="hidden" name="system_code" value="<%=system_code%>"/>
		<input type="hidden" name="phone_num" value="<%=phone_num%>"/>
		<input type="hidden" name="phone_ip" value="<%=phone_ip%>"/>
	</form>
	<!--grid 영역-->
	<div id="grid"></div>
	<!--grid 영역 끝-->
	<!--팝업창 띠우기-->
	<div class="modal inmodal" id="modalRegiForm" tabindex="-1" role="dialog"  aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content animated fadeIn">
				<form id="regi">
					<input type="hidden" name="system_code" value="<%=system_code%>"/>

					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
						<h4 class="modal-title">채널 등록</h4>
					</div>
					<div class="modal-body" >
						<!--업무코드 table-->
						<table class="table top-line1 table-bordered2">
							<thead>
							<tr>
								<td style="width:40%;" class="table-td">시스템명</td>
								<td style="width:60%; padding: 6px 9px;">
									<%=system_name%>
								</td>
							</tr>
							</thead>
							<tr>
								<td class="table-td">내선번호 <span class="required">*</span></td>
								<td>
									<input type="text" name="phone_num" class="form-control" id="" placeholder="">
								</td>
							</tr>
							<tr>
								<td class="table-td">아이피 <span class="required">*</span></td>
								<td>
									<input type="text" name="phone_ip" class="form-control" id="" placeholder="">
								</td>
							</tr>
							<tr>
								<td class="table-td">채널번호 <span class="required">*</span></td>
								<td>
									<select class="form-control" name="channel">
									</select>
								</td>
							</tr>
							<tr>
								<td class="table-td">교환기번호</td>
								<td>
									<input type="text" name="tn_num" class="form-control" id="" placeholder="">
								</td>
							</tr>
						</table>
						<!--업무코드 table 끝-->
					</div>
					<div class="modal-footer">
						<button type="button" name="modal_regi" class="btn btn-primary btn-sm"><i class="fa fa-pencil"></i> 등록</button>
						<button type="button" name="modal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>
					</div>
				</form>
			</div>
		</div>
	</div>
	<!--팝업창 띠우기 끝-->
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
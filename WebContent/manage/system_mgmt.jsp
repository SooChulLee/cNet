<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"system_mgmt","")) return;

	Db db = null;

	try {
		db = new Db(true);
%>
<jsp:include page="../include/top.jsp" flush="false"/>
<script type="text/javascript">
$(function () {
	var colModel = [
		{ title: "업무구분", width: 100, dataIndx: "business_name", editable: false },
		{ title: "시스템코드", width: 100, dataIndx: "system_code", editable: false	},
		{ title: "시스템명", width: 120, dataIndx: "system_name",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			],
		},
		{ title: "시스템IP", width: 120, dataIndx: "system_ip",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			],
		},
		{ title: "백업IP", width: 120, dataIndx: "backup_ip" },
		{ title: "총채널수", width: 100, dataIndx: "license_cnt",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
				{ type: "regexp", value: /^[0-9]*$/, msg: "숫자로만 입력 가능합니다." },
			],
		},
		{ title: "사용채널수", width: 100, dataIndx: "license_used_cnt", editable: false },
		{ title: "서버구분", width: 80, dataIndx: "system_rec",
			editor: {
				type: 'select',
				options: [{'1':'녹취 서버'}, {'2':'백업 서버'}, {'0':'기타 서버'}]
			},
			render: function(ui) {

				var options = ui.column.editor.options,
					cellData = ui.cellData;
				for (var i = 0; i < options.length; i++) {
					var option = options[i];
					if (option[cellData]) {
						return option[cellData];
					}
				}

			},
		},
		{ title: "삭제", width: 40, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_delete.png' class='btn_delete'/>";
			}
		}
	];

	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		sorting:"local",
		//sortIndx: "system_code",
		//sortDir: "up",
		recIndx: "system_code"
	});

 	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("system_mgmt", "N", "N", "Y", "Y");
	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		scrollModel: { autoFit: true },
		numberCell:{resizable:true, title:"#"},
	});

	$grid = $("#grid").pqGrid(obj);

	// 시스템 등록폼 오픈시
	$("#modalRegiForm").on("show.bs.modal", function(e) {
		// 업무 구분
		$.ajax({
			type: "POST",
			url: "../common/get_business_code_list.jsp",
			async: false,
			dataType: "json",
			success:function(dataJSON){
				$("#regi select[name=business_code]").html("");

				if(dataJSON.code!="ERR") {
					if(dataJSON.data.length>0) {
						var html = "";
						for(var i=0;i<dataJSON.data.length;i++) {
							html += "<option value='" + dataJSON.data[i].business_code + "'>" + dataJSON.data[i].business_name + "</option>";
						}
						$("#regi select[name=business_code]").append(html);
					} else {
						alert("업무 구분 데이터가 없습니다.");
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

	// 시스템 등록 저장
	$("#regi button[name=modal_regi]").click(function() {
		if(!$("input[name=system_code]").val().trim()) {
			alert("시스템 코드를 입력해 주십시오.");
			$("input[name=system_code]").focus();
			return false;
		}
		if(!$("input[name=system_name]").val().trim()) {
			alert("시스템 명을 입력해 주십시오.");
			$("input[name=system_name]").focus();
			return false;
		}
		if(!$("input[name=system_ip]").val().trim()) {
			alert("시스템 IP를 입력해 주십시오.");
			$("input[name=system_ip]").focus();
			return false;
		}
		if(!$("input[name=license_cnt]").val().trim()) {
			alert("총 채널 수를 입력해 주십시오.");
			$("input[name=license_cnt]").focus();
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_system_mgmt_proc.jsp",
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

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>시스템 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 관리</a></li>
			 <li class="active"><strong>시스템 관리</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->

	<!--wrapper-content영역-->
	<div class="wrapper-content">
		<!--Data table 영역-->
		<div class="contentArea" style="padding-top: 10px;">
			<!--grid 영역-->
			<div id="grid"></div>
			<!--grid 영역 끝-->
			<!--팝업창 띠우기-->
			<div class="modal inmodal" id="modalRegiForm" tabindex="-1" role="dialog"  aria-hidden="true">
				<div class="modal-dialog">
					<div class="modal-content animated fadeIn">
						<form id="regi">
							<div class="modal-header">
								<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
								<h4 class="modal-title">시스템 등록</h4>
							</div>
							<div class="modal-body">
								<!--시스템 영역 table-->
								<table class="table top-line1 table-bordered2">
									<thead>
									<tr>
										<td style="width:40%;" class="table-td">업무구분 <span class="required">*</span></td>
										<td style="width:60%;">
											<select class="form-control" name="business_code">
											</select>
										</td>
									</tr>
									</thead>
									<tr>
										<td class="table-td">시스템코드 <span class="required">*</span></td>
										<td><input type="text" class="form-control" name="system_code" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">시스템명 <span class="required">*</span></td>
										<td><input type="text" class="form-control" name="system_name" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">시스템IP <span class="required">*</span></td>
										<td><input type="text" class="form-control" name="system_ip" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">백업IP</td>
										<td><input type="text" class="form-control" name="backup_ip" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">총채널수 <span class="required">*</span></td>
										<td><input type="text" class="form-control" name="license_cnt" placeholder=""></td>
									</tr>
									<tr>
										<td class="table-td">서버구분 <span class="required">*</span></td>
										<td>
											<select class="form-control" name="system_rec">
												<option value="1">녹취 서버</option>
												<option value="2">백업 서버</option>
												<option value="0">기타 서버</option>
											</select>
										</td>
									</tr>
								</table>
								<!--메뉴 코드 영역 table 끝-->
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
		</div>
		<!--Data table 영역 끝-->
	</div>
	<!--wrapper-content영역 끝-->

<%@ include file="../include/bottom.jsp" %>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_mgmt","")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String part_code = CommonUtil.getParameter("part_code", "");
		String user_id = CommonUtil.getParameter("user_id", "");
		String user_name = CommonUtil.getParameter("user_name", "");
		String local_no = CommonUtil.getParameter("local_no", "");

		Map<String,Object> argMap = new HashMap();

		// part_path 조회
		String part_path = "";
		if(CommonUtil.hasText(part_code)) {
			argMap.clear();
			argMap.put("business_code",CommonUtil.leftString(part_code, 2));
			//argMap.put("bpart_code",part_code.substring(2, 7));
			//argMap.put("mpart_code",part_code.substring(7, 12));
			//argMap.put("spart_code",part_code.substring(12, 17));
			argMap.put("bpart_code",part_code.substring(2, 2+(_PART_CODE_SIZE*1)));
			argMap.put("mpart_code",part_code.substring(2+(_PART_CODE_SIZE*1), 2+(_PART_CODE_SIZE*2)));
			argMap.put("spart_code",part_code.substring(2+(_PART_CODE_SIZE*2), 2+(_PART_CODE_SIZE*3)));

			part_path = db.selectOne("user_group.selectUserGroupPath", argMap);
		}

		// system_code list
		argMap.clear();
		argMap.put("system_rec", "1");

		List<Map<String, Object>> system_list = db.selectList("system.selectCodeList", argMap);
		String col_system_code = "";

		if(system_list.size()>0) {
			for(Map<String, Object> item : system_list) {
				col_system_code += ",{'" + item.get("system_code") + "':'" + item.get("system_name") + "'}";
			}
			col_system_code = col_system_code.substring(1);
		}

		// user_level list
		String _parent_code = "USER_LEVEL";

		List<Map<String, Object>> user_level_list = db.selectList("code.selectCodeList", _parent_code);
		String col_user_level = "";

		if(user_level_list.size()>0) {
			for(Map<String, Object> item : user_level_list) {
				col_user_level += ",{'" + item.get("comm_code") + "':'" + item.get("code_name") + "'}";
			}
			col_user_level = col_user_level.substring(1);
		}
%>
<script type="text/javascript">
$(function () {
	var colModel = [
		{ title: "순번", width: 60, dataIndx: "idx", editable: false, sortable: false },
		{ title: "상담원ID", width: 80, dataIndx: "user_id", editable: false },
		{ title: "비밀번호", width: 80, dataIndx: "user_pass", editor: {type: "textbox", attr: "type='password'"},
			validations: [
				{ type: function(ui) {
					var msg = checkPasswd(ui.rowData["user_id"], ui.value, true);
					if(msg!="") {
						ui.msg = msg;
						return false;
					}
				}}
			],
		},
		{ title: "상담사명", width: 80, dataIndx: "user_name",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			]
		},
		{ title: "내선번호", width: 80, dataIndx: "local_no",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			]
		},
		{ title: "채널번호", width: 80, dataIndx: "channel_no",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
				{ type: "maxLen", value: "3", msg: "3자리 이하로 입력해 주십시오." },
			]
		},
		{ title: "시스템명", width: 80, dataIndx: "system_code",
			editor: {
				type: 'select',
				options: [<%=col_system_code%>]
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
		{ title: "등급", width: 80, dataIndx: "user_level",
			editor: {
				type: 'select',
				options: [<%=col_user_level%>]
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
		{ title: "평가자", width: 80, dataIndx: "eval_yn",
			editor: {
				type: 'select',
				options: [{'n':'×'}, {'y':'o'}]
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
		{ title: "기존등급", dataIndx: "origin_level", hidden: true },
		/* { title: "비밀번호 사용기간", width: 80, dataIndx: "pass_chg_term",
			editor: {
				type: 'select',
				options: [{'90':'90일'}, {'60':'60일'}, {'30':'30일'}, {'10':'10일'}, {'7':'7일'}, {'1':'1일'}, {'0':'제한없음'}]
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
		}, */
		/* { title: "비밀번호 만료일자", width: 80, dataIndx: "pass_expire_date", editable: false }, */
		{ title: "비밀번호 변경일자", width: 80, dataIndx: "pass_upd_date", editable: false },
		{ title: "아이피", width: 80, dataIndx: "user_ip"},
		{ title: "퇴사여부", width: 80, dataIndx: "resign_yn",
			editor: {
				type: 'select',
				options: [{'1':'퇴사'}, {'0':'재직'}]
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
		{ title: "사용여부", width: 80, dataIndx: "use_yn",
			editor: {
				type: 'select',
				options: fn.usedCode.colModel
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
		{ title: "등록일자", width: 80, dataIndx: "regi_datm", editable: false,
			render: function (ui) {
				return ui.rowData["regi_datm"].substring(0,10);
			}
		},
		{ title: "잠금해제", width: 80, editable: false, sortable: false,
			render: function (ui) {
				if(ui.rowData["lock_yn"]=="1") {
					return "<img src='../img/icon/ico_unlock.png' class='btn_unlock'/>";
				} else {
					return "";
				}
				return "<img src='../img/icon/ico_unlock.png' class='btn_unlock'/>";
			}
		},
		{ title: "삭제", width: 40, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_delete.png' class='btn_delete'/>";
			}
		}
	];

	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		//sortIndx: "regi_datm",
		sortDir: "down",
		recIndx: "user_id"
	});

	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("user_list", "Y", "Y", "Y", "Y");
	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		scrollModel: { autoFit: true },
	});

	$grid = $("#grid").pqGrid(obj);

	// 상담원 등록폼 오픈시
	$("#modalRegiForm").on("show.bs.modal", function(e) {
		// 업무 구분/대분류/중분류/소분류 셋팅
		var part_path = "<%=part_path%>";
		if(part_path=="") {
			alert("선택된 조직도가 존재해야만 등록 가능합니다.");
			return false;
		}

		var part_arr = part_path.split(":");
  		$("#regi #business_name").text(part_arr[0]);
  		$("#regi #bpart_name").text(part_arr[1]);
  		$("#regi #mpart_name").text(part_arr[2]);
  		$("#regi #spart_name").text(part_arr[3]);
<%
		//사용자 등급
		String opt_user_level = "";
		if(user_level_list.size()>0) {
			for(Map<String, Object> item : user_level_list) {
				opt_user_level += "<option value='" + item.get("comm_code") + "'>" + item.get("code_name") + "</option>";
			}
		}
%>
		$("#regi select[name=user_level]").html("");
		$("#regi select[name=user_level]").append("<%=opt_user_level%>");

<%
		//시스템 명
		String opt_system_code = "<option value=''></option>";
		if(system_list.size()>0) {
			for(Map<String, Object> item : system_list) {
				opt_system_code += "<option value='" + item.get("system_code") + "'>" + item.get("system_name") + "</option>";
			}
		}
%>
		$("#regi select[name=system_code]").html("");
		$("#regi select[name=system_code]").append("<%=opt_system_code%>");
	});

	// 상담원 등록 저장
	$("#regi button[name=modal_regi]").click(function() {
		if(!$("#regi input[name=user_id]").val().trim()) {
			alert("상담원ID를 입력해 주십시오.");
			$("#regi input[name=user_id]").focus();
			return false;
		}
		if(!$("#regi input[name=user_pass]").val().trim()) {
			alert("비밀번호를 입력해 주십시오.");
			$("#regi input[name=user_pass]").focus();
			return false;
		}
		if(!checkPasswd($("#regi input[name=user_id]").val().trim(), $("#regi input[name=user_pass]").val().trim(), false)) {
			$("#regi input[name=user_pass]").focus();
			return false;
		}
		if(!$("#regi input[name=user_name]").val().trim()) {
			alert("상담사명을 입력해 주십시오.");
			$("#regi input[name=user_name]").focus();
			return false;
		}
		if(!$("#regi input[name=local_no]").val().trim()) {
			alert("내선 번호를 입력해 주십시오.");
			$("#regi input[name=local_no]").focus();
			return false;
		}
		if($("#regi input[name=channel_no]") && !$("#regi input[name=channel_no]").val().trim()) {
			alert("채널 번호를 입력해 주십시오.");
			$("#regi input[name=channel_no]").focus();
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_user_list_proc.jsp",
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

	// 잠금해제 실행
	$grid.on("pqgridrefresh", function(event, ui) {
		$grid.find(".btn_unlock")
		.unbind("click")
		.bind("click", function (evt) {
			if (confirm("정말로 잠금해제 하시겠습니까?")) {
				var $tr = $(this).closest("tr");
				var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;
				var recIndx = $grid.pqGrid("getRecId", { rowIndx: rowIndx });

				$.ajax({
					type: "POST",
					url: "remote_user_list_proc.jsp",
					async: false,
					data: "step=unlock&row_id="+recIndx,
					dataType: "json",
					success:function(dataJSON){
						if(dataJSON.code=="OK") {
							alert("정상적으로 잠금해제 되었습니다.");
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
	<div class="bullet"><i class="fa fa-angle-right"></i></div>
	<h5 style="margin-top:0;color:#2e71b9">상담사 관리</h5>
	<div class="hr2" style="margin-bottom: 12px;"></div>
	<form id="search">
		<input type="hidden" name="part_code" value="<%=part_code%>"/>
		<input type="hidden" name="user_id" value="<%=user_id%>"/>
		<input type="hidden" name="user_name" value="<%=user_name%>"/>
		<input type="hidden" name="local_no" value="<%=local_no%>"/>
	</form>
	<!--grid 영역-->
	<div id="grid"></div>
	<!--grid 영역 끝-->
	<!--팝업창 띠우기-->
	<div class="modal inmodal" id="modalRegiForm" tabindex="-1" role="dialog"  aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content animated fadeIn">
				<form id="regi">
					<input type="hidden" name="part_code" value="<%=part_code%>"/>

					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
						<h4 class="modal-title">상담사 등록</h4>
					</div>
					<div class="modal-body" >
						<!--업무코드 table-->
						<table class="table top-line1 table-bordered2">
							<thead>
							<tr>
								<td style="width:40%;" class="table-td">업무구분</td>
								<td style="width:60%; padding: 6px 9px;">
									<span id="business_name"></span>
								</td>
							</tr>
							</thead>
							<tr>
								<td class="table-td">대분류</td>
								<td style="padding: 6px 9px;">
									<span id="bpart_name"></span>
								</td>
							</tr>
							<tr>
								<td class="table-td">중분류</td>
								<td style="padding: 6px 9px;">
									<span id="mpart_name"></span>
								</td>
							</tr>
							<tr>
								<td class="table-td">소분류</td>
								<td style="padding: 6px 9px;">
									<span id="spart_name"></span>
								</td>
							</tr>
							<tr>
								<td class="table-td">상담원ID <span class="required">*</span></td>
								<td>
									<input type="text" name="user_id" class="form-control" id="" placeholder="" maxlength="20">
								</td>
							</tr>
							<tr>
								<td class="table-td">비밀번호 <span class="required">*</span></td>
								<td>
									<input type="password" name="user_pass" class="form-control" id="" placeholder="" maxlength="30">
								</td>
							</tr>
							<tr>
								<td class="table-td">상담사명 <span class="required">*</span></td>
								<td>
									<input type="text" name="user_name" class="form-control" id="" placeholder="" maxlength="20">
								</td>
							</tr>
							<tr>
								<td class="table-td">내선번호 <span class="required">*</span></td>
								<td>
									<input type="text" name="local_no" class="form-control" id="" placeholder="" maxlength="15">
								</td>
							</tr>
							<tr>
								<td class="table-td">채널번호 <span class="required">*</span></td>
								<td>
									<input type="text" name="channel_no" class="form-control" id="" placeholder="" maxlength="3">
								</td>
							</tr>
							<tr>
								<td class="table-td">시스템명</td>
								<td>
									<select class="form-control" name="system_code">
									</select>
								</td>
							</tr>
							<tr>
								<td class="table-td">등급 <span class="required">*</span></td>
								<td>
									<select class="form-control" name="user_level">
									</select>
								</td>
							</tr>
							<tr>
								<td class="table-td">평가자여부</td>
								<td>
									<label><input type=radio name="eval_yn" value="y"> 예</label>
									<label><input type=radio name="eval_yn" value="n" checked> 아니오</label>
								</td>
							</tr>
							<!-- <tr>
								<td class="table-td">비밀번호 사용기간 <span class="required">*</span></td>
								<td>
									<select class="form-control" name="pass_chg_term">
										<option value="90">90일</option>
										<option value="60">60일</option>
										<option value="30">30일</option>
										<option value="10">10일</option>
										<option value="7">7일</option>
										<option value="1">1일</option>
										<option value="0">제한없음</option>
									</select>
								</td>
							</tr> -->
							<tr>
								<td class="table-td">아이피</td>
								<td>
									<input type="text" name="user_ip" class="form-control" id="" placeholder="" maxlength="15">
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
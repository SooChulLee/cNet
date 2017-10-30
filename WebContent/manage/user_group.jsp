<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"eval","")) return;

	Db db = null;

	try {
		db = new Db(true);

		String type = CommonUtil.getParameter("type", "depth0");
		String part_code = CommonUtil.getParameter("part_code", "");

		// 첫번째 업무코드 조회
		if(!CommonUtil.hasText(part_code)) {
			Map<String, Object> resmap = db.selectOne("business.selectFirstItem");
			if(resmap!=null) {
				//part_code = resmap.get("business_code").toString() + "00000" + "00000" + "00000";
				part_code = resmap.get("business_code").toString() + _PART_DEFAULT_CODE + _PART_DEFAULT_CODE + _PART_DEFAULT_CODE;
			}
		}

		String prefix_name = "";
		if("depth0".equals(type)) {
			prefix_name = "대분류";
		} else if("depth1".equals(type)) {
			prefix_name = "중분류";
		} else if("depth2".equals(type)) {
			prefix_name = "소분류";
		} else {
			out.print(CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}
%>
<script type="text/javascript">
$(function () {
	//alert("<%=type%>");
	var type = "<%=type%>";
	if (type == "depth2"){
		var colModel = [
			{ title: "<%=prefix_name%>코드", minWidth: 150, dataIndx: "part_code", editable: false },
			{ title: "<%=prefix_name%>명", minWidth: 200, dataIndx: "part_name",
				validations: [
					{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
				]
			},

			{ title: "녹취파일 보관일수", width: 150, dataIndx: "delete_day",
				editor: {
					type: 'select',
					options: [{'':''},{'90':'3개월'},{'120':'6개월'}, {'365':'1년'}, {'730':'2년'}, {'1825':'5년'}]
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


			{ title: "삭제", minWidth: 40, editable: false, sortable: false, render: function (ui) {
					return "<img src='../img/icon/ico_delete.png' class='btn_delete'/>";
				}
			}
		];

	}else {
		var colModel = [
			{ title: "<%=prefix_name%>코드", minWidth: 150, dataIndx: "part_code", editable: false },
			{ title: "<%=prefix_name%>명", minWidth: 200, dataIndx: "part_name",
				validations: [
					{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
				]
			},
			{ title: "삭제", minWidth: 40, editable: false, sortable: false, render: function (ui) {
					return "<img src='../img/icon/ico_delete.png' class='btn_delete'/>";
				}
			}
		];
	}
	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		sorting:"local",
		//sortIndx: "part_code",
		//sortDir: "up",
		recIndx: "row_id"
	});

	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("user_group", "N", "N", "Y", "Y");
	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		flexWidth: true,
		numberCell:{resizable:true, title:"#"},
	});

	$grid = $("#grid").pqGrid(obj);

	// 그룹 등록 저장
	$("#regi button[name=modal_regi]").click(function() {
		var part_name_txt = "<%=prefix_name%>";
		var part_code_len = <%=_PART_CODE_SIZE%>;

		if(!$("input[name=part_code]").val().trim()) {
			alert(part_name_txt + " 코드를 입력해 주십시오.");
			$("input[name=part_code]").focus();
			return false;
		}

		if($("input[name=part_code]").val().trim().length!=part_code_len) {
			alert(part_name_txt + " 코드를 " + part_code_len + "자리 숫자로 입력해 주십시오.");
			$("input[name=part_code]").focus();
			return false;
		}

		if(!$("input[name=part_name]").val().trim()) {
			alert(part_name_txt + " 명을 입력해 주십시오.");
			$("input[name=part_name]").focus();
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_user_group_proc.jsp",
			async: false,
			data: "step=insert&"+$("#regi").serialize(),
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					alert("정상적으로 등록되었습니다.");
					$("#modalRegiForm").modal("hide");
					$grid.pqGrid("refreshDataAndView");

					// tree reload
					$("#tree").jstree(true).refresh();
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
	<h5 style="margin-top:0;color:#2e71b9"><%=prefix_name%> 관리</h5>
	<div class="hr2" style="margin-bottom: 12px;"></div>
	<form id="search">
		<input type="hidden" name="type" value="<%=type%>"/>
		<input type="hidden" name="parent_code" value="<%=part_code%>"/>
	</form>
	<!--grid 영역-->
	<div id="grid"></div>
	<!--grid 영역 끝-->
	<!--팝업창 띠우기-->
	<div class="modal inmodal" id="modalRegiForm" tabindex="-1" role="dialog"  aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content animated fadeIn">
				<form id="regi">
					<input type="hidden" name="type" value="<%=type%>"/>
					<input type="hidden" name="parent_code" value="<%=part_code%>"/>

					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
						<h4 class="modal-title"><%=prefix_name%> 등록</h4>
					</div>
					<div class="modal-body" >
						<!--업무코드 table-->
						<table class="table top-line1 table-bordered2">
							<thead>
							<tr>
								<td style="width:40%;" class="table-td"><%=prefix_name%>코드 <span class="required">*</span></td>
								<td style="width:60%;">
									<input type="text" name="part_code" class="form-control" id="" placeholder="" maxlength="6">
								</td>
							</tr>
							</thead>
							<tbody>
							<tr>
								<td class="table-td"><%=prefix_name%>명 <span class="required">*</span></td>
								<td>
									<input type="text" name="part_name" class="form-control" id="" placeholder="">
								</td>
							</tr>
							<% if("depth2".equals(type)) { %>
							<tr>
								<td class="table-td">녹취파일 보관일수 <span class="required">*</span></td>
								<td>
									<select name="delete_day" class="form-control" id="" placeholder="">
										<option value=""></option>
										<option value="90">3개월</option>
										<option value="120" selected>6개월</option>
										<option value="365">1년</option>
										<option value="730">2년</option>
										<option value="1825">5년</option>
									</select>
								</td>
							</tr>
							<% }%>
							</tbody>
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
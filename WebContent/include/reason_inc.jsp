<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="modal inmodal" id="modalReasonForm" tabindex="-1" role="dialog" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content animated fadeIn">									
			<div class="modal-header">							
				<h4 class="modal-title">청취/다운로드 사유등록</h4>
			</div>
			<div class="modal-body" >
				<!--업무코드 table-->	
				<table class="table top-line1 table-bordered2">
					<thead>
					<tr>
						<td style="width:40%;" class="table-td">사유선택 <span class="required">*</span></td>
						<td style="width:60%;">
							<select name="reason_code" class="form-control">
								<option value="">사유 선택</option>
							</select>
						</td>
					</tr>
					</thead>	
					<tbody>
					<tr>
						<td class="table-td">기타</td>
						<td>
							<input type="text" name="reason_text" class="form-control" id="" placeholder="" disabled="disabled">
						</td>
					</tr>							
					</tbody>					
				</table>
				<!--업무코드 table 끝-->	
			</div>
			<div class="modal-footer">
				<button type="button" name="modal_regi" class="btn btn-primary btn-sm"><i class="fa fa-pencil"></i> 등록</button>
				<button type="button" name="modal_cancel" class="btn btn-default btn-sm" onclick="self.close();"><i class="fa fa-times"></i> 취소</button>
			</div>				
		</div>
	</div>
</div>
<script type="text/javascript">
$(function(){
	$("#modalReasonForm").on("show.bs.modal", function(e) {
		// 청취/다운로드 사유 코드
		getCommCodeToForm("LD_REASON", "modalReasonForm", "reason_code");
	});
	
	// 사유코드 변경시
	$("#modalReasonForm select[name=reason_code]").change(function(){		
		if($(this).val()=="99") {
			$("#modalReasonForm input[name=reason_text]").attr("disabled", false);
			$("#modalReasonForm input[name=reason_text]").focus();
		} else {
			$("#modalReasonForm input[name=reason_text]").attr("disabled", true);
		}
	});
	
	$("#modalReasonForm").modal("toggle");
});

// form check
function reasonFormChk() {
	if(!$("#modalReasonForm select[name=reason_code]").val()) {
		alert("사유코드를 선택해 주십시오.");
		return false;
	}
	if($("#modalReasonForm select[name=reason_code]").val()=="99" && $("#modalReasonForm input[name=reason_text]").val().trim()=="") {
		alert("기타 내용을 입력해 주십시오.");
		$("#modalReasonForm input[name=reason_text]").focus();
		return false;
	}
	return true;
};
</script>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"item","")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String cate_code = CommonUtil.getParameter("cate_code");
		String selected_index = CommonUtil.getParameter("selected_index", "0");
		String selected_code = CommonUtil.getParameter("selected_code");

		// 파라미터 체크
		if(!CommonUtil.hasText(cate_code)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","back"));
			return;
		}

		// 변수 선언
		String select_item_code = "";
		int n = 0;
		String odd = "";

		// 항목 조회
		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("cate_code",cate_code);
		argMap.put("item_depth","1");

		// 항목 리스트
		List<Map<String, Object>> item_list = db.selectList("item.selectList", argMap);

		if(!CommonUtil.hasText(selected_code) && item_list.size()>0) {
			// 첫번째 item_code
			selected_code = item_list.get(0).get("item_code").toString();
		}
%>
<script type="text/javascript">
$(function () {
	// 평가항목 등록
	$("button[name=btn_item_regi]").click(function() {
		itemProc("item", $(this).attr("prop"), "");
	});

	// 평가항목 수정폼 셋팅
	$(".icon_item_update").click(function() {
		itemUpdForm("item", $(".icon_item_update").index(this), $(".item_row").eq($(".icon_item_update").index(this)).attr("prop"));
	});

	// 평가항목 삭제
	$(".icon_item_delete").click(function() {
		itemProc("item", "delete", $(".item_row").eq($(".icon_item_delete").index(this)).attr("prop"));
	});

	// 평가보기 조회
	$(".txt_item_name").click(function() {
		getExamList($(".txt_item_name").index(this), $(".item_row").eq($(".txt_item_name").index(this)).attr("prop"), "<%=cate_code%>");
	});

	// 평가항목보기 등록
	$("button[name=btn_exam_regi]").click(function() {
		itemProc("exam", $(this).attr("prop"), "");
	});

	// 첫번째 평가항목 select
	getExamList("<%=selected_index%>", "<%=selected_code%>", "<%=cate_code%>");
});

// 평가항목 수정폼 셋팅
var itemUpdForm = function(type, idx, item_code) {
	if(idx=="" && idx==undefined) {
		return;
	}
	// form object
	var obj = $("#"+type+"_regi");
	// 항목 코드
	obj.find("input[name=item_code]").val(item_code);
	// 항목 명
	obj.find("input[name=item_name]").val($(".txt_" + type + "_name").eq(idx).html());
	// 사용 여부
	obj.find("select[name=use_yn]").val($(".txt_" + type + "_use_yn").eq(idx).html());
	// step
	obj.find("button[name=btn_" + type + "_regi]").attr("prop", "update");
};

// 평가항목 등록/수정/삭제
var itemProc = function(type, step, item_code) {
	var obj = $("#"+type+"_regi");
	var txt = "";
	var param = "";
	var type_name = (type=="item") ? "항목" : "항목 보기";

	if(step=="delete") {
		if(!confirm("정말로 삭제하시겠습니까?")) {
			return false;
		}
		txt = "삭제";
		param = "item_code="+item_code;
	} else {
		if(!obj.find("input[name=item_name]").val().trim()) {
			alert("평가 " + type_name + "명을 입력해 주십시오.");
			obj.find("input[name=item_name]").focus();
			return false;
		}
		txt = (step=="insert") ? "등록" : "수정";
		param = obj.serialize();
	}

	$.ajax({
		type: "POST",
		url: "remote_item_list_proc.jsp",
		async: false,
		data: "step="+step+"&"+param,
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code=="OK") {
				alert("정상적으로 " + txt + " 되었습니다.");
				// data reload
				$("#tree").jstree("deselect_all");
				$("#tree").jstree("select_node", $("#item_regi input[name=cate_code]").val());
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

// 평가보기 조회
function getExamList (idx, parent_code, cate_code) {
	if(parent_code=="") return;

	// all deselect
	$(".item_row").each(function(i){
		$(".item_row").eq(i).removeClass("odd5");
	});
	// select
	$(".item_row").eq(idx).addClass("odd5");

	// set value
	$("#exam_regi input[name=parent_code]").val(parent_code);
	$("#outer_list").attr("idx", idx);
	$("#outer_list").attr("prop", parent_code);

	$.ajax({
		type: "POST",
		url: "remote_item_list.jsp",
		async: false,
		data: "cate_code="+cate_code+"&parent_code="+parent_code+"&item_depth=2",
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code=="ERR") {
				alert(dataJSON.msg);
				return false;
			} else {
				// 초기화
				$("#exam_list").html("");

				var html = "";
				if(dataJSON.totalRecords>0) {
					var odd = "";
					for(var i=0;i<dataJSON.data.length;i++) {
						odd = (i%2==1) ? " odd" : "";

						html += "<tr class=\"exam_row"+odd+"\" prop=\"" + dataJSON.data[i].item_code + "\">";
						html += "<td>" + (i+1) + "</td>";
						html += "<td class=\"t-left\"><span class=\"txt_exam_name\">" + dataJSON.data[i].item_name + "</span></td>";
						html += "<td>" + fn.getValue("usedCode",dataJSON.data[i].use_yn) + "<span class=\"txt_exam_use_yn hidden\">" + dataJSON.data[i].use_yn + "</span></td>";
						html += "<td><a href=\"#none\" onclick=\"itemUpdForm('exam', '" + i + "', '" + dataJSON.data[i].item_code + "');\" class=\"icon_exam_update\"><i class=\"fa fa-pencil-square-o fontIcon\"></i></a></td>";
						html += "<td><a href=\"#none\" onclick=\"itemProc('exam', 'delete', '" + dataJSON.data[i].item_code + "');\" class=\"icon_exam_delete\"><i class=\"fa fa-trash-o fontIcon\"></i></a></td>";
						html += "</tr>";
					}
				} else {
					html = "<tr><td colspan=\"5\">등록된 평가 항목보기가 없습니다.</td></tr>";
				}
				$("#exam_list").html(html);
			}
		},
		error:function(req,status,err){
			alertJsonErr(req,status,err);
			return false;
		}
	});
};
</script>

	<!--평가 항목 영역-->
	<div class="tableRadius1">
		<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">평가 질문</h5>
		<!--table-->
		<table class="table top-line1 table-bordered tt">
			<thead>
				<tr>
					<th style="width:7%;">순번</th>
					<th>질문</th>
					<th style="width:15%;">사용 여부</th>
					<th style="width:10%;">수정</th>
					<th style="width:10%;">삭제</th>
				</tr>
			</thead>
			<tbody id="item_list">
<%
		if(item_list.size()>0) {
			for(Map<String, Object> item : item_list) {
				odd = (n%2==1) ? " odd" : "";
%>
				<tr class="item_row<%=odd%>" prop="<%=item.get("item_code")%>">
					<td><%=n+1 %></td>
					<td class="t-left"><a href="#none" class="txt_item_name"><%=item.get("item_name") %></a></td>
					<td><%=Finals.getValue(Finals.hUsedCode,item.get("use_yn"))%><span class="txt_item_use_yn hidden"><%=item.get("use_yn") %></span></td>
					<td><a href="#none" class="icon_item_update"><i class="fa fa-pencil-square-o fontIcon"></i></a></td>
					<td><a href="#none" class="icon_item_delete"><i class="fa fa-trash-o fontIcon"></i></a></td>
				</tr>
<%
				n++;
			}
		} else {
			out.print("<tr><td colspan=\"5\">등록된 평가 항목이 없습니다.</td></tr>");
		}

%>
			</tbody>
		</table>
		<!--table 끝-->
	</div>
	<div class="tableRadius3 t-space">
		<form id="item_regi">
			<input type="hidden" name="item_code" value=""/>
			<input type="hidden" name="cate_code" value="<%=cate_code%>"/>
			<div id="listDiv1">
				<div id="labelDiv">
					<label class="simple_tag">질문</label><input type="text" class="form-control list_form1" id="" name="item_name" placeholder="">
				</div>
			</div>

			<div id="listDiv2">
				<div id="label_Div">
					<label class="simple_tag">사용 여부</label>
					<select class="form-control list_form2" name="use_yn">
						<option value="1">사용</option>
						<option value="0">사용안함</option>
					</select>
				</div>
			</div>
			<span class="colRight"><button type="button" name="btn_item_regi" class="btn btn-register btn-sm" prop="insert"><i class="fa fa-check"></i> 저장</button></span>
		</form>
	</div>
	<!--평가 항목 영역 끝-->

	<!--평가 답변 영역-->
	<div class="tableRadius1">
		<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">평가 답변</h5>
		<!--table-->
		<table class="table top-line1 table-bordered tt">
			<thead>
				<tr>
					<th style="width:7%;">순번</th>
					<th>답변</th>
					<th style="width:15%;">사용 여부</th>
					<th style="width:10%;">수정</th>
					<th style="width:10%;">삭제</th>
				</tr>
			</thead>
			<tbody id="exam_list">
				<tr>
					<td colspan="5">먼저 평가 항목을 선택하여 주십시오.</td>
				</tr>
			</tbody>
		</table>
		<!--table 끝-->
	</div>
	<div class="tableRadius3 t-space">
		<form id="exam_regi">
			<input type="hidden" name="item_code" value=""/>
			<input type="hidden" name="parent_code" value=""/>
			<input type="hidden" name="cate_code" value="<%=cate_code%>"/>
			<div id="listDiv1">
				<div id="labelDiv">
					<label class="simple_tag">답변</label><input type="text" class="form-control list_form1" id="" name="item_name" placeholder="">
				</div>
			</div>

			<div id="listDiv2">
				<div id="label_Div">
					<label class="simple_tag">사용 여부</label>
					<select class="form-control list_form2" name="use_yn">
						<option value="1">사용</option>
						<option value="0">사용안함</option>
					</select>
				</div>
			</div>
			<span class="colRight"><button type="button" name="btn_exam_regi" class="btn btn-register btn-sm" prop="insert"><i class="fa fa-check"></i> 저장</button></span>
		</form>
	</div>
	<!--평가 답변 영역 끝-->
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>

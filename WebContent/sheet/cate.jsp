<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"cate","")) return;

	Db db = null;

	try {
		db = new Db(true);

		// parent_code list
		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("cate_depth","1");

		List<Map<String, Object>> parent_code_list = db.selectList("cate.selectCateList", argMap);

%>
<jsp:include page="/include/top.jsp" flush="false"/>
<link rel="stylesheet" href="../css/tree/default/style.css" />
<script type="text/javascript" src="../js/plugins/tree/jstree.min.js"></script>
<script type="text/javascript">
$(function () {
	//tree
	var tree = $("#tree").jstree({
		"core" : {
			"data" : {
				"url": "/common/get_eval_cate_tree.jsp",
				"dataType": "json",
			},
			"themes" : {
				"variant" : "medium"
			}
		},
		"types" : {
			"depth1" : {
				"icon" : "../img/tree_depth1_close.gif"
			},
			"depth2" : {
				"icon" : "jstree-file"
			}
		},
		"plugins" : ["types"]
	});

	tree.bind("loaded.jstree", function() {
		tree.jstree("open_all");
	});

	// tree 클릭 시
	tree.bind("select_node.jstree", function(obj, data) {
		//tree node를 클릭하면 해당 정보 등록폼에 셋팅
		$.ajax({
			type: "POST",
			url: "remote_cate.jsp",
			async: false,
			data: "cate_code="+data.node.id,
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					// html
					$(".table-title3").html("카테고리 수정");
					$("#regi button[name=btn_regi] span").html("수정");
					$("#regi button[name=btn_delete]").removeClass("hidden").addClass("show");
					// form
					$("#regi input[name=cate_code]").val(data.node.id);
					$("#regi input[name=cate_name]").val(dataJSON.data.cate_name);
					$("#regi select[name=parent_code]").val((dataJSON.data.cate_depth=="1") ? "_parent" : dataJSON.data.parent_code);
					$("#regi input[name=parent_ori_code]").val($("#regi select[name=parent_code]").val());
					$("#regi textarea[name=cate_desc]").val(dataJSON.data.cate_desc);
					$("#regi input[name=cate_etc]").val(dataJSON.data.cate_etc);
					$("#regi select[name=use_yn]").val(dataJSON.data.use_yn);
					$("#regi button[name=btn_regi]").attr("prop","update");
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
	});

	// 카테고리 등록/수정 저장
	$("#regi button[name=btn_regi]").click(function() {
		var step = $("button[name=btn_regi]").attr("prop");
		var text = (step=="insert") ? "등록" : "수정";

		if(!$("input[name=cate_name]").val().trim()) {
			alert("카테고리 명을 입력해 주십시오.");
			$("input[name=cate_name]").focus();
			return false;
		}
		if(step=="update" && $("select[name=parent_code]").val()!=$("input[name=parent_ori_code]").val()) {
			alert("상위 카테고리는 변경하실 수 없습니다.");
			$("select[name=parent_code]").val($("input[name=parent_ori_code]").val());
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_cate_proc.jsp",
			async: false,
			data: "step="+step+"&"+$("#regi").serialize(),
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					alert("정상적으로 " + text + "되었습니다.");
					// form clear
					$("#regi")[0].reset();
					// tree reload
					tree.jstree(true).refresh();
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
	});

	// 삭제 버튼 클릭 시
	$("#regi button[name=btn_delete]").click(function() {
		if(!$("input[name=cate_code]").val().trim()) {
			alert("필수 파라미터가 없습니다.");
			return false;
		}

		if(confirm("정말로 삭제하시겠습니까?")) {
			$.ajax({
				type: "POST",
				url: "remote_cate_proc.jsp",
				async: false,
				data: "step=delete&cate_code="+$("input[name=cate_code]").val(),
				dataType: "json",
				success:function(dataJSON){
					if(dataJSON.code=="OK") {
						alert("정상적으로 삭제되었습니다.");
						// html
						$(".table-title3").html("카테고리 등록");
						$("#regi button[name=btn_regi] span").html("등록");
						$("#regi button[name=btn_delete]").removeClass("show").addClass("hidden");
						// form clear
						$("#regi")[0].reset();
						// tree reload
						tree.jstree(true).deselect_all();
						tree.jstree(true).refresh();
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
		}
	});

	// 취소 버튼 클릭 시
	$("#regi button[name=btn_cancel]").click(function() {
		location.reload();
	});
});
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>카테고리 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 시트 관리</a></li>
			 <li class="active"><strong>카테고리 관리</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->

		<!--wrapper-content영역-->
		<div class="wrapper-content">
			<!--class conSize 시작-->
			<div class="conSize">
				<!--평가 카테고리 트리메뉴 시작-->
				<div id="frameDiv1">
					<div class="categoryFrame1">
						<h5>평가 카테고리 <a href="cate.jsp"><span style="padding-left: 5px; font-size: 12px;">[등록]</span></a></h5>
					</div>
					<div class="categoryFrame2">
						<!-- 카테고리 tree -->
						<div id="tree"></div>
						<!-- 카테고리 tree 끝 -->
					</div>
				</div>
				<!--평가 카테고리 트리메뉴 끝-->

				<!--컨텐츠 영역 시작-->
				<div id="frameDiv2" >
					<form id="regi">
						<input type="hidden" name="cate_code" value=""/>
						<input type="hidden" name="parent_ori_code" value=""/>
						<div class="tableRadius1">
							<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">카테고리 등록</h5>
							<!--table-->
							<table class="table top-line1 table-bordered2">
								<thead>
								<tr>
									<td style="width:40%;" class="table-td">카테고리 명</td>
									<td style="width:60%;"><input type="text" class="form-control" name="cate_name" placeholder=""></td>
								</tr>
								</thead>
								<tr>
									<td class="table-td">상위 카테고리</td>
									<td><select class="form-control" name="parent_code">
											<option value="_parent">상위 카테고리 없음</option>
<%
						if(parent_code_list!=null) {
							for(Map<String, Object> item : parent_code_list) {
								out.print("<option value='"+item.get("cate_code")+"'>"+item.get("cate_name")+"</option>\n");
							}
						}
%>
										</select>
									</td>
								</tr>
								<tr>
									<td class="table-td">설명</td>
									<td><textarea class="form-control message-input2" name="cate_desc" placeholder=""></textarea></td>
								</tr>
								<tr>
									<td class="table-td">비고</td>
									<td><input type="text" class="form-control" name="cate_etc" placeholder=""></td>
								</tr>
								<tr>
									<td class="table-td">사용 여부</td>
									<td><select class="form-control" name="use_yn">
											<option value="1">사용</option>
											<option value="0">사용안함</option>
										</select>
									</td>
								</tr>
							</table>
							<!--table 끝-->
						</div>
						<div class="tableRadius2 colCenter">
							<button type="button" name="btn_regi" class="btn btn-register btn-sm" prop="insert"><i class="fa fa-pencil"></i> <span>등록</span></button>
							<button type="button" name="btn_cancel" class="btn btn-default btn-sm"><i class="fa fa-times"></i> 취소</button>
							<button type="button" name="btn_delete" class="btn btn-danger btn-sm pull-right hidden"><i class="fa fa-pencil"></i> 삭제</button>
						</div>
					</form>
				</div>
				<!--컨텐츠 영역 끝-->

			</div>
			<!--class conSize 끝-->

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

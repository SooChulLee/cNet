<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"rec_search","close")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String rec_datm = CommonUtil.getParameter("rec_datm");
		String local_no = CommonUtil.getParameter("local_no");
		String rec_filename = CommonUtil.getParameter("rec_filename");

		// 파라미터 체크
		if(!CommonUtil.hasText(rec_datm) || !CommonUtil.hasText(local_no) || !CommonUtil.hasText(rec_filename)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}

		// 사용권한 체크
		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("conf_field","memo");
		argMap.put("user_id",_LOGIN_ID);
		argMap.put("user_level",_LOGIN_LEVEL);

		if(!"1".equals(db.selectOne("search_config.selectResultPerm", argMap))) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("ERR_PERM"),"","close"));
			return;
		}

		// yyyyMMddHHmmssSSS -> yyyy-MM-dd HH:mm:ss.SSS
		//rec_datm = DateUtil.getDateFormatByIntVal(rec_datm, "yyyy-MM-dd HH:mm:ss.SSS");
		rec_datm = DateUtil.getDateFormatByIntVal(rec_datm, "yyyy-MM-dd HH:mm:ss");

		argMap.clear();
		argMap.put("dateStr", CommonUtil.getRecordTableNm(rec_datm));
		argMap.put("rec_datm",rec_datm);
		argMap.put("local_no",local_no);
		argMap.put("rec_filename",rec_filename);

		// 녹취이력 조회
		Map<String, Object> data  = db.selectOne("rec_search.selectItem", argMap);
		if(data==null) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_DATA"),"","close"));
			return;
		}

		// 메모 리스트 조회
		argMap.clear();
		argMap.put("rec_datm",rec_datm);
		argMap.put("local_no",local_no);
		argMap.put("rec_filename",rec_filename);

		// 사용자 권한에 따른 조직도 조회
		argMap.put("_user_id",_LOGIN_ID);
		argMap.put("_user_level",_LOGIN_LEVEL);
		argMap.put("_bpart_code",_BPART_CODE);
		argMap.put("_mpart_code",_MPART_CODE);
		argMap.put("_spart_code",_SPART_CODE);

		List<Map<String, Object>> list = db.selectList("rec_memo.selectList", argMap);
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>메모</title>
<link href="../css/bootstrap.css" rel="stylesheet">
<link href="../css/font-awesome.css" rel="stylesheet">
<link href="../css/animate.css" rel="stylesheet">
<link href="../css/style.css" rel="stylesheet">

<script type="text/javascript" src="../js/site.js"></script>
<script type="text/javascript" src="../js/jquery-1.11.0.min.js"></script>
<script type="text/javascript">
$(function () {
	// 메모 저장
	$("#regi button[name=btn_regi]").click(function() {
		if(!$("textarea[name=memo_text]").val().trim()) {
			alert("메모 내용을 입력해 주십시오.");
			$("textarea[name=memo_text]").focus();
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_memo_proc.jsp",
			async: false,
			data: "step=insert&"+$("#regi").serialize(),
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					alert("정상적으로 등록되었습니다.");
					location.reload();
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

var deleteMemo = function(memoSeq) {
	if(confirm("정말로 삭제하시겠습니까?")) {
		if(!memoSeq.trim()) {
			alert("필수 파라미터가 없습니다.");
			return;
		}

		var param = {
			step: "delete",
			memo_seq: memoSeq,
			rec_datm: $("#regi input[name=rec_datm]").val(),
			local_no: $("#regi input[name=local_no]").val(),
			rec_filename: $("#regi input[name=rec_filename]").val()
		};

		$.ajax({
		   	type: "POST",
		   	url: "remote_memo_proc.jsp",
			async: false,
		   	data: param,
		   	dataType: "json",
		   	success:function(dataJSON){
				if(dataJSON.code=="OK") {
					alert("정상적으로 삭제되었습니다.");
					location.reload();
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
};
</script>
</head>

<body class="white-bg">
	<div class="memo-body">
		<!--메모 등록 영역-->
		<div class="memo-post tableSize3">
			<form id="regi">
				<input type="hidden" name="rec_datm" value="<%=rec_datm%>"/>
				<input type="hidden" name="local_no" value="<%=local_no%>"/>
				<input type="hidden" name="rec_filename" value="<%=rec_filename%>"/>
				<span class="colLeft"><textarea name="memo_text" class="form-control message-input" name="message" placeholder="Enter message text"></textarea></span>
				<span class="colRight"><button type="button" name="btn_regi" class="btn btn-memo block"> 메모등록</button></span>
			</form>
		</div>
		<!--메모 등록 영역 끝-->

		<!--메모 리스트 영역-->
		<div class="memo-discussion tableSize3">
<%
	if(list!=null) {
		for(Map<String, Object> item : list) {
%>
			<div class="message">
				<a class="message-author" href="#"> <%=item.get("regi_name") %>(<%=item.get("regi_id") %>) </a>
				<a href="#none" onclick="deleteMemo('<%=item.get("memo_seq") %>');" class="message-author"><i class="fa fa-trash-o"></i></a>
				<span class="message-date"> <%=item.get("regi_datm") %> </span>
				<span class="message-content"><%=item.get("memo_text") %></span>
			</div>
<%
		}
	}
%>
		</div>
		<!--메모 리스트 영역 끝-->

	</div>
</body>

</html>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
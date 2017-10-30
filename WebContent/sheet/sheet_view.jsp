<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"sheet","close")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String sheet_code = CommonUtil.getParameter("sheet_code");

		// 파라미터 체크
		if(!CommonUtil.hasText(sheet_code)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>시트 보기</title>
<link href="../css/bootstrap.css" rel="stylesheet">
<link href="../css/font-awesome.css" rel="stylesheet">
<link href="../css/animate.css" rel="stylesheet">
<link href="../css/style.css" rel="stylesheet">

<script type="text/javascript" src="../js/jquery-1.11.0.min.js"></script>
<script type="text/javascript">
$(function () {
	var sheetView = function(sheet_code) {
		$.ajax({
			type: "POST",
			url: "remote_sheet_view.jsp",
			data: "sheet_code="+sheet_code,
			async: false,
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code!="ERR") {
					var html = "";
					if(dataJSON.data.length>0) {
						var cp_idx=0, ca_idx=0, it_idx=0, n=0, odd="";
						for(var i=0;i<dataJSON.data.length;i++) {
							html += "<tr>\n";

							if(cp_idx<1) {
								html += "	<td class=\"t-left\" rowspan=\"" + dataJSON.rs_pcate[dataJSON.data[i].cate_pcode] + "\">" + dataJSON.data[i].cate_pname + "</td>\n";
								cp_idx = parseInt(dataJSON.rs_pcate[dataJSON.data[i].cate_pcode])-1;
							} else {
								cp_idx--;
							}

							if(ca_idx<1) {
								html += "	<td class=\"t-left\" rowspan=\"" + dataJSON.rs_cate[dataJSON.data[i].cate_code] + "\">" + dataJSON.data[i].cate_name + "</td>\n";
								ca_idx = parseInt(dataJSON.rs_cate[dataJSON.data[i].cate_code])-1;
							} else {
								ca_idx--;
							}

							if(it_idx<1) {
								odd = (n%2==1) ? " odd3" : "";
								html += "	<td class=\"t-left" + odd + "\" rowspan=\"" + dataJSON.rs_item[dataJSON.data[i].item_code] + "\">" + dataJSON.data[i].item_name + "</td>\n";
								it_idx = parseInt(dataJSON.rs_item[dataJSON.data[i].item_code])-1;
								n++;
							} else {
								it_idx--;
							}

							html += "	<td class=\"t-left" + odd + "\">" + dataJSON.data[i].exam_name + "</td>\n";
							html += "	<td class=\"t-left" + odd + "\">" + dataJSON.data[i].exam_score + "</td>\n";
							html += "	<td class=\"t-left" + odd + "\">" + dataJSON.data[i].add_score + "</td>\n";
							html += "	<td class=\"t-left" + odd + "\">" + ((dataJSON.data[i].default_yn=="y") ? "<img src=../img/icon/ico_selected.gif>" : "") + "</td>\n";
							html += "</tr>\n";
						}
					} else {
						html = "<tr><td colspan=\"6\">시트 데이터가 없습니다.</td></tr>";
					}
					$("#sheet").html(html);
				}
			},
			error:function(req,status,err){
				return;
			}
		});
	};

	// 닫기 버튼 클릭
	$("button[name=btn_close], button[name=btn_pop_close]").click(function() {
		self.close();
	});

	sheetView("<%=sheet_code%>");
});
</script>
</head>

<body class="white-bg">
<div id="container" style="width: 900px; padding: 2px;">
	<div class="popup-header">
		<button type="button" name="btn_pop_close" class="close"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
		<h4 class="popup-title">시트 보기</h4>
	</div>
	<div class="memo-body tableRadius2" style="padding-top: 20px;">
		<!--table-->
		<table class="table top-line1 table-bordered tt">
			<thead>
				<tr>
					<th colspan="2" style="width:22%;">카테고리</th>
					<th>항목</th>
					<th style="width:30%;">보기</th>
					<th style="width:60px;">배점</th>
					<th style="width:60px;">가중치</th>
					<th style="width:68px;">기본선택</th>
				</tr>
			</thead>
			<tbody id="sheet">
			</tbody>
		</table>
		<!--table 끝-->
	</div>
	<div class="text-center" style="margin: 15px 0;">
		<button type="button" name="btn_close" class="btn btn-default btn-sm"><i class="fa fa-times"></i> 닫기</button>
	</div>
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
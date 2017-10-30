<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	// DB Connection Object
	Db db = null;

	try {
		// DB Connection
		db = new Db(true);

		// get parameter
		int cur_page = CommonUtil.getParameterInt("cur_page", "1");
		int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");

		String log_date1 = CommonUtil.getParameter("log_date1", DateUtil.getToday("yyyy-MM-dd"));
		String log_date2 = CommonUtil.getParameter("log_date2", DateUtil.getToday("yyyy-MM-dd"));
		String mon_system = CommonUtil.getParameter("mon_system");
		String mon_flag = CommonUtil.getParameter("mon_flag");

		cur_page = (cur_page<1) ? 1 : cur_page;

		// paging 변수
		int tot_cnt = 0;
		int page_cnt = 0;
		int start_cnt = 0;
		int end_cnt = 0;

		//
		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("top_cnt", top_cnt);
		argMap.put("log_date1",log_date1.replace("-", ""));
		argMap.put("log_date2",log_date2.replace("-", ""));
		argMap.put("mon_system",mon_system);
		argMap.put("mon_alram",mon_flag);

		// hist count
		Map<String, Object> cntmap  = db.selectOne("dashboard.selectLogCount", argMap);
		tot_cnt = ((Integer)cntmap.get("tot_cnt")).intValue();
		page_cnt = ((Double)cntmap.get("page_cnt")).intValue();

		// paging 변수
		end_cnt = (cur_page*1)*top_cnt;
		start_cnt = end_cnt-(top_cnt-1);

		// search
		argMap.put("tot_cnt", tot_cnt);
		argMap.put("start_cnt", start_cnt);
		argMap.put("end_cnt", end_cnt);

		// hist list
		List<Map<String, Object>> list = db.selectList("dashboard.selectLogList", argMap);

		//
		argMap = new HashMap();

		// 관제서버 목록 조회
		List<Map<String, Object>> svrlist = db.selectList("dashboard.selectMonSystem", argMap);

		// 에러 코드 조회
		List<Map<String, Object>> codelist = db.selectList("dashboard.selectCodeList", argMap);
%>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<title>녹취관제 시스템</title>

	<link href="../css/smoothness/jquery-ui-1.10.4.custom.min.css" rel="stylesheet" />
	<link href="../css/bootstrap.css" rel="stylesheet" />
	<link href="../css/font-awesome.css" rel="stylesheet" />
	<link href="../css/dashboard.css" rel="stylesheet" />

	<script type="text/javascript" src="../js/jquery-1.11.0.min.js"></script>
	<script type="text/javascript" src="../js/jquery.number.min.js"></script>
	<script type="text/javascript" src="../js/jquery.cookie.js"></script>
	<script type="text/javascript" src="../js/jquery.resize.js"></script>
	<script type="text/javascript" src="../js/bootstrap.js"></script>
	<script type="text/javascript" src="../js/jquery-ui-1.10.4.custom.min.js"></script>
	<script type="text/javascript" src="../js/common.js"></script>
	<script type="text/javascript" src="../js/dashboard.js"></script>
	<script type="text/javascript">
		$(function(){
			// 조회 버튼 클릭
			$("button[name=btn_search]").click(function() {
				$("#log_search").submit();
			});

			// 엑셀 버튼 클릭
			$("button[name=btn_excel]").click(function() {
				$("#hiddenFrame").prop("src", "excel_dash_hist.jsp?"+$("#log_search").serialize());
			});

			// input field 셋팅
			$("#log_search").find("select[name=top_cnt]").val("<%=top_cnt%>");
			$("#log_search").find("select[name=mon_system]").val("<%=mon_system%>");
			$("#log_search").find("select[name=mon_flag]").val("<%=mon_flag%>");
		});
	</script>
</head>

<body style="padding: 0 10px; background-color: #FFF; color: #212831;">
<form id="log_search" method="post">
<!--wrapper 시작-->
<div id="wrapper">
	<div class="container">
		<h5><i class="fa fa-volume-up blue" aria-hidden="true"></i> 관제 히스토리</h5>
		<div class="hist_search">
			<div class="label-date pull-left">날짜</div>
			<div class="input-date pull-left">
				<input type="text" name="log_date1" value="<%=log_date1%>" class="form-control datepicker" style="width: 80px;"/> ~
				<input type="text" name="log_date2" value="<%=log_date2%>" class="form-control datepicker" style="width: 80px;"/>
			</div>
			<div class="label-system pull-left">대상</div>
			<div class="input-system pull-left">
				<select name="mon_system" class="form-control">
					<option value="">전체</option>
<%
	if(svrlist.size()>0) {
		for(int i=0;i<svrlist.size();i++) {
			out.print("<option value=\"" + svrlist.get(i).get("mon_system").toString() + "\">" + svrlist.get(i).get("mon_name").toString() + "</option>\n");
		}
	}
%>
				</select>
			</div>
			<div class="label-flag pull-left">에러 유형</div>
			<div class="input-flag pull-left">
				<select name="mon_flag" class="form-control">
					<option value="">전체</option>
<%
	if(codelist.size()>0) {
		for(int i=0;i<codelist.size();i++) {
			out.print("<option value=\"" + codelist.get(i).get("code").toString() + "\">" + codelist.get(i).get("code_descript").toString() + "</option>\n");
		}
	}
%>
				</select>
			</div>
			<div class="pull-left">
				<button type="button" id="btn_search" name="btn_search" class="btn btn-primary btn-sm"><i class="fa fa-search"></i> 조회</button> &nbsp;
				<button type="button" id="btn_excel" name="btn_excel" class="btn btn-success btn-sm"><i class="fa fa-file-excel-o"></i> 엑셀</button>
			</div>
		</div>
		<div class="hist_list">
			<table class="table table-bordered table-error">
				<thead>
					<tr align="center">
						<td style="width: 60px;">번호</td>
						<td style="width: 90px;">날짜</td>
						<td style="width: 80px;">시간</td>
						<td style="width: 100px;">대상</td>
						<td>내용</td>
						<td style="width: 90px;">장애등급</td>
					</tr>
				</thead>
				<tbody>
<%
	if(list.size()>0) {
		for(int i=0;i<list.size();i++) {
			String idx = list.get(i).get("idx").toString();
			String mon_date = list.get(i).get("mon_date").toString();
			String mon_time = list.get(i).get("mon_time").toString();
			String mon_name = list.get(i).get("mon_name").toString();
			String mon_alram = list.get(i).get("mon_alram").toString();
			String flag_desc = list.get(i).get("flag_desc").toString();

			mon_date = mon_date.substring(0, 4) + "-" + mon_date.substring(4, 6) + "-" + mon_date.substring(6, 8);
			mon_time = mon_time.substring(0, 2) + ":" + mon_time.substring(2, 4) + ":" + mon_time.substring(4, 6);
%>
					<tr align="center">
						<td><%=idx%></td>
						<td><%=mon_date%></td>
						<td><%=mon_time%></td>
						<td><%=mon_name%></td>
						<td><%=mon_alram%></td>
						<td><img src="../img/icon_<%=flag_desc%>.jpg"/></td>
					</tr>
<%
		}
	} else {
		out.print("	<tr align=\"center\"><td colspan=\"6\">" + CommonUtil.getErrorMsg("NO_DATA") + "</td></tr>\n");
	}
%>
				</tbody>
			</table>
		</div>
		<div class="hist_foot">
			<!--pagination-->
			<ul id="paging" class="paging list-inline">
				<li><a href="javascript:goDashPage('log_search', 'first', '<%=cur_page%>', '<%=page_cnt%>');" aria-label="First"><img src="../img/button/paging_first<%=((cur_page<=1) ? "_dis" : "")%>.gif" align="absmiddle" /></a></li>
				<li><a href="javascript:goDashPage('log_search', 'prev', '<%=cur_page%>', '<%=page_cnt%>');" aria-label="Prev"><img src="../img/button/paging_prev<%=((cur_page<=1) ? "_dis" : "")%>.gif" align="absmiddle" /></a></li>
				<li><span>Page <input type="text" name="cur_page" value="<%=cur_page%>" onchange="javascript:goDashPage('log_search', 'direct', this.value, '<%=page_cnt%>');" class="form-control" style="width: 35px;" id="" placeholder="" /> of <span id="tot_page"><%=page_cnt%></span></span></li>
				<li><a href="javascript:goDashPage('log_search', 'next', '<%=cur_page%>', '<%=page_cnt%>');" aria-label="Next"><img src="../img/button/paging_next<%=((cur_page>=page_cnt) ? "_dis" : "")%>.gif" align="absmiddle" /></a></li>
				<li><a href="javascript:goDashPage('log_search', 'last', '<%=cur_page%>', '<%=page_cnt%>');" aria-label="Last"><img src="../img/button/paging_last<%=((cur_page>=page_cnt) ? "_dis" : "")%>.gif" align="absmiddle" /></a></li>
			  	<li>
			  		<span>
				  		<select class="form-control" name="top_cnt" onchange="javascript:goDashPage('log_search', 'direct', '1', '1');">
				  			<option value="1">1</option>
				  			<option value="10">10</option>
				  			<option value="20">20</option>
				  			<option value="50">50</option>
				  			<option value="100">100</option>
						</select>
					</span>
			  	</li>
			</ul>
			<!--pagination 끝-->
		</div>
	</div>
</div>
</form>
<iframe id="hiddenFrame" style="display: none;"></iframe>
</body>
</html>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
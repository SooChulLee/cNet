<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	//if(!Site.isPmss(out,"rec_search","close")) return;

	Db db = null;

	try {
		db = new Db(true);

		String rec_datm = CommonUtil.getParameter("rec_datm");
		String local_no = CommonUtil.getParameter("local_no");
		String rec_filename = CommonUtil.getParameter("rec_filename");

		// 파라미터 체크
		if(!CommonUtil.hasText(rec_datm) || !CommonUtil.hasText(local_no) || !CommonUtil.hasText(rec_filename)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}

		// yyyyMMddHHmmss -> yyyy-MM-dd HH:mm:ss
		rec_datm = DateUtil.getDateFormatByIntVal(rec_datm, "yyyy-MM-dd HH:mm:ss");

		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("rec_datm",rec_datm);
		argMap.put("local_no",local_no);
		argMap.put("rec_filename",rec_filename);
		argMap.put("regi_id", _LOGIN_ID);

		List<Map<String, Object>> list = db.selectList("rec_marking.selectList", argMap);

		if(list.size()>0) {
%>
		<div class="tableSize4 p-space">
			<h5 style="margin-top:0;">마킹 이력</h5>
			<table class="table top-line1 table-bordered" row_cnt="<%=list.size()%>">
				<thead>
					<tr>
						<th style="width:38%;">구분</th>
						<th style="width:26%;">시작 시간</th>
						<th style="width:26%;">종료 시간</th>
						<th style="width:10%;">삭제</th>
					</tr>
				</thead>
				<tbody>
<%			for(Map<String, Object> item : list) { %>
					<tr>
						<td><a href="#none" onclick="playMarking('<%=DateUtil.getSecToHms(item.get("mk_stime").toString())%>','<%=DateUtil.getSecToHms(item.get("mk_etime").toString())%>');"><%=item.get("mk_name")%></a></td>
						<td><%=item.get("mk_stime")%></td>
						<td><%=item.get("mk_etime")%></td>
						<td><a href="#none" onclick="deleteMarking('<%=item.get("mk_seq")%>');"><img src="../img/icon/ico_delete.png"/></a></td>
					</tr>
<%			} %>
				</tbody>
			</table>
		</div>
<%
		}
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
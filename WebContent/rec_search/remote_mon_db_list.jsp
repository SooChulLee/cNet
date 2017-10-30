<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
// 메뉴 접근권한 체크
if(!Site.isPmss(out,"mon_db_list","")) return;

Db db = null;

try {
	// DB Connection
	db = new Db();

	// get parameter
	String bpart_code = CommonUtil.getParameter("bpart_code");
	String mpart_code = CommonUtil.getParameter("mpart_code");
	String spart_code = CommonUtil.getParameter("spart_code");
	String s_local_no = CommonUtil.getParameter("local_no");

	// 파라미터 체크
	if(!CommonUtil.hasText(bpart_code)) {
		//out.print(CommonUtil.getErrorMsg("NO_PARAM"));
		return;
	}

	Map<String, Object> argMap = new HashMap<String, Object>();

	argMap.put("bpart_code",bpart_code);
	argMap.put("mpart_code",mpart_code);
	argMap.put("spart_code",spart_code);
	argMap.put("local_no",s_local_no);

	// 사용자 권한에 따른 녹취이력 조회
	argMap.put("_user_id", _LOGIN_ID);
	argMap.put("_user_level", _LOGIN_LEVEL);
	argMap.put("_bpart_code",_BPART_CODE);
	argMap.put("_mpart_code",_MPART_CODE);
	argMap.put("_spart_code",_SPART_CODE);

	List<Map<String, Object>> list = db.selectList("mon_db.selectList", argMap);

	if(list.size()<1) {
		out.print(CommonUtil.getErrorMsg("NO_DATA"));
		return;
	}

	//20170908 현원희 수정
	//카운트 조회 쿼리 추가
	List<Map<String, Object>> list2 = db.selectList("mon_db.selectCountList", argMap);

	%>
	<div class="grey_back1">
		<div class="colLeft"><span class="ext_text"><font size="4"><b><%=list2.get(0).get("time").toString()%></b></font></span></div>
		<div class="colLeft">&nbsp;&nbsp;&nbsp;</div>
		<div class="colLeft"><span class="ext_text"><font size="4">당일 녹취 건수 : <b><%=list2.get(0).get("rec_count").toString()%>건</b></font></span></div>
		<div class="colLeft">&nbsp;&nbsp;&nbsp;</div>
		<div class="colLeft"><span class="ext_text"><font size="4">현재 녹취 중 : <b><%=list2.get(0).get("mon_count").toString()%>건</b><font></span></div>
	</div>

	<!--내선번호 영역 시작-->
	<div class="grey_back1">
	<%
	for(Map<String, Object> item : list) {
		String ch_no = item.get("channel").toString();
		String ch_status = item.get("state").toString();
		String user_name = item.get("user_name").toString();
		String local_no = item.get("phone").toString();
		String system_ip = item.get("system_ip").toString();
		String backup_ip = item.get("backup_ip").toString();
		String call_time = ("1".equals(ch_status)) ? item.get("call_time").toString() : "&nbsp;";

		// 상태별 색상 설정
		String status_cls = "";
		if("0".equals(ch_status)) {				// 대기
			status_cls = "1";
		} else if("1".equals(ch_status)) {		// 녹취 상태
			status_cls = "2";
		} else {								// 녹취 불량
			status_cls = "3";
		}

		out.print("<div class=\"ext_frame\">\n");
		out.print("	<div class=\"ext_number ext_bg0" + status_cls + "\" style=\"cursor: pointer;\" onclick=\"playRlisten('" + ch_status + "','" + ch_no + "','" + local_no + "','" + system_ip + "/" + backup_ip + "')\">" + ch_no + "</div>\n");
		out.print("	<div class=\"ext_name\">\n");
		out.print("		<span>" + user_name + "</span>\n");
		out.print("		<span style=\"font-size:12px;color:#666;\">" + local_no + "</span>\n");
		out.print("		<span style=\"color:#00679d;\">" + call_time + "</span>\n");
		out.print("	</div>\n");
		out.print("</div>\n");
	}
	%>
	</div>
	<!--내선번호 영역 끝-->

	<div class="grey_back2">
		<div class="colLeft"><span class="ext_squre01 colLeft"></span><span class="ext_text">대기상태</span></div>
		<div class="colLeft"><span class="ext_squre02 colLeft"></span><span class="ext_text">녹취상태</span></div>
		<div class="colLeft"><span class="ext_squre03 colLeft"></span><span class="ext_text">녹취불량</span></div>
	</div>
<%

} catch(Exception e) {
	logger.error(e.getMessage());
} finally {
	if(db!=null) db.close();
}
%>
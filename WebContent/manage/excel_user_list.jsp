<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"user_mgmt","")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "상담사");

	db = new Db(true);

	// get parameter
	String part_code = CommonUtil.getParameter("part_code");
	String user_id = CommonUtil.getParameter("user_id", "");
	String user_name = CommonUtil.getParameter("user_name", "");
	String local_no = CommonUtil.getParameter("local_no", "");
	String sort_idx = CommonUtil.getParameter("sort_idx", "regi_datm");
	String sort_dir = CommonUtil.getParameter("sort_dir", "down");

	sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

	// part_code
	String business_code = "";
	String bpart_code = "";
	String mpart_code = "";
	String spart_code = "";

	if(CommonUtil.hasText(part_code)) {
		business_code = CommonUtil.leftString(part_code, 2);
		//bpart_code = part_code.substring(2, 7);
		//mpart_code = part_code.substring(7, 12);
		//spart_code = part_code.substring(12, 17);
		bpart_code = part_code.substring(2, 2+(_PART_CODE_SIZE*1));
		mpart_code = part_code.substring(2+(_PART_CODE_SIZE*1), 2+(_PART_CODE_SIZE*2));
		spart_code = part_code.substring(2+(_PART_CODE_SIZE*2), 2+(_PART_CODE_SIZE*3));
	}

	StringBuffer sb = new StringBuffer();


	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>상담원ID</td>");
	sb.append("<td class=th>상담사명</td>");
	sb.append("<td class=th>내선번호</td>");
	sb.append("<td class=th>채널번호</td>");
	sb.append("<td class=th>등급</td>");
	/* sb.append("<td class=th>비밀번호 사용기간</td>");
	sb.append("<td class=th>비밀번호 만료일자</td>"); */
	sb.append("<td class=th>비밀번호 변경일자</td>");
	sb.append("<td class=th>아이피</td>");
	sb.append("<td class=th>퇴사여부</td>");
	sb.append("<td class=th>사용여부</td>");
	sb.append("<td class=th>등록일자</td>");
	sb.append("</tr>");

	Map<String, Object> argMap = new HashMap<String, Object>();

	argMap.put("business_code", business_code);
	argMap.put("bpart_code", bpart_code);
	argMap.put("mpart_code", mpart_code);
	argMap.put("spart_code", spart_code);
	argMap.put("user_id", user_id);
	argMap.put("user_name", user_name);
	argMap.put("local_no", local_no);
	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);

	List<Map<String, Object>> list = db.selectList("user.selectListAll", argMap);

	// 2016.12.27 현원희 추가 -다운로드 이력
	//=========================================================================
	Map<String, Object> selmap2 = new HashMap();

	selmap2.put("excel_id", _LOGIN_ID);
	selmap2.put("excel_menu", "상담사");
	selmap2.put("excel_name", _LOGIN_NAME);
	selmap2.put("excel_ip",request.getRemoteAddr());

	int ins_cnt = db.insert("hist_excel.insertExcelHist", selmap2);
	//=========================================================================

	if(list.size()>0) {
		for(Map<String, Object> item : list) {
			sb.append("<tr>");
			sb.append("<td>" + item.get("user_id") + "</td>");
			sb.append("<td>" + item.get("user_name") + "</td>");
			sb.append("<td>" + item.get("local_no") + "</td>");
			sb.append("<td>" + item.get("channel_no") + "</td>");
			sb.append("<td>" + item.get("user_level_desc") + "</td>");
			/* sb.append("<td>" + item.get("pass_chg_term_desc") + "</td>");
			sb.append("<td>" + item.get("pass_expire_date") + "</td>");	 */
			sb.append("<td>" + item.get("pass_upd_date") + "</td>");
			sb.append("<td>" + item.get("user_ip") + "</td>");
			sb.append("<td>" + item.get("resign_yn_desc") + "</td>");
			sb.append("<td>" + Finals.getValue(Finals.hUsedCode,item.get("use_yn")) + "</td>");
			sb.append("<td>" + item.get("regi_datm") + "</td>");
			sb.append("</tr>");
		}
	}

	sb.append("</table>");
	out.print(sb.toString());
} catch(Exception e) {
	logger.error(e.getMessage());
} finally {
	if(db!=null) db.close();
}
%>
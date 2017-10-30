<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"eval_result","")) return;

	Db db = null;

	try {
		db = new Db(true);

		Site.setExcelHeader(response, out, "상담원별통계-평가점수");

		int userViewDepth = Site.getDepthByUserLevel(_LOGIN_LEVEL);

		// get parameter
		String sort_idx = CommonUtil.getParameter("sort_idx", "result_seq");
		String sort_dir = CommonUtil.getParameter("sort_dir", "down");

		String eval_date1	= CommonUtil.getParameter("eval_date1");
		String eval_date2	= CommonUtil.getParameter("eval_date2");
		String event_code	= CommonUtil.getParameter("event_code");
		String eval_user_id	= CommonUtil.getParameter("eval_user_id");
		String bpart_code	= CommonUtil.getParameter("bpart_code");
		String mpart_code	= CommonUtil.getParameter("mpart_code");
		String spart_code	= CommonUtil.getParameter("spart_code");
		String user_id		= CommonUtil.getParameter("user_id");
		String user_name	= CommonUtil.getParameter("user_name");
		String eval_status	= CommonUtil.getParameter("eval_status");

		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		StringBuffer sb = new StringBuffer();

		sb.append("<table border='1' bordercolor='#bbbbbb'>");
		sb.append("<tr align='center'>");
		sb.append("<td class=th>이벤트명</td>");
		if(userViewDepth>-1) sb.append("<td class=th>평가자명</td>");
		sb.append("<td class=th>소분류</td>");
		sb.append("<td class=th>상담원명</td>");
		sb.append("<td class=th>평가일자</td>");
		sb.append("<td class=th>녹취일시</td>");
		sb.append("<td class=th>점수/배점</td>");
		sb.append("<td class=th>평가상태</td>");
		sb.append("</tr>");

		// search
		Map<String, Object> argMap = new HashMap<String, Object>();
		//System.out.println("eval_user_id="+eval_user_id);
		//System.out.println("_LOGIN_ID"+_LOGIN_ID);
		argMap.put("eval_date1", eval_date1);
		argMap.put("eval_date2", eval_date2);
		argMap.put("event_code", event_code);
		argMap.put("eval_user_id", eval_user_id);
		argMap.put("bpart_code", bpart_code);
		argMap.put("mpart_code", mpart_code);
		argMap.put("spart_code", spart_code);
		argMap.put("user_name", user_name);
		argMap.put("user_id", user_id);
		argMap.put("eval_status", eval_status);
		argMap.put("_eval_user_id", _LOGIN_ID);
		argMap.put("_user_level", _LOGIN_LEVEL);
		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);

		List<Map<String, Object>> list = db.selectList("eval_result.selectListAll", argMap);

		if(list.size()>0) {
			for(Map<String, Object> item : list) {
				sb.append("<tr>");
				sb.append("<td>" + item.get("event_name") + "</td>");
				if(userViewDepth>-1) sb.append("<td>" + item.get("eval_user_name") + "</td>");
				sb.append("<td>" + item.get("spart_name") + "</td>");
				sb.append("<td>" + item.get("user_name") + "</td>");
				sb.append("<td>" + item.get("eval_date") + "</td>");
				sb.append("<td class=c>&nbsp;" + item.get("rec_date") + "&nbsp;</td>");
				sb.append("<td class=r>" + item.get("eval_score") + " / " + item.get("tot_score") + "</td>");
				sb.append("<td class=c>" + Finals.getValue(Finals.hEvalStatusHtml,item.get("eval_status")) + "</td>");
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
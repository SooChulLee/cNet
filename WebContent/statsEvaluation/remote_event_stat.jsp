<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"event_stat","json")) return;
	Db db = null;

	try {
		// DB Connection
		db = new Db(true);

		String showType = CommonUtil.getParameter("showType","garo");
		String sort_idx = CommonUtil.getParameter("sort_idx", "event_code");
		String sort_dir = CommonUtil.getParameter("sort_dir", "down");
		String sort_idx2 = CommonUtil.getParameter("sort_idx2", "eval_order");
		String sort_dir2 = CommonUtil.getParameter("sort_dir2", "up");
		String eval_date1 = CommonUtil.getParameter("eval_date1");
		String eval_date2 = CommonUtil.getParameter("eval_date2");
		String event_code = CommonUtil.getParameter("event_code");
		String sheet_code = CommonUtil.getParameter("sheet_code");
		int eval_order_max = ComLib.getPI(request, "eval_order_max");

		sort_dir  = ("down".equals(sort_dir)) ? "desc" : "asc";
		sort_dir2 = ("down".equals(sort_dir2)) ? "desc" : "asc";

		//
		JSONObject json = new JSONObject();

		// search
		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("eval_date1",eval_date1.replace("-", ""));
		argMap.put("eval_date2",eval_date2.replace("-", ""));
		argMap.put("event_code",event_code);
		argMap.put("sheet_code",sheet_code);
		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);
		argMap.put("sort_idx2", sort_idx2);
		argMap.put("sort_dir2", sort_dir2);
		argMap.put("eval_order_max", eval_order_max);

		// record select
		showType = (showType.equals("garo")) ? "stat_event.selectListAllOrder" : "stat_event.selectList";
		List<Map<String, Object>> list = db.selectList(showType, argMap);

		json.put("totalRecords", list.size());

		//
		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"dept_stat","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String groupDepth	= CommonUtil.getParameter("groupDepth","1");
		String showType		= CommonUtil.getParameter("showType","garo");
		String sort_idx		= CommonUtil.getParameter("sort_idx", "bpart_name");
		String sort_dir		= CommonUtil.getParameter("sort_dir", "up");
		String eval_date1	= CommonUtil.getParameter("eval_date1");
		String eval_date2	= CommonUtil.getParameter("eval_date2");
		String event_code	= CommonUtil.getParameter("event_code");
		String sheet_code	= CommonUtil.getParameter("sheet_code");
		String bpart_code	= CommonUtil.getParameter("bpart_code");
		String mpart_code	= CommonUtil.getParameter("mpart_code");
		String spart_code	= CommonUtil.getParameter("spart_code");
		String eval_user_name = CommonUtil.getParameter("eval_user_name");
		int eval_order_max = ComLib.getPI(request, "eval_order_max");

		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		JSONObject json = new JSONObject();

		// search
		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("eval_date1",eval_date1.replace("-", ""));
		argMap.put("eval_date2",eval_date2.replace("-", ""));
		argMap.put("event_code",event_code);
		argMap.put("sheet_code",sheet_code);
		argMap.put("bpart_code",bpart_code);
		argMap.put("mpart_code",mpart_code);
		argMap.put("spart_code",spart_code);
		argMap.put("eval_user_name",eval_user_name);
		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);
		argMap.put("eval_order_max", eval_order_max);

		String dbXmlName = (groupDepth.equals("1")) ?
				(showType.equals("garo")) ? "stat_dept.selectListAllOrder1" : "stat_dept.selectList1" : //소분류별
				(showType.equals("garo")) ? "stat_dept.selectListAllOrder2" : "stat_dept.selectList2" ; //중분류별

		List<Map<String, Object>> list = db.selectList(dbXmlName, argMap);

		json.put("totalRecords", list.size());

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
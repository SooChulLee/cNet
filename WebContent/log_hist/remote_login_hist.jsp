<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"login_hist","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		int cur_page = CommonUtil.getParameterInt("cur_page", "1");
		int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");
		String sort_idx = CommonUtil.getParameter("sort_idx", "login_datm");
		String sort_dir = CommonUtil.getParameter("sort_dir", "down");

		String login_date1 = CommonUtil.getParameter("login_date1");
		String login_date2 = CommonUtil.getParameter("login_date2");
		String login_id = CommonUtil.getParameter("login_id");
		String login_name = CommonUtil.getParameter("login_name");
		String login_type = CommonUtil.getParameter("login_type");
		String login_result = CommonUtil.getParameter("login_result");

		cur_page = (cur_page<1) ? 1 : cur_page;
		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		// paging 변수
		int tot_cnt = 0;
		int page_cnt = 0;
		int start_cnt = 0;
		int end_cnt = 0;

		JSONObject json = new JSONObject();

		// search
		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("top_cnt", top_cnt);
		argMap.put("login_date1",login_date1);
		argMap.put("login_date2",login_date2);
		argMap.put("login_id",login_id);
		argMap.put("login_name",login_name);
		argMap.put("login_type",login_type);
		argMap.put("login_result",login_result);

		// hist count
		Map<String, Object> cntmap  = db.selectOne("hist_login.selectCount", argMap);
		tot_cnt = ((Integer)cntmap.get("tot_cnt")).intValue();
		page_cnt = ((Double)cntmap.get("page_cnt")).intValue();

		json.put("totalRecords", tot_cnt);
		json.put("totalPages", page_cnt);
		json.put("curPage", cur_page);

		// paging 변수
		end_cnt = (cur_page*1)*top_cnt;
		start_cnt = end_cnt-(top_cnt-1);

		// search
		argMap.put("tot_cnt", tot_cnt);
		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);
		argMap.put("start_cnt", start_cnt);
		argMap.put("end_cnt", end_cnt);

		List<Map<String, Object>> list = db.selectList("hist_login.selectList", argMap);

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
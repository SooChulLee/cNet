<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"down_hist","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		int cur_page = CommonUtil.getParameterInt("cur_page", "1");
		int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");
		String sort_idx = CommonUtil.getParameter("sort_idx", "down_datm");
		String sort_dir = CommonUtil.getParameter("sort_dir", "down");

		String down_date1 = CommonUtil.getParameter("down_date1");
		String down_date2 = CommonUtil.getParameter("down_date2");
		String login_id = CommonUtil.getParameter("login_id");
		String login_name = CommonUtil.getParameter("login_name");
		String rec_date1 = CommonUtil.getParameter("rec_date1","");
		String rec_date2 = CommonUtil.getParameter("rec_date2","");
		String user_id = CommonUtil.getParameter("user_id");
		String user_name = CommonUtil.getParameter("user_name");
		String reason_code = CommonUtil.getParameter("reason_code");
		String down_src = CommonUtil.getParameter("down_src");

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
		argMap.put("down_date1",down_date1);
		argMap.put("down_date2",down_date2);
		argMap.put("down_id",login_id);
		argMap.put("down_name",login_name);
		argMap.put("rec_date1",rec_date1);
		argMap.put("rec_date2",rec_date2);
		argMap.put("user_id",user_id);
		argMap.put("user_name",user_name);
		argMap.put("reason_code",reason_code);
		argMap.put("down_src",down_src);

		// hist count
		Map<String, Object> cntmap  = db.selectOne("hist_down.selectCount", argMap);
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

		List<Map<String, Object>> list = db.selectList("hist_down.selectList", argMap);

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
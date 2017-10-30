<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"abort_hist","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		int cur_page = CommonUtil.getParameterInt("cur_page", "1");
		int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");
		String sort_idx = CommonUtil.getParameter("sort_idx", "abort_datm");
		String sort_dir = CommonUtil.getParameter("sort_dir", "down");

		String abort_date1 = CommonUtil.getParameter("abort_date1");
		String abort_date2 = CommonUtil.getParameter("abort_date2");
		String abort_id = CommonUtil.getParameter("abort_id");
		String abort_name = CommonUtil.getParameter("abort_name");
		String start_rec_date = CommonUtil.getParameter("rec_date1","");
		String end_rec_date = CommonUtil.getParameter("rec_date2","");

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
		argMap.put("abort_date1",abort_date1);
		argMap.put("abort_date2",abort_date2);
		argMap.put("abort_id",abort_id);
		argMap.put("abort_name",abort_name);
		argMap.put("start_rec_date",start_rec_date);
		argMap.put("end_rec_date",end_rec_date);


		// hist count
		Map<String, Object> cntmap  = db.selectOne("hist_abort.selectCount", argMap);
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

		List<Map<String, Object>> list = db.selectList("hist_abort.selectList", argMap);

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
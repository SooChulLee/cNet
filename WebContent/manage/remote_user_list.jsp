<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_mgmt","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String part_code = CommonUtil.getParameter("part_code");
		String user_id = CommonUtil.getParameter("user_id", "");
		String user_name = CommonUtil.getParameter("user_name", "");
		String local_no = CommonUtil.getParameter("local_no", "");

		int cur_page = CommonUtil.getParameterInt("cur_page", "1");
		int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");
		String sort_idx = CommonUtil.getParameter("sort_idx", "regi_datm");
		String sort_dir = CommonUtil.getParameter("sort_dir", "down");

		cur_page = (cur_page<1) ? 1 : cur_page;
		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		// paging 변수
		int tot_cnt = 0;
		int page_cnt = 0;
		int start_cnt = 0;
		int end_cnt = 0;

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

		JSONObject json = new JSONObject();

		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("top_cnt", top_cnt);
		argMap.put("business_code", business_code);
		argMap.put("bpart_code", bpart_code);
		argMap.put("mpart_code", mpart_code);
		argMap.put("spart_code", spart_code);
		argMap.put("user_id", user_id);
		argMap.put("user_name", user_name);
		argMap.put("local_no", local_no);

		// count
		Map<String, Object> cntmap  = db.selectOne("user.selectCount", argMap);
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

		List<Map<String, Object>> list = db.selectList("user.selectList", argMap);

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
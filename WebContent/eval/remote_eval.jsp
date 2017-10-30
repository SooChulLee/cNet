<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"eval","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step", "event");
		String event_code = CommonUtil.getParameter("event_code", "");
		String eval_order = CommonUtil.getParameter("eval_order", "");
		String eval_user_id = CommonUtil.getParameter("eval_user_id", "");
		String user_name = CommonUtil.getParameter("user_name", "");

		String rec_date1 = CommonUtil.getParameter("rec_date1");
		String rec_date2 = CommonUtil.getParameter("rec_date2");

		String rec_start_hour1 = CommonUtil.getParameter("rec_start_hour1");
		String rec_start_min1 = CommonUtil.getParameter("rec_start_min1");
		String rec_start_hour2 = CommonUtil.getParameter("rec_start_hour2");
		String rec_start_min2 = CommonUtil.getParameter("rec_start_min2");

		String rec_call_time1 = CommonUtil.getParameter("rec_call_time1");
		String rec_call_time2 = CommonUtil.getParameter("rec_call_time2");
		String user_id = CommonUtil.getParameter("user_id");
		String cust_name = CommonUtil.getParameter("cust_name");
		String sortMethod = CommonUtil.getParameter("sortMethod");
		
		JSONObject json = new JSONObject();

		Map<String, Object> argMap = new HashMap<String, Object>();
		List<Map<String, Object>> list = null;

		if("agent".equals(step)) {
			//평가대상자 조회 (평가자에 배정된 상담원 조회)

			if(!CommonUtil.hasText(event_code) || !CommonUtil.hasText(eval_user_id)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// 해당 평가자에 배정된 상담원 조회
			argMap.put("event_code", event_code);
			argMap.put("eval_order", eval_order);
			argMap.put("eval_user_id", eval_user_id);
			argMap.put("user_name", user_name);
			argMap.put("_eval_user_id", _LOGIN_ID);
			argMap.put("_user_level", _LOGIN_LEVEL);
			list = db.selectList("eval_target.selectAssignList", argMap);
		}
		else if("record".equals(step)) {
			//상담이력 조회

			int cur_page = CommonUtil.getParameterInt("cur_page", "1");
			int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");

			if(!CommonUtil.hasText(user_id)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			cur_page = (cur_page<1) ? 1 : cur_page;

			// paging 변수
			int tot_cnt = 0;
			int page_cnt = 0;
			int start_cnt = 0;
			int end_cnt = 0;

			argMap.put("top_cnt", top_cnt);
			argMap.put("rec_date1",rec_date1);
			argMap.put("rec_date2",rec_date2);
			argMap.put("rec_start_time1",rec_start_hour1+":"+rec_start_min1+":00");
			argMap.put("rec_start_time2",rec_start_hour2+":"+rec_start_min2+":59.999");
			argMap.put("rec_call_time1",DateUtil.getHmsToSec(Integer.parseInt(rec_call_time1)));
			argMap.put("rec_call_time2",DateUtil.getHmsToSec(Integer.parseInt(rec_call_time2)));
			argMap.put("user_id", user_id);
			argMap.put("cust_name", cust_name);

			argMap.put("event_code", event_code);
			argMap.put("_eval_user_id", _LOGIN_ID);

			// hist count
			Map<String, Object> cntmap  = db.selectOne("eval_rec_search.selectCount", argMap);
			tot_cnt = ((Integer)cntmap.get("tot_cnt")).intValue();
			page_cnt = ((Double)cntmap.get("page_cnt")).intValue();

			json.put("totalRecords", tot_cnt);
			json.put("totalPages", page_cnt);
			json.put("curPage", cur_page);

			// paging 변수
			end_cnt = (cur_page*1)*top_cnt;
			start_cnt = end_cnt-(top_cnt-1);

			// search
			argMap.put("sortMethod", sortMethod);
			argMap.put("tot_cnt", tot_cnt);
			argMap.put("start_cnt", start_cnt);
			argMap.put("end_cnt", end_cnt);

			list = db.selectList("eval_rec_search.selectList", argMap);
		} else {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		Site.writeJsonResult(out,e);
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
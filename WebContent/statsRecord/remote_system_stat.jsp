<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"system_stat","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String sort_idx = CommonUtil.getParameter("sort_idx", "system_name,rec_date");
		String sort_dir = CommonUtil.getParameter("sort_dir", "up,down");
		String rec_date1 = CommonUtil.getParameter("rec_date1");
		String rec_date2 = CommonUtil.getParameter("rec_date2");
		String rec_hour1 = CommonUtil.getParameter("rec_hour1");
		String rec_hour2 = CommonUtil.getParameter("rec_hour2");
		String system_code = CommonUtil.getParameter("system_code");
		String date_type = CommonUtil.getParameter("date_type", "DD");

		//sort_idx = ("v_rec_date".equals(sort_idx)) ? "rec_date" : sort_idx;
		//sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		logger.debug("sort_idx="+sort_idx);
		JSONObject json = new JSONObject();

		// search
		Map<String, Object> argMap = new HashMap<String, Object>();
		Map<String, Object> ordmap = new LinkedHashMap();
		Map<String, Object> parmap = new HashMap();

		argMap.put("rec_date1",rec_date1.replace("-", ""));
		argMap.put("rec_date2",rec_date2.replace("-", ""));
		argMap.put("rec_hour1",rec_hour1);
		argMap.put("rec_hour2",rec_hour2);
		argMap.put("system_code",system_code);
		argMap.put("date_type",date_type);
		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);

		// order map
		String ordarr[] = sort_idx.split(",");
		String dirarr[] = sort_dir.split(",");

		if(ordarr.length>0) {
			for(int i=0;i<ordarr.length;i++) {
				ordmap.put(("v_rec_date".equals(ordarr[i])) ? "rec_date" : ordarr[i], ("down".equals(dirarr[i])) ? "desc" : "asc");
			}
		}

		parmap.put("s", argMap);
		parmap.put("o", ordmap);

		List<Map<String, Object>> list = db.selectList("stat_system.selectList", parmap);
		int sum_tot_cnt = 0;
		int sum_tot_call_time = 0;
		int sum_in_cnt = 0;
		int sum_out_cnt = 0;
		int sum_local_cnt = 0;
		for(Map<String, Object> item : list) {
			/* grid에서 처리
			// 총계 저장
			sum_tot_cnt += ((Integer) item.get("tot_cnt")).intValue();
			sum_tot_call_time += ((Integer) item.get("tot_call_time")).intValue();
			sum_in_cnt += ((Integer) item.get("in_cnt")).intValue();
			sum_out_cnt += ((Integer) item.get("out_cnt")).intValue();
			sum_local_cnt += ((Integer) item.get("local_cnt")).intValue();
			*/

			if(item.containsKey("tot_call_time")) {		// 초 -> HH:mm:ss
				item.put("tot_call_sec", item.get("tot_call_time"));
				item.put("tot_call_time", DateUtil.getHmsToSec((Integer) item.get("tot_call_time")));
			}
		}

		json.put("totalRecords", list.size());

		/*if(list.size()>0) {
			Map<String, Object> summap = new HashMap();

			summap.put("system_name", "총계");
			summap.put("rec_date", "");
			summap.put("tot_cnt", sum_tot_cnt);
			summap.put("tot_call_time", DateUtil.getHmsToSec(sum_tot_call_time));
			summap.put("in_cnt", sum_in_cnt);
			summap.put("out_cnt", sum_out_cnt);
			summap.put("local_cnt", sum_local_cnt);
			list.add(summap);
		}*/

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
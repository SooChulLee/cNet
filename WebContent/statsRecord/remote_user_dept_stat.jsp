<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_dept_stat","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String sort_idx = CommonUtil.getParameter("sort_idx", "user_name,rec_date");
		String sort_dir = CommonUtil.getParameter("sort_dir", "up,down");
		String rec_date1 = CommonUtil.getParameter("rec_date1");
		String rec_date2 = CommonUtil.getParameter("rec_date2");
		String rec_hour1 = CommonUtil.getParameter("rec_hour1");
		String rec_hour2 = CommonUtil.getParameter("rec_hour2");
		String stat_type = CommonUtil.getParameter("stat_type", "U");
		String date_type = CommonUtil.getParameter("date_type", "DD");
		String bpart_code = CommonUtil.getParameter("bpart_code");
		String mpart_code = CommonUtil.getParameter("mpart_code");
		String spart_code = CommonUtil.getParameter("spart_code");
		String user_name = CommonUtil.getParameter("user_name");

		//sort_idx = ("v_rec_date".equals(sort_idx)) ? "rec_date" : sort_idx;
		//sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		JSONObject json = new JSONObject();

		// search
		Map<String, Object> argMap = new HashMap<String, Object>();
		Map<String, Object> ordmap = new LinkedHashMap();
		Map<String, Object> parmap = new HashMap();

		argMap.put("rec_date1",rec_date1.replace("-", ""));
		argMap.put("rec_date2",rec_date2.replace("-", ""));
		argMap.put("rec_hour1",rec_hour1);
		argMap.put("rec_hour2",rec_hour2);
		argMap.put("stat_type",stat_type);
		argMap.put("date_type",date_type);
		argMap.put("bpart_code",bpart_code);
		argMap.put("mpart_code",mpart_code);
		argMap.put("spart_code",spart_code);
		argMap.put("user_name",user_name);
		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);
		argMap.put("_part_code_size",_PART_CODE_SIZE);

		// 사용자 권한에 따른 녹취이력 조회
		argMap.put("_user_id", _LOGIN_ID);
		argMap.put("_user_level", _LOGIN_LEVEL);
		argMap.put("_bpart_code",_BPART_CODE);
		argMap.put("_mpart_code",_MPART_CODE);
		argMap.put("_spart_code",_SPART_CODE);

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

		List<Map<String, Object>> list = db.selectList("stat_user_dept.selectList", parmap);
		int sum_tot_cnt = 0;
		int sum_tot_call_time = 0;
		int sum_avg_call_time = 0;
		int sum_in_cnt = 0;
		int sum_out_cnt = 0;
		int sum_local_cnt = 0;
		int sum_one_under_cnt = 0;
		int sum_one_five_cnt = 0;
		int sum_five_ten_cnt = 0;
		int sum_ten_over_cnt = 0;

		for(Map<String, Object> item : list) {
			// 총계 저장
			sum_tot_cnt += ((Integer) item.get("tot_cnt")).intValue();
			sum_tot_call_time += ((Integer) item.get("tot_call_time")).intValue();
			sum_avg_call_time += ((Integer) item.get("avg_call_time")).intValue();
			sum_in_cnt += ((Integer) item.get("in_cnt")).intValue();
			sum_out_cnt += ((Integer) item.get("out_cnt")).intValue();
			sum_local_cnt += ((Integer) item.get("local_cnt")).intValue();
			sum_one_under_cnt += ((Integer) item.get("one_under_cnt")).intValue();
			sum_one_five_cnt += ((Integer) item.get("one_five_cnt")).intValue();
			sum_five_ten_cnt += ((Integer) item.get("five_ten_cnt")).intValue();
			sum_ten_over_cnt += ((Integer) item.get("ten_over_cnt")).intValue();

			if(item.containsKey("tot_call_time")) {		// 초 -> HH:mm:ss
				item.put("tot_call_sec", item.get("tot_call_time"));
				item.put("tot_call_time", DateUtil.getHmsToSec((Integer) item.get("tot_call_time")));
			}
			if(item.containsKey("avg_call_time")) {		// 초 -> HH:mm:ss
				item.put("avg_call_sec", item.get("avg_call_time"));
				item.put("avg_call_time", DateUtil.getHmsToSec((Integer) item.get("avg_call_time")));
			}
		}

		json.put("totalRecords", list.size());

		/*if(list.size()>0) {
			Map<String, Object> summap = new HashMap();

			summap.put("user_name", "총계");
			summap.put("rec_date", "");
			summap.put("tot_cnt", sum_tot_cnt);
			summap.put("tot_call_time", DateUtil.getHmsToSec(sum_tot_call_time));
			summap.put("avg_call_time", DateUtil.getHmsToSec(sum_avg_call_time));
			summap.put("in_cnt", sum_in_cnt);
			summap.put("out_cnt", sum_out_cnt);
			summap.put("local_cnt", sum_local_cnt);
			summap.put("one_under_cnt", sum_one_under_cnt);
			summap.put("one_five_cnt", sum_one_five_cnt);
			summap.put("five_ten_cnt", sum_five_ten_cnt);
			summap.put("ten_over_cnt", sum_ten_over_cnt);

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
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"rec_search","")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "녹취이력");

	db = new Db(true);

	// get parameter
	int cur_page = CommonUtil.getParameterInt("cur_page", "1");
	int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");
	String sort_idx = CommonUtil.getParameter("sort_idx", "rec_datm");
	String sort_dir = CommonUtil.getParameter("sort_dir", "down");

	String rec_date1 = CommonUtil.getParameter("rec_date1");
	String rec_date2 = CommonUtil.getParameter("rec_date2");
	String rec_start_hour1 = CommonUtil.getParameter("rec_start_hour1");
	String rec_start_hour2 = CommonUtil.getParameter("rec_start_hour2");
	String rec_call_time1 = CommonUtil.getParameter("rec_call_time1");
	String rec_call_time2 = CommonUtil.getParameter("rec_call_time2");
	String bpart_code = CommonUtil.getParameter("bpart_code");
	String mpart_code = CommonUtil.getParameter("mpart_code");
	String spart_code = CommonUtil.getParameter("spart_code");
	String system_code = CommonUtil.getParameter("system_code");
	String local_no1 = CommonUtil.getParameter("local_no1");
	String local_no2 = CommonUtil.getParameter("local_no2");
	String rec_inout = CommonUtil.getParameter("rec_inout");
	String user_id = CommonUtil.getParameter("user_id");
	String user_name = CommonUtil.getParameter("user_name");
	String cust_id = CommonUtil.getParameter("cust_id");
	String cust_name = CommonUtil.getParameter("cust_name");
	String cust_tel = CommonUtil.getParameter("cust_tel");
	String rec_keycode = CommonUtil.getParameter("rec_keycode");
	// tree에서 선택된 user id list
	String user_list = CommonUtil.getParameter("user_list");

	cur_page = (cur_page<1) ? 1 : cur_page;
	sort_idx = "v_".equals(CommonUtil.leftString(sort_idx, 2)) ? sort_idx.substring(2) : sort_idx;
	sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

	// user id list parsing
	if(CommonUtil.hasText(user_list)) {
		String user_ids[] = user_list.split(",");
		String tmp_user_list = "";
		for(int i=0;i<user_ids.length;i++) {
			tmp_user_list += ",'" + user_ids[i] + "'";
		}
		user_list = tmp_user_list.substring(1);
	}

	// paging 변수
	int tot_cnt = 0;
	int page_cnt = 0;
	int start_cnt = 0;
	int end_cnt = 0;

	Map<String, Object> confmap = new HashMap();
	Map<String, Object> resmap = new LinkedHashMap();
	Map<String, Object> argMap = new HashMap<String, Object>();
	Map<String, Object> parmap = new HashMap();

	// 엑셀 결과에 표시될 데이터 key 배열
	List<String> resarr = new ArrayList<String>();

	// config (session value mapping)
	confmap.put("business_code", _BUSINESS_CODE);
	confmap.put("user_id", _LOGIN_ID);
	confmap.put("user_level", _LOGIN_LEVEL);
	confmap.put("default_used", "1");

	// config select
	List<Map<String, Object>> conf_list = db.selectList("rec_search.selectResultConfig", confmap);

	StringBuffer sb = new StringBuffer();


	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");

	for(Map<String, Object> item : conf_list) {
		// result
		resmap.put(item.get("result_value").toString(), item.get("field_value").toString());

		// 리스트 설정에서 hidden 개념 삭제
		//if(!"hidden".equals(item.get("result_value"))) {
			// 듣기, 다운로드, 메모 제외
			if(!"v_url".equals(item.get("result_value")) && !"v_download".equals(item.get("result_value")) && !"v_memo".equals(item.get("result_value"))) {
				sb.append("<td class=th><font color='#E4E4E4'>'</font>" + item.get("conf_name").toString() + "</td>");

							resarr.add(item.get("result_value").toString());
			}
		//}
	}

	sb.append("</tr>");

	// search
	argMap.put("top_cnt", top_cnt);
	argMap.put("rec_date1",rec_date1);
	argMap.put("rec_date2",rec_date2);
	argMap.put("rec_start_time1",rec_start_hour1+":00:00");
	argMap.put("rec_start_time2",("24".equals(rec_start_hour2)) ? "23:59:59" : rec_start_hour2+":00:00");
	argMap.put("rec_call_time1",DateUtil.getHmsToSec(Integer.parseInt(rec_call_time1)));
	argMap.put("rec_call_time2",DateUtil.getHmsToSec(Integer.parseInt(rec_call_time2)));
	argMap.put("bpart_code", bpart_code);
	argMap.put("mpart_code", mpart_code);
	argMap.put("spart_code", spart_code);
	argMap.put("system_code", system_code);
	argMap.put("local_no1", local_no1);
	argMap.put("local_no2", local_no2);
	argMap.put("rec_inout", rec_inout);
	argMap.put("user_id", user_id);
	argMap.put("user_name", user_name);
	argMap.put("cust_id", cust_id);
	argMap.put("cust_name", cust_name);
	argMap.put("cust_tel", cust_tel);
	argMap.put("rec_keycode", rec_keycode);
	argMap.put("user_list", user_list);

	// record count
	Map<String, Object> cntmap = db.selectOne("rec_search.selectCount", argMap);
	tot_cnt = ((Integer)cntmap.get("tot_cnt")).intValue();
	page_cnt = ((Double)cntmap.get("page_cnt")).intValue();

	// paging 변수
	end_cnt = (cur_page*1)*top_cnt;
	start_cnt = end_cnt-(top_cnt-1);

	// search
	argMap.put("tot_cnt", tot_cnt);
	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);
	argMap.put("start_cnt", start_cnt);
	argMap.put("end_cnt", end_cnt);

	parmap.put("s", argMap);
	parmap.put("r", resmap);

	List<Map<String, Object>> list = db.selectList("rec_search.selectList", parmap);

	// 2016.12.27 현원희 추가 -다운로드 이력
	//=========================================================================
	Map<String, Object> selmap2 = new HashMap();

	selmap2.put("excel_id", _LOGIN_ID);
	selmap2.put("excel_menu", "녹취이력");
	selmap2.put("excel_name", _LOGIN_NAME);
	selmap2.put("excel_ip",request.getRemoteAddr());

	int ins_cnt = db.insert("hist_excel.insertExcelHist", selmap2);
	//=========================================================================

	if(list.size()>0) {
		for(Map<String, Object> item : list) {
			sb.append("<tr>");
			for(int i=0;i<resarr.size();i++){
				sb.append("<td>" + item.get(resarr.get(i)) + "</td>");
			}
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
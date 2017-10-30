<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%
// DB Connection Object
	Db db = null;

		// DB Connection
		db = new Db(true);

		// paging 변수
		int tot_cnt = 1;
		int page_cnt = 0;
		int start_cnt = 0;
		int end_cnt = 0;
		int cur_page = 1;
		JSONObject json = new JSONObject();

		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("top_cnt", tot_cnt);
		// count
		Map<String, Object> cntmap  = db.selectOne("user.selectCount", argMap);
		tot_cnt = ((Integer)cntmap.get("tot_cnt")).intValue();
		page_cnt = ((Double)cntmap.get("page_cnt")).intValue();


		Map<String, Object> selmap2 = new HashMap();
		// search
		selmap2.put("tot_cnt", tot_cnt);
		selmap2.put("sort_idx", "user_id");
		selmap2.put("sort_dir", "desc");
		selmap2.put("start_cnt", "0");
		selmap2.put("end_cnt", tot_cnt);

		// record select
		List<Map<String, Object>> list = db.selectList("user.selectList", selmap2);

		CNCrypto sha256 = new CNCrypto("HASH",CommonUtil.getEncKey());

		if(list.size()>0) {
			for(Map<String, Object> item : list) {
				//out.println("pass : " + item.get("user_pass") + "<BR>");
				if (item.get("user_pass")==null && item.get("user_pass")==""){

					String enc_user_pass = sha256.Encrypt("lotte"+item.get("user_id")+"!");

					out.println(item.get("user_id")+" : update tbl_user set user_pass='"+enc_user_pass+"' where user_id='"+item.get("user_id")+"' <BR>");

				} else {
					out.println(item.get("user_id")+" : 비밀번호 있음 <BR>");

				}
			}
		}

%>
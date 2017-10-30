<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_stat","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		String act = CommonUtil.getParameter("act");
		if(act.equals("list")){
			String sort_idx = CommonUtil.getParameter("sort_idx", "user_id");
			String sort_dir = CommonUtil.getParameter("sort_dir", "up");
			String eval_date1 = CommonUtil.getParameter("eval_date1");
			String eval_date2 = CommonUtil.getParameter("eval_date2");
			String event_code = CommonUtil.getParameter("event_code");
			String sheet_code = CommonUtil.getParameter("sheet_code");
			String bpart_code = CommonUtil.getParameter("bpart_code");
			String mpart_code = CommonUtil.getParameter("mpart_code");
			String spart_code = CommonUtil.getParameter("spart_code");
			String user_name = CommonUtil.getParameter("user_name");
			String eval_user_name = CommonUtil.getParameter("eval_user_name");
			sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

			Map<String, Object> argMap = new HashMap<String, Object>();
			argMap.put("eval_date1",eval_date1.replace("-", ""));
			argMap.put("eval_date2",eval_date2.replace("-", ""));
			argMap.put("event_code",event_code);
			argMap.put("sheet_code",sheet_code);
			argMap.put("bpart_code",bpart_code);
			argMap.put("mpart_code",mpart_code);
			argMap.put("spart_code",spart_code);
			argMap.put("user_name",user_name);
			argMap.put("eval_user_name",eval_user_name);
			argMap.put("sort_idx", sort_idx);
			argMap.put("sort_dir", sort_dir);

			List<HashMap<String, Object>> list = db.selectList("stat_user.selectListItem", argMap);
			List<HashMap<String, Object>> resultList = new ArrayList<HashMap<String, Object>>();
			HashMap<String, Object> resultMap = new HashMap<String, Object>();
			String newInfo="", oldInfo="", newUserId="", oldUserId="", newOrder="";
			int idx=0;
			//이벤트코드 + 사용자ID + 평가차수 별 :: 유일
			for(HashMap<String, Object> item : list){
				newUserId = item.get("user_id").toString();
				newOrder  = item.get("eval_order").toString();
				newInfo   = newUserId +"/"+ newOrder;
				//System.out.println("newInfo="+newInfo+" , oldInfo="+oldInfo+" , resultList.size()="+resultList.size());
				if(!newInfo.equals(oldInfo)){
					//맨최초 레코드일 때 소계와 레코드 정보 안넣기 위함
					if(!oldInfo.equals("")){
						resultList.add(resultMap);
						//사용자ID + 차수 : 정보가 모두 병합되고 사용자가 바뀔 때 아래 실행
						//소계 입력
						if(!newUserId.equals(oldUserId)){
							resultList.add(getSubSum(list, idx, oldUserId));
						}
					}
					
					resultMap = (HashMap<String, Object>) item.clone();

					if(newUserId.equals(oldUserId)){
						resultMap.put("part_name", " ");
						resultMap.put("user_id", "");
						resultMap.put("user_name", "");
					}
				}

				resultMap.put("exam_score_"+item.get("item_code"),item.get("exam_score"));
				resultMap.put("add_score_"+item.get("item_code"),item.get("add_score"));
				resultMap.put("item_score_"+item.get("item_code"),item.get("exam_score")+"<font color=#bbbbbb>/</font>"+item.get("add_score"));
				resultMap.remove("exam_score");
				resultMap.remove("add_score");

				oldUserId = newUserId;
				oldInfo   = newInfo;
				idx++;
			}
			if(!oldUserId.equals("")){
				resultList.add(resultMap);
				resultList.add(getSubSum(list, idx, oldUserId));
			}

			JSONObject json = new JSONObject();
			json.put("totalRecords", resultList.size());
			json.put("data", resultList);
			out.print(json.toJSONString());
		}
		else if(act.equals("getItem")){
			Map<String, Object> argMap = new HashMap<String, Object>();
			argMap.put("sheet_code",CommonUtil.getParameter("sheet_code"));
			List<Map<String, Object>> list = db.selectList("stat_user.getItem", argMap);

			JSONObject json = new JSONObject();
			json.put("code", "OK");
			json.put("data", list);
			out.print(json.toJSONString());
		}
	} catch(Exception e) {
		logger.error(e.getMessage());
		Site.writeJsonResult(out,e);
	} finally {
		if(db!=null) db.close();
	}

%><%!

public HashMap<String, Object> getSubSum(List<HashMap<String, Object>> list, int idx, String user_id){
	//System.out.println(idx+" , user_id="+user_id+" , list="+list);
	HashMap<String, Object> rsltMap = new HashMap<String, Object>();
	HashMap<String, Integer> itemMap = new HashMap<String, Integer>();
	rsltMap.put("kind", "subSum");
	rsltMap.put("part_name", "<font color=gray>소계</font>");
	rsltMap.put("user_id", "-");
	rsltMap.put("user_name", "-");
	rsltMap.put("eval_order", "");
	rsltMap.put("eval_user_name", "-");
	rsltMap.put("upd_datm", "-");
	rsltMap.put("pq_rowcls", "red");


	int best_cnt=0, worst_cnt=0, eval_score=0, exam_score_tot=0, add_score_tot=0;
	double eval_cnt=0;
	String evalOrderOld = "";
	for(HashMap<String, Object> item : list){
		//System.out.println(item.get("user_id")+" : "+item.get("eval_order"));
		if(item.get("user_id").toString().equals(user_id)){
			if(!item.get("eval_order").toString().equals(evalOrderOld)){
				eval_cnt++;
				//System.out.println(item.get("user_id")+" : "+item.get("eval_order"));
				best_cnt += Integer.parseInt(item.get("best_cnt").toString());
				worst_cnt += Integer.parseInt(item.get("worst_cnt").toString());
				eval_score += Integer.parseInt(item.get("eval_score").toString());
				exam_score_tot += Integer.parseInt(item.get("exam_score_tot").toString());
				add_score_tot += Integer.parseInt(item.get("add_score_tot").toString());
			}
			itemMap.put("exam_score_"+item.get("item_code"), ComLib.toINN(itemMap.get("exam_score_"+item.get("item_code"))) + ComLib.toINN(item.get("exam_score")));
			itemMap.put("add_score_"+item.get("item_code"),  ComLib.toINN(itemMap.get("add_score_"+item.get("item_code")))  + ComLib.toINN(item.get("add_score")));
			rsltMap.put("item_score_"+item.get("item_code"),"<b><font color=blue>"+ComLib.round(itemMap.get("exam_score_"+item.get("item_code"))/eval_cnt,1)+"<font color=#bbbbbb>/</font>"+ComLib.round(itemMap.get("add_score_"+item.get("item_code"))/eval_cnt,1)+"</font></b>");
			evalOrderOld = item.get("eval_order").toString();
		}
		else{
			evalOrderOld = "";
		}
	}
	rsltMap.put("eval_cnt", (int) eval_cnt);
	rsltMap.put("best_cnt", best_cnt);
	rsltMap.put("worst_cnt", worst_cnt);
	rsltMap.put("eval_score", eval_score);
	rsltMap.put("exam_score_tot", exam_score_tot);
	rsltMap.put("add_score_tot", add_score_tot);
	return rsltMap;
}
%>
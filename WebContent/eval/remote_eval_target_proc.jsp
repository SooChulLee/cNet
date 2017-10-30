<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"eval_target","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");
		String eval_user_id = CommonUtil.getParameter("eval_user_id", "");
		String eval_user_name = CommonUtil.getParameter("eval_user_name", "");
		String user_list = CommonUtil.getParameter("user_list", "");

		// 파라미터 체크
		if(!CommonUtil.hasText(step) || !CommonUtil.hasText(eval_user_id) || !CommonUtil.hasText(user_list)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// &quot; -> " 로 replace
		user_list = "{\"user_list\":" + CommonUtil.toTextHTML(user_list) + "}";

		String client_ip = request.getRemoteAddr();

		Map<String, Object> argMap = new HashMap<String, Object>();

		JSONObject json = new JSONObject();
		JSONParser jsonParser = new JSONParser();

		json = (JSONObject) jsonParser.parse(user_list);
		JSONArray jsonArr = (JSONArray) json.get("user_list");

		if("insert".equals(step)) {
			int ins_cnt = 0;
		   	if(jsonArr!=null) {
		   		// 기존 데이터와 신규 데이터의 code 값을 비교하여 동일한 값이 없을 경우만 추가
				for(int i=0; i<jsonArr.size(); i++){
					JSONObject jsonItem = (JSONObject) jsonArr.get(i);

					argMap = new HashMap();
					argMap.put("eval_user_id",eval_user_id);
					argMap.put("eval_user_name",eval_user_name);
					argMap.put("user_id",jsonItem.get("user_id").toString());
					argMap.put("regi_ip",client_ip);
					argMap.put("regi_id",_LOGIN_ID);

					int tmp_ins_cnt = db.insert("eval_target.insertEventAgentList", argMap);
					ins_cnt += tmp_ins_cnt;
				}
		   	}

				if(ins_cnt<1) {
				Site.writeJsonResult(out, false, "등록에 실패했습니다.");
				return;
			}
		} else if("delete".equals(step)) {
			int del_cnt = 0;
		   	if(jsonArr!=null) {
		   		// 기존 데이터와 신규 데이터의 code 값을 비교하여 동일한 값이 없을 경우만 추가
				for(int i=0; i<jsonArr.size(); i++){
					JSONObject jsonItem = (JSONObject) jsonArr.get(i);

					argMap = new HashMap();
					argMap.put("eval_user_id",eval_user_id);
					argMap.put("user_id",jsonItem.get("user_id").toString());

					int tmp_del_cnt = db.insert("eval_target.deleteEventAgentList", argMap);
					del_cnt += tmp_del_cnt;
				}
		   	}

				if(del_cnt<1) {
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}
		} else {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		Site.writeJsonResult(out,true);
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
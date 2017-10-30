<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"event","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");

		String client_ip = request.getRemoteAddr();

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("insert".equals(step)) {
			// get parameter
			String event_name = CommonUtil.getParameter("event_name");
			String event_sdate = CommonUtil.getParameter("event_sdate");
			String event_edate = CommonUtil.getParameter("event_edate");
			String sheet_code = CommonUtil.getParameter("sheet_code");
			String eval_order_max = CommonUtil.getParameter("eval_order_max");
			String event_desc = CommonUtil.getParameter("event_desc");

			// 파라미터 체크
			if(!CommonUtil.hasText(event_name) || !CommonUtil.hasText(event_sdate) || !CommonUtil.hasText(event_edate) || !CommonUtil.hasText(sheet_code)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

				argMap.put("event_name",event_name);
			argMap.put("event_sdate",event_sdate.replace("-", ""));
			argMap.put("event_edate",event_edate.replace("-", ""));
			argMap.put("sheet_code",sheet_code);
			argMap.put("eval_order_max",eval_order_max);
			argMap.put("event_desc",event_desc);
			argMap.put("event_status","2");
			argMap.put("regi_ip",client_ip);
			argMap.put("regi_id",_LOGIN_ID);

			int ins_cnt = db.insert("event.insertEvent", argMap);
			if(ins_cnt<1) {
				throw new Exception("등록에 실패했습니다.");
			}
			Site.writeJsonResult(out,true);
		} else if("update".equals(step)) {
			// get parameter
			String data_list = CommonUtil.getParameter("data_list");

			// 파라미터 체크
			if(!CommonUtil.hasText(data_list)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			// &quot; -> " 로 replace
			data_list = "{\"data_list\":" + CommonUtil.toTextHTML(data_list) + "}";

				JSONParser jsonParser = new JSONParser();

				JSONObject jsonObj = (JSONObject) jsonParser.parse(data_list);

			JSONArray jsonArr = (JSONArray) jsonObj.get("data_list");
			Iterator<Object> iterator = jsonArr.iterator();

			int upd_cnt = 0, cnt=0;
			boolean isFailedRecord = false, isFailedMagam = false;
			while (iterator.hasNext()) {
				JSONObject jsonItem = (JSONObject) iterator.next();
				argMap.clear();
				argMap.put("event_name",jsonItem.get("event_name"));
				argMap.put("event_sdate",jsonItem.get("event_sdate").toString().replace("-", ""));
				argMap.put("event_edate",jsonItem.get("event_edate").toString().replace("-", ""));
				argMap.put("eval_order_max",jsonItem.get("eval_order_max"));
				argMap.put("event_desc",jsonItem.get("event_desc"));
				argMap.put("event_status",jsonItem.get("event_status"));
				argMap.put("upd_ip",client_ip);
				argMap.put("upd_id",_LOGIN_ID);
				argMap.put("event_code",jsonItem.get("event_code"));

				cnt = db.update("event.updateEvent", argMap);
				if(cnt==0){
					isFailedRecord = true;
					if(jsonItem.get("event_status").equals("5")) isFailedMagam = true;
				}
				upd_cnt += cnt;
			}
			//System.out.println("isFailedMagam="+isFailedMagam);
			if(isFailedMagam){
				Site.writeJsonResult(out,true, "마감에 실패한 이벤트가 있습니다.\\n\\n이의신청중인 평가가 하나라도 있으면 마감 하실 수 없습니다.");
			}
			else if(isFailedRecord){
				Site.writeJsonResult(out,true, "수정에 실패한 이벤트가 있습니다.");
			}
			else{
				Site.writeJsonResult(out,true);
			}
		} else if("delete".equals(step)) {
			// get parameter
			String event_code = CommonUtil.getParameter("row_id");

			// 파라미터 체크
			if(!CommonUtil.hasText(event_code)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			// 시트 삭제
			int del_cnt = db.delete("event.deleteEvent", event_code);
			if(del_cnt<1) {
				throw new Exception("삭제에 실패했습니다.");
			}

			Site.writeJsonResult(out,true);
		} else {
			throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
		}
	} catch(Exception e) {
		if(db!=null) db.rollback();
		Site.writeJsonResult(out,e);
		//logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
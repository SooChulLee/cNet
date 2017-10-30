<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"event","json")) return;

	Db db = null;

	try {
		db = new Db();

		String step = CommonUtil.getParameter("step");

		String client_ip = request.getRemoteAddr();

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("delete".equals(step)) {
			// get parameter
			String result_seq = CommonUtil.getParameter("result_seq");

			// 파라미터 체크
			if(!CommonUtil.hasText(result_seq)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// 평가결과 조회
			argMap.put("result_seq",result_seq);

			Map<String, Object> resmap = db.selectOne("eval_result.selectItem", argMap);
			if(resmap==null) {
				Site.writeJsonResult(out, false, "평가결과 조회에 실패했습니다.");
				return;
			}

			String event_code = resmap.get("event_code").toString();
			String assign_user_id = resmap.get("assign_user_id").toString();
			String user_id = resmap.get("user_id").toString();

			// 평가대상자 조회
			argMap.clear();
			argMap.put("event_code",event_code);
			argMap.put("eval_user_id",assign_user_id);
			argMap.put("user_id",user_id);

			Map<String, Object> usermap = db.selectOne("eval_target.selectItem", argMap);
			if(usermap==null) {
				Site.writeJsonResult(out, false, "평가대상자 조회에 실패했습니다.");
				return;
			}

			// 평가결과 삭제
			argMap.clear();
			argMap.put("result_seq",result_seq);
			argMap.put("_eval_user_id", _LOGIN_ID);
			argMap.put("_user_level", _LOGIN_LEVEL);

			int del_cnt = db.delete("eval_result.deleteEvalEventResultList", argMap);
			if(del_cnt<1) {
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}

			// 평가결과 상세 삭제
			del_cnt = db.delete("eval_result.deleteEvalEventResultItem", argMap);
			if(del_cnt<1) {
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}

			/*
			//이벤트별 배정기능을 없앴으므로 사용 안함 : 2017-09-06
			// 평가대상자 정보 업데이트
			String eval_status = (Integer.parseInt(usermap.get("eval_cnt").toString())<=1) ? "0" : "";
			argMap.clear();
			argMap.put("event_code",event_code);
			argMap.put("eval_user_id",assign_user_id);
			argMap.put("user_id",user_id);
			argMap.put("eval_status",eval_status);
			argMap.put("eval_cnt_minus","1");// 평가건수 -1

			int upd_cnt = db.update("eval_target.updateEventAgentList", argMap);
			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "평가대상자 업데이트에 실패했습니다.");
				return;
			}
			*/

			Site.writeJsonResult(out,true);
		}
		else if("chg2to9".equals(step)) {
			String event_code = CommonUtil.getParameter("event_code");
			//등록상태 일괄 완료처리
			argMap.put("event_code", event_code);
			int cnt = db.update("eval_result.updateStatus2To9", argMap);
			out.print("{\"code\":\"OK\", \"msg\":\"\", \"cnt\":"+cnt+"}");
		}
		else {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// commit
		db.commit();

	} catch(Exception e) {
		// rollback
		if(db!=null) db.rollback();

		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
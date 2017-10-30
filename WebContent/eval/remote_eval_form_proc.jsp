<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
// 메뉴 접근권한 체크
if(!Site.isPmss(out,"eval","json")) return;

Db db = null;
String eval_order = "";

try {
	// DB Connection
	db = new Db();

	// get parameter
	String step = CommonUtil.getParameter("step");
	String eval_status = CommonUtil.getParameter("eval_status");//평가상태 : 진행(1) / 등록(2) / 완료(9)

	String client_ip = request.getRemoteAddr();

	Map<String, Object> argMap = new HashMap<String, Object>();

	// get parameter
	String event_code = CommonUtil.getParameter("event_code");
	String sheet_code = CommonUtil.getParameter("sheet_code");
	String rec_date = CommonUtil.getParameter("rec_date");
	String rec_seq = CommonUtil.getParameter("rec_seq");
	String eval_user_id = CommonUtil.getParameter("eval_user_id");
	String user_id = CommonUtil.getParameter("user_id");
	String eval_comment = CommonUtil.getParameter("eval_comment");
	String eval_text = CommonUtil.getParameter("eval_text");
	String eval_rate_code = CommonUtil.getParameter("eval_rate_code");
	String result_seq = CommonUtil.getParameter("result_seq");
	eval_order = CommonUtil.getParameter("eval_order");


	// 파라미터 체크
	if(!CommonUtil.hasText(event_code) || !CommonUtil.hasText(sheet_code) || !CommonUtil.hasText(rec_seq) || !CommonUtil.hasText(rec_date) || !CommonUtil.hasText(eval_user_id) || !CommonUtil.hasText(user_id)) {
		throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
	}

	// 녹취정보 조회
	argMap.clear();
	argMap.put("rec_seq", rec_seq);

	Map<String, Object> recmap  = db.selectOne("eval_rec_search.selectItem", argMap);
	if(recmap==null) {
		throw new Exception("녹취 데이터 조회에 실패했습니다.");
	}

	// 기존 평가내용이 있는지 확인
	String result_yn = "0";
	// 평가결과 pk
	int _result_seq = 0;
	// 총점, 항목점수, 가중치 점수
	int eval_score_score = 0, exam_score_sum = 0, add_score_sum = 0;
	// 배정된 평가자 아이디
	String assign_user_id = "";

	// 평가결과 조회
	argMap.clear();
	argMap.put("event_code",event_code);
	argMap.put("sheet_code",sheet_code);
	argMap.put("rec_seq",rec_seq);
	argMap.put("user_id",user_id);

	if(CommonUtil.hasText(result_seq)) {
		// 평가 결과조회에서 오픈
		argMap.put("result_seq", result_seq);
		argMap.put("_eval_user_id", _LOGIN_ID);
		argMap.put("_user_level", _LOGIN_LEVEL);
	} else {
		// 평가 수행에서 오픈
		argMap.put("eval_user_id", _LOGIN_ID);
	}

	Map<String, Object> resmap = db.selectOne("eval_result.selectItem", argMap);
	if(resmap!=null) {
		// 업데이트
		result_yn = "1";
		_result_seq = Integer.parseInt(resmap.get("result_seq").toString());
		assign_user_id = resmap.get("assign_user_id").toString();
	}

	// 결과 등록/업데이트
	if("1".equals(result_yn)) {
		// 업데이트
		argMap.clear();
		argMap.put("result_seq", _result_seq);
		argMap.put("event_code",event_code);
		argMap.put("eval_comment",eval_comment);
		argMap.put("eval_text",eval_text);
		argMap.put("eval_rate_code",eval_rate_code);
		argMap.put("eval_status",eval_status);
		argMap.put("eval_order",eval_order);
		argMap.put("upd_ip",client_ip);
		argMap.put("_eval_user_id", _LOGIN_ID);
		argMap.put("_user_level", _LOGIN_LEVEL);

		int upd_cnt = db.update("eval_result.updateEvalEventResultList", argMap);
		if(upd_cnt<1) {
			throw new Exception("녹취 업데이트에 실패했습니다.");
		}

		// 이전 등록된 평가항목 데이터 삭제
		argMap.clear();
		argMap.put("result_seq",_result_seq);
		argMap.put("event_code",event_code);

		int del_cnt = db.insert("eval_result.deleteEvalEventResultItem", argMap);
		if(del_cnt<1) {
			throw new Exception("상세 삭제에 실패했습니다.");
		}
	} else {
		// 등록
		argMap.clear();
		argMap.put("event_code",event_code);
		argMap.put("sheet_code",sheet_code);
		argMap.put("eval_order",eval_order);
		argMap.put("eval_user_id", _LOGIN_ID);
		argMap.put("eval_user_name", _LOGIN_NAME);
		argMap.put("assign_user_id", eval_user_id);
		argMap.put("rec_seq",rec_seq);
		argMap.put("rec_datm",recmap.get("rec_datm"));
		argMap.put("rec_filename",recmap.get("rec_filename"));
		argMap.put("rec_keycode",recmap.get("rec_keycode"));
		argMap.put("user_id",user_id);
		argMap.put("user_name",recmap.get("user_name"));
		argMap.put("bpart_code",recmap.get("bpart_code"));
		argMap.put("bpart_name",recmap.get("bpart_name"));
		argMap.put("mpart_code",recmap.get("mpart_code"));
		argMap.put("mpart_name",recmap.get("mpart_name"));
		argMap.put("spart_code",recmap.get("spart_code"));
		argMap.put("spart_name",recmap.get("spart_name"));
		argMap.put("local_no",recmap.get("local_no"));
		argMap.put("cust_name",recmap.get("cust_name"));
		argMap.put("eval_score",eval_score_score);
		argMap.put("exam_score",exam_score_sum);
		argMap.put("add_score",add_score_sum);
		argMap.put("eval_comment",eval_comment);
		argMap.put("eval_text",eval_text);
		argMap.put("eval_rate_code",eval_rate_code);
		argMap.put("eval_status",eval_status);
		argMap.put("regi_ip",client_ip);

		int ins_cnt = db.insert("eval_result.insertEvalEventResultList", argMap);
		if(ins_cnt<1) {
			throw new Exception("등록에 실패했습니다.");
		}

		_result_seq = Integer.parseInt(argMap.get("result_seq").toString());
		assign_user_id = eval_user_id;
	}

	// 평가 채점관련 파라미터 데이터 등록 (평가결과 항목별 점수)
	int ins_item_cnt = 0;
	Enumeration eval_params = request.getParameterNames();
	
	while(eval_params.hasMoreElements()) {
		String eval_name = (String) eval_params.nextElement();
		if(eval_name.indexOf("exam_score_")>-1) {
			String examScore[] = CommonUtil.getParameter(eval_name).split(":");//0=rec_id
			// 평가항목 등록
			argMap.clear();
			argMap.put("result_seq",_result_seq);
			argMap.put("event_code",event_code);
			argMap.put("sheet_code",sheet_code);
			argMap.put("cate_code",examScore[0]);
			argMap.put("item_code",examScore[1]);
			argMap.put("exam_code",examScore[2]);
			argMap.put("exam_score",examScore[3]);
			argMap.put("add_score",examScore[4]);

			ins_item_cnt += db.insert("eval_result.insertEvalEventResultItem", argMap);

			// 항목 총점 계산
			exam_score_sum += Integer.parseInt(examScore[3]);
			// 가중치 총점 계산
			add_score_sum += Integer.parseInt(examScore[4]);
			// 총점 계산
		}
	}
	if(ins_item_cnt<1) {
		throw new Exception("상세 등록에 실패했습니다.");
	}

	eval_score_score = exam_score_sum + add_score_sum;

	// 평가총점 업데이트
	argMap.clear();
	argMap.put("result_seq", _result_seq);
	argMap.put("event_code",event_code);
	argMap.put("eval_score",eval_score_score);
	argMap.put("exam_score",exam_score_sum);
	argMap.put("add_score",add_score_sum);
	argMap.put("_eval_user_id", _LOGIN_ID);
	argMap.put("_user_level", _LOGIN_LEVEL);

	int upd_score_cnt = db.update("eval_result.updateEvalEventResultList", argMap);
	if(upd_score_cnt<1) {
		throw new Exception("평가점수 업데이트에 실패했습니다.");
	}

	/*
	//이벤트별 배정기능을 없앴으므로 사용 안함 : 2017-09-06
	// 평가대상자 평가상태 업데이트
	argMap.clear();
	argMap.put("event_code",event_code);
	argMap.put("eval_user_id",assign_user_id); // 배정된 평가자 아이디
	argMap.put("user_id",user_id);
	argMap.put("eval_status",eval_status);
	// 평가를 최초 등록할 경우만 count + 1
	if("0".equals(result_yn)) {
		argMap.put("eval_cnt_plus","1");
	}

	int upd_agent_cnt = db.update("eval_target.updateEventAgentList", argMap);
	if(upd_agent_cnt<1) {
		throw new Exception("평가대상자 업데이트에 실패했습니다.");
	}
	*/

	db.commit();

	Site.writeJsonResult(out,true);
} catch(Exception e) {
	if(db!=null) db.rollback();
	String errMsg = e.getMessage();
	if (errMsg.indexOf("IX_EVAL_EVENT_RESULT_LIST_eval_order_unique")>-1){
		Site.writeJsonResult(out,false,eval_order+"차평가는 이미 평가 한 차수 입니다!\\n\\n확인 하세요.");
	}
	else{
		Site.writeJsonResult(out,e);
		logger.error(e.getMessage());
	}
} finally {
	if(db!=null) db.close();
}
%>
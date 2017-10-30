<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"eval","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String event_code = CommonUtil.getParameter("event_code");
		String sheet_code = CommonUtil.getParameter("sheet_code");
		String rec_seq = CommonUtil.getParameter("rec_seq");
		String eval_user_id = CommonUtil.getParameter("eval_user_id");
		String user_id = CommonUtil.getParameter("user_id");
		String result_seq = CommonUtil.getParameter("result_seq");

		// 파라미터 체크
		if(!CommonUtil.hasText(event_code) || !CommonUtil.hasText(sheet_code) || !CommonUtil.hasText(eval_user_id) || !CommonUtil.hasText(rec_seq) || !CommonUtil.hasText(user_id)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		JSONObject json = new JSONObject();

		Map<String, Object> argMap = new LinkedHashMap<String, Object>();
		Map<String, Object> cpmap  = new LinkedHashMap<String, Object>();
		Map<String, Object> camap  = new LinkedHashMap<String, Object>();
		Map<String, Object> itmap  = new LinkedHashMap<String, Object>();

		// 평가 수행 = 로그인한 사용자의 평가 내용만 확인 가능 / 평가 결과조회 = 관리자 권한일 경우 다른 평가자가 평가한 내용도 확인 가능해야 함
		argMap.put("event_code", event_code);
		argMap.put("sheet_code", sheet_code);
		argMap.put("rec_seq", rec_seq);
		argMap.put("user_id", user_id);

		if(CommonUtil.hasText(result_seq)) {
			// 평가 결과조회에서 오픈
			argMap.put("result_seq", result_seq);
			argMap.put("_eval_user_id", _LOGIN_ID);
			argMap.put("_user_level", _LOGIN_LEVEL);
		} else {
			// 평가 수행에서 오픈
			argMap.put("eval_user_id", _LOGIN_ID);
		}

		// result select
		Map<String, Object> resmap = db.selectOne("eval_result.selectItem", argMap);

		// sheet select
		List<Map<String, Object>> list = db.selectList("eval_result.sheetView", argMap);
		for(Map<String, Object> item : list) {
			// 부모 카테고리 건수
			if(cpmap.containsKey(item.get("cate_pcode"))) {
				cpmap.put(item.get("cate_pcode").toString(), Integer.parseInt(cpmap.get(item.get("cate_pcode")).toString())+1);
			} else {
				cpmap.put(item.get("cate_pcode").toString(), 1);
			}
			// 자식 카테고리 건수
			if(camap.containsKey(item.get("cate_code"))) {
				camap.put(item.get("cate_code").toString(), Integer.parseInt(camap.get(item.get("cate_code")).toString())+1);
			} else {
				camap.put(item.get("cate_code").toString(), 1);
			}
			// 평가 항목 건수
			if(itmap.containsKey(item.get("item_code"))) {
				itmap.put(item.get("item_code").toString(), Integer.parseInt(itmap.get(item.get("item_code")).toString())+1);
			} else {
				itmap.put(item.get("item_code").toString(), 1);
			}
		}

		json.put("result", resmap);
		json.put("rs_pcate", cpmap);
		json.put("rs_cate", camap);
		json.put("rs_item", itmap);
		json.put("data", list);

		List<Map<String, Object>> claimList = db.selectList("eval_claim.selectList", argMap);
		json.put("claimList", claimList);

		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
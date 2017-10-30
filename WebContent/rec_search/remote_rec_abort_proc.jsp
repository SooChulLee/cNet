<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"rec_search","json")) return;

	// 관리자 이상 등급만 업데이트 가능
	//if(!"0".equals(_LOGIN_LEVEL) && !"A".equals(_LOGIN_LEVEL)) {
	/*if(_LOGIN_LEVEL.charAt(0)>="B".charAt(0)) {	// 관리자 권한 이상일 경우 버튼 노출
		Site.writeJsonResult(out, false, "" + CommonUtil.getErrorMsg("ERR_PERM") + "");
		return;
	}*/

	Db db = null;

	try {
		db = new Db();

		// get parameter
		String step = CommonUtil.getParameter("step");

		Map<String, Object> argMap = new HashMap<String, Object>();
		Map<String, Object> selmap2 = new HashMap();

		if("abort".equals(step)) {
			// get parameter
			String rec_date = CommonUtil.getParameter("rec_date");
			String rec_shour = CommonUtil.getParameter("rec_shour");
			String rec_smin = CommonUtil.getParameter("rec_smin");
			String rec_ehour = CommonUtil.getParameter("rec_ehour");
			String rec_emin = CommonUtil.getParameter("rec_emin");

			String rec_date2 = rec_date.replace("-", "");

			// 파라미터 체크
			if(!CommonUtil.hasText(step) || !CommonUtil.hasText(rec_date) || !CommonUtil.hasText(rec_shour) || !CommonUtil.hasText(rec_smin) || !CommonUtil.hasText(rec_ehour) || !CommonUtil.hasText(rec_emin)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				String rec_datm1 = rec_date + " " + rec_shour + ":" + rec_smin + ":00.000";
			String rec_datm2 = rec_date + " " + rec_ehour + ":" + rec_emin + ":00.997";

			String rec_start_time = "1900-01-01" + " " + rec_shour + ":" + rec_smin + ":00.000";
			String rec_end_time = "1900-01-01" + " " + rec_ehour + ":" + rec_emin + ":59.997";

				argMap.put("dateStr", CommonUtil.getRecordTableNm(rec_datm1));
			argMap.put("rec_datm1", rec_datm1);
			argMap.put("rec_datm2", rec_datm2);
			argMap.put("rec_abort_code", "1");
			argMap.put("rec_start_time", rec_start_time);
			argMap.put("rec_end_time", rec_end_time);
			argMap.put("rec_date2", rec_date2);



				int upd_cnt = db.insert("rec_search.updateAbortCode", argMap);
			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "조회 조건과 일치하는 데이터가 없습니다.");
				return;
			}

			selmap2.put("dateStr", CommonUtil.getRecordTableNm(rec_datm1));
			selmap2.put("start_rec_datm", rec_datm1);
			selmap2.put("end_rec_datm", rec_datm2);
			selmap2.put("abort_state", "등록");
			selmap2.put("abort_id",_LOGIN_ID);
			selmap2.put("abort_name",_LOGIN_NAME);
			selmap2.put("abort_ip",request.getRemoteAddr());

			int ins_cnt = db.insert("hist_abort.insertAbortHist", selmap2);

		} else {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// commit
		db.commit();

		Site.writeJsonResult(out,true);
	} catch(Exception e) {
		// rollback
		if(db!=null) db.rollback();

		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
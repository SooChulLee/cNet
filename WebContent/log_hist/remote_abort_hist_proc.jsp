<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ include file="/common/function.jsp" %>
<%
	if(!Site.isPmss(out,"abort_hist","json")) return;

	// 관리자 이상 등급만 업데이트 가능
	//if(!"0".equals(_LOGIN_LEVEL) && !"A".equals(_LOGIN_LEVEL)) {
	/* if(_LOGIN_LEVEL.charAt(0)>="B".charAt(0)) {	// 관리자 권한 이상일 경우 버튼 노출
		Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("ERR_PERM"));
		return;
	} */

	Db db = null;

	try {
		db = new Db();

		// get parameter
		String step = CommonUtil.getParameter("step");

		Map<String, Object> argMap = new HashMap<String, Object>();
		Map<String, Object> selmap2 = new HashMap();

		if("abort".equals(step)) {
			// get parameter
			String start_rec_datm = CommonUtil.getParameter("start_rec_datm");
			String end_rec_datm = CommonUtil.getParameter("end_rec_datm");

			String rec_date = start_rec_datm.substring(0, 4) + "-" + start_rec_datm.substring(4, 6) + "-" + start_rec_datm.substring(6, 8);
			String rec_shour = start_rec_datm.substring(8, 10);
			String rec_smin = start_rec_datm.substring(10, 12);
			String rec_ehour = end_rec_datm.substring(8, 10);
			String rec_emin = end_rec_datm.substring(10 , 12);

			String rec_date2 = start_rec_datm.substring(0, 4) + start_rec_datm.substring(4, 6) + start_rec_datm.substring(6, 8);
			String rec_start_time = "1900-01-01" + " " + rec_shour + ":" + rec_smin + ":00.000";
			String rec_end_time = "1900-01-01" + " " + rec_ehour + ":" + rec_emin + ":59.997";

			//20161207130000

			// 파라미터 체크
			if(!CommonUtil.hasText(step) || !CommonUtil.hasText(start_rec_datm) || !CommonUtil.hasText(end_rec_datm)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				//String rec_datm1 = start_rec_datm.substring(0, 4) + "-" + start_rec_datm.substring(5, 2) + "-" + start_rec_datm.substring(7, 2) + " " + start_rec_datm.substring(9, 2) + ":" + start_rec_datm.substring(11, 2) + ":00.000";
			//String rec_datm2 = end_rec_datm.substring(0, 4) + "-" + end_rec_datm.substring(5, 2) + "-" + end_rec_datm.substring(7, 2) + " " + end_rec_datm.substring(9, 2) + ":" + end_rec_datm.substring(11, 2) + ":00.997";

				String rec_datm1 = rec_date + " " + rec_shour + ":" + rec_smin + ":00.000";
			String rec_datm2 = rec_date + " " + rec_ehour + ":" + rec_emin + ":00.997";

				argMap.put("dateStr", CommonUtil.getRecordTableNm(rec_datm1));
			argMap.put("rec_datm1", rec_datm1);
			argMap.put("rec_datm2", rec_datm2);
			argMap.put("rec_abort_code", null);
			argMap.put("rec_date2", rec_date2);
			argMap.put("rec_start_time", rec_start_time);
			argMap.put("rec_end_time", rec_end_time);
				int upd_cnt = db.insert("rec_search.updateAbortCode", argMap);
			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "조회 조건과 일치하는 데이터가 없습니다.");
				return;
			}


			selmap2.put("dateStr", CommonUtil.getRecordTableNm(rec_datm1));
			selmap2.put("start_rec_datm", rec_datm1);
			selmap2.put("end_rec_datm", rec_datm2);
			selmap2.put("abort_state", "취소");
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
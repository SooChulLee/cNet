<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"rec_search","json")) return;

	Db db = null;

	try {
		db = new Db();

		// get parameter
		String step = CommonUtil.getParameter("step");

		Map<String, Object> argMap = new HashMap<String, Object>();

		// 사용권한 체크
		argMap.put("conf_field","memo");
		argMap.put("user_id",_LOGIN_ID);
		argMap.put("user_level",_LOGIN_LEVEL);

		if(!"1".equals(db.selectOne("search_config.selectResultPerm", argMap))) {
			Site.writeJsonResult(out, false, "" + CommonUtil.getErrorMsg("ERR_PERM") + "");
			return;
		}

		if("insert".equals(step)) {
			// get parameter
			String rec_datm = CommonUtil.getParameter("rec_datm");
			String local_no = CommonUtil.getParameter("local_no");
			String rec_filename = CommonUtil.getParameter("rec_filename");

			String memo_text = CommonUtil.getParameter("memo_text");
			String client_ip = request.getRemoteAddr();

			// 파라미터 체크
			if(!CommonUtil.hasText(rec_datm) || !CommonUtil.hasText(local_no) || !CommonUtil.hasText(rec_filename) || !CommonUtil.hasText(memo_text)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// tbl_record_{yyyy}의 년도 조회
			String rec_year = CommonUtil.getRecordTableNm(rec_datm);	// rec_datm.substring(0, 4);

				argMap.put("dateStr", rec_year);
			argMap.put("rec_datm",rec_datm);
			argMap.put("local_no",local_no);
			argMap.put("rec_filename",rec_filename);

			// 녹취이력 조회
			Map<String, Object> data  = db.selectOne("rec_search.selectItem", argMap);
			if(data==null) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_DATA"));
				return;
			}

				argMap.put("dateStr", rec_year);
			argMap.put("rec_datm",rec_datm);
			argMap.put("local_no",local_no);
			argMap.put("rec_filename",rec_filename);
			argMap.put("regi_id",_LOGIN_ID);
			argMap.put("regi_name",_LOGIN_NAME);
			argMap.put("memo_text",memo_text);
			argMap.put("regi_ip",client_ip);

				int ins_cnt = db.insert("rec_memo.insertMemo", argMap);
			if(ins_cnt<1) {
				Site.writeJsonResult(out, false, "등록에 실패했습니다.");
				return;
			}

			// 메모 건수 업데이트 (+1)
			argMap.clear();
			argMap.put("step","I");
			argMap.put("dateStr", rec_year);
			argMap.put("rec_datm",rec_datm);
			argMap.put("local_no",local_no);
			argMap.put("rec_filename",rec_filename);
			argMap.put("rec_datm",rec_datm);

			int upd_cnt = db.update("rec_memo.updateMemoCnt", argMap);
		} else if("delete".equals(step)) {
			// get parameter
			String memo_seq = CommonUtil.getParameter("memo_seq");
			String rec_datm = CommonUtil.getParameter("rec_datm");
			String local_no = CommonUtil.getParameter("local_no");
			String rec_filename = CommonUtil.getParameter("rec_filename");

			// 파라미터 체크
			if(!CommonUtil.hasText(memo_seq) || !CommonUtil.hasText(rec_datm) || !CommonUtil.hasText(local_no) || !CommonUtil.hasText(rec_filename)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				argMap.put("memo_seq",memo_seq);
			argMap.put("rec_datm",rec_datm);
			argMap.put("local_no",local_no);
			argMap.put("rec_filename",rec_filename);
			argMap.put("regi_id",_LOGIN_ID);
			argMap.put("_user_level",_LOGIN_LEVEL);

			int del_cnt = db.delete("rec_memo.deleteMemo", argMap);
			if(del_cnt<1) {
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}

			// 메모 건수 업데이트 (-1)
			argMap.clear();
			argMap.put("step","D");
			argMap.put("dateStr", CommonUtil.getRecordTableNm(rec_datm));
			argMap.put("rec_datm",rec_datm);
			argMap.put("local_no",local_no);
			argMap.put("rec_filename",rec_filename);
			argMap.put("rec_datm",rec_datm);

			int upd_cnt = db.update("rec_memo.updateMemoCnt", argMap);
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
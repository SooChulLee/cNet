<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	//if(!Site.isPmss(out,"rec_search","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");

		Map<String, Object> argMap = new HashMap<String, Object>();

		// 사용권한 체크
//		argMap.put("conf_field","url");
//		argMap.put("user_id",_LOGIN_ID);
//		argMap.put("user_level",_LOGIN_LEVEL);

//		if(!"1".equals(db.selectOne("search_config.selectResultPerm", argMap))) {
//			Site.writeJsonResult(out, false, "" + CommonUtil.getErrorMsg("ERR_PERM") + "");
//			return;
//		}

		if("insert".equals(step)) {
			// get parameter
			String rec_datm = CommonUtil.getParameter("rec_datm");
			String local_no = CommonUtil.getParameter("local_no");
			String rec_filename = CommonUtil.getParameter("rec_filename");
			String mk_name = CommonUtil.getParameter("mk_name");
			String mk_stime = CommonUtil.getParameter("mk_stime");
			String mk_etime = CommonUtil.getParameter("mk_etime");
			String client_ip = request.getRemoteAddr();

			// 파라미터 체크
			if(!CommonUtil.hasText(rec_datm) || !CommonUtil.hasText(local_no) || !CommonUtil.hasText(rec_filename) || !CommonUtil.hasText(mk_name) || !CommonUtil.hasText(mk_stime) || !CommonUtil.hasText(mk_etime)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// yyyyMMddHHmmss -> yyyy-MM-dd HH:mm:ss
			rec_datm = DateUtil.getDateFormatByIntVal(rec_datm, "yyyy-MM-dd HH:mm:ss");

				argMap.put("rec_datm",rec_datm);
			argMap.put("local_no",local_no);
			argMap.put("rec_filename",rec_filename);
			argMap.put("regi_id",_LOGIN_ID);
			argMap.put("mk_name",mk_name);
			argMap.put("mk_stime",mk_stime);
			argMap.put("mk_etime",mk_etime);
			argMap.put("regi_ip",client_ip);

				int ins_cnt = db.insert("rec_marking.insertMarking", argMap);
			if(ins_cnt<1) {
				Site.writeJsonResult(out, false, "등록에 실패했습니다.");
				return;
			}
		} else if("delete".equals(step)) {
			// get parameter
			String mk_seq = CommonUtil.getParameter("mk_seq");
			String rec_datm = CommonUtil.getParameter("rec_datm");
			String local_no = CommonUtil.getParameter("local_no");
			String rec_filename = CommonUtil.getParameter("rec_filename");

			// 파라미터 체크
			if(!CommonUtil.hasText(mk_seq) || !CommonUtil.hasText(rec_datm) || !CommonUtil.hasText(local_no) || !CommonUtil.hasText(rec_filename)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				argMap.put("mk_seq",mk_seq);
			argMap.put("rec_datm",rec_datm);
			argMap.put("local_no",local_no);
			argMap.put("rec_filename",rec_filename);
			argMap.put("regi_id",_LOGIN_ID);

			int del_cnt = db.delete("rec_marking.deleteMarking", argMap);
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
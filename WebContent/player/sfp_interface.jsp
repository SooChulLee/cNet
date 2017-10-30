<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="wfm.com.util.AES256Cipher"%>
<%
	// DB Connection Object
	Db db = null;

	try {
		// DB Connection
		db = new Db(true);

		// get parameter
		String rec_date = CommonUtil.ifNull(request.getParameter("rec_date"));
		String local_no = CommonUtil.ifNull(request.getParameter("local_no"));
		String rec_keycode = CommonUtil.ifNull(request.getParameter("rec_keycode"));
		String store_code = CommonUtil.ifNull(request.getParameter("store_code"));
		String mystery_code = CommonUtil.ifNull(request.getParameter("mystery_code"));

		// 파라미터 체크
		if(!CommonUtil.hasText(rec_date) || !CommonUtil.hasText(local_no) || !CommonUtil.hasText(rec_keycode)) {
			out.print("ERR" + CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// parameter decrypt
		/*AES256Cipher a256 = AES256Cipher.getInstance(CommonUtil.getWfmEncKey());

		String dec_rec_date = a256.decrypt(rec_date);
		String dec_local_no = a256.decrypt(local_no);
		String dec_rec_keycode = a256.decrypt(rec_keycode);
		*/

		//
		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("rec_date",rec_date);
		argMap.put("local_no",local_no);
		argMap.put("rec_keycode",rec_keycode);
		argMap.put("rec_store_code",store_code);
		argMap.put("rec_mystery_code",mystery_code);

		int ins_cnt = db.insert("softphone_hist.insertSoftphoneHist", argMap);
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
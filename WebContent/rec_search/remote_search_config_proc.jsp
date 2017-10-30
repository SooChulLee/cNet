<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"rec_search","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String conf_type = CommonUtil.getParameter("conf_type");
		String conf_codes = CommonUtil.getParameter("conf_codes");

		// 파라미터 체크
		if(!CommonUtil.hasText(conf_type) || !CommonUtil.hasText(conf_codes)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		Map<String, Object> parmap = new HashMap();

		parmap.put("business_code", _BUSINESS_CODE);
		parmap.put("user_id", _LOGIN_ID);
		parmap.put("conf_type", conf_type);

		// 기존 데이터 삭제
		int del_cnt = db.delete("search_config.deleteSearchUserConfig", parmap);

		// 신규 데이터 등록
		String[] arr_code = conf_codes.split(",");
		int ins_cnt=0;
		int tmp_cnt=0;
		for(int i=0;i<arr_code.length;i++) {
			parmap.put("conf_code", arr_code[i]);
			parmap.put("order_no", i+1);

			tmp_cnt = db.insert("search_config.insertSearchUserConfig", parmap);
			ins_cnt+=tmp_cnt;
		}

		if(ins_cnt<1) {
			Site.writeJsonResult(out, false, "등록된 데이터가 없습니다.");
			return;
		}

		Site.writeJsonResult(out,true);
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
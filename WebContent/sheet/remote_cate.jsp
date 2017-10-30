<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"cate","json")) return;

	Db db = null;

	try {
		// get parameter
		String cate_code = CommonUtil.getParameter("cate_code");

		// 파라미터 체크
		if(!CommonUtil.hasText(cate_code)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		db = new Db(true);

		JSONObject json = new JSONObject();

		Map<String, Object> data = db.selectOne("cate.selectItem", cate_code);

		// text -> html형태로 변환
		for(String key : data.keySet()) {
			data.put(key, CommonUtil.toTextHTML(data.get(key).toString()));
		}

		if(data!=null) {
			json.put("code", "OK");
			json.put("data", data);
			out.print(json.toJSONString());
		}
		else {
			Site.writeJsonResult(out,false,"카테고리 데이터 없음");
		}
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"sheet","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String sheet_code = CommonUtil.getParameter("sheet_code");

		// 파라미터 체크
		if(!CommonUtil.hasText(sheet_code)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		JSONObject json = new JSONObject();

		Map<String, Object> cpmap = new LinkedHashMap();
		Map<String, Object> camap = new LinkedHashMap();
		Map<String, Object> itmap = new LinkedHashMap();

		// sheet select
		List<Map<String, Object>> list = db.selectList("sheet.sheetView", sheet_code);
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

		json.put("rs_pcate", cpmap);
		json.put("rs_cate", camap);
		json.put("rs_item", itmap);
		json.put("data", list);
		out.print(json.toJSONString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
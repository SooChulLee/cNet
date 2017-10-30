<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"item","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("insert".equals(step)) {
			// get parameter
			String cate_code = CommonUtil.getParameter("cate_code");
			String parent_code = CommonUtil.getParameter("parent_code", "_parent");
			String item_name = CommonUtil.getParameter("item_name");
			String item_etc = CommonUtil.getParameter("item_etc");
			String use_yn = CommonUtil.getParameter("use_yn");

			// 파라미터 체크
			if(!CommonUtil.hasText(cate_code) || !CommonUtil.hasText(item_name) || !CommonUtil.hasText(use_yn)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			argMap.put("cate_code",cate_code);
			argMap.put("parent_code",parent_code);
			argMap.put("item_name",item_name);
			argMap.put("item_etc",item_etc);
			argMap.put("use_yn",use_yn);

			int ins_cnt = db.insert("item.insertItem", argMap);
			if(ins_cnt<1) {
				Site.writeJsonResult(out, false, "등록에 실패했습니다.");
				return;
			}
		} else if("update".equals(step)) {
			// get parameter
			String item_code = CommonUtil.getParameter("item_code");
			String item_name = CommonUtil.getParameter("item_name");
			String item_etc = CommonUtil.getParameter("item_etc");
			String use_yn = CommonUtil.getParameter("use_yn");

			// 파라미터 체크
			if(!CommonUtil.hasText(item_code) || !CommonUtil.hasText(item_name) || !CommonUtil.hasText(use_yn)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				argMap.put("item_code",item_code);
			argMap.put("item_name",item_name);
			argMap.put("item_etc",item_etc);
			argMap.put("use_yn",use_yn);

				int upd_cnt = db.update("item.updateItem", argMap);
			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
				return;
			}
		} else if("delete".equals(step)) {
			// get parameter
			String item_code = CommonUtil.getParameter("item_code");

			// 파라미터 체크
			if(!CommonUtil.hasText(item_code)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				argMap.put("item_code", item_code);

				int del_cnt = db.delete("item.deleteItem", argMap);
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
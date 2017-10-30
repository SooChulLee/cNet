<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"cate","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("insert".equals(step)) {
			// get parameter
			String cate_name = CommonUtil.getParameter("cate_name");
			String parent_code = CommonUtil.getParameter("parent_code");
			String cate_desc = CommonUtil.getParameter("cate_desc");
			String cate_etc = CommonUtil.getParameter("cate_etc");
			String use_yn = CommonUtil.getParameter("use_yn");

			// 파라미터 체크
			if(!CommonUtil.hasText(cate_name) || !CommonUtil.hasText(parent_code)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				argMap.put("cate_name",cate_name);
			argMap.put("parent_code",parent_code);
			argMap.put("cate_desc",cate_desc);
			argMap.put("cate_etc",cate_etc);
			argMap.put("use_yn",use_yn);

				int ins_cnt = db.insert("cate.insertCate", argMap);
			if(ins_cnt<1) {
				Site.writeJsonResult(out, false, "등록에 실패했습니다.");
				return;
			}
		} else if("update".equals(step)) {
			// get parameter
			String cate_code = CommonUtil.getParameter("cate_code");
			String cate_name = CommonUtil.getParameter("cate_name");
			String parent_code = CommonUtil.getParameter("parent_code");
			String cate_desc = CommonUtil.getParameter("cate_desc");
			String cate_etc = CommonUtil.getParameter("cate_etc");
			String use_yn = CommonUtil.getParameter("use_yn");

			// 파라미터 체크
			if(!CommonUtil.hasText(cate_code) || !CommonUtil.hasText(cate_name)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				argMap.put("cate_code",cate_code);
			argMap.put("cate_name",cate_name);
			argMap.put("cate_desc",cate_desc);
			argMap.put("cate_etc",cate_etc);
			argMap.put("use_yn",use_yn);

				int upd_cnt = db.update("cate.updateCate", argMap);
			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
				return;
			}
		} else if("delete".equals(step)) {
			// get parameter
			String cate_code = CommonUtil.getParameter("cate_code");

			// 파라미터 체크
			if(!CommonUtil.hasText(cate_code)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				argMap.put("cate_code", cate_code);

				int del_cnt = db.delete("cate.deleteCate", argMap);
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
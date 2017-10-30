<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"mon_list","json")) return;

	Db db = null;

	try {
		db = new Db();

		// get parameter
		String ch_no = CommonUtil.getParameter("ch_no");
		String local_no = CommonUtil.getParameter("local_no");
		String system_code = CommonUtil.getParameter("system_code");

		String user_id = CommonUtil.getParameter("user_id");
		String user_name = CommonUtil.getParameter("user_name");

		Map<String, Object> argMap = new HashMap<String, Object>();

		//getdate(),#{system_code},#{channel_no},#{login_id},#{login_name},#{listen_ip},#{user_id},#{user_name},#{local_no}
		argMap.put("system_code",system_code);

		argMap.put("login_id",_LOGIN_ID);
		argMap.put("login_name",_LOGIN_NAME);
		argMap.put("listen_ip",request.getRemoteAddr());

		argMap.put("user_id",user_id);
		argMap.put("user_name",user_name);
		argMap.put("channel_no",ch_no);
		argMap.put("local_no",local_no);

		int ins_cnt = db.insert("hist_rlisten.insertListenHist", argMap);
		if(ins_cnt<1) {
			Site.writeJsonResult(out, false, "등록에 실패했습니다.");
			return;
		}
		Site.writeJsonResult(out,true);
		db.commit();

	} catch(Exception e) {
		// rollback
		if(db!=null) db.rollback();

		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
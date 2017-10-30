<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ include file="/common/function.jsp" %>
<%


	// DB Connection Object
	Db db = null;

	try {
		// DB Connection
		db = new Db(true);

		// get parameter
		String info = CommonUtil.ifNull(request.getParameter("info"));


		// 파라미터 체크
		if(!CommonUtil.hasText(info)) {
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}

		//
		Map<String, Object> argMap = new HashMap<String, Object>();
		Map<String, Object> curdata = new HashMap();


		argMap.put("phone_num",info);

		List<Map<String, Object>> channel_info = db.selectList("channel.selectItemByPhoneNum", argMap);



		if(curdata.size()<1) {
			curdata = channel_info.get(0);
		}

		//logger.error(curdata.get("channel").toString());

		String ch_no = curdata.get("channel").toString();
		String system_ip = curdata.get("system_ip").toString();
		String status = "1";

		// 서버 아이피 조회
		String server_ip = request.getServerName();


%>
<script type="text/javascript">
/*var playRlisten = function(status, ch_no, local_no, system_ip) {
	//alert(status);
	// 녹취상태일 경우만 감청 플레이어 오픈
	if(status=="1") {
		if(CNet.CheckMon("192.168.0.78")){
			//alert(parseInt(local_no));
			CNet.PlayMon(system_ip+","+parseInt(ch_no)+","+local_no);
		}
	}
};*/
var playRlisten = function(status, ch_no, local_no, system_ip) {
	// 녹취상태일 경우만 감청 플레이어 오픈
	if(status=="1") {
		if(CNet.CheckMon("<%=server_ip%>")){
			CNet.PlayMon(system_ip+","+parseInt(ch_no)+","+local_no);
		}
	}
};

</script>

	<!--감청 플레이어 OCX-->
	<object id="CNet" classid="CLSID:CA177FAA-118C-4ACB-80F5-671E66766073" width="0" height="0" codebase="../Setup/CnetLauncher.CAB#version=1,0,0,93" hidden="true"></object>
<body onload="javascript:playRlisten('<%=status%>','<%=ch_no%>','<%=info%>','<%=system_ip%>');">
</body>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
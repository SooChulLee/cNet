<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
Db db = null;
try {
	// DB Connection
	db = new Db(true);
	int obsCnt1 = db.selectOne("db_dual.getObstacleCnt", "");
	out.println("obsCnt1="+obsCnt1);
} catch(Exception e) {
	logger.error(e.getMessage());
} finally {
	if(db!=null) db.close();
}

%>
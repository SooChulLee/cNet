<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
HashMap<String, String> hEvalStatus	= new HashMap<String, String>();

out.println("hEvalStatus.isEmpty()="+hEvalStatus.isEmpty()+"<br>");

out.println("Finals.hEvalStatus.isEmpty()="+Finals.hEvalStatus.isEmpty()+"<br>");

int sum[] = new int[5];
initIntValue(sum, 1);
out.println("sum[4]="+sum[4]);




%><%!
public static void initIntValue(int[] base, int val){
	for(int i=0, len=base.length; i < len; i++) {
		base[i]=val;
	}
}
%>
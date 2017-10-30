<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
ExcelController xls = new ExcelController();
xls.toExcel(request, response, out);
System.out.println(1);
//ComLib.writeParameters(request, out);
//System.out.println(request.getQueryString());
%>
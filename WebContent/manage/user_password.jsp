<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<table>
	<tr>
		<td colspan="2">문자1 :</td>
		<td colspan="3"><input type="text" name="t1" onkeyUp="javascript:document.getElementById('name1').innerText=this.value"></td>
		<td rowpsna="3" onclick =""> 확인 </td>
	</tr>
	<tr>
		<td colspan="2">문자2 :</td>
		<td colspan="3"><input type="text" name="t2" onkeyUp="javascript:document.getElementById('name1').innerText=this.value"></td>
	</tr>
	<tr>
		<td><div id="name1">문자1</div></td>
		<td>+</td>
		<td>상담원ID</td>
		<td>+</td>
		<td><div id="name2">문자2</div></td>
	</tr>
</table>
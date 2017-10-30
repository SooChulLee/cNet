<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,org.apache.ibatis.mapping.*,org.apache.ibatis.session.*,com.cnet.crec.common.*,com.cnet.crec.mybatis.*,org.apache.ibatis.type.TypeHandler"
%><%@ include file="/common/common.jsp" %><%
Db db = new Db(true);

Map<String, Object> argMap = new HashMap<String, Object>();
argMap.put("arg","''");

String arg = "abcd";
int ins_cnt = db.insert("db_dual.test", argMap);
out.println("Insert Count="+ins_cnt+"<br>");
Configuration configuration = SqlSessionFactoryManager.getSqlSessionFactory().getConfiguration();
configuration.setUseColumnLabel(true);
configuration.setUseGeneratedKeys(true);

//MappedStatement ms = configuration.getMappedStatement("sheet.insertSheet");
//MappedStatement ms = configuration.getMappedStatement("sheet.copySheet_sheet");
//BoundSql boundSql = ms.getBoundSql(argMap);

//String login_id = "abcde";
//MappedStatement ms = configuration.getMappedStatement("login.selectCountLoginResult");
//BoundSql boundSql = ms.getBoundSql(login_id);

//실제 쿼리문은 돌리지 않고 configuration을 구했기 때문에 XML내부에서 구해진 바인드변수가 구해지지 않는것임
//쿼리문 돌리고 configuration을 구하면 바인드변수가 구해짐
MappedStatement ms = configuration.getMappedStatement("db_dual.test");
BoundSql boundSql = ms.getBoundSql(argMap);

String sql = boundSql.getSql();

List<ParameterMapping> boundParams = boundSql.getParameterMappings();
String paramStr="";
Object obj = boundSql.getParameterObject();
if(obj instanceof Map){
	out.println("Map");
	Map<String, Object> params = (Map<String, Object>) boundSql.getParameterObject();

	String value = "";
	for(ParameterMapping param : boundParams) {
		value = ComLib.toNN(params.get(param.getProperty())).replaceAll("'","''");
		out.println("<br>"+param.getProperty()+"="+value);

	//	out.println(" , param.getExpression()="+boundSql.);

		sql = sql.replaceFirst("\\?", "'" + value + "'");
		paramStr += boundSql.getAdditionalParameter(param.getProperty()) + ";";
	}
}
else{
	sql = sql.replaceFirst("\\?", "'" + obj + "'");
	out.println("String");
	//paramStr += boundSql.getAdditionalParameter("sheet_code");
}
out.println("<br>sql="+sql);
out.println("<br>params="+paramStr);
%>
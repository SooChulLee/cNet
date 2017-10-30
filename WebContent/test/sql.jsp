<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,org.apache.ibatis.mapping.*,org.apache.ibatis.session.*,com.cnet.crec.common.*,com.cnet.crec.mybatis.*,org.apache.ibatis.type.TypeHandler"
%><%
Configuration configuration = SqlSessionFactoryManager.getSqlSessionFactory().getConfiguration();

Map<String, Object> argMap = new HashMap<String, Object>();
argMap.put("sheet_name","1");
argMap.put("item_cnt",2);
argMap.put("tot_score",3);
argMap.put("add_score",4);
argMap.put("sheet_etc","6");
argMap.put("use_yn","y");
argMap.put("regi_ip","8");
argMap.put("regi_id","9");

configuration.setUseColumnLabel(true);
configuration.setUseGeneratedKeys(true);
MappedStatement ms = configuration.getMappedStatement("sheet.insertSheet");
BoundSql boundSql = ms.getBoundSql(argMap);
String sql = boundSql.getSql();
out.println(sql);

List<ParameterMapping> boundParams = boundSql.getParameterMappings();
Map<String, Object> params = (Map<String, Object>) boundSql.getParameterObject();

String value = "", paramStr="";
for(ParameterMapping param : boundParams) {
	value = ComLib.toNN(params.get(param.getProperty()));
	out.println("<br>"+param.getProperty()+"="+value);

//	out.println(" , param.getExpression()="+boundSql.);

	sql = sql.replaceFirst("\\?", "'" + value + "'");
	paramStr += boundSql.getAdditionalParameter(param.getProperty()) + ";";
}

out.println("<br>sql="+sql);
out.println("<br>params="+paramStr);
%>
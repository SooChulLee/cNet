package com.cnet.crec.common;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.mapping.ParameterMapping;
import org.apache.ibatis.session.Configuration;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.type.TypeHandler;

import com.cnet.crec.mybatis.SqlSessionFactoryManager;

public class Test {
	public static void main(String[] args) throws Exception {
		SqlSessionFactory sessionFactory = SqlSessionFactoryManager.getSqlSessionFactory();
		Configuration configuration = sessionFactory.getConfiguration();

		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("sheet_name","1");
		argMap.put("item_cnt",2);
		argMap.put("tot_score",3);
		argMap.put("add_score",4);
		argMap.put("sheet_etc","6");
		argMap.put("use_yn","y");
		argMap.put("regi_ip","8");
		argMap.put("regi_id","9");

		MappedStatement ms = configuration.getMappedStatement("sheet.insertSheet");
		BoundSql boundSql = ms.getBoundSql(argMap);
		String sql = boundSql.getSql();
		System.out.println(sql);

		List<ParameterMapping> boundParams = boundSql.getParameterMappings();
		System.out.println("<br>boundParams.size()="+boundParams.size());
		String value = "", sqlValue="", params="";
		for(ParameterMapping param : boundParams) {
			System.out.println("<br>name="+param.getProperty()+" , ");
			System.out.println("value="+boundSql.getAdditionalParameter(param.getProperty()));
			System.out.println("<br>"+param);
			//value = param.getProperty().toString();
			TypeHandler typeHandler = param.getTypeHandler();
			
			sql = sql.replaceFirst("\\?", "'" + value + "'");
			params += boundSql.getAdditionalParameter(param.getProperty()) + ";";
		}
		
	}
}

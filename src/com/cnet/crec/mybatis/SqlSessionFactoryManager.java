package com.cnet.crec.mybatis;

import java.io.Reader;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

import com.cnet.crec.common.Finals;

public class SqlSessionFactoryManager {
	
	private final static String RESOURCE = "mybatis-config.xml";
	private static SqlSessionFactory FACTORY = null;
	private static SqlSessionFactory FACTORY_BAK = null;

	static {
		Reader reader;
		try {
			reader = Resources.getResourceAsReader(RESOURCE);
			FACTORY = new SqlSessionFactoryBuilder().build(reader, "crec");
			
		} catch (Exception e) {
			//e.printStackTrace();
			//throw new RuntimeException("SqlSessionFactoryManager Fatal Error : " + e, e);
		}		
			
		try {
			// 백업DB가 존재하면 가져온다
			reader = Resources.getResourceAsReader(RESOURCE);
			FACTORY_BAK = (Finals.isExistBackupServer) ? new SqlSessionFactoryBuilder().build(reader, "crec_bak") : null;
		} catch (Exception e) {
			//e.printStackTrace();
			//throw new RuntimeException("SqlSessionFactoryManager Fatal Error : " + e, e);
		}		
	}
	
	public static SqlSessionFactory getSqlSessionFactory() {
		if(FACTORY == null) {
			try {
				Reader reader = Resources.getResourceAsReader(RESOURCE);
				FACTORY = new SqlSessionFactoryBuilder().build(reader, "crec");
			} catch (Exception e) {}
			
		}
		return FACTORY;
	}
	
	public static SqlSessionFactory getSqlSessionFactoryBak() {
		if(Finals.isExistBackupServer && FACTORY_BAK == null) {
			try {
				Reader reader = Resources.getResourceAsReader(RESOURCE);
				FACTORY_BAK = new SqlSessionFactoryBuilder().build(reader, "crec_bak");
			} catch (Exception e) {}
			
		}
		return FACTORY_BAK;	
	}
	
	//DB SqlSession 리턴
	public static SqlSession getSqlSession() {
		try {
			return FACTORY.openSession();
		} catch (Exception e) {
			return null;
		}
	}
	public static SqlSession getSqlSession(boolean arg) {
		try {
			return FACTORY.openSession(arg);
		} catch (Exception e) {
			return null;
		}
	}
	
	//백업DB SqlSession 리턴
	public static SqlSession getSqlSessionBak() {
		try {
			return FACTORY_BAK.openSession();
		} catch (Exception e) {
			return null;
		}
	}		
	public static SqlSession getSqlSessionBak(boolean arg) {
		try {
			return FACTORY_BAK.openSession(arg);
		} catch (Exception e) {
			return null;
		}
	}
}

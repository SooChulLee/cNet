package com.cnet.crec.common;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.mapping.ParameterMapping;
import org.apache.ibatis.session.Configuration;
import org.apache.ibatis.session.SqlSession;
import org.apache.log4j.Logger;

import com.cnet.crec.mybatis.SqlSessionFactoryManager;

public class Db {
	//운영DB 장애여부
	private static boolean isLiveDb1 = true;
	private static boolean isLiveDb1_prev = isLiveDb1;
	//백업DB 장애여부
	private static boolean isLiveDb2 = (Finals.isExistBackupServer);
	private static boolean isLiveDb2_prev = isLiveDb2;
	//운영DB 장애건수
	private static int obsDbCnt1 = 0;
	//백업DB 장애건수
	private static int obsDbCnt2 = 0;
	//운영DB 장애Log 건수
	private static int obsLogCnt1 = 0;
	//백업DB 장애Log 건수
	private static int obsLogCnt2 = 0;
	//서비스 시작 후 맨최초 장애시에는 서비스시작시 FACTORY를 구했으므로 다시 구하지 않기 위함 
	//최초 웹서버 시작시 DB가 장애가 있는 경우 연속으로 2번 구하기 위해 시간 소비하는것을 제거하기 위함
	private static boolean isFirstObs = true;

	private static final Logger logger = Logger.getLogger(Db.class);
	
	//현재사용세션
	//운영DB가 죽었다가 살아나도, 백업DB에 남아 있는 운영DB 장애정보가 모두 처리되지 않으면 백업DB로 계속 붙게 만든다.
	private SqlSession ss0 = null;
	//운영세션
	private SqlSession ss1 = null;
	//백업세션
	private SqlSession ss2 = null;
	//두 DB가 살아 있고 운영DB로 붙는 경우(백업DB의 장애로그 테이블에 미처리가 없는 경우<-운영DB 장애시 적재 되는데 프로시저에서 장애정보 모두 처리 된 경우)
	private boolean isAllDualDbStatusOk = false;

	public Db() throws Exception {
		//운영DB 체크시 에러 여부
		setSS1();
		setSS2();
		setDbLive();
	}
	public Db(boolean arg) throws Exception {
		setSS1(arg);
		setSS2(arg);
		setDbLive();
	}
	private void setDbLive() throws Exception {
		boolean isChkedLiveDb1 = false;

		if(Finals.isExistBackupServer) {
			if(!isLiveDb1 && !isLiveDb2) {isLiveDb1=true;isLiveDb2=true;};
			if(isLiveDb1) {
				isChkedLiveDb1 = true;
				try {
					// ss1이 null이 아닌데도 접속실패가 있음
					//양쪽 DB 장애 미처리 유무 체크 (장애 발생시 반대 DB에 장애정보 입력 하므로 아래처럼 DB를 반대로 접속함)
					obsLogCnt2 = ss1.selectOne("db_dual.getObstacleLogCnt");
					if(!isLiveDb2) {
						obsDbCnt2 = ss1.selectOne("db_dual.getObstacleDbCnt");
						if(obsDbCnt2==0 && ss2==null) {
							//DB IP 가 처음부터 죽어 있는 경우 해당함
							//재접속 프로세스를 여기에 구현
							if(isFirstObs) isFirstObs=false;
							else {
								SqlSessionFactoryManager.getSqlSessionFactoryBak();
								setSS2();
							}
						}
						isLiveDb2 = (ss2!=null && obsDbCnt2==0);
					}
				}
				catch(Exception e) {
					isLiveDb1=false;
				}
			}
			if(isLiveDb2) {
				try {
					obsLogCnt1 = ss2.selectOne("db_dual.getObstacleLogCnt");
					//System.out.println("DB obsLogCnt1 = "+ obsLogCnt1);
					if(!isLiveDb1 && !isChkedLiveDb1) {
						obsDbCnt1 = ss2.selectOne("db_dual.getObstacleDbCnt");
						//System.out.println("DB obsDbCnt = "+ obsDbCnt1);
						if(obsDbCnt1==0) {
							try {
								if(ss1==null) {
									//DB IP 가 웹서버 스타팅시 처음부터 죽어 있는 경우 해당함
									//재접속 프로세스를 여기에 구현
									if(isFirstObs) isFirstObs=false;
									else {
										SqlSessionFactoryManager.getSqlSessionFactory();
										setSS1();
									}
								}
								if(ss1!=null) {
									obsLogCnt2 = ss1.selectOne("db_dual.getObstacleLogCnt");
								}
							}
							catch(Exception e) {
								isLiveDb1=false;
							}
						}
						isLiveDb1 = (ss1!=null && obsDbCnt1==0);
					}
				}
				catch(Exception e) {
					isLiveDb2=false;
				}
			}
			//운영DB가 살아 있다가 죽고 백업DB가 살아 있으면, 백업DB쪽에 운영DB는 죽었다고 표기한다.
			//하기 기능은 db procedure 인 sp_sync_obstacle 에서도 처리한다.
			if(isLiveDb1_prev && !isLiveDb1 && isLiveDb2) {
				Map<String, Object> arg = new HashMap<String, Object>();
				arg.put("db_raise_time", ComLib.getDateStr("yyyy-MM-dd HH:mm:ss.SSS"));
				ss2.insert("db_dual.insertObstacleDb",arg);
			}
			//백업DB가 살아 있다가 죽고 운영DB가 살아 있으면, 운영DB쪽에 백업DB는 죽었다고 표기한다. 
			//하기 기능은 db procedure 인 sp_sync_obstacle 에서도 처리한다.
			if(isLiveDb2_prev && !isLiveDb2 && isLiveDb1) {
				Map<String, Object> arg = new HashMap<String, Object>();
				arg.put("db_raise_time", ComLib.getDateStr("yyyy-MM-dd HH:mm:ss.SSS"));
				ss1.insert("db_dual.insertObstacleDb",arg);
			}
			isLiveDb1_prev = isLiveDb1;
			isLiveDb2_prev = isLiveDb2;
			
			if(!isLiveDb1 && !isLiveDb2) throw new Exception("DB Connection failed !!");
			else ss0 = getCurrentSqlSession();

			isAllDualDbStatusOk = (ss0.equals(ss1) && isLiveDb2);
		}
		else {
			if(!isLiveDb1) throw new Exception("DB Connection failed !!");
			else ss0 = ss1;
		}
		showDbInfo();
	}
	
	//ssl==null : 최초 웹서버 구동시 부터 DB가 죽어 있는 경우
	//ssl!=null && 접속 안됨 : 최초 웹서버 구동시에는 DB가 살아 있다가 추후 죽는 경우
	private void setSS1() {
		try {ss1 = SqlSessionFactoryManager.getSqlSession();	if(ss1==null) isLiveDb1=false;} catch(Exception e) {isLiveDb1=false;ss1=null;}
	}
	private void setSS1(boolean arg) {
		try {ss1 = SqlSessionFactoryManager.getSqlSession(arg);	if(ss1==null) isLiveDb1=false;} catch(Exception e) {isLiveDb1=false;ss1=null;}
	}
	private void setSS2() {
		try {ss2 = SqlSessionFactoryManager.getSqlSessionBak();	if(ss2==null) isLiveDb2=false;} catch(Exception e) {isLiveDb2=false;ss2=null;}
	}
	private void setSS2(boolean arg) {
		try {ss2 = SqlSessionFactoryManager.getSqlSessionBak(arg);	if(ss2==null) isLiveDb2=false;} catch(Exception e) {isLiveDb2=false;ss2=null;}
	}
	
	//현재 접속해야 하는 DB 세션 리턴
	//장애정보가 남아 있는 경우, 웹서버 재시작 하면 obsLogCnt1, obsLogCnt2 가 0으로 초기화 되기 때문에 obsLogCnt 조회시 실패하면 0으로 남아 있기 때문에 DB에 붙는다. (문제발생 소지가 있음)
	//바로 위 정보를 막게 되면 한쪽DB가 장애가 일어 난 경우, 웹서버가 재시작 하게 되면 다른쪽 DB의 장애정보를 체크 할 수 없어서 어쩔 수가 없다.
	public SqlSession getCurrentSqlSession() throws Exception {
		//둘다 살아 있는 경우
		if(isLiveDb1 && isLiveDb2){
			if		(obsLogCnt1==0) return ss1; //운영DB의 장애 미처리건이 백업DB에 없으면 운영DB 리턴
			else if	(obsLogCnt2==0) return ss2 ;//운영DB의 장애 미처리건이 백업DB에 남아 있으면 백업DB 리턴
			//둘다 장애 미처리 건이 남아 있으면 동기화 실패 리턴
			//나중에 여기다 양쪽 장애건 동기화 처리프로시저 호출 삽입
			else throw new Exception("(1) DB Synchronize failed !!");
		}
		//운영만 살아 있는 경우
		else if(isLiveDb1 && !isLiveDb2){
			//이전 운영DB 미처리 장애정보가 없는 경우 운영DB로 붙는다.
			if(obsLogCnt1==0) return ss1;
			//이전 백업DB에 운용DB 장애정보가 미처리로 남아 있는 경우
			else throw new Exception("(2) DB Synchronize failed !!");
		}
		//백업만 살아 있는 경우
		else if(!isLiveDb1 && isLiveDb2){
			//이전 장애DB 미처리 장애정보가 없는 경우 운영DB로 붙는다.
			if(obsLogCnt2==0) return ss2;
			else throw new Exception("(3) DB Synchronize failed !!");
		}
		//둘다 죽음
		else {
			throw new Exception("DB Connection failed !!");
		}
	}

	public <E> List<E> selectList(String queryId) {
		return ss0.selectList(queryId);
	}

	public <E> List<E> selectList(String queryId, Object arg) {
		return ss0.selectList(queryId, arg);
	}

	public <T> T selectOne(String queryId) {
		return ss0.selectOne(queryId);
	}

	public <T> T selectOne(String queryId, Object arg) {
		return ss0.selectOne(queryId, arg);
	}

	public int insert(String queryId, Object arg) throws Exception {
		int cnt = ss0.insert(queryId, arg);
		if(isAllDualDbStatusOk) {
			int cnt2 = ss2.insert(queryId, arg);
			if(cnt!=cnt2) raiseError("Insert DB synchronization failed !!", cnt, cnt2, queryId, arg);
		}
		else setObstacleInfo(queryId,arg);
		return cnt;
	}

	public int update(String queryId, Object arg) throws Exception {
		int cnt = ss0.update(queryId, arg);
		if(isAllDualDbStatusOk) {
			int cnt2 = ss2.update(queryId, arg);
			if(cnt!=cnt2) raiseError("Update DB synchronization failed !!", cnt, cnt2, queryId, arg);
		}
		else setObstacleInfo(queryId,arg);
		return cnt;
	}

	public int delete(String queryId, Object arg) throws Exception {
		int cnt = ss0.delete(queryId, arg);
		if(isAllDualDbStatusOk) {
			int cnt2 = ss2.delete(queryId, arg);
			if(cnt!=cnt2) raiseError("Delete DB synchronization failed !!", cnt, cnt2, queryId, arg);
		}
		else setObstacleInfo(queryId,arg);
		return cnt;
	}

	@SuppressWarnings("unchecked")
	// 장애쿼리 저장
	private void setObstacleInfo(String queryId, Object paramObj) {
		//if(Finals.isExistBackupServer && !isAllDualDbStatusOk) {
		if(Finals.isExistBackupServer) {
			Configuration configuration = (ss0.equals(ss1)) ? SqlSessionFactoryManager.getSqlSessionFactory().getConfiguration() : SqlSessionFactoryManager.getSqlSessionFactoryBak().getConfiguration();

			MappedStatement ms = configuration.getMappedStatement(queryId);
			BoundSql boundSql = ms.getBoundSql(paramObj);

			String sql = boundSql.getSql();
			//System.out.println("Db.setObstacleInfo.sql="+sql);
			if (paramObj instanceof Map) {
				List<ParameterMapping> boundParamList = boundSql.getParameterMappings();
				//Map<String, Object> paramMap = (Map<String, Object>) boundSql.getParameterObject();//아래와 같음
				Map<String, Object> paramMap = (Map<String, Object>) paramObj;

				for(ParameterMapping param : boundParamList) {
					sql = sql.replaceFirst("\\?", "'" + ComLib.toNN(paramMap.get(param.getProperty())).replaceAll("'", "''") + "'");
					//System.out.println(param.getProperty(+"="+paramMap.get(param.getProperty()));
				}
			}
			else {
				sql = sql.replaceFirst("\\?", "'" + ComLib.toNN(paramObj).replaceAll("'", "''") + "'");
			}

			//실행된 쿼리문을 장애로그 테이블(tbl_obstacle) 에 저장
			Map<String, Object> arg = new HashMap<String, Object>();
			//장애시간을 웹서버 시간으로 입력
			arg.put("raise_time", ComLib.getDateStr("yyyy-MM-dd HH:mm:ss.SSS"));
			arg.put("sql", sql);
			ss0.insert("db_dual.insertObstacleLog",arg);
		}
	}
	//에러 발생시 DB 롤백하고 로그 남기고 에러 리턴
	public void raiseError(String msg, int cnt1, int cnt2, String queryId, Object arg) throws Exception {
		rollback();
		//여기에 로그 남기는 기능 만들기
		throw new Exception(msg + " ("+cnt1+":"+cnt2+") :: queryId=" + queryId + " , arg=" + arg);
	}
	public void commit(){
		if(isLiveDb1 && ss1!=null) ss1.commit();
		if(isLiveDb2 && ss2!=null) ss2.commit();
	}
	public void rollback() {
		if(isLiveDb1 && ss1!=null) ss1.rollback();
		if(isLiveDb2 && ss2!=null) ss2.rollback();
	}
	public void close() {
		if(isLiveDb1 && ss1!=null) {ss1.commit();ss1.close();}
		if(isLiveDb2 && ss2!=null) {ss2.commit();ss2.close();}
	}

	private void showDbInfo() {
		if(Finals.isDev) {
			System.out.println(
				"\n-- DB Info --------------------------------"+
				"\nisLiveDb1 ="+isLiveDb1 +" , isLiveDb2 ="+isLiveDb2+
				"\nobsDbCnt1 ="+obsDbCnt1 +" , obsDbCnt2 ="+obsDbCnt2+
				"\nobsLogCnt1="+obsLogCnt1+" , obsLogCnt2="+obsLogCnt2+
				"\nss1="+ss1+" , ss2="+ss2+
				"\nss0="+((ss0.equals(ss1) ? "ss1" : "ss2"))+
				"\nisAllDualDbStatusOk="+isAllDualDbStatusOk+
				"\n-------------------------------------------"
			);
		}
		else if(!isAllDualDbStatusOk) {
			logger.info(
				"DB Info "+
				":: isLiveDb1 ="+isLiveDb1 +" , isLiveDb2 ="+isLiveDb2+
				" / obsDbCnt1 ="+obsDbCnt1 +" , obsDbCnt2 ="+obsDbCnt2+
				" / obsLogCnt1="+obsLogCnt1+" , obsLogCnt2="+obsLogCnt2+
				" / ss1="+ss1+" , ss2="+ss2+
				" / ss0="+((ss0.equals(ss1) ? "ss1" : "ss2"))+
				" / isAllDualDbStatusOk="+isAllDualDbStatusOk
			);
		}
	}
}

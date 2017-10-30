package com.cnet.crec.common;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.JspWriter;

import org.apache.ibatis.session.SqlSession;

import com.cnet.crec.util.CommonUtil;
import com.cnet.crec.util.DateUtil;

//현재사이트에서만 사용되는 공통모듈
public class Site {
	// 현재 권한코드별 볼 수 있는 조직 Depth 리턴 
	public static int getDepthByUserLevel(Object userLevel) {
		return 	(userLevel.equals("0")) ? 9 : //시스템 관리자
				(userLevel.equals("A")) ? 3 : //관리자	: 대분류 전체
				(userLevel.equals("B")) ? 2 : //센터장 	: 중분류 전체
				(userLevel.equals("C")) ? 1 : //팀장 	: 소분류 전체
				(userLevel.equals("D")) ? 0 : //조장		: 소분류 하나 : 자신이 속한 소분류만
				-1;							  //상담원	: 소분류 하나 : 자신이 속한 소분류만
	}

	//평가자 여부
	public static boolean isEvaluator(HttpServletRequest request) {
		return ComLib.getSessionValue(request, "eval_yn").equals("y");
	}

	//S : 이벤트 콤보박스 ---------------------------------------------------------------------------------------------------------
	public static String getEventComboHtml(String event_status) throws Exception {
		return getEventComboSelHtml(event_status, "", null);
	}
	public static String getEventComboHtml(String event_status, String addValName) throws Exception {
		return getEventComboSelHtml(event_status, addValName, null);
	}
	public static String getEventComboSelHtml(String event_status, String selValue) throws Exception {
		return getEventComboSelHtml(event_status, "", selValue);
	}
	public static String getEventComboSelHtml(String event_status, String addValName, String selValue) throws Exception {
		Db db = null;
		String htmResult = "";
		try {
			db = new Db(true);
			Map<String, String> argMap = new HashMap<String, String>();
			argMap.put("event_status", event_status);
			if(event_status.equals("2")){
				//진행중인 경우 이벤트 유효기간 까지 비교
				argMap.put("event_date", DateUtil.getToday("yyyyMMdd"));
			}
			List<Map<String, Object>> list = db.selectList("event.selectCodeList", argMap);
			String optVal="";
			for(Map<String, Object> item : list) {
				optVal = (addValName.equals("")) ? item.get("event_code").toString() : item.get("event_code") + "/" + ComLib.toNN(item.get(addValName));
				htmResult += "<option value='"+optVal+"' "+((item.get("event_code").equals(selValue)) ? "selected" : "")+">"+item.get("event_name")+"</option>";
			}

		} catch(Exception e) {
			htmResult = e.toString();
			System.out.println(htmResult);
		} finally {
			if(db!=null) db.close();
		}
		return htmResult;
	}
	//E : 이벤트 콤보박스 ---------------------------------------------------------------------------------------------------------

	//평가자 콤보박스
	public static String getEvaluatorComboHtml(HttpSession sess, boolean isAll) throws Exception {
		Db db = null;
		String htmResult = "";
		try {
			db = new Db(true);
			Map<String, Object> argMap = new HashMap<String, Object>();
			argMap.put("business_code", sess.getAttribute("login_business_code"));
			argMap.put("_user_id", sess.getAttribute("login_id"));
			if(!isAll) argMap.put("_user_level", sess.getAttribute("login_level"));

			List<Map<String, Object>> list = db.selectList("user.selectEvalListCombo", argMap);
	
			if(list!=null) {
				for(Map<String, Object> item : list) {
					htmResult += "<option value='"+item.get("user_id")+"'>"+item.get("user_name")+"</option>";
				}
			}
		} catch(Exception e) {
			htmResult = e.toString();
			System.out.println(htmResult);
		} finally {
			if(db!=null) db.close();
		}
		return htmResult;
	}

	//내 조직도 콤보박스 (맨처음 호출됨)
	public static String getMyPartCodeComboHtml(HttpSession sess, int part_depth) throws Exception{
		int depthByUserLevel = getDepthByUserLevel(sess.getAttribute("login_level"));
		
		if(part_depth==2 && depthByUserLevel>=3) {
			return "<option value=''>중분류</option>";
		}
		else if(part_depth==3 && depthByUserLevel>=2) {
			return "<option value=''>소분류</option>";
		}
		
		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("_user_level", sess.getAttribute("login_level"));
		argMap.put("business_code", sess.getAttribute("login_business_code"));
		argMap.put("bpart_code", sess.getAttribute("login_bpart"));
		argMap.put("mpart_code", sess.getAttribute("login_mpart"));
		argMap.put("spart_code", sess.getAttribute("login_spart"));
		argMap.put("part_depth", part_depth);
		argMap.put("firstStr", ((part_depth==1) ? "대분류" : (part_depth==2) ? "중분류" : "소분류"));
		return getPartCodeComboHtml(argMap);
	}
	
	//조직도 콤보박스
	public static String getPartCodeComboHtml(Map<String, Object> m) throws Exception{
		Db db = null;
		String htmResult = "";
		try {
			db = new Db(true);
			List<Map<String, Object>> list = db.selectList("user_group.selectPartCode", m);

			if(list!=null) {
				String selected = "";
				for(Map<String, Object> item : list) {
					selected = (item.get("part_code").equals(m.get("selVal"))) ? "selected" : "";
					htmResult += "<option value='"+item.get("part_code")+"' "+selected+">"+item.get("part_name")+"</option>";
				}
			}
			if(list.size()>1 && m.get("firstStr") != null) {
				String selected = (ComLib.toNN(m.get("selVal")).equals("")) ? "selected" : "";
				htmResult = "<option value='' "+selected+">"+m.get("firstStr")+"</option>"+htmResult;
			}
		} catch(Exception e) {
			htmResult = e.toString();
			System.out.println(htmResult);
		} finally {
			if(db!=null) db.close();
		}
		return htmResult;
	}

	// 시트 목록 조회
	public static String getSheetComboHtml(Map<String, Object> m) throws Exception{
		Db db = null;
		String htmResult = "";
		try {
			db = new Db(true);
			List<Map<String, Object>> list = db.selectList("sheet.selectCodeList", m);

			if(list!=null) {
				String selected = "";
				for(Map<String, Object> item : list) {
					selected = (item.get("sheet_code").equals(m.get("selVal"))) ? "selected" : "";
					htmResult += "<option value='"+item.get("sheet_code")+"' "+selected+">"+item.get("sheet_name")+"</option>";
				}
			}
			if(list.size()>1 && m.get("firstStr") != null) {
				String selected = (ComLib.toNN(m.get("selVal")).equals("")) ? "selected" : "";
				htmResult = "<option value='' "+selected+">"+m.get("firstStr")+"</option>"+htmResult;
			}
		} catch(Exception e) {
			htmResult = e.toString();
			System.out.println(htmResult);
		} finally {
			if(db!=null) db.close();
		}
		return htmResult;
	}

	//성공 실패 Json 메시지
	public static void writeJsonResult(JspWriter out, boolean isSuccess) throws Exception {
		out.println(getJsonResult(isSuccess,""));
	}
	public static void writeJsonResult(JspWriter out, Exception e) throws Exception {
		String errMsg = ComLib.cvtToAjaxAlertValue(e.getMessage());
		out.println(getJsonResult(false,errMsg));
	}
	public static void writeJsonResult(JspWriter out, boolean isSuccess, Object msg) throws Exception {
		out.println(getJsonResult(isSuccess,msg));
	}
	public static String getJsonResult(boolean isSuccess, Object msg) {
		String code = (isSuccess) ? "OK" : "ERR";
		return "{\"code\":\""+code+"\", \"msg\":\""+ComLib.toNN(msg)+"\"}";
	}
	public static void dbClose(Object ... args) throws Exception{
		for(Object arg : args){
			if(arg==null){}
			else if (arg instanceof SqlSession){
				SqlSession ssn = (SqlSession) arg;
				ssn.commit();
				ssn.close();
			}
			else if (arg instanceof Connection){
				Connection con = (Connection) arg;
				con.setAutoCommit(true);
				con.commit();
				con.close();
			}
			else if (arg instanceof PreparedStatement)	((PreparedStatement)arg).close();
			else if (arg instanceof CallableStatement)	((CallableStatement)arg).close();
			else if (arg instanceof ResultSet)			((ResultSet)arg).close();
		}
	}
	
	//권한체크
	public static boolean isPmss(JspWriter out, String menuName) throws Exception{
		return isPmss(out, menuName, "");
	}
	public static boolean isPmss(JspWriter out, String menuName, String type) throws Exception{
		String _check_login = CommonUtil.checkLogin(menuName,type);
		if(CommonUtil.hasText(_check_login)) {
			out.print(_check_login);
			return false;
		}
		return true;
	}
	
	//엑셀 헤더
	public static void setExcelHeader(HttpServletResponse response, JspWriter out, String fileName) throws Exception{
		response.reset();
		response.setHeader("Content-type","application/vnd.ms-excel; charset=euc_kr");
		response.setHeader("Content-Description","Generated By CNetTechnology");
		response.setHeader("Content-Disposition","attachment; filename = " + java.net.URLEncoder.encode(fileName+"_"+DateUtil.getToday("yyyy-MM-dd")+""+".xls", "UTF-8"));
		out.println(
			"<meta http-equiv='Content-Type' content='application/vnd.ms-excel;charset=euc-kr'>"+
			"<style>"+
				"body, td, th, div {font-size:12px}"+
				".th {background-color:#DCE4E9;font-weight:lighter}"+
				".subSum {background-color:#EEEEEE;text-align:right}"+
				".sum {background-color:#DDDDDD;text-align:right}"+
				".l {text-align:left}"+
				".r {text-align:right}"+
				".c {text-align:center}"+
			"</style>"
		);
	}
}

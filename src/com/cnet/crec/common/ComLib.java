package com.cnet.crec.common;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.StringTokenizer;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.JspWriter;

public class ComLib {

	public ComLib()	{}

	// sBase에서 sFrom의 문자열을 찾아 sTo 문자로 바꾸어 리턴
	public static String replaceStr(String sBase, String sFrom, String sTo) {
		String sRtn="";
		int bLen = sBase.length();
		int fLen = sFrom.length();
		int from = 0;
		while(true)
		{
			int pos=sBase.indexOf(sFrom,from);
			if(pos<0) {
				sRtn = sRtn + sBase.substring(from);
				break;
			}
			sRtn = sRtn + sBase.substring(from,pos);
			sRtn = sRtn +  sTo;
			from = pos+fLen;
			if(from>=bLen) break;
		}

		return sRtn;
	}

	public static boolean equal(Object from,Object to){
		if(from==null && to==null) return true;
		else if(from!=null && to!=null){
			if(from.equals(to)) return true;
			else return false;
		}
		else return false;
	}

	// 문자열을 type형식으로 Encoding..
	public static String toEncByType(Object obj, String type) {
		if(obj==null) return null;
		String sRtn = null;
		try {
			sRtn = new String(obj.toString().getBytes("8859_1"), type);
		}catch (java.io.UnsupportedEncodingException e){
			sRtn = obj.toString();
		}
		return  sRtn;
	}

	public static String rTrim(String str){
		char[] val = str.toCharArray();
		int idx = 0;
		int len = str.length();
		while (idx < len && val[len-1] <= ' '){
			len--;
		}
		return str.substring(0, len);
	}
	public static String lTrim(String str){
		char[] val = str.toCharArray();
		int idx  = 0;
		int len = str.length();
		while (idx < len && val[idx] <= ' '){
			idx++;
		}
		return str.substring(idx, len);
	}
	//int 배열 초기화
	public static void initIntArray(int[] base, int val){
		for(int i=0, len=base.length; i < len; i++) {
			base[i]=val;
		}
	}
	//초기화 한 int 배열 리턴
	public static int[] makeIntArray(int len, int val){
		int[] base = new int[len];
		initIntArray(base, val);
		return base;
	}

	//String 배열 초기화
	public static void initStringArray(String[] base, String val){
		for(int i=0, len=base.length; i < len; i++) {
			base[i]=val;
		}
	}
	//초기화 한 String 배열 리턴
	public static String[] makeStringArray(int len, String val){
		String[] base = new String[len];
		initStringArray(base, val);
		return base;
	}

	//반올림 : 분자 / 분모 / 보여줄 소숫점 수
	public static String calcRound(Object upVal, Object downVal, int showLimit) {
		return ComLib.round(Double.parseDouble(upVal.toString())/Double.parseDouble(downVal.toString()),showLimit);
	}
	//반올림
	public static String round(double nCalcVal, int nDigit) {
		if(nDigit < 0) {
			nDigit = -(nDigit);
			nCalcVal = Math.round(nCalcVal / Math.pow(10, nDigit)) * Math.pow(10, nDigit);
		} else {
			nCalcVal = Math.round(nCalcVal * Math.pow(10, nDigit)) / Math.pow(10, nDigit);
		}
		return (nCalcVal%1==0) ? Integer.toString((int) nCalcVal) : String.valueOf(nCalcVal);
	}
	public static String ceil(double nCalcVal, int nDigit) {
		if(nDigit < 0) {
			nDigit = -(nDigit);
			nCalcVal = Math.ceil(nCalcVal / Math.pow(10, nDigit)) * Math.pow(10, nDigit);
		} else {
			nCalcVal = Math.ceil(nCalcVal * Math.pow(10, nDigit)) / Math.pow(10, nDigit);
		}
		return (nCalcVal%1==0) ? Integer.toString((int) nCalcVal) : String.valueOf(nCalcVal);
	}
	public static String floor(double nCalcVal, int nDigit) {
		if(nDigit < 0) {
			nDigit = -(nDigit);
			nCalcVal = Math.floor(nCalcVal / Math.pow(10, nDigit)) * Math.pow(10, nDigit);
		} else {
			nCalcVal = Math.floor(nCalcVal * Math.pow(10, nDigit)) / Math.pow(10, nDigit);
		}
		return (nCalcVal%1==0) ? Integer.toString((int) nCalcVal) : String.valueOf(nCalcVal);
	}

	public static boolean in(Object baseStr, Object ... inStrs){
		for(Object inStr : inStrs){if(baseStr.equals(inStr)) return true;}
		return false;
	}
	public static boolean in(Object baseStr, String[] inStrs){
		for(String inStr : inStrs){if(baseStr.equals(inStr)) return true;}
		return false;
	}

	// 문자열이 null이면 "" or 0 으로 바꿈. nullPointException Error를 위함...
	public static String toNNHtm(Object obj) {
		return toNN(obj,"&nbsp;");
	}
	public static String nullToDash(Object obj) {
		return toNN(obj,"<font class=fNot>-</font>");
	}

	//toNotNull
	public static String toNN(Object obj) {
		return toNN(obj,"");
	}
	public static String toNN(Object obj, Object nullTo) {
		try{return (obj==null || obj.equals("")) ? nullTo.toString() : obj.toString();}
		catch(Exception e){return "";}
	}

	//toIntNotNull
	public static int toINN(Object obj) {
		return toINN(obj,0);
	}
	public static int toINN(Object obj, int toInt) {
		return Integer.parseInt(toNN(obj,toInt));
	}

	public static String nvl2(Object baseStr, Object notNullTo, Object nullTo) {
		Object oRtn = (baseStr==null || baseStr.equals("")) ? nullTo : notNullTo;
		return (oRtn==null) ? null : oRtn.toString();
	}
	public static String strTo(Object baseStr, Object fromStr, Object nullTo) {
		if(baseStr==null) return null;
		if(baseStr.toString().equals(fromStr.toString())) return nullTo.toString();
		else return baseStr.toString();
	}

	// ----------------------------------------------------------

	// 스크립트에서 Alert 띄우기 위함
	public static String cvtToAjaxAlertValue(String baseStr){
		if (baseStr==null) return "";
		String returnStr = baseStr;
		returnStr = replaceStr(returnStr,"\r","");
		returnStr = replaceStr(returnStr,"\n","\\n");
		return returnStr;
	}

	//input type=text 의 value에 바로 값을 입력 할 때	: out.println("<input type=text value='"+c.cvtToTextValue(rs.getString("cux_address"))+"'");
	//HTML Title에 변수가 사용 될 때				: out.println("<td title='"+c.cvtToTextValue(rs.getString("sc_name"))+"'>");
	public static String cvtToTextValue(String baseStr){
		if (baseStr==null) return "";
		String returnStr = baseStr;
		returnStr = replaceStr(returnStr,"\"","&#34;");
		returnStr = replaceStr(returnStr,"\'","&#39;");
		return returnStr;
	}

	// 스크립트 안에서 값을 지정할때
	public static String cvtToScriptValue(String baseStr){
		if (baseStr==null) return "";
		String returnStr = baseStr;
		returnStr = replaceStr(returnStr,"\\","\\\\");
		returnStr = replaceStr(returnStr,"\"","\\\"");
		returnStr = replaceStr(returnStr,"'","\\'");
		returnStr = replaceStr(returnStr,"\r\n","\\n");
		returnStr = replaceStr(returnStr,"\r","\\n");
		returnStr = replaceStr(returnStr,"\n","\\n");
		return returnStr;
	}

	// 스크립트 ",' 안에서 argument 전달 될때, 그 속에 ",' 가 있는 경우
	// 예 : out.println("<div onclick=\"alert('"+c.cvtToScriptFuncArgValue(값)+"')\">클릭</div>");
	public static String cvtToScriptFuncArgValue(String baseStr){
		if (baseStr==null) return "";
		String returnStr = baseStr;
		returnStr = replaceStr(returnStr,"\\","\\\\"); //replaceStr(returnStr,"\\","&#92;&#92;");
		returnStr = replaceStr(returnStr,"\"","&#92;&#34;");
		returnStr = replaceStr(returnStr,"\'","&#92;&#39;");
		returnStr = replaceStr(returnStr,"\r\n","\\\\n");
		returnStr = replaceStr(returnStr,"\r","\\\\n");
		returnStr = replaceStr(returnStr,"\n","\\\\n");
		return returnStr;
	}

	// 태그를 제거 < ... > 문자 제거
	public static String removeTag(String sBase){
		int pos1 = 0;
		int pos2 = 0;
		while(true){
			pos1=sBase.indexOf("<",pos1);
			if (pos1<0)  break;
			else {
				pos2=sBase.indexOf(">",pos1);
				if (pos2<0){
	//				sBase = sBase.substring(0,pos1); // '<' 이후의 모든 문자 제거
					break;
				}
				else {
					sBase = sBase.substring(0,pos1)+sBase.substring(pos2+1);
				}
			}
		}
		return sBase;
	}

	// 일반 문자열을 HTML에서 같은 형식으로 보이게끔 변경
	public static String toHtml(Object str) {
		if(str==null) return "";
		String s = str.toString();
		str=replaceStr(s,"&" ,"&#38;");
		s=replaceStr(s,"  ","&nbsp;&nbsp;");
		s=replaceStr(s,"<" ,"&#60;");
		s=replaceStr(s,">" ,"&#62;");
		s=replaceStr(s,"'" ,"&#39;");
		s=replaceStr(s,"\"","&#34");
		s=replaceStr(s,"\r\n","<br>");
		s=replaceStr(s,"\n","<br>");
		return s;
	}
	public static String toHtmlExceptTag(String str) {
		if(str==null) return "";
		str=replaceStr(str,"&" ,"&#38;");
		str=replaceStr(str,"  ","&nbsp;&nbsp;");
		str=replaceStr(str,"'" ,"&#39;");
		str=replaceStr(str,"\"","&#34");
		str=replaceStr(str,"\r\n","<br>");
		str=replaceStr(str,"\n","<br>");
		return str;
	}

	// 폼으로 입력된 데이타를 DB에 넣을때 항상 처리
	public static String toDBText(String str) {
		str=replaceStr(str,"<","&lt;");
		str=replaceStr(str,">","&gt;");
		return str;
	}

	// DB에 입력된 내용을 TextArea나 TextBox에 뿌릴때..
	public static String toText(String str) {
		str=removeTag(str);
		str=replaceStr(str,"&lt;","<");
		str=replaceStr(str,"&gt;",">");
		return str;
	}

	//달(-1,0,1,2...), 말일(true/false)
	public static String getDateStr(){
		return getDateStr(new Date(),0, 0, 0, "yyyyMMdd");
	}
	public static String getDateStr(String sFormat){
		return getDateStr(new Date(),0, 0, 0, sFormat);
	}
	public static String getDateStr(int gapDay, String sFormat){
		return getDateStr(new Date(),0, gapDay, 0, sFormat);
	}
	public static String getDateStr(int gapMonth, int gapDay, String sFormat){
		return getDateStr(new Date(),gapMonth, gapDay, 0, sFormat);
	}
	public static String getDateStr(int gapMonth, int gapDay, int fixDay, String sFormat){
		return getDateStr(new Date(),gapMonth, gapDay, fixDay, sFormat);
	}
	public static String getDateStr(Date date, int gapMonth, int gapDay, int fixDay, String sFormat){
		try{
			GregorianCalendar cal = new GregorianCalendar();
			cal.setTime(date);
			cal.add(Calendar.MONTH,gapMonth);
			cal.add(Calendar.DATE,gapDay);

			SimpleDateFormat sdf = new SimpleDateFormat(sFormat);
			if(fixDay==99){
				cal.set(Calendar.DATE, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
			}
			else if(fixDay!=0){
				cal.set(Calendar.DATE, fixDay);
			}
			return sdf.format(cal.getTime());
		}
		catch(Exception e) {return null;}
	}

	public static String getDateStr(String sDate, String sFormat){
		return getDateStr(strToDate(sDate),0,0,0,sFormat);
	}
	public static String getDateStr(String sDate, int gapDay, String sFormat){
		return getDateStr(strToDate(sDate),0,gapDay,0,sFormat);
	}
	public static String getDateStr(String sDate, int gapMonth, int gapDay, String sFormat){
		return getDateStr(strToDate(sDate),gapMonth,gapDay,0,sFormat);
	}
	// fixDay : 일자를 해당일자로 고정 (99:인 경우에는 해당월의 마지막일자)
	public static String getDateStr(String sDate, int gapMonth, int gapDay, int fixDay, String sFormat){
		return getDateStr(strToDate(sDate),gapMonth,gapDay,fixDay,sFormat);
	}

	public static Date strToDate(String sDate){
		return strToDate(sDate, "yyyyMMddHHmmss");
	}
	public static Date strToDate(String sDate, String sFormat){
		try{
			sDate = fillRight(sDate.replaceAll("-","").replaceAll("\\.","").replaceAll(":","").replaceAll(" ",""),"0",14);
			SimpleDateFormat sdf = new SimpleDateFormat(sFormat);
			return sdf.parse(sDate);
		}
		catch(Exception e) {return null;}
	}
	public static String toDateFormat(String sDate, String sFormat){
		Date date = strToDate(sDate,"yyyyMMddHHmmss");
		return (date==null) ? sDate : getDateStr(date,0,0,0,sFormat);
	}
	public static String toDateFormat(String sDate){
		return toDateFormat(sDate,"yyyy-MM-dd HH:mm:ss");
	}

	public static String toDivDate(String sDate, String sDiv) {
		try {
			if(sDate.length()>=8)
				return sDate.substring(0,4) + sDiv + sDate.substring(4,6) + sDiv + sDate.substring(6,8);
			else if(sDate.length()==6)
				return sDate.substring(0,2) + sDiv + sDate.substring(2,4) + sDiv + sDate.substring(4,6);
			else
				return sDate;
		}
		catch (Exception e){
			return toNN(sDate);
		}
	}

	public static String toDivDate(String sDate) {
		return toDivDate(sDate,".");
	}

	public static String toDivMMDD(String sDate, String sDiv) {
		try {
			return sDate.substring(4,6) + sDiv + sDate.substring(6,8);
		}
		catch (Exception e){
			return toNN(sDate);
		}
	}

	public static String toDivTime(String sDate, String sDiv) {
		try {
			if (sDate.length()>12)
				return sDate.substring(8,10) + sDiv + sDate.substring(10,12) + sDiv + sDate.substring(12);
			else
				return sDate.substring(8,10) + sDiv + sDate.substring(10);
		}
		catch (Exception e){
			return toNN(sDate);
		}
	}

	public static String toDivTime(String sDate){
		return toDivTime(sDate,":");
	}

	public static String getDateTimeByGapDay(double gapDay){
		long lTime = (long) (gapDay*1000*60*60*24);
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
		return sdf.format(new Date( new Date().getTime() - lTime));
	}
	public static String getDateByGapDay(Object oGapDay,String sDiv){
		double gapDay = Double.parseDouble(oGapDay.toString());
		long lTime = (long) (gapDay*1000*60*60*24);
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy"+sDiv+"MM"+sDiv+"dd");
		return sdf.format(new Date( new Date().getTime() - lTime));
	}
	public static long getGapTime(Date fromDate,Date toDate,String unit){
		long gapTime  = toDate.getTime() - fromDate.getTime();
		long calcTime = (unit.equals("d")) ? 1000*60*60*24 : (unit.equals("h")) ? 1000*60*60 : (unit.equals("m")) ? 1000*60 : (unit.equals("s")) ? 1000 : 1;
		return gapTime/calcTime;
	}

	//날짜의 시작시간을 리턴한다.
	public static String getFormatTimeByGapDay(Object gapDay){
		return getFormatTimeByGapDay(gapDay,"from");
	}
	// from = 00:00 , to = 23:59 (HHmm)
	public static String getFormatTimeByGapDay(Object gapDay,String loc){
		long gapSec = (long) (Double.parseDouble(gapDay.toString())*1000*60*60*24);
		gapSec += (loc.equals("from")) ? 0 : -60;//1분 뺌

		Date d = strToDate(getDateStr());
		d = new Date( d.getTime() + gapSec);
		SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
		String sDate = sdf.format(d);
		return sDate;
	}

	/*
	// 유일한 문자열을 시스템 시간을 이용해서 생성(14자리) <-유일하지 않음
	public static String makeID(){
		Long l=new Long(0);
		long seed = 0;
		seed= System.currentTimeMillis();
		Random rd = new Random(seed);
		long seed2 = rd.nextLong();
		long seed3 = rd.nextLong();

		String tmp =null;
		String sid = l.toHexString(seed);

		tmp = l.toHexString(seed2);
		sid += tmp.substring(1,3);
		tmp = l.toHexString(seed3);
		sid += tmp.substring(1,3);
		return sid;
	}
	*/
	public static String makeID(){//36자리
		return UUID.randomUUID().toString();
	}

	public static void viewNotice(JspWriter out, String sAct, String sNotice) throws Exception {
		sNotice = replaceStr(sNotice,"\n","\\n");
		sNotice = replaceStr(sNotice,"'","\\'");
		if (!sNotice.equals("")) sNotice="alert('"+sNotice+"');";

		out.println("<script language=javascript>");
		out.println(sAct);
		out.println(sNotice);
		out.println("</script>");
	}

	public static String getFrontDomain(HttpServletRequest request) {
		return request.getHeader("host").substring(0,request.getHeader("host").indexOf("."));
	}

	public static String getDomain(HttpServletRequest request, int backCnt) {
		String domain = request.getHeader("host");
		int idx = domain.length();
		try{
			for(int i=0;i<backCnt;i++){
				idx = domain.lastIndexOf(".",idx)-1;
			}
			idx = (idx<0) ? 0 : idx+2;
			return domain.substring(idx);
		}
		catch(Exception e){
			return "";
		}
	}
	//기본도메인의 URL만 구한다. (맨마지막 '/' 미포함)
	public static String getMainUrl(HttpServletRequest request) {
		String url = request.getRequestURL().toString();
		try{
			if(url.indexOf("/")==-1) return url;
			else if (url.indexOf("://")==-1) return url.substring(0,url.indexOf("/"));
			else {
				String protocol = url.substring(0,url.indexOf("://"));
				url = url.substring(url.indexOf("://")+3);
				if(url.indexOf("/")>-1) url = url.substring(0, url.indexOf("/"));
				return protocol +"://"+ url;
			}
		}
		catch(Exception e){
			return url;
		}
	}
	//현재 URL의 파일을 제외한 값을 구한다. (맨마지막 '/' 포함)
	public static String getUrlPath(HttpServletRequest request) {
		String url = request.getRequestURL().toString();
		return (url.indexOf("/")==-1) ? url+"/" : url.substring(0,url.lastIndexOf("/"))+"/";
	}

	public static boolean isDevSite(HttpServletRequest request) {
		return (request.getHeader("host").indexOf(".dev.") > -1);
	}

	// request값의 변수를 받기 ----------------------------------------------------------------
	public static String getPS(HttpServletRequest request, String sName) {
		return request.getParameter(sName);
	}

	public static int getPI(HttpServletRequest request, String sName) throws Exception {
		return getPI(request,sName,0);
	}

	public static int getPI(HttpServletRequest request, String sName, int nullToInt) throws Exception {
		String val = getPSNN(request,sName).replaceAll(",","");
		return (!val.equals("")) ? Integer.parseInt(val) : nullToInt;
	}

	public static String[] getPSA(HttpServletRequest request, String sName) {
		String[] aReturn = request.getParameterValues(sName);
		return aReturn;
	}

	public static String getPSD(HttpServletRequest request, String sName) throws Exception {
		return toDec(request.getParameter(sName));
	}

	// request값의 변수를 받아 NULL없애고 받기 ------------------------------------------------
	public static String getPSNN(HttpServletRequest request, String sName) {
		return toNN(request.getParameter(sName));
	}
	public static String getPSNN(HttpServletRequest request, String sName, String nullTo) {
		return toNN(request.getParameter(sName),nullTo);
	}

	public static String[] getPSANN(HttpServletRequest request, String sName) {
		return getPSANN(request, sName, "");
	}
	public static String[] getPSANN(HttpServletRequest request, String sName, String nullTo) {
		if (request.getParameterValues(sName)==null) {
			String[] aReturn = {nullTo};
			return aReturn;
		}
		else {
			String[] aReturn = request.getParameterValues(sName);
			for (int i=0;i<aReturn.length;i++)  aReturn[i] = (toNN(aReturn[i]).equals("")) ? nullTo : aReturn[i];
			return aReturn;
		}
	}
	//스트링으로 정수배열을 리턴한다.
	public static String[] getPSIA(HttpServletRequest request, String sName) throws Exception{
		if (request.getParameterValues(sName)==null) {
			String[] aReturn = {"0"};
			return aReturn;
		}
		else {
			String[] aReturn = request.getParameterValues(sName);
			for (int i=0;i<aReturn.length;i++)  aReturn[i] = (toNN(aReturn[i]).equals("")) ? "0" : aReturn[i].replaceAll(",","");
			return aReturn;
		}
	}

	public static int[] getPIA(HttpServletRequest request, String sName) throws Exception{
		return getPIA(request, sName, 0);
	}
	public static int[] getPIA(HttpServletRequest request, String sName, int nullTo) throws Exception{
		if (request.getParameterValues(sName)==null) {
			int[] aReturn = {nullTo};
			return aReturn;
		}
		else {
			String[] aStr = request.getParameterValues(sName);
			int[] aReturn = new int[aStr.length];
			for (int i=0;i<aReturn.length;i++)  aReturn[i] = (aStr[i]==null) ? nullTo : Integer.parseInt(aStr[i].replaceAll(",",""));
			return aReturn;
		}
	}

	public static String getPSDNN(HttpServletRequest request, String sName) throws Exception {
		return toDec(toNN(request.getParameter(sName)));
	}

	public static String getPSDNN(HttpServletRequest request, String sName, String nullTo) throws Exception {
		return toDec(toNN(request.getParameter(sName),nullTo));
	}

	public static String[] getPSDANN(HttpServletRequest request, String sName) throws Exception {
		if (request.getParameterValues(sName)==null) {
			String[] aReturn= {""};
			return aReturn;
		}
		else {
			String[] aReturn = request.getParameterValues(sName);
			for (int i=0;i<aReturn.length;i++)  aReturn[i] = (aReturn[i]==null) ? "" : toDec(aReturn[i]);
			return aReturn;
		}
	}

	// ----------------------------------------------------------------------------------------

	public static String toEnc(String str) throws Exception {
		if(str==null) return null;
		else return URLEncoder.encode(str,"EUC-KR");
	}

	public static String toDec(String str) throws Exception {
		if(str==null) return null;
		else return URLDecoder.decode(str,"EUC-KR");
	}

	public static String[] split(String bStr, String spliter) throws Exception {
		String aStr[] = (bStr+" ").split(spliter);
		aStr[aStr.length-1] = aStr[aStr.length-1].substring(0,aStr[aStr.length-1].length()-1);
		return aStr;
	}
	public static String[] splitXBlank(String bStr, String spliter) throws Exception {
		int i = 0;
		StringTokenizer st = new StringTokenizer(bStr,spliter);
		String[] aStr=new String[st.countTokens()];
		while (st.hasMoreTokens()) {
			aStr[i++]=(String) st.nextElement();
		}
		return aStr;
	}

	//넘어온 스트링 값을 spliter로 분리하여 int 배열에 저장하여 리턴
	public static int[] iSplit(String base, String spliter) throws Exception {
		int i = 0;
		StringTokenizer st = new StringTokenizer(base,spliter);
		int[] aReturn=new int[st.countTokens()];
		while (st.hasMoreTokens()) {
			aReturn[i++]= Integer.parseInt(st.nextElement().toString());
		}
		return aReturn;
	}

	public static String join(String[] base, String spliter) throws Exception {
		String sReturn="";
		if (base==null)		return null;
		if (base.length==1)	return base[0];
		for(int i=0;i<base.length;i++){
			sReturn+=toNN(base[i]) + spliter;
		}
		return sReturn.substring(0,sReturn.length()-spliter.length());
	}

	//한글이 섞인 문자열에서 길이로 짜르기
	public static String getSubStr(String sBase, int sIdx, int eIdx){
		String sRtn = "";
		char[] chr = sBase.replaceAll("\r\n","\n").toCharArray();
		int j=0;
		try{
			for (int i=0;i<eIdx;i++) {
				if (i>=sIdx) sRtn += chr[j];
				if (chr[j]>127) {
					i++;
					if(i>=eIdx) sRtn = sRtn.substring(0,sRtn.length()-1);
				}
				j++;
			}
		}
		catch(ArrayIndexOutOfBoundsException e){
			return sRtn;
		}
		return sRtn;
	}
	public static String getSubStrDot(String sBase, int len){
		if(sBase==null) return "";
		//sBase = sBase.replaceAll("\r\n","\n");
		int sBaseLen = sBase.getBytes().length;
		if(sBaseLen > len) return getSubStr(sBase,0,len-2) + "…";
		else return sBase;
	}

	public static LinkedHashMap<String,String> getFormData(HttpServletRequest req) throws Exception {
		LinkedHashMap<String,String> h = new LinkedHashMap<String,String>();
		Enumeration<String> e = req.getParameterNames();
		while (e.hasMoreElements()) {
			String name = e.nextElement();
			String[] values = req.getParameterValues(name);

			if(values.length == 1) h.put(name, toNN(values[0]));
			else{
				// multiple select
				String realValue = toNN(values[0]);
				for(int i=1; i < values.length; i++) realValue += "\n" + toNN(values[i]);
				h.put(name, realValue);
			}
		}
		return h;
	}
	//요청값을 해쉬테이블에 넣어서 리턴한다.
	public static HashMap<String,String> getParameters(HttpServletRequest req) throws Exception {
		HashMap<String,String> h = new LinkedHashMap<String,String>();
		Enumeration<String> e = req.getParameterNames();
		while (e.hasMoreElements()) {
			String name = e.nextElement();
			String values[] = getPSANN(req,name);
			//배열 인 경우 Tab 으로 join 하여 문자열에 넣는다.
			if(values.length == 1) h.put(name, values[0]);
			else h.put(name, String.join("\t",values));
		}
		//클라이언트 IP 값 추가
		h.put("_clientIp", req.getRemoteAddr());
		return h;
	}
	//요청값 화면출력용 또는 DB Log 입력용
	public static LinkedHashMap<String,String> getParametersUsedLog(HttpServletRequest req) throws Exception {
		LinkedHashMap<String,String> ht = new LinkedHashMap<String,String>();
		Enumeration<String> e = req.getParameterNames();
		while (e.hasMoreElements()) {
			String name = e.nextElement();
			String values[] = getPSANN(req,name);

			if(values.length == 1) ht.put(name, values[0]);
			else {
				name +="["+values.length+"]";
				String realValue = values[0];
				for(int i=1; i < values.length; i++) realValue += " , " + values[i];
				ht.put(name, realValue);
			}
		}
		return ht;
	}
	//화면에 요청값을 출력한다.
	public static void writeParameters(HttpServletRequest req, JspWriter out) throws Exception {
		LinkedHashMap<String,String> ht = getParametersUsedLog(req);
		String key;
		Iterator<String> it = ht.keySet().iterator();
		while(it.hasNext()){
			key = it.next();
			out.println(key+" = "+ht.get(key)+"<br>");
		}
	}
	public static String getParametersToDBInsert(HttpServletRequest req) throws Exception {
		LinkedHashMap<String,String> ht = getParametersUsedLog(req);
		String key;
		Iterator<String> it = ht.keySet().iterator();
		String result = "";
		while(it.hasNext()){
			key = it.next();
			result +=key+" = "+ht.get(key)+"\n";
		}
		return result;
	}

	public static String getCookie(HttpServletRequest request, String name){
		Cookie cookie[] = request.getCookies();
		if (cookie==null) return "";
		for(int i=0;i<cookie.length;i++){
			if (cookie[i].getName().toUpperCase().equals(name.toUpperCase())) return cookie[i].getValue();
		}
		return "";
	}

	public static void setPstmtArg(PreparedStatement pstmt,String arg) throws Exception {
		setPstmtArg(pstmt,arg,"■");
	}

	public static void setPstmtArg(PreparedStatement pstmt,String arg,String d){
		try{
			String aStr = (arg.substring(arg.length()-1).equals(d)) ? arg.substring(0,arg.length()-1) : arg;
			String[] args = split(aStr,d);
			for(int i=0;i<args.length;i++){
				pstmt.setString(i+1,args[i]);
			}
		}
		catch(Exception e) {}
	}

	public static void setPstmtByArg(PreparedStatement pstmt,String arg) throws Exception {
		try{
			String[] args = split(arg,"■");
			for(int i=0;i<args.length;i++){
				pstmt.setString(i+1,args[i]);
			}
		}
		catch(Exception e) {}
	}

	public static void setPstmtArg(PreparedStatement pstmt,String arg,String rootSpliter,String subSpliter) throws Exception {
		String[] arg1 = split(arg,rootSpliter);
		for(int i=0;i<arg1.length;i++){
			String[] arg2 = split(arg1[i],subSpliter);
			if(arg2[0].equals("S")){
				if(arg2.length == 1)
					pstmt.setString(i+1,null);
				else if(arg2.length == 2)
					pstmt.setString(i+1,arg2[1]);
				else if(arg2.length == 3)
					pstmt.setString(Integer.parseInt(arg2[1]),arg2[2]);
			}
			else if(arg2[0].equals("I")){
				if(arg2.length == 1)
					pstmt.setString(i+1,null);
				else if (arg2.length == 2)
					pstmt.setInt(i+1,Integer.parseInt(arg2[1]));
				else if(arg2.length == 3)
					pstmt.setInt(Integer.parseInt(arg2[1]),Integer.parseInt(arg2[2]));
			}

		}
	}

	public static String getCommaNumber(double arg) throws Exception{
		NumberFormat nf = NumberFormat.getInstance();
		return nf.format(arg);
	}
	public static String getCommaNumber(String arg){
		if (arg==null) return "";
		try{
			return getCommaNumber(Double.parseDouble(arg));
		}
		catch(Exception e){
			return arg;
		}
	}
	public static String getBizNoFormat(String bizNo){
		if(bizNo==null) return "";
		bizNo = replaceStr(bizNo,"-","");
		try{
			return bizNo.substring(0,2)+"-"+bizNo.substring(2,5)+"-"+bizNo.substring(5);
		}
		catch(Exception e){
			return bizNo;
		}
	}
	public static String getPhoneFormat(String phone){
		if(phone==null) return "";
		phone = replaceStr(phone,"-","");
		int phoneLen = phone.length();
		try{
			if(phoneLen<6 || 12<phoneLen) return phone;
			if(phoneLen==10 && phone.substring(0,1).equals("1")) return phone.substring(0,5)+"-"+phone.substring(5);//지능망번호 16666-16666(헛수번호 인정)
			String s3,s2,s1;
			s3 = phone.substring(phoneLen-4);
			s2 = phone.substring(0,phoneLen-4);
			if(phoneLen<9) return s2+"-"+s3;
			s1 = (phone.substring(0,2).equals("02")) ? "02" : (phoneLen==12) ? phone.substring(0,4) : phone.substring(0,3);
			return s1 +"-"+ s2.substring(s1.length()) +"-"+ s3;
		}
		catch(Exception e){
			return phone;
		}
	}
	public static String getPhoneFormatHideHtml(String phone){
		try{
			phone = getPhoneFormat(phone);
			phone = phone.substring(0,phone.length()-7)+"<font color=#aaaaaa>**</font>"+phone.substring(phone.length()-5);
			return phone;
		}
		catch(Exception e){
			return phone;
		}
	}
	public static boolean isPhoneNumber(String phone){
		if(phone==null) return false;
		phone = phone.replaceAll("-","");
		int phoneLen = phone.length();
		return	(phoneLen<8 || 12<phoneLen) ? false :
				(phoneLen==8 || phoneLen==10) ? (phone.substring(0,1).equals("1")) ://지능망번호 1666-1666 , 16666-16666(헛수번호 인정)
				(!phone.substring(0,1).equals("0")) ? false :						//8자리 초과 전화번호는 무조건 0으로 시작한다.
				(phone.substring(0,2).equals("02")) ? (9<=phoneLen && phoneLen<=10) ://앞자리 02인 경우 9~10자리
				(in(phone.substring(0,3),"010","011","016","017","018","019")) ? (10<=phoneLen && phoneLen<=11) :	// 10~11자리
				(phoneLen>=10);														//10자리 이상
	}

	public static String getHeaderValue(HttpServletRequest request, String headerName, String key){
		String keyValue[] = request.getHeader(headerName).split(";");
		for(int i=0;i<keyValue.length;i++){
			String value[] = keyValue[i].split("=");
			if (value[0].trim().toUpperCase().equals(key.toUpperCase())) return value[1].trim();
		}
		return "";
	}
	public static String getHeaderAll(HttpServletRequest request){
		Enumeration<String> en = request.getHeaderNames();
		String header = "";

		while(en.hasMoreElements()){
			String headerName  = en.nextElement();
			String headerValue = request.getHeader(headerName);
			header +=headerName +" = "+ headerValue+"<br>\n";
		}
		return header;
	}
	public static String toBaseDong(String dong){
		if(toNN(dong).equals("")) return "";
		if(in(dong.substring(dong.length()-1),"동") && !in(dong,"본동","산본동","동본동")){
			if(dong.substring(dong.length()-2).equals("본동")){
				dong = dong.substring(0,dong.length()-2) + "동";
			}
			else{
				try{
					//숫자가 없으면 에러나서 다음으로 자동 넘어
					@SuppressWarnings("unused")
					int dongNum = Integer.parseInt(dong.substring(dong.length()-2, dong.length()-1));
					dong = dong.substring(0,dong.length()-2) + dong.substring(dong.length()-1);
					dongNum = Integer.parseInt(dong.substring(dong.length()-2, dong.length()-1));
					dong = dong.substring(0,dong.length()-2) + dong.substring(dong.length()-1);
				}
				catch(Exception e){
					return dong;
				}
			}
		}
		return dong;
	}
	public static boolean isHandphone(String phoneNum){
		if(toNN(phoneNum).equals("")) return false;
		Pattern p = Pattern.compile("(010|011|016|017|018|019|013\\d{1})([1-9]{1}\\d{2,3})(\\d{4})");
		Matcher m = p.matcher(phoneNum);
		return (m.matches());
	}


	//서울 02 	경기 031 	인천 032 	강원 033 	충남 041 	대전 042 	충북 043 	부산 051
	//울산 052 	대구 053 	경북 054 	경남 055 	전남 061 	광주 062 	전북 063 	제주 064
	//지능망번호(예:1644-1644) 체크 못함 -> getPhoneFormat(pNum) 사용하기 바람
	public static String getChkPhoneFormat(String phoneNum){
		if(phoneNum==null) return "";
		Pattern p = Pattern.compile("(010|011|016|017|018|019|030|050|060|070|080|02|031|032|033|041|042|043|051|052|053|054|055|061|062|063|064)([1-9]{1}\\d{2,3})(\\d{4})");
		Matcher m = p.matcher(phoneNum);
		if(m.matches())	return m.group(1) +"-"+ m.group(2) +"-"+ m.group(3);
		else			return "";
	}

	public static String fillStr(Object fObj,int len){
		String sReturn = "";
		String fStr = fObj.toString();
		if(len<0) return "";
		for(int i=0;i<len;i+=fStr.length()) {sReturn+=fStr;}
		return sReturn.substring(0,len);
	}
	public static String fillRight(Object oBase, Object fObj, int len){
		return (oBase.toString() + fillStr(fObj,len-oBase.toString().getBytes().length));
	}
	public static String fillLeft(Object oBase, Object fObj, int len){
		return (fillStr(fObj,len-oBase.toString().getBytes().length) + oBase);
	}

	/**
	 * 반각문자로 변경
	 * @param src 변경할값
	 * @return String 변경된값
	 */
	public static String toHalfChar(String src){
		StringBuffer strBuf = new StringBuffer();

		char c = 0;
		int nSrcLength = src.length();

		for (int i = 0; i < nSrcLength; i++)
		{
			c = src.charAt(i);
			//영문이거나 특수 문자 일경우.
			if (c >= '！' && c <= '～')
			{
				c -= 0xfee0;
			}
			else if (c == '　')
			{
				c = 0x20;
			}
			// 문자열 버퍼에 변환된 문자를 쌓는다
			strBuf.append(c);
		}

		return strBuf.toString();
	}
	/**
	 * 전각문자로 변경
	 * @param src 변경할값
	 * @return String 변경된값
	 */
	public static String toFullChar(String src){
		// 입력된 스트링이 null 이면 null 을 리턴
		if (src == null)
			return null;

		// 변환된 문자들을 쌓아놓을 StringBuffer 를 마련한다
		StringBuffer strBuf = new StringBuffer();

		char c = 0;
		int nSrcLength = src.length();

		for (int i = 0; i < nSrcLength; i++)
		{
			c = src.charAt(i);
			//영문이거나 특수 문자 일경우.
			if (c >= 0x21 && c <= 0x7e)
			{
				c += 0xfee0;
			}
			//공백일경우
			else if (c == 0x20)
			{
				c = 0x3000;
			}
			// 문자열 버퍼에 변환된 문자를 쌓는다
			strBuf.append(c);
		}
		return strBuf.toString();
	}

	public static String getFilePath(HttpServletRequest request){
		return request.getRequestURI();
	}
	public static String getFileName(HttpServletRequest request){
		String fileName = request.getRequestURI();
		try{
			fileName = fileName.substring(fileName.lastIndexOf("/")+1);
		}
		catch(Exception e){}
		return fileName;
	}
	public static String getFileNameNoExt(HttpServletRequest request){
		String fileName = request.getRequestURI();
		try{
			fileName = fileName.substring(fileName.lastIndexOf("/")+1,fileName.lastIndexOf("."));
		}
		catch(Exception e){}
		return fileName;
	}
	public static String getFileName(Object obj){
		String fileName = obj.getClass().getName();
		try{
			fileName = fileName.substring(fileName.lastIndexOf(".")+1);
			fileName = (fileName.substring(fileName.length()-4).equals("_jsp")) ? fileName.substring(0,fileName.length()-4) : fileName;
		}
		catch(Exception e){}
		return fileName;
	}
	//-값이면 뒤에서 부터 구한다.
	public static String getFolderName(HttpServletRequest request, int seq){
		try{
			String tmpStr[] = request.getRequestURI().split("/");
			return (seq>=0) ? tmpStr[seq] : tmpStr[tmpStr.length+seq-1];
		}
		catch(Exception e){return "";}
	}

	//S : 검색 쿼리 생성 ---------------------------------------------------------------------------
	//검색필드값과 쿼리를 넘겨서 where 쿼리 리턴함
	public static String getQueryByValue(String value, String query){
		return getQueryByValue(!(value==null || value.equals("")),query);
	}
	public static String getQueryByValue(boolean isApplyQuery, String query){
		return (isApplyQuery) ? " and "+query+" " : " and 1=nvl2(?,1,1) ";
	}
	public static String getSrchQuery(String srchKey, String srchVal){
		String srchType	= srchKey.substring(0,2);
		String srchCol	= srchKey.substring(2);
		return	(srchVal.equals(""))	? " and 1=nvl2(?,1,1) " :
				(srchType.equals("l:"))	? " and "+srchCol+" like ?||'%' " :
				(srchType.equals("=:"))	? " and "+srchCol+" = ? " :
				(srchType.equals("i:"))	? " and "+srchCol+" like '%'||?||'%' " :
				(srchType.equals("r:"))	? " and "+srchCol+" like '%'||? " : "and "+srchKey+" = ? ";
	}
	//E : 검색 쿼리 생성 ---------------------------------------------------------------------------

	public static void viewMessage(JspWriter out, Object message) throws Exception {
		viewMessage(out,message,"",false);
	}
	public static void viewMessage(JspWriter out, Object message, boolean isBlank) throws Exception {
		viewMessage(out,message,"",isBlank);
	}
	public static void viewMessage(JspWriter out, Object message, String script) throws Exception {
		viewMessage(out,message,script,false);
	}
	public static void viewMessage(JspWriter out, Object message, String script, boolean isBlank) throws Exception {
		String msg = (toNN(message).equals("")) ? "" : "alert('"+cvtToScriptValue(message.toString())+"');\n";;
		script(out,msg+script,isBlank);
	}
	public static void viewMsgAfterScript(JspWriter out, String script, Object message) throws Exception {
		viewMsgAfterScript(out,script,message,false);
	}
	public static void viewMsgAfterScript(JspWriter out, String script, Object message, boolean isBlank) throws Exception {
		String msg = (toNN(message).equals("")) ? "" : "alert('"+cvtToScriptValue(message.toString())+"');\n";;
		script(out,script+"\n"+msg,isBlank);
	}
	public static void script(JspWriter out, String script) throws Exception {
		script(out,script,false);
	}
	public static void script(JspWriter out, String script, boolean isBlank) throws Exception {
		String strBlank = (isBlank) ? "\ndocument.location='about:blank';" : "";
		out.println("<script> "+script+""+strBlank+" </script>");
	}
	// 목록에서 rPage(record per page) 줄 수 맞추기 위해 줄 찍는 펑션
	public static void printBlankTd(JspWriter out, int tdCnt, int trCnt) throws Exception {
		if (trCnt<=0) return;
		String trStr = "<tr>";
		for(int i=0;i<tdCnt;i++) trStr += "<td>&nbsp;</td>";
		for(int i=0;i<trCnt;i++) out.println(trStr);
	}
	public static void printBlankTd(JspWriter out, String tdStr, int trCnt) throws Exception {
		if (trCnt<=0) return;
		String trStr = "<tr>" +tdStr.replaceAll(">",">&nbsp;</td>");
		for(int i=0;i<trCnt;i++) out.println(trStr);
	}
	public static void printBlankTdWhite(JspWriter out, int tdCnt, int trCnt) throws Exception {
		if (trCnt<=0) return;
		String trStr = "<tr class=bgW>";
		for(int i=0;i<tdCnt;i++) trStr += "<td>&nbsp;</td>";
		for(int i=0;i<trCnt;i++) out.println(trStr);
	}
	public static String getAddSrchArg(String srchVal){
		return	(srchVal.equals("")) ? "" : srchVal+"■";
	}

	public static String getDBErrMessage(SQLException e) throws Exception {
		String errMsg = e.getMessage();
		if(e.getErrorCode()==20002){
			errMsg = errMsg.substring(errMsg.lastIndexOf("ORA-20002")+11);
			if(errMsg.indexOf("ORA-")==0)
				errMsg = errMsg.substring(1,errMsg.indexOf("ORA-"));
			else
				errMsg = errMsg.substring(0,errMsg.indexOf("ORA-"));
		}
		else if(errMsg.indexOf("ORA-20002")>=0){
			errMsg = errMsg.substring(errMsg.lastIndexOf("ORA-20002")+11);
			if(errMsg.indexOf("ORA-")==0)
				errMsg = errMsg.substring(1,errMsg.indexOf("ORA-"));
			else
				errMsg = errMsg.substring(0,errMsg.indexOf("ORA-"));
		}
		return errMsg;
	}
	public static String getErrMessage(String msg){
		return (msg==null) ? "" : (msg.indexOf("{{")>-1 && msg.indexOf("}}")>-1) ? msg.substring(msg.lastIndexOf("{{")+2,msg.indexOf("}}")) : msg;
	}
	public static String getErrMessage(Exception e){
		return getErrMessage(getExceptionMsg(e));
	}
	public static String getErrMessage(SQLException e){
		return getErrMessage(getExceptionMsg(e));
	}

	public static String getErrMessage(Object obj, Exception e){
		return getFileName(obj)+" :: "+getErrMessage(getExceptionMsg(e));
	}
	public static String getErrMessage(Object obj, SQLException e){
		return getFileName(obj)+" :: "+getErrMessage(getExceptionMsg(e));
	}

	public static String getErrMessage(HttpServletRequest request, Exception e){
		return getFilePath(request)+" :: "+getErrMessage(getExceptionMsg(e));
	}
	public static String getErrMessage(HttpServletRequest request, SQLException e){
		return getFilePath(request)+" :: "+getErrMessage(getExceptionMsg(e));
	}

	public static String getExceptionMsg(Exception e){
		return "Exception :: "+e.toString();
		//return (e.getCause()!=null) ? e.getMessage() +"→"+ e.getCause().toString() : e.getMessage();
		//try{return e.getMessage() +"→"+ e.getCause().getMessage();}catch(Exception ee){return e.getMessage().toString();}
	}
	public static String getExceptionMsg(SQLException e){
		try{
			return "SQLException :: ("+e.getErrorCode()+") "+e.getMessage() +"→"+ e.getCause().getMessage();
		}
		catch(Exception ee){
			return "SQLException :: ("+e.getErrorCode()+") "+e.toString();
		}
	}

	//존재유무에 따른 display css 구하기
	public static String getCssDisplayStr(boolean isExist) {
		return (isExist) ? "" : "none";
	}

	//세션정보 설정
	public static void setSession(HttpServletRequest request, String name, Object value) {
		setSession(request.getSession(), name, value);
	}
	public static void setSession(HttpSession sess, String name, Object value) {
		sess.setAttribute(name, value);
	}
	//세션정보 조회
	public static String getSessionValue(HttpServletRequest request, String name) {
		return getSessionValue(request.getSession(),name);
	}
	public static String getSessionValue(HttpSession sess, String name) {
		return toNN(sess.getAttribute(name));
	}

	/*
	public static String toKor(Object obj) {
		return toEncByType(obj,"KSC5601");
	}
	public static String getPKS(HttpServletRequest request, String sName) {
		return toKor(request.getParameter(sName));
	}
	public static String[] getPKSA(HttpServletRequest request, String sName) {
		String[] aReturn = request.getParameterValues(sName);
		for (int i=0;i<aReturn.length;i++)  aReturn[i] = toKor(aReturn[i]);
		return aReturn;
	}
	public static String[] getPKSANN(HttpServletRequest request, String sName) {
		if (request.getParameterValues(sName)==null) {
			String[] aReturn= {""};
			return aReturn;
		}
		else {
			String[] aReturn = request.getParameterValues(sName);
			for (int i=0;i<aReturn.length;i++)  aReturn[i] = toKNN(aReturn[i]);
			return aReturn;
		}
	}
	public static String toKNN(Object obj) {
		return toNN(toKor(obj));
	}
	public static String getPKSNN(HttpServletRequest request, String sName) {
		return toKor(toNN(request.getParameter(sName)));
	}
	*/
}

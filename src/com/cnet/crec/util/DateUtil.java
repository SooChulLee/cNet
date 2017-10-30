package com.cnet.crec.util;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import org.apache.log4j.Logger;

public class DateUtil {
	private static final Logger logger = Logger.getLogger(DateUtil.class);
	
	/**
	 * 현재날짜 객체 리턴
	 * @return
	 */
	public static Date getToday() {
		Date rtnDate = null;
		
		try {
			Calendar cal = Calendar.getInstance();
			
			rtnDate = cal.getTime();
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
		
		return rtnDate;
	}
	
	/**
	 * 주어진 포맷으로 현재 날짜 리턴
	 * @param format 
	 * default("yyyy-MM-dd")
	 * 1. 년 - yyyy
	 * 2. 월 - MM
	 * 3. 일 - dd
	 * 4. 시 - hh (24시로 표시하고싶으면 HH)
	 * 5. 분 - mm
	 * 6. 초 - ss
	 * 7. 밀리초 - SSS
	 * 참고 url : http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
	 * @return 
	 */
	public static String getToday(String format) {
		String rtnDate = "";
		
		try {
			if (!CommonUtil.hasText(format)) {
				format = "yyyy-MM-dd";
			}
			
			SimpleDateFormat sdf = new SimpleDateFormat(format);
			
			rtnDate   = sdf.format(getToday());	
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
		
		return rtnDate;
	}	
	
	/**
	 * 문자열로 된 날짜를 주어진 포맷으로 파싱하여 date 객체 리턴
	 * @param strDate 
	 * @param format
	 * 1. 년 - yyyy
	 * 2. 월 - MM
	 * 3. 일 - dd
	 * 4. 시 - hh (24시로 표시하고싶으면 HH)
	 * 5. 분 - mm
	 * 6. 초 - ss
	 * 7. 밀리초 - SSS
	 * 참고 url : http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
	 * @return
	 */
	public static Date getDate(String strDate, String format) {
		Date rtnDate = null;
		
		try {
			if (!CommonUtil.hasText(format)) {
				format = "yyyy-MM-dd";
			}				
			if (!CommonUtil.hasText(strDate)) {
				strDate = getToday(format);
			}			   
						
			SimpleDateFormat sdf = new SimpleDateFormat(format);
			
			rtnDate = sdf.parse(strDate);
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
		
		return rtnDate;
	}  
	
	/**
	 * 문자열로 된 날짜를 주어진 포맷으로 리턴
	 * @param strDate 
	 * @param format
	 * 1. 년 - yyyy
	 * 2. 월 - MM
	 * 3. 일 - dd
	 * 4. 시 - hh (24시로 표시하고싶으면 HH)
	 * 5. 분 - mm
	 * 6. 초 - ss
	 * 7. 밀리초 - SSS
	 * 참고 url : http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
	 * @return
	 */
	public static String getDateFormat(String strDate, String format) {
		String rtnDate = null;
		
		try {
			if (!CommonUtil.hasText(format)) {
				format = "yyyy-MM-dd";
			}   			
			if (!CommonUtil.hasText(strDate)) {
				strDate = getToday(format);
			}				
						
			SimpleDateFormat sdf = new SimpleDateFormat(format);
			
			rtnDate = sdf.format(sdf.parse(strDate));
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
		
		return rtnDate;
	} 
	
	/**
	 * 숫자 형태로 된 문자열 날짜를 주어진 포맷으로 리턴
	 * @param strDate 
	 * @param format
	 * 1. 년 - yyyy
	 * 2. 월 - MM
	 * 3. 일 - dd
	 * 4. 시 - hh (24시로 표시하고싶으면 HH)
	 * 5. 분 - mm
	 * 6. 초 - ss
	 * 참고 url : http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
	 * @return
	 */	
	public static String getDateFormatByIntVal(String strDate, String format) {
		String rtnDate = null;
		
		try {
			if (!CommonUtil.hasText(format)) {
				format = "yyyy-MM-dd";
			}  
			
			// yyyy-MM-dd
			rtnDate = strDate.substring(0, 4) + "-" + strDate.substring(4, 6) + "-" + strDate.substring(6, 8);
			// yyyy-MM-dd HH:mm:ss 
			if(strDate.length()>8) {
				rtnDate += " " + strDate.substring(8, 10) + ":" + strDate.substring(10, 12) + ":" + strDate.substring(12, 14);
			}
			// yyyy-MM-dd HH:mm:ss.SSS
			if(strDate.length()>14) {
				rtnDate += "." + strDate.substring(14, 17);
			}

			SimpleDateFormat sdf = new SimpleDateFormat(format);
			
			rtnDate = sdf.format(sdf.parse(rtnDate));
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
		
		return rtnDate;
	} 	
	   
	/**
	 * 주어진 date를 주어진 포맷으로 리턴
	 * @param baseDate  날짜
	 * @param format 	포맷
	 * default("yyyy-MM-dd")
	 * 1. 년 - yyyy
	 * 2. 월 - MM
	 * 3. 일 - dd
	 * 4. 시 - hh (24시로 표시하고싶으면 HH)
	 * 5. 분 - mm
	 * 6. 초 - ss
	 * 7. 츠(millisec) 
	 * 참고 url : http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
	 * @return 
	 */
	public static String getDateFormat(Date baseDate, String format) {
		String rtnDate = "";
		
		try {
			if (!CommonUtil.hasText(format)) {
				format = "yyyy-MM-dd";
			}
			
			SimpleDateFormat sdf = new SimpleDateFormat(format);
			
			rtnDate = sdf.format(baseDate);	
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
		
		return rtnDate;
	}
	
	/**
	 * 주어진 기준일에 day를 더해서 format으로 출력
	 * @param baseDate  기준일
	 * @param addDay	더할 날짜
	 * @param format 	출력포맷
	 * @return
	 */
	public static String getDateAdd(Date baseDate, int addDay, String format) {
		String rtnDate = "";
		
		try {
			if (!CommonUtil.hasText(format)) {
				format = "yyyy-MM-dd";
			}	 
			
			// 기준일설정 (입력 없을 경우 오늘)
			Calendar cal = Calendar.getInstance();
			
			if (baseDate!=null) {
				cal.setTime(baseDate);
			}
			
			// 날짜를 더한다.
			cal.add(Calendar.DATE, addDay);
			
			// 리턴포맷
			SimpleDateFormat sdf = new SimpleDateFormat(format);

			rtnDate   = sdf.format(cal.getTime());
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
		
		return rtnDate;
	}
	
	/**
	 * 특정날자에 일을 더해서 format에 맞게끔 출력
	 * @param strDate (yyyy-MM-dd)형식
	 * @param addDay  더해줄 날짜
	 * @param format  return format (YYYY년 MM월 DD일 / YYYY-MM-DD)
	 * @return
	 */
	public static String getDateAdd(String strDate, int addDay, String format) {
		String rtnDate = "";
		
		try {	 
			if (!CommonUtil.hasText(format)) {
				format = "yyyy-MM-dd";
			}  
			
			Calendar cal = Calendar.getInstance();
			cal.set(Calendar.YEAR, Integer.parseInt(strDate.substring(0,4)));
			cal.set(Calendar.MONTH, Integer.parseInt(strDate.substring(5,7))-1);
			cal.set(Calendar.DATE, Integer.parseInt(strDate.substring(8,10)));
			
			cal.add(Calendar.DATE, addDay); 
			
			SimpleDateFormat sdf = new SimpleDateFormat(format);
				
			rtnDate   = sdf.format(cal.getTime());						
		}catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
		
		return rtnDate;
	}	
	
	/**
	 * 날짜 차이 계산 
	 * @param date1
	 * @param date2
	 * @param type = D or H or M
	 * @return
	 */
	public static int getDateDiff(Date date1, Date date2, String type) {
		int result = 0;
		
		try{	
			Calendar calendar1 = Calendar.getInstance();
			calendar1.setTime(date1);
										
			Calendar calendar2 = Calendar.getInstance();
			calendar2.setTime(date2);
					 
			int number = 0;
			switch(type){
				case "D":
					number = 1000*3600*24;
					break;
				case "H":
					number = 1000*3600;
					break;
				case "M":
					number = 1000*60;
					break;
			}
					 
			result = (int)((calendar2.getTimeInMillis() - calendar1.getTimeInMillis())/number);
		}catch(Exception ex){
			logger.error(ex.getMessage(), ex);
		}
		
		return result;
	}  
	
	/**
	 * 초 -> 시:분:초 
	 * @param sec
	 * @return
	 */
	public static String getHmsToSec(int sec) {
		int h = sec/3600;
		int m = sec%3600/60;
		int s = sec%3600%60;
		
		return CommonUtil.getFormatString(Integer.toString(h),"00")+":"+CommonUtil.getFormatString(Integer.toString(m),"00")+":"+CommonUtil.getFormatString(Integer.toString(s),"00");
	}	 
	
	/**
	 * 시:분:초 -> 초  
	 * @param hms
	 * @return
	 */
	public static int getSecToHms(String hms) {
		int sec = 0;
		String[] tmparr = hms.split(":"); 
		
		sec += Integer.parseInt(tmparr[0])*3600;	// 시간
		sec += Integer.parseInt(tmparr[1])*60;		// 분
		sec += Integer.parseInt(tmparr[2])*1;		// 초
		
		return sec;
	}	
	
	/*public static void main(String args[]) {	
		System.out.println(getSecToHms("00:01:51"));
	} */   
}

package com.cnet.crec.util;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.cnet.crec.common.Site;

//import org.apache.log4j.Logger;

public class CommonUtil {
	//private static final Logger logger = Logger.getLogger(CommonUtil.class);

	private static HttpServletRequest request;
	private static final String ENC_KEY = "!@CNET#$";									// 암호화 key
	private static final String WFM_ENC_KEY = "lotte-wfms-cipher@20160622-qwer1";		// 암호화 key

	/**
	 * request set
	 * @param request
	 * @return
	 */
	public static void setReqest(HttpServletRequest argRequest) {
		request = argRequest;
	}

	/**
	 * get enc_key
	 * @return
	 */
	public static String getEncKey() {
		return ENC_KEY;
	}

	/**
	 * get wfm enc_key
	 * @return
	 */
	public static String getWfmEncKey() {
		return WFM_ENC_KEY;
	}

	/**
	 * 문자열이 null인 경우 대체 문자열로 리턴
	 * @param str
	 * @param rep 대체 문자열
	 * @return
	 */
	public static String ifNull(String str, String rep) {
		return (str==null || "null".equals(str) || "".equals(str)) ? rep : str;
	}

	/**
	 * 문자열이 null인 경우 빈 문자열로 리턴
	 * @param str
	 * @return
	 */
	public static String ifNull(String str) {
		return ifNull(str,"");
	}

	/**
	 * 빈문자열인지 아닌지를 체크
	 * @param str
	 * @return
	 */
	public static boolean hasText(String str) {
 		return (str==null || str.replace(" ", "").length()==0) ? false : true;
	}

	/**
	 * 왼쪽에서부터 substring
	 * @param str
	 * @param cnt
	 * @return
	 */
	public static String leftString(String str, int cnt){
		return str.substring(0, cnt);
	}

	/**
	 * 오른쪽에서 부터 substring
	 * @param str
	 * @param cnt
	 * @return
	 */
	public static String rightString(String str, int cnt){
		return str.substring(str.length()-cnt, str.length());
	}

	/**
	 * 문자열 중에 한글 갯수 리턴
	 * @param str
	 * @return
	 */
	public static int getHangulCnt(String str) {
		int cnt =0;
		for(int i=0;i<str.length();i++) {
			char c = str.charAt(i);
			if((0xAC00<=c && c<=0xD7A3) || (0x3131<=c && c<=0x318E)) {
				cnt++;
			}
		}
		return cnt;
	}

	/**
	 * 문자열을 역순으로 리턴
	 * @param str : 문자열
	 * @return
	 */
	public static String getReverseString(String str) {
		String rev_str = "";

		for(int i=str.length();i>0;i--) {
			rev_str += String.valueOf(str.charAt(i-1));
		}
		return rev_str;
	}

	/**
	 * 연속된 문자열 여부 확인
	 * @param str : 문자열
	 * @param cipher : 체크할 연속된 문자 숫자
	 * @return
	 */
	public static boolean checkStraightString(String str, int cipher) {
		str = str.toLowerCase();

		for(int i=0;i<(str.length()-cipher+1);i++) {
			int cnt = 0;
			int tmp = 0;

			// 현재 문자의 achii 값과 이전 achii 값을 뺀 값이 1이면 연속되는 문자열
			for(int j=0;j<cipher;j++) {
				int ac = str.substring(i+j, i+j+1).charAt(0);

				if(j>0 && ac-tmp==1) {
					cnt++;
				}
				tmp = ac;
			}

			// 연속되는 문자열이 cipher-1만큼 있다면 비교 기준 문자에서 지정한 자릿수만큼 연속되는 문자열로 판명
			if(cnt-cipher+1==0) {
				return true;
			}
		}

		return false;
	}

	/**
	 * URL에서 마지막 디렉토리 추출
	 * @param url : 파일 경로
	 * @return
	 */
	public static String getLastUrlDir(String url) {
		if(!hasText(url)) return "";

		String[] tmparr = url.split("/");
		return tmparr[tmparr.length-2];
	}

	/**
	 * 확장자가 없는 파일명 추출
	 * @param url : 파일 경로
	 * @return
	 */
	public static String getFilenameNoExt(String url) {
		if(!hasText(url)) return "";

		String[] tmparr = url.split("/");
		return leftString(tmparr[tmparr.length-1],tmparr[tmparr.length-1].lastIndexOf("."));
	}

	/**
	 * 캐릭터 인코딩
	 * @param str
	 * @param fromEnc 원본 캐릭터 셋
	 * @param toEnc 변경할 캐릭터 셋
	 * @return
	 */
	public static String getEncodeString(String str, String fromEnc, String toEnc){
		try {
			return new String (str.getBytes(fromEnc), toEnc);
		} catch(Exception e) {
			return "";
		}
	}

	/**
	 * 기본 캐릭터 인코딩
	 * @param str
	 * @return
	 */
	public static String getEncodeString(String str){
		return getEncodeString(str, "8859_1", "UTF-8");
	}

	/**
	 * HTML -> Text
	 * @param str
	 * @return
	 */
	public static String toHTMLText(String str) {
		return str.replace(";", "&#59;")
					.replace("'", "&apos;")
					.replace("\"", "&quot;")
					.replace("<", "&lt;")
					.replace(">", "&gt;")
					.replace("(", "&#40;")
					.replace(")", "&#41;")
					.replace("/", "&#47;");
	}

	/**
	 * Text -> HTML
	 * @param str
	 * @return
	 */
	public static String toTextHTML(String str) {
		return str.replace("&#59;", ";")
					.replace("&apos;", "'")
					.replace("&quot;", "\"")
					.replace("&lt;", "<")
					.replace("&gt;", ">")
					.replace("&#40;", "(")
					.replace("&#41;", ")")
					.replace("&#47;", "/");
	}

	/**
	 * Text -> JSON
	 * @param str
	 * @return
	 */
	public static String toTextJSON(String str) {
		return str.replace("&quot;", "\"")
					.replace("&lt&#59;", "&lt;")	// grid parameter
					.replace("&gt&#59;", "&gt;");	// grid parameter
	}

	/**
	 * Base64 Text -> HTML Entity
	 * @param str
	 * @return
	 */
	public static String toBase64TextHTML(String str) {
		return str.replace("&", "%26")
					.replace("+", "%2B");
	}

	/**
	 * Base64 HTML Entity -> Text
	 * @param str
	 * @return
	 */
	public static String toBase64HTMLText(String str) {
		return str.replace("%26", "&")
					.replace("%2B", "+");
	}

	/**
	 * 파라미터 가공
	 * @param str
	 * @return
	 */
	public static String getParameter(String argName) {
		return ifNull(request.getParameter(argName),"");
		//return toHTMLText(ifNull(request.getParameter(argName),""));
	}

	/**
	 * 파라미터 가공
	 * @param str, rep
	 * @return
	 */
	public static String getParameter(String argName, String rep) {
		return ifNull(request.getParameter(argName),rep);
		//return toHTMLText(ifNull(request.getParameter(argName),rep));
	}

	/**
	 * 파라미터 가공
	 * @param str
	 * @return
	 */
	public static int getParameterInt(String argName) {
		return Integer.parseInt(getParameter(argName, "0"));
	}

	/**
	 * 파라미터 가공
	 * @param str, rep
	 * @return
	 */
	public static int getParameterInt(String argName, String rep) {
		return Integer.parseInt(getParameter(argName, rep));
	}

	/**
	 * 숫자 ,로 구분
	 * @param number
	 * @return
	 */
	public static String getNumberFormat(int number){
		NumberFormat numFormat = NumberFormat.getNumberInstance();
		return numFormat.format(number);
	}

	/**
	 * 지정된 숫자를 숫자포맷 리턴 숫자포맷 (자리수 맞추기 위함) ex) 00000, 123 --> 00123
	 * @param str(지정숫자는 문자 형식으로 보낸다)
	 * @param format
	 * @return
	 */
	public static String getFormatString(String str, String format){
		double number = Double.valueOf(str);
		// 포맷 설정
		DecimalFormat df = new DecimalFormat(format) ;
		return df.format(number);
	}

	/**
	 * Random 숫자를 생성하여 리턴한다.
	 * @param format 숫자포맷 (자리수 맞추기 위함) ex) 00000
	 * @return
	 */
	public static String getRandomNumber(String format) {
		double seed = Math.pow(10, format.length());

		// random 숫자 발생
		double n = (seed * Math.random()) + 1;

		// 반올림하면서 자릿수가 늘어나는것을 막기 위해 - 1.5처리.
		n = n - 1.5;

		// 포맷 설정
		DecimalFormat df = new DecimalFormat(format) ;

		// 결과 리턴
		return df.format(n);
	}

	/**
	 * 문자열 마스킹
	 * @param str : 대상 문자열
	 * @param type : 문자열 구분 (ani=전화번호, ssn=주민번호)
	 * @return
	 */
	public static String getMaskString(String str, String type) {
		if("ani".equals(type)) {
			str = str.substring(0, str.length()-4) + "****";
		} else if("ssn".equals(type)) {
			str = str.substring(0, str.length()-6) + "******";
		}
		return str;
	}

	/**
	 * 쿠키값 가져오기
	 * @param ck_name : 쿠키 명
	 * @return
	 */
	public static String getCookieValue(String ck_name) {
		String ck_value = "";
		Cookie[] cook = request.getCookies();

		if(cook!=null){
			for(int i = 0; i < cook.length; i++){
				if(cook[i].getName().equals(ck_name)){
					ck_value = cook[i].getValue();
					break;
				}
			}
		}

		return ck_value;
	}

	/**
	 * 에러 메시지 조회
	 * @param err_code : 에러코드
	 * @return
	 */
	public static String getErrorMsg(String err_code) {
		String err_msg = "";

		switch(err_code) {
			case "NO_PARAM": 		err_msg="필수 파라미터가 없습니다."; break;
			case "NO_LOGIN": 		err_msg="로그인 후 이용해 주십시요."; break;
			case "NO_DATA": 		err_msg="데이터가 존재하지 않습니다."; break;
			case "ERR_WRONG": 		err_msg="잘못된 접근입니다."; break;
			case "ERR_PERM": 		err_msg="권한이 없습니다."; break;
			case "DUP_PHONE_NUM_IP":err_msg="내선번호와 아이피가 중복됩니다."; break;
			case "DUP_PHONE_NUM": 	err_msg="중복된 내선번호가 있습니다."; break;
			case "DUP_PHONE_IP": 	err_msg="중복된 아이피가 있습니다."; break;
			default: 				err_msg="ERR : "+err_code; break;
		}
		return err_msg;
	}

	/**
	 * javascript 소스 리턴
	 * @param msg : 메시지
	 * @param url : 리턴 url
	 * @param type : 리턴 타입
	 * @return
	 */
	public static String getPopupMsg(String msg, String url, String type) {
		StringBuffer sb = new StringBuffer();

		if("json".equals(type)) {
			sb.append(Site.getJsonResult(false, msg));
		} else {
			sb.append("<script>");
			switch(type) {
				case "back": sb.append("alert('"+msg+"');"); sb.append("history.back();"); break;
				case "url": sb.append("alert('"+msg+"');"); sb.append("top.location.replace('"+url+"');"); break;
				case "close": sb.append("alert('"+msg+"');"); sb.append("self.close();"); break;
				default: sb.append("alert('"+msg+"');"); break;
			}
			sb.append("</script>");
		}
		return sb.toString();
	}

	//alert 창으로 안 띄우고 바디에 직접 메시지 뿌리기
	public static String getDocumentMsg(String msg, String url, String type) {
		StringBuffer sb = new StringBuffer();

		if("json".equals(type)) {
			sb.append(Site.getJsonResult(false, msg));
		} else {
			sb.append("<div class='ibox-content contentRadius3' style=margin:10px;padding:15px;text-align:center>"+ msg+"</div>");
		}
		return sb.toString();
	}

	/**
	 * 로그인, 메뉴 접근권한 세션 체크
	 * @param menu : 메뉴 확장자 없는 파일명
	 * @return
	 */
	public static String checkLogin(String menu, String type) {
		HttpSession session = null;

		try {
			session = request.getSession();

			// return type default
			type = ("".equals(type)) ? "url" : type;

			// 로그인 세션 체크
			if(!hasText((String) session.getAttribute("login_id")) || !hasText((String) session.getAttribute("login_level"))) {
				return getPopupMsg(getErrorMsg("NO_LOGIN"),"../index.jsp",type);
			}
			// 로그인 아이피 체크
			if(!hasText((String) session.getAttribute("login_ip")) || !request.getRemoteAddr().equals((String) session.getAttribute("login_ip"))) {
				return getPopupMsg(getErrorMsg("ERR_WRONG"),"../index.jsp",type);
			}
			// 메뉴권한 체크
			if(hasText(menu)) {
				boolean flag = false;
				if(session.getAttribute("menu_perm")!=null) {
					@SuppressWarnings("unchecked")
					HashMap<String,String> map = (HashMap<String,String>) session.getAttribute("menu_perm");
					if(map.containsValue(menu)) {
						flag = true;
					}
				}
				if(!flag) {
					return getPopupMsg(getErrorMsg("ERR_PERM"),"../index.jsp",type);
				}
			}
		} catch(Exception e){
			return getPopupMsg(getErrorMsg("ERR_OCCURED"),"../index.jsp",type);
		}

		return "";
	}

	/**
	 * password validator
	 * @param pwd : 비밀번호
	 * @param id : 아이디
	 * @param type : 리턴 구분
	 * @return
	 */
	public static String checkPasswd(String pwd, String id, String type) {
		// 공백 체크
		Pattern sc_p = Pattern.compile("[\\s]");
		Matcher sc_m = sc_p.matcher(pwd);

		if(pwd.length()<10 || pwd.length()>30 || sc_m.find()) {
			return getPopupMsg("비밀번호를 공백없이 10자리 이상 30자리 이하로 입력해 주십시오.","",type);
		}
		if(pwd.indexOf(id)>-1) {
			return getPopupMsg("비밀번호에 아이디를 사용할 수 없습니다.","",type);
		}

		// 영문/숫자/특수문자 중 2가지 이상 조합
		int cb_cnt = 0;
		Pattern en_p = Pattern.compile("[a-zA-Z]");
		Matcher en_m = en_p.matcher(pwd);
		Pattern num_p = Pattern.compile("[0-9]");
		Matcher num_m = num_p.matcher(pwd);
		// {}[]/?.,;:|)*~`!^-_+<>@#$%&\=(
		//Pattern sp_p = Pattern.compile("[\\{\\}\\[\\]\\/?.,;:|\\)*~`!^\\-_+<>@\\#$%&\\\\\\=\\(]");
		Pattern sp_p = Pattern.compile("[\\{\\}\\[\\]\\/?.,|\\)*~`!^\\-_+@\\#$&\\\\\\(]");
		Matcher sp_m = sp_p.matcher(pwd);

		if(en_m.find()) cb_cnt++;
		if(num_m.find()) cb_cnt++;
		if(sp_m.find()) cb_cnt++;

		if(cb_cnt<2) {
			return getPopupMsg("비밀번호를 영문/숫자/특수문자 중 2가지 이상을 조합하여 입력해 주십시오.","",type);
		}

		// 특정특수문자 사용금지
		Pattern no_sp_p = Pattern.compile("[\"';:<>%\\=]");
		Matcher no_sp_m = no_sp_p.matcher(pwd);

		if(no_sp_m.find()) {
			return getPopupMsg("특정 특수문자는 사용하실 수 없습니다. [ \" % ' : ; < = > ]","",type);
		}

		// 동일문자 3회 이상 사용 금지
		Pattern eq_p = Pattern.compile("(\\w)\\1{2}");
		Matcher eq_m = eq_p.matcher(pwd);

		if(eq_m.find()) {
			return getPopupMsg("비밀번호는 동일 문자/숫자를 3회 이상 사용하실 수 없습니다.","",type);
		}

		// 연속된 문자/숫자 사용금지
		if(checkStraightString(pwd, 3)) {
			return getPopupMsg("비밀번호는 연속된 문자/숫자를 3회 이상 사용하실 수 없습니다.","",type);
		}
		if(checkStraightString(getReverseString(pwd), 3)) {
			return getPopupMsg("비밀번호는 역순으로 연속된 문자/숫자를 3회 이상 사용하실 수 없습니다.","",type);
		}

		return "";
	}

	/**
	 * tbl_record 테이블 명 리턴
	 * @param rec_date : 녹취일자
	 * @return
	 */
	public static String getRecordTableNm(String rec_date) {

		int yser = Integer.parseInt(rec_date.substring(0, 4));

		if ( yser >= 2016){
			return "";
		} else {
			return "_before";
		}


		//return ("2016".equals(rec_date.substring(0, 4))) ? "" : "_before";
	}
}

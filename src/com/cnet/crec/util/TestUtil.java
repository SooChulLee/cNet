package com.cnet.crec.util;

import java.util.regex.*;

public class TestUtil {
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
	 * password validator
	 * @param pwd : 비밀번호
	 * @param id : 아이디
	 * @param type : 리턴 구분
	 * @return
	 */	
	public static String checkPasswd(String pwd, String id, String type) {
		String msg = "";
		
		if(pwd.length()<8 || pwd.length()>30) {
			return "비밀번호를 8자리 이상 30자리 이하로 입력해 주십시오.";
		}
		if(pwd.indexOf(id)>-1) {
			return "비밀번호에 아이디를 사용할 수 없습니다.";
		}
		
		// 정규표현식
		Pattern sc_p = Pattern.compile("[\\s]");
		Matcher sc_m = sc_p.matcher(pwd);		
		Pattern en_p = Pattern.compile("[a-zA-Z]");
		Matcher en_m = en_p.matcher(pwd);
		Pattern num_p = Pattern.compile("[0-9]");
		Matcher num_m = num_p.matcher(pwd);
		// {}[]/?.,;:|)*~`!^-_+<>@#$%&\=(	
		Pattern sp_p = Pattern.compile("[\\{\\}\\[\\]\\/?.,;:|\\)*~`!^\\-_+<>@\\#$%&\\\\\\=\\(]");
		Matcher sp_m = sp_p.matcher(pwd);
		Pattern eq_p = Pattern.compile("(\\w)\\1{2}");
		Matcher eq_m = eq_p.matcher(pwd);
				
		if(sc_m.find() || !en_m.find() || !num_m.find() || !sp_m.find()) {
			return "비밀번호를 공백없이 영문자, 숫자, 특수문자를 조합하여 입력해 주십시오.";
		}
		if(eq_m.find()) {
			return "비밀번호는 동일 문자를 3회 이상 사용하실 수 없습니다.";
		}
		if(TestUtil.checkStraightString(pwd, 3)) {
			return "비밀번호는 연속된 문자를 3회 이상 사용하실 수 없습니다.";
		}
		if(TestUtil.checkStraightString(TestUtil.getReverseString(pwd), 3)) {
			return "비밀번호는 역순으로 연속된 문자를 3회 이상 사용하실 수 없습니다.";
		}		
		
		return "valid";
	}
	
	public static void main(String[] args) {
		String result = "";
		result = TestUtil.checkPasswd("cnet25cba!", "admin", "");
		System.out.println(result);
		
		if(TestUtil.checkStraightString("123", 3)) {
			System.out.println("연속");
		} else {
			System.out.println("비연속");
		}
		
		System.out.println(TestUtil.getReverseString("123"));
	}
}

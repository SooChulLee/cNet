<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cnet.crec.util.CommonUtil"%>
<%@ page import="com.cnet.crec.util.DateUtil"%>
<%@ page import="wfm.com.util.AES256Cipher"%>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%
	// 자동 로그인
	String key = "lotte-wfms-cipher@20160622-qwer1";
	AES256Cipher a256 = AES256Cipher.getInstance(key);
	
	String plain = "admin|" + DateUtil.getToday("yyyyMMddHHmmssSSS");
	
	out.print("평문 = " + plain + "<br>");
	
	String result = a256.encrypt(plain);
	
	out.print("암호화 = " + result + "<br><br>");
%>
<a href="auto_login.jsp?info=<%=java.net.URLEncoder.encode(result)%>" target="_blank">자동 로그인</a>
<%
	// 청취 인터페이스
	/*
	String rec_datm = a256.encrypt("20160519165750000");
	String local_no = a256.encrypt("1636");
	String rec_keycode = a256.encrypt("22628127");
	String rec_filename = a256.encrypt("20160519165750_1636.wav");
	*/
	// 평문 청취 인터페이스
	//String rec_datm1 = "20160726";
	String rec_datm1 = "20160920";
	//String local_no1 = "118017";
	String local_no1 = "118014";
	//String rec_keycode1 = "00001007891469518948";
	String rec_keycode1 = "00001005791474346311";
	//String rec_filename1 = "20160726164039_118010";
	String rec_filename1 = "20160920133813_118014";
	
	String user_id1 = "C410287";
	String user_name1 = "신혜숙174";
	String user_ip1 = "10.144.243.60";
	String reason_code1 = "05";
	String reason_text1 = "";
			
	String sfp_rec_date1 = "20160920";
	String sfp_local_no1 = "118014";
	String sfp_rec_keycode1 = "00001005791474346311";
	String sfp_store_code1 = "1";
	String sfp_mystery_code1 = "1";
	
	// 암호화
	String rec_datm = a256.encrypt(rec_datm1);
	String local_no = a256.encrypt(local_no1);
	String rec_keycode = a256.encrypt(rec_keycode1);
	String rec_filename = a256.encrypt(rec_filename1);
	
	String user_id = a256.encrypt(user_id1);
	String user_name = a256.encrypt(user_name1);
	String user_ip = a256.encrypt(user_ip1);
	String reason_code = a256.encrypt(reason_code1);
	String reason_text = a256.encrypt(reason_text1);
	
	// 소프트폰
	String sfp_rec_date = a256.encrypt(sfp_rec_date1);
	String sfp_local_no = a256.encrypt(sfp_local_no1);
	String sfp_rec_keycode = a256.encrypt(sfp_rec_keycode1);

	out.print("<br> 평문 = " + rec_datm1 + "<br>");
	out.print("평문 = " + local_no1 + "<br>");
	out.print("평문 = " + rec_keycode1 + "<br>");
	out.print("평문 = " + rec_filename1 + "<br>");	
	out.print("암호화 = " + rec_datm + "<br>");
	out.print("암호화 = " + local_no + "<br>");
	out.print("암호화 = " + rec_keycode + "<br>");
	out.print("암호화 = " + rec_filename + "<br>");	
	out.print("URL = " + java.net.URLEncoder.encode(rec_datm) + "<br>");
	
	// 비밀번호 암호화
	CNCrypto sha256 = new CNCrypto("HASH",CommonUtil.getEncKey());
	String enc_user_pass = sha256.Encrypt("lotte12345!");
	
	out.print("비밀번호 암호화 = " + enc_user_pass + "<br>");
	
	// 파일 경로 복호화
	CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());
	String dec_file_url = aes.Decrypt("/ukwRBccthAQcZ+LW3y1ukP1/40HXBotGjCfdGBv0C1GSHGD+6WUS7zP6GnoAJ9rbvBg+w17YBsA7Rhy5zA3wA==");
	
	out.print("파일경로 복호화 = " + dec_file_url + "<br>");	
%>
<br>
<br>
<!--
<a href="../player/player_rn.jsp?rec_datm=<%//=java.net.URLEncoder.encode(rec_datm) %>&local_no=<%//=java.net.URLEncoder.encode(local_no) %>&rec_keycode=<%//=java.net.URLEncoder.encode(rec_keycode) %>" target="_blank">청취 플레이어</a>
<br>
<br>
-->
<a href="../player/player_rn.jsp?rec_datm=<%=java.net.URLEncoder.encode(rec_datm) %>&rec_keycode=<%=java.net.URLEncoder.encode(rec_keycode) %>" target="_blank">청취 플레이어</a>
<br>
<br>
<a href="../player/player_rn.jsp?rec_datm=<%=java.net.URLEncoder.encode(rec_datm) %>&rec_keycode=<%=java.net.URLEncoder.encode(rec_keycode) %>&user_id=<%=java.net.URLEncoder.encode(user_id) %>&user_nm=<%=java.net.URLEncoder.encode(user_name) %>" target="_blank">청취 플레이어(신규)</a>
<br>
<br>
<a href="../player/download_rn.jsp?rec_datm=<%=java.net.URLEncoder.encode(rec_datm) %>&rec_keycode2=<%=java.net.URLEncoder.encode(rec_filename) %>" target="_blank">다운로드</a>
<br>
<br>
<a href="../player/download_app.jsp?rec_datm=<%=java.net.URLEncoder.encode(rec_datm) %>&rec_keycode2=<%=java.net.URLEncoder.encode(rec_filename) %>" target="_blank">다운로드(사유없음)</a>
<br>
<br>
<a href="../player/download_app.jsp?rec_datm=<%=java.net.URLEncoder.encode(rec_datm) %>&rec_keycode2=<%=java.net.URLEncoder.encode(rec_filename) %>&user_id=<%=java.net.URLEncoder.encode(user_id) %>&user_nm=<%=java.net.URLEncoder.encode(user_name) %>&user_ip=<%=java.net.URLEncoder.encode(user_ip) %>&reason_code=<%=java.net.URLEncoder.encode(reason_code) %>&reason_text=<%=java.net.URLEncoder.encode(reason_text) %>" target="_blank">다운로드(신규)</a>
<br>
<br>
<a href="../player/sfp_interface.jsp?rec_date=<%=java.net.URLEncoder.encode(sfp_rec_date1) %>&local_no=<%=java.net.URLEncoder.encode(sfp_local_no1) %>&rec_keycode=<%=java.net.URLEncoder.encode(sfp_rec_keycode1) %>&store_code=<%=java.net.URLEncoder.encode(sfp_store_code1) %>&mystery_code=<%=java.net.URLEncoder.encode(sfp_mystery_code1) %>" target="_blank">소프트폰 인터페이스</a>

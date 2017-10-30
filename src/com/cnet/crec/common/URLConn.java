package com.cnet.crec.common;

import java.net.URL;
import java.net.URLConnection;
import java.net.HttpURLConnection;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;


public class URLConn{
	private String html;
	private int code;

	public String getHtml() {
		return (html == null) ? "" : html;
	}

	public void setHtml(String html) {
		this.html = html;
	}

	public int getCode() {
		return code;
	}

	public void setCode(int code) {
		this.code = code;
	}

	public void connect(String strUrl){
		try{
			URL url = new URL(strUrl);
			URLConnection con = url.openConnection();
			
			con.setDoInput(true);	//입력 스트림 사용 여부
			con.setUseCaches(false);//케쉬사용안함
			con.setConnectTimeout(10000);

			BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream())); 
			StringBuilder sb = new StringBuilder("");
			char[] buf = new char[1024];
			int len = 0;
			while ((len = br.read(buf, 0, 1024)) > 0) {
				sb.append(new String(buf, 0, len));
			}
			this.html = sb.toString();
			this.code = 1;
		}catch(Exception e){
			this.code = 0;
			this.html = e.toString();
		}
	}

	//param 예시 : name=홍길동&no=123
	public void connectPost(String strUrl, String param){
		try{
			URL url = new URL(strUrl);
			//connect 처럼 URLConnection 을 사용해도 무방함 <- 단 setRequestMethod는 사용 불가
			HttpURLConnection con = (HttpURLConnection) url.openConnection();

			con.setDoOutput(true);			//출력 스트림 사용 여부 (아래 OutputStream을 사용하겠다는 말임)
			con.setDoInput(true);			//입력 스트림 사용 여부
			con.setUseCaches(false);		//케쉬사용안함
			con.setRequestMethod("POST");	// -> 이거 GET으로 해도 POST가 됨 <- 아래 os.write 하면 무조건 POST가 됨
			con.setConnectTimeout(10000);

			OutputStream os = con.getOutputStream();//쓰기 객체 구함
			os.write(param.getBytes());
			os.flush();

			BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream())); 
			StringBuilder sb = new StringBuilder("");
			char[] buf = new char[1024];
			int len = 0;
			while ((len = br.read(buf, 0, 1024)) > 0) {
				sb.append(new String(buf, 0, len));
			}

			this.html = sb.toString();
			this.code = 1;//con.getResponseCode();
		}catch(Exception e){
			this.code = 0;
			this.html = e.toString();
		}
	}
}

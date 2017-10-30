<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="com.cnet.crec.util.CommonUtil"%>
<%@ page import="com.cnet.crec.util.DateUtil"%>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%@ page import="java.net.DatagramSocket"%>
<%@ page import="java.net.DatagramPacket"%>
<%@ page import="java.net.InetAddress"%>
<%@ page import="java.net.SocketTimeoutException"%>
<%@ page import="java.util.*"%>
<%@ page import="com.cnet.crec.common.*"%>
<%!
/**
 * 녹취파일 청취 URL 리턴
 * @param type : 구분 (현재 사용안함)
 * @param data : 녹취 데이터 map
 * @return
 */
public static String getListenURL(String type, Map<String, Object> data, Logger logger) {
	String file_url = "";
	String file_prefix = "";
	String file_path = "";
	String file_ext = "";
	try {
		String rec_date = data.get("rec_date").toString();
		String rec_hour = data.get("rec_start_time").toString().substring(0,2);
		String file_name = data.get("rec_filename").toString();
		String system_code = data.get("system_code").toString();
		String store_code = data.get("rec_store_code").toString();
		String web_url = data.get("web_url").toString();

		// 파라미터 체크
		if(!CommonUtil.hasText(rec_date) || !CommonUtil.hasText(rec_hour) || !CommonUtil.hasText(file_name) || !CommonUtil.hasText(system_code)) {
			throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
		}

		// 암호화 모듈 생성
		CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());

		if("99".equals(system_code) || "88".equals(system_code)) {
			file_path = web_url.substring(0, web_url.lastIndexOf("."));
		} else if("2".equals(store_code)) {
			file_path = system_code;	// 기존 시스템 코드 추가
			file_path += "/" + rec_date;
			file_path += "/" + rec_hour;
			file_path += "/" + file_name.substring(0, file_name.lastIndexOf("."));

			// 영구보관 콜일 경우 청취를 위해 system_code 변경
			system_code = "00";
		} else {
			file_path = rec_date;
			file_path += "/" + rec_hour;
			file_path += "/" + file_name.substring(0, file_name.lastIndexOf("."));
		}

		file_prefix = system_code + "|" + DateUtil.getToday("yyyyMMddHHmmss");
		file_ext = ("PCM".equals(type)) ? "pcm" : "wav";
		file_url = Finals.MEDIA_SERVER_URL + "/?refer=" + aes.Encrypt(file_prefix + "|" + file_path) + "." + file_ext;


		//원본 url
		logger.debug("file_url : " + Finals.MEDIA_SERVER_URL + "/?refer=" + file_prefix + "|" + file_path + "." + file_ext);
		//전송 url
		logger.debug("file_url : " + file_url);

	} catch (Exception e) {
		logger.error(e.getMessage());
		return "ERR" + e.getMessage();
	}
	return file_url;
}

/**
 * 녹취파일 청취 URL 리턴
 * @param type : 구분 (현재 사용안함)
 * @param data : 녹취 데이터 map
 * @return
 */
public static String getListenURL2(String type, Map<String, Object> data, Logger logger, String type2) {
	String file_url = "";
	String file_prefix = "";
	String file_path = "";
	String file_ext = "";
	try {
		String rec_date = data.get("rec_date").toString();
		String rec_hour = data.get("rec_start_time").toString().substring(0,2);
		String file_name = data.get("rec_filename").toString();
		String system_code = data.get("system_code").toString();
		String store_code = data.get("rec_store_code").toString();
		String web_url = data.get("web_url").toString();

		// 파라미터 체크
		if(!CommonUtil.hasText(rec_date) || !CommonUtil.hasText(rec_hour) || !CommonUtil.hasText(file_name) || !CommonUtil.hasText(system_code)) {
			throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
		}

		// 암호화 모듈 생성
		CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());

		if("99".equals(system_code) || "88".equals(system_code)) {
			file_path = web_url.substring(0, web_url.lastIndexOf("."));
		} else if("2".equals(store_code)) {
			file_path = system_code;	// 기존 시스템 코드 추가
			file_path += "/" + rec_date;
			file_path += "/" + rec_hour;
			file_path += "/" + file_name.substring(0, file_name.lastIndexOf("."));

			// 영구보관 콜일 경우 청취를 위해 system_code 변경
			system_code = "00";
		} else {
			file_path = rec_date;
			file_path += "/" + rec_hour;
			file_path += "/" + file_name.substring(0, file_name.lastIndexOf("."));
		}

		file_prefix = system_code + "|" + DateUtil.getToday("yyyyMMddHHmmss");
		file_ext = ("PCM".equals(type)) ? "pcm" : "wav";

		logger.debug("type2 : " + type2);
		if ("RX".equals(type2)){
			file_url = Finals.MEDIA_SERVER_URL + "/?refer=" + aes.Encrypt(file_prefix + "|" + file_path + "_RX") + "." + file_ext;
			//원본 url
			logger.debug("file_url 원본RX: " + Finals.MEDIA_SERVER_URL + "/?refer=" + file_prefix + "|" + file_path + "_RX." + file_ext);
		} else if ("TX".equals(type2)) {
			file_url = Finals.MEDIA_SERVER_URL + "/?refer=" + aes.Encrypt(file_prefix + "|" + file_path + "_TX") + "." + file_ext;
			//원본 url
			logger.debug("file_url 원본TX: " + Finals.MEDIA_SERVER_URL + "/?refer=" + file_prefix + "|" + file_path + "_TX." + file_ext);
		} else {
			file_url = Finals.MEDIA_SERVER_URL + "/?refer=" + aes.Encrypt(file_prefix + "|" + file_path) + "." + file_ext;
			//원본 url
			logger.debug("file_url 원본: " + Finals.MEDIA_SERVER_URL + "/?refer=" + file_prefix + "|" + file_path + "." + file_ext);
		}


		//전송 url
		logger.debug("file_url 암호화: " + file_url);

	} catch (Exception e) {
		logger.error(e.getMessage());
		return "ERR" + e.getMessage();
	}
	return file_url;
}

/**
 * 녹취파일 청취 URL 리턴
 * @param type : 구분 (현재 사용안함)
 * @param data : 녹취 데이터 map
 * @return
 */
 public static String getListenURL3(String type, Map<String, Object> data, Logger logger, String type2) {
		String file_url = "";
		String file_prefix = "";
		String file_path = "";
		String file_ext = "";
		try {
			String rec_date = data.get("rec_date").toString();
			String rec_hour = data.get("rec_start_time").toString().substring(0,2);
			String file_name = data.get("rec_filename").toString();
			String system_code = data.get("system_code").toString();
			String store_code = data.get("rec_store_code").toString();
			String web_url = data.get("web_url").toString();

			// 파라미터 체크
			if(!CommonUtil.hasText(rec_date) || !CommonUtil.hasText(rec_hour) || !CommonUtil.hasText(file_name) || !CommonUtil.hasText(system_code)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			// 암호화 모듈 생성
			CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());

			if("99".equals(system_code) || "88".equals(system_code)) {
				file_path = web_url.substring(0, web_url.lastIndexOf("."));
			} else if("2".equals(store_code)) {
				file_path = system_code;	// 기존 시스템 코드 추가
				file_path += "/" + rec_date;
				file_path += "/" + rec_hour;
				file_path += "/" + file_name.substring(0, file_name.lastIndexOf("."));

				// 영구보관 콜일 경우 청취를 위해 system_code 변경
				system_code = "00";
			} else {
				file_path = rec_date;
				file_path += "/" + rec_hour;
				file_path += "/" + file_name.substring(0, file_name.lastIndexOf("."));
			}

			file_prefix = system_code + "|" + DateUtil.getToday("yyyyMMddHHmmss");
			file_ext = ("PCM".equals(type)) ? "pcm" : "wav";
			file_url = Finals.MEDIA_SERVER_URL + "/?refer=" + aes.Encrypt(file_prefix + "|" + file_path.replace(".wav", "") + "|" + type2 + "|aa") + ".zip";


			//원본 url
			logger.debug("file_url : " + Finals.MEDIA_SERVER_URL + "/?refer=" + file_prefix + "|" + file_path.replace(".wav", "") + "|" + type2 + "|aa" + ".zip");
			//전송 url
			logger.debug("file_url : " + file_url);

		} catch (Exception e) {
			logger.error(e.getMessage());
			return "ERR" + e.getMessage();
		}
		return file_url;
	}

/**
 * 녹취파일 청취 URL 리턴
 * @param type : 구분 (현재 사용안함)
 * @param data : 녹취 데이터 map
 * @return
 */
 public static String getListenURL4(String type, Map<String, Object> data, Logger logger, int type2, int type3) {
	 String file_url = "";
		String file_prefix = "";
		String file_path = "";
		String file_ext = "";
		try {
			String rec_date = data.get("rec_date").toString();
			String rec_hour = data.get("rec_start_time").toString().substring(0,2);
			String file_name = data.get("rec_filename").toString();
			String system_code = data.get("system_code").toString();
			String store_code = data.get("rec_store_code").toString();
			String web_url = data.get("web_url").toString();

			// 파라미터 체크
			if(!CommonUtil.hasText(rec_date) || !CommonUtil.hasText(rec_hour) || !CommonUtil.hasText(file_name) || !CommonUtil.hasText(system_code)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			// 암호화 모듈 생성
			CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());

			if("99".equals(system_code) || "88".equals(system_code)) {
				file_path = web_url.substring(0, web_url.lastIndexOf("."));
			} else if("2".equals(store_code)) {
				file_path = system_code;	// 기존 시스템 코드 추가
				file_path += "/" + rec_date;
				file_path += "/" + rec_hour;
				file_path += "/" + file_name.substring(0, file_name.lastIndexOf("."));

				// 영구보관 콜일 경우 청취를 위해 system_code 변경
				system_code = "00";
			} else {
				file_path = rec_date;
				file_path += "/" + rec_hour;
				file_path += "/" + file_name.substring(0, file_name.lastIndexOf("."));
			}

			file_prefix = system_code + "|" + DateUtil.getToday("yyyyMMddHHmmss");
			file_ext = ("PCM".equals(type)) ? "pcm" : "wav";
			file_url = Finals.MEDIA_SERVER_URL + "/?refer=" + aes.Encrypt(file_prefix + "|" + file_path.replace(".wav", "") + "|" + type2 + "|" + type3 + "|"+ file_path) + ".par";


			//원본 url
			logger.debug("file_url4 : " + Finals.MEDIA_SERVER_URL + "/?refer=" + file_prefix + "|" + file_path.replace(".wav", "") + "|" + type2 + "|" + type3 + "|"+ file_path + ".par");
			//전송 url
			logger.debug("file_url4 : " + file_url);

		} catch (Exception e) {
			logger.error(e.getMessage());
			return "ERR" + e.getMessage();
		}
		return file_url;
	}

 /**
  * 녹취파일 청취 URL 리턴
  * @param type : 구분 (현재 사용안함)
  * @param data : 녹취 데이터 map
  * @return
  */
 public static String getListenURL5(String type, Map<String, Object> data, Logger logger) {
	 String file_url = "";
		String file_prefix = "";
		String file_path = "";
		String file_ext = "";
		try {
			String rec_date = data.get("rec_date").toString();
			String rec_hour = data.get("rec_start_time").toString().substring(0,2);
			String file_name = data.get("rec_filename").toString();
			String system_code = data.get("system_code").toString();
			String store_code = data.get("rec_store_code").toString();
			String web_url = data.get("web_url").toString();

			// 파라미터 체크
			if(!CommonUtil.hasText(rec_date) || !CommonUtil.hasText(rec_hour) || !CommonUtil.hasText(file_name) || !CommonUtil.hasText(system_code)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			// 암호화 모듈 생성
			CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());

			if("99".equals(system_code) || "88".equals(system_code)) {
				file_path = web_url.substring(0, web_url.lastIndexOf("."));
			} else if("2".equals(store_code)) {
				file_path = system_code;	// 기존 시스템 코드 추가
				file_path += "/" + rec_date;
				file_path += "/" + rec_hour;
				file_path += "/" + file_name.substring(0, file_name.lastIndexOf("."));

				// 영구보관 콜일 경우 청취를 위해 system_code 변경
				system_code = "00";
			} else {
				file_path = rec_date;
				file_path += "/" + rec_hour;
				file_path += "/" + file_name.substring(0, file_name.lastIndexOf("."));
			}

			file_prefix = system_code + "|" + DateUtil.getToday("yyyyMMddHHmmss");
			file_ext = ("PCM".equals(type)) ? "pcm" : "wav";
			file_url = Finals.MEDIA_SERVER_URL + "/?refer=" + aes.Encrypt(file_prefix + "|" + file_path) + "." + file_ext;
			//file_url = Finals.MEDIA_SERVER_URL + "/?refer=" + aes.Encrypt(file_prefix + "|" + file_path) + ".dwn";


			//원본 url
			logger.debug("file_url : " + Finals.MEDIA_SERVER_URL + "/?refer=" + file_prefix + "|" + file_path + "." + file_ext);
			//logger.debug("file_url : " + Finals.MEDIA_SERVER_URL + "/?refer=" + file_prefix + "|" + file_path + ".dwn");
			//전송 url
			logger.debug("file_url : " + file_url);

		} catch (Exception e) {
			logger.error(e.getMessage());
			return "ERR" + e.getMessage();
		}
		return file_url;
 }

/**
 * 녹취파일 청취 URL 리턴
 * @param type : 구분 (현재 사용안함)
 * @param file_path : 녹취파일 경로
 * @return
 */
public static String getListenURL(String type, String file_path, Logger logger) {
	String file_url = "";
	String file_ext = "";

	try {
		// 파라미터 체크
		if(!CommonUtil.hasText(file_path)) {
			throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
		}

		// 암호화 모듈 생성
		CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());

		file_path = file_path.substring(0, file_path.lastIndexOf("."));

		file_ext = ("PCM".equals(type)) ? "pcm" : "wav";

		file_url = Finals.MEDIA_SERVER_URL + "/?refer=" + aes.Encrypt(DateUtil.getToday("yyyyMMddHHmmss") + "|" + file_path) + "." + file_ext;

		//원본 url
		logger.debug("file_url : " + Finals.MEDIA_SERVER_URL + "/?refer=" + DateUtil.getToday("yyyyMMddHHmmss") + "|" + file_path + "." + file_ext);
		//전송 url
		logger.debug("file_url : " + file_url);
	} catch (Exception e) {
		logger.error(e.getMessage());
		return "ERR" + e.getMessage();
	}

	return file_url;
}

/**
 * APP 녹취파일 청취 URL 리턴
 * @param type : URL 구분 (L:청취 / D:다운로드)
 * @param data : 녹취 데이터 map
 * @return
 */
 public static String getListenURLApp(String type, Map<String, Object> data, Logger logger) {
	String file_url = "";

	try {

	} catch (Exception e) {
		logger.error(e.getMessage());
		return "ERR" + e.getMessage();
	}

	return file_url;
}

/**
 * 녹취파일 청취 URL 리턴
 * @param addr : 서버 아이피
 * @param header : 전송 전문
 * @return
 */
public static String getListenUrlDecode(String addr, String header) throws Exception {
	DatagramSocket ds = null;
	String file_url = "";
	String file_name = "";
	int port = 1002;

	try {
		// 파일명 추출
		file_name = header.substring(header.toString().lastIndexOf("\\")+1);

		// UDP 통신 수신 전문
		ds = new DatagramSocket();

		// send data 설정
		InetAddress address = InetAddress.getByName(addr);
		byte[] buf = header.getBytes();

		// send
		DatagramPacket packet = new DatagramPacket(buf, buf.length, address, port);
		ds.send(packet);
		// timeout
		ds.setSoTimeout(2000);

		// receive
		buf = new byte[40000];
		packet = new DatagramPacket(buf, buf.length);
		String recv = "";

		while(true) {
			try {
				ds.receive(packet);
				recv = new String(packet.getData()).trim();
				break;
			} catch (SocketTimeoutException se) {
				throw new Exception("소켓 데이터 수신에 실패했습니다.");
			}
		}

		if("OK".equals(recv.substring(0, 2))) {
			file_url = "http://" + addr + "/AES/" + file_name;
		} else {
			throw new Exception("녹취파일 복호화에 실패했습니다.[" + recv + "]");
		}
	}
	catch (Exception e) {
		throw new Exception(e.getMessage());
	}
	finally{
		if(ds!=null) ds.close();
	}

	return file_url;
}
%>
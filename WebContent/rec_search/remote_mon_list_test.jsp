<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="java.net.DatagramSocket"%>
<%@ page import="java.net.DatagramPacket"%>
<%@ page import="java.net.InetAddress"%>
<%@ page import="java.net.SocketTimeoutException"%>
<%
	if(!Site.isPmss(out,"mon_list","")) return;

	DatagramSocket ds = null;

	try {
		// get parameter
		String system_ip = CommonUtil.getParameter("system_ip");

		// 파라미터 체크
		if(!CommonUtil.hasText(system_ip)) {
			out.print(CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// UDP 통신 수신 전문
		ds = new DatagramSocket();

		// send data 설정
		InetAddress address = InetAddress.getByName(system_ip);
		int port = 9998;
		//String header = "MON000000X";
		String header = "NON";
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
				recv = new String(packet.getData(), "EUC-KR").trim();
				break;
			} catch (SocketTimeoutException se) {
				out.print("소켓 데이터 수신에 실패했습니다.");
				ds.close();
				throw new Exception(se);
			}
		}

		// receive data
		//logger.debug("receive data : " + recv);

		out.print("receive data : " + recv);
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		// socket close
		if (ds != null) ds.close();
	}
%>
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
		String s_local_no = CommonUtil.getParameter("local_no");

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
		String header = "MON000000X";
		//String header = "NON";
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
		logger.debug("receive data : " + recv);

		// example data
		//String recv = "MON112333X02C 107372  43732  63640D1793032 965021 82801109000125000700 701 E17001	   박현주			  1101	2112130025442468   00225000700 701 E17004	   이우리			  1102	211214101086603029 0031			E								1103	1				  0041			E								1104	1				  00515000700 701 E17003	   김형이			  1105	1111601			0061			E								1106	1				  00712000300 301 E12001	   김봄시내			1201	1094419			0082200021002101E12012	   김래희			  1202	211225901031016884 00912000300 301 E12008	   장인애			  1203	1112323			01022000300 301 E12009	   김효정			  1204	211232201088541444 01112000300 301 E12013	   채송아			  1205	1175951			0121			E								1206	1				  0131			E12026						   1207	1				  0141			E								1208	1				  0151			E								1209	1				  01612000300 301 E12003	   박소윤			  1210	1170034			01722000300 301 E12014	   신선화			  1211	211225101064736435 01812000300 301 E12016	   임태미			  1212	1175906			01912000300 301 E12025	   정수강			  1213	1125457			0201			E								1214	1				  02112000300 301 E12017	   임자영			  1109	1210147			0221			E								1110	1				  0231100010001002E11011	   정가영			  1111	1111058			0241100010001001E11012	   이인애			  1112	1105759			0251100010001002E11013	   우혜리			  1113	1112041			02613000400 401 E13001	   정지야			  1301	1111949			02723000400 401 E13003	   변명화			  1302	211225001099179793 02813000400 401 E13008	   한향숙			  1303	1111925			0291			E								1304	1				  0301			E								1305	1				  03113000400 401 E13007	   김혜숙			  1306	1112037			03212000300 301 E12019	   최은영			  1221	1210139			0331			E								1107	1				  03412000300 301 E12002	   이종희			  1108	1205854			0351100010001001E11014	   어인영			  1114	1102407			0361100010001001E11015	   홍지윤			  1115	1111201			0371			E								1116	1				  0381			E								1117	1				  0391			E								1118	1				  04014000500 506 E16012	   김동규			  1601	1191840			04114000500 506 E16020	   김용호			  1602	1210148			04214000500 506 E16030	   이인규			  1603	1205904			04314000500 502 E16074	   최수희			  1604	1112027			04414000500 502 E16050	   서희경			  1605	1144441			04514000500 502 E16056	   정솔이			  1606	1112313			04624000500 502 E16055	   김유진			  1607	21122140328308203  0471400041004101E16081	   김미경			  1608	1180444			04814000500 502 E16090	   고아름			  1609	1222534			0491400041004101E16040	   안소연2			 1610	1165850			0501400041004101E16037	   장기원			  1611	1111013			0511			E								1612	1				  05224000500 502 E16051	   한이임철			1613	211195201028995118 0531400041004101E16064	   장혜원			  1614	1210201			05414000500 502 E16083	   이명화			  1615	1110524			05514000500 502 E16042	   채소망			  1616	1111549			05614000500 502 E16048	   김효진			  1617	1111757			05714000500 505 E16058	   이수연			  1618	1090441			05814000500 501 E16047	   최성룡			  1619	1095137			05914000500 505 E16072	   오은경			  1620	1092033			06014000500 502 E16043	   장혜원			  1621	1090558			06114000500 501 E16049	   이형정			  1622	1145238			06214000500 502 E16066	   장휘현			  1623	1172506			06314000500 502 E16042	   채소망			  1624	1				  06414000500 505 E16071	   이준상			  1625	1090046			06514000500 506 E16012	   김동규			  1626	1095901			0661400041004101E16039	   박선라2			 1627	1090531			0671400041004101E16034	   이성호			  1628	1085255			06814000500 502 E16076	   정유정			  1629	1154804			06914000500 506 E16077	   황은지			  1630	1173220			07014000500 502 E16078	   이성원			  1631	1155059			07114000500 507 E14007	   홍승연			  1632	1102810			0721			E								1633	1				  07314000500 506 E16096	   이준일			  1634	1112214			07414000500 506 E16028	   이대경			  1635	1180556			07524000500 506 E16020	   김용호			  1636	211231390319671591 07614000500 506 E16030	   이인규			  1637	1085406			07714000500 506 E16015	   김지현			  1638	1210335			07814000500 506 E16099	   이상현			  1639	1090743			0791			E								1640	1				  08014000500 506 E16024	   김문수			  1641	1181747			08114000500 506 E16023	   임상우			  1642	1090536			08214000500 506 E16021	   이주창			  1643	1084452			08314000500 506 E16025	   고대훈			  1644	1085248			08414000500 501 E16061	   한경화			  1645	1094029			08514000500 502 E16079	   장경아			  1646	1150158			0861			E								1215	1				  0871			E								1216	1				  08814000500 506 E16060	   이지현			  1647	1173201			0891400041004101E16038	   박미선			  1648	1112250			0901			E										1";

		int hdd_cnt = 0;
		int ch_cnt = 0;
		int p = 0;
		String hdd_data = "";
		String ch_data = "";

		// 헤더 정보 삭제 (MON163335X)
		recv = recv.substring(10);

		// 하드 수량
		hdd_cnt = Integer.parseInt(recv.substring(0,2));

		// 하드 데이터
		hdd_data = recv.substring(2, (hdd_cnt*22)+2);

		// 하드 데이터 삭제 (D 718278 176349 541929E 165277 158941   6336)
		recv = recv.substring((hdd_cnt*22)+2);

		// 채널 수
		ch_cnt = Integer.parseInt(recv.substring(0,3));

		// 채널 데이터 (채널 데이터 삭제, 061)
		ch_data = recv.substring(3);
%>
	<!--HDD 데이터 table-->
	<div class="tableSize2">
		<table class="table top-line1 table-bordered">
			<thead>
				<tr>
					<th style="width:10%;">디스크 명</th>
					<th style="width:25%;">사용량 / 총 용량</th>
					<th style="width:15%;">사용률</th>
					<th style="width:10%;">디스크 명</th>
					<th style="width:25%;">사용량 / 총 용량</th>
					<th style="width:15%;">사용률</th>
				</tr>
			</thead>
			<tbody>
<%
	if(hdd_cnt>0) {
		out.print("<tr>\n");
		String hdd_name = "";
		Float hdd_total = 0.0f;
		Float hdd_use = 0.0f;
		Float hdd_free = 0.0f;
		for(int i=0;i<hdd_cnt;i++) {
			if(i!=0 && i%2==0) {
				out.print("</tr><tr class='odd'>");
			}

			hdd_name = hdd_data.substring(p+0, p+1);
			hdd_total = Float.parseFloat(hdd_data.substring(p+1, p+8).trim());
			hdd_free = Float.parseFloat(hdd_data.substring(p+8, p+15).trim());
			hdd_use = Float.parseFloat(hdd_data.substring(p+15, p+22).trim());

			out.print("<td>" + hdd_name + " Drive</td>");
			out.print("<td>" + Math.round(hdd_use/1024*100)/100.0 + "G / " + Math.round(hdd_total/1024*100)/100.0 + "G</td>");
			out.print("<td>" + Math.round(hdd_use/hdd_total*100*100)/100.0 + "%</td>");

			p+=22;
		}
		if(hdd_cnt%2==1) {
			out.print("<td></td>");
			out.print("<td></td>");
			out.print("<td></td>");
		}
		out.print("</tr>\n");
	}
%>
			</tbody>
		</table>
	</div>
	<!--내선번호 영역 시작-->
	<div class="grey_back1">
<%
	/* 전문정보
		-----------------------------------------------------------------------------
		구분			자릿수	위치			값
		-----------------------------------------------------------------------------
		채널번호		3		0-2			001
		채널종류		1		3			2
		대분류		4		4-7			5000
		중분류		4		8-11		700\s
		소분류		4		12-15		701\s
		레벨			1		16			E
		아이디		12		17-28		17001\s\s\s\s\s\s\s
		상담원명		20		29-48		박현주\s\s\s\s\s\s\s\s\s\s\s\s\s\s (한글 2자리)
		내선번호		8		49-56		1101\s\s\s\s
		상태			1		57			2
		상태변경시간	6		58-63		112130
		고객전화번호	12		64-75		025442468\s\s\s
		-----------------------------------------------------------------------------
	*/
	if(ch_cnt>0) {
		p = 0;
		int h_cnt = 0;
		// 채널 1개당 문자열 수
		int per_ch_cnt = 76;
		String ch_no = "";
		String user_name = "";
		String user_id = "";
		String local_no = "";
		String ch_status = "";
		String status_cls = "";

		for(int i=0;i<ch_cnt;i++) {
			ch_no = ch_data.substring(p+0,p+3).trim();
			// 상담원명 중 한글 개수 카운트
			h_cnt = CommonUtil.getHangulCnt(ch_data.substring(p+29,p+49));
				user_id = ch_data.substring(p+17,p+29-h_cnt).trim();
			user_name = ch_data.substring(p+29,p+49-h_cnt).trim();
			local_no = ch_data.substring(p+49-h_cnt,p+57-h_cnt).trim();
			ch_status = ch_data.substring(p+57-h_cnt,p+58-h_cnt).trim();

			// 상태별 색상 설정
			if("1".equals(ch_status)) {										// 대기
				status_cls = "1";
			} else if("2".equals(ch_status) || "3".equals(ch_status)) {		// 녹취 상태
				status_cls = "2";
			} else {														// 녹취 불량
				status_cls = "3";
			}

			if("".equals(s_local_no) || (!"".equals(s_local_no) && local_no.equals(s_local_no))) {
				out.print("<div class=\"ext_frame\">\n");
				out.print("	<div class=\"ext_number ext_bg0" + status_cls + "\" style=\"cursor: pointer;\" onclick=\"playRlisten('" + status_cls + "','" + ch_no + "','" + local_no + "','01','" + user_id + "','" + user_name + "')\">" + ch_no + "</div>\n");
				out.print("	<div class=\"ext_name\">\n");
				out.print("		<span>" + user_name + "</span>\n");
				out.print("		<span style=\"font-size:12px;color:#666;\">" + local_no + "</span>\n");
				out.print("	</div>\n");
				out.print("</div>\n");
			}

			p+=per_ch_cnt-h_cnt;
		}
	}
%>
	</div>
	<!--HDD 데이터 table 끝-->
	<div class="grey_back2">
		<div class="colLeft"><span class="ext_squre01 colLeft"></span><span class="ext_text">대기상태</span></div>
		<div class="colLeft"><span class="ext_squre02 colLeft"></span><span class="ext_text">녹취상태</span></div>
		<div class="colLeft"><span class="ext_squre03 colLeft"></span><span class="ext_text">녹취불량</span></div>
	</div>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		// socket close
		if (ds != null) ds.close();
	}
%>
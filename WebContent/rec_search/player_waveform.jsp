<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="java.io.*"%>
<%@ page import="java.net.URL"%>
<%@ page import="java.net.HttpURLConnection"%>
<%@ page import="java.awt.*"%>
<%@ page import="java.awt.geom.*"%>
<%@ page import="Acme.JPM.Encoders.GifEncoder"%>
<%
	try {
		// get parameter
		String file_url = request.getParameter("url");

		// 파라미터 체크
		if(!CommonUtil.hasText(file_url)) {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// 파일 확장자 변경
		file_url = file_url.replace(".wav", ".fft");

		// get waveform data
		URL url = new URL(file_url);

		HttpURLConnection httpconn = (HttpURLConnection) url.openConnection();
		httpconn.setConnectTimeout(10000);

		if(httpconn.getResponseCode()!=HttpURLConnection.HTTP_OK) {
			Site.writeJsonResult(out, false, "미디어 서버 연결에 실패했습니다.");
			return;
		}

		BufferedReader in = new BufferedReader(new InputStreamReader(httpconn.getInputStream()));
		String inputLine = "";
		StringBuffer sb = new StringBuffer();

		while((inputLine=in.readLine())!=null) {
			sb.append(inputLine);
		}

		in.close();
		httpconn.disconnect();

		// data check
		if(sb.toString().toLowerCase().indexOf("error")>-1) {
			Site.writeJsonResult(out, false, "미디어 서버에 오류가 발생하였습니다.");
			return;
		}

		// image create
		Frame frame = null;
		Graphics2D g = null;
		Rectangle2D rect = null;

		int width = 534;
		int height = 80;
		int mid = height/2;

		frame = new Frame();
		frame.addNotify();

		Image image = frame.createImage(width, height);
		g = (Graphics2D) image.getGraphics();

		// draw background
		//g.setColor(new Color(79, 78, 101));
		g.setColor(new Color(23, 26, 32));
		g.fillRect(0, 0, width, height);

		// progress data create
		ArrayList<Double> data = new ArrayList<Double>();
		ArrayList<Double> newdata = new ArrayList<Double>();

		int i=0, before=0, after=0;
		double sfactor=0, atpoint=0, tmp=0;

		// string data -> double data
		String[] tmpdata = sb.toString().split(",");

		for(i=0;i<tmpdata.length;i++) {
			data.add(Double.parseDouble(tmpdata[i]));
		}

		// create newdata
		sfactor = (double) (data.size()-1) / (width-1);

		newdata.add(data.get(0));
		i=1;
		while(i<width-1) {
			tmp = i*sfactor;
			before = (int) Math.floor(tmp);
			after = (int) Math.ceil(tmp);
			atpoint = tmp-before;

			newdata.add(data.get(before)+(data.get(after)-data.get(before))*atpoint);
			i++;
		}
		newdata.add(data.get(data.size()-1));

		// draw progress image
		int w = width/newdata.size();

		//g.setColor(new Color(168, 219, 168));
		g.setColor(new Color(50, 255, 255));

		for(int j=0;j<newdata.size();j++) {
			rect = new Rectangle2D.Double((w * j), (mid-mid*newdata.get(j)), w, (mid*newdata.get(j)*2));
			g.draw(rect);
		}

		// out image
		response.setContentType("image/gif");
		out.clear();
		GifEncoder encoder = new GifEncoder(image, response.getOutputStream());

		encoder.encode();
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {

	}
out.flush();
%>
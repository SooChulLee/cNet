<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_stat","")) return;

	try {
		Site.setExcelHeader(response, out, "상담원별통계-평가점수");

		String dataStr 		= ComLib.getPSNN(request,"data");
		String itemDataStr 	= ComLib.getPSNN(request,"itemData");

		JSONParser jsonParser = new JSONParser();
		//System.out.println(dataStr);
		JSONArray data 		= (JSONArray) jsonParser.parse(dataStr);
		JSONArray itemData 	= (JSONArray) jsonParser.parse(itemDataStr);
		//System.out.println("itemDataStr="+itemDataStr);
		int itemSize = itemData.size();

		StringBuffer sb = new StringBuffer();

		sb.append
			("<table border='1' bordercolor='#bbbbbb'>").append
				("<tr align='center'>").append
				("<td class=th>대분류</td>").append
				("<td class=th>중분류</td>").append
				("<td class=th>소분류</td>").append

				("<td class=th>상담원 ID</td>").append
				("<td class=th>상담원 명</td>").append

				("<td class=th>평가차수</td>").append
				("<td class=th>평가자</td>").append
				("<td class=th>평가일</td>");

		for(int i=0; i<itemSize; i++) {
			JSONObject d = (JSONObject) itemData.get(i);
			sb.append("<td class=th><nobr>"+d.get("item_name")+"<br>["+d.get("exam_score_max")+"<font color=gray>/</font>"+d.get("add_score_max")+"]</td>");
		}

		sb.append("<td class=th>총점</td>");
		sb.append("<td class=th>코멘트</td>");
		sb.append("<td class=th>총평</td>");
		sb.append("</tr>");

		int sum_eval_cnt = 0;
		int sum_exam_score_tot = 0;
		int sum_add_score_tot = 0;
		int sum_eval_score = 0;
		int sum_best_cnt = 0;
		int sum_worst_cnt = 0;

		for(int i=0, len=data.size();i<len;i++) {
			JSONObject d = (JSONObject) data.get(i);

			if(ComLib.toNN(d.get("kind")).equals("subSum")){
				int eval_cnt = ComLib.toINN(d.get("eval_cnt"),1);
				sb.append("<tr><td class=subSum colspan=8 style=text-align:left>소계</td>");
				for(int ii=0; ii<itemSize; ii++) {
					JSONObject dd = (JSONObject) itemData.get(ii);
					sb.append("<td class=subSum>&nbsp;"+d.get("item_score_"+dd.get("item_code"))+"</td>");
				}
				sb.append("<td class=subSum><font color=blue>"+d.get("best_cnt")+"</font><font color=#aaaaaa>/</font><font color=red>"+ d.get("worst_cnt") +"</font><font color=#aaaaaa>/</font>"+ ComLib.round(Double.parseDouble(d.get("eval_score").toString())/eval_cnt,0) +"<font color=#aaaaaa>/</font>"+ ComLib.round((double)sum_exam_score_tot/eval_cnt,0) +"<font color=#aaaaaa>/</font>"+ d.get("add_score_tot")+"</td><td class=subSum colspan=2></td>");
			}
			else{
				// 총계 저장
				sum_eval_cnt		+= ComLib.toINN(d.get("eval_cnt"),1);
				sum_exam_score_tot	+= ComLib.toINN(d.get("exam_score_tot"));
				sum_add_score_tot	+= ComLib.toINN(d.get("add_score_tot"));
				sum_eval_score		+= ComLib.toINN(d.get("eval_score"));
				sum_best_cnt		+= ComLib.toINN(d.get("best_cnt"));
				sum_worst_cnt		+= ComLib.toINN(d.get("worst_cnt"));

				sb.append("<tr class=l>");
				if(d.get("user_id").equals("")){
					sb.append("<td colspan=5></td>");
					//sb.append("<td></td><td></td><td></td><td></td><td></td>");
				}
				else{
					sb.append("<td>" + ComLib.toNN(d.get("bpart_name"),"-") + "</td>");
					sb.append("<td>" + ComLib.toNN(d.get("mpart_name"),"-") + "</td>");
					sb.append("<td>" + ComLib.toNN(d.get("spart_name"),"-") + "</td>");
					sb.append("<td>" + d.get("user_id") + "</td>");
					sb.append("<td>" + d.get("user_name") + "</td>");
				}

				sb.append("<td>" + ComLib.nvl2(d.get("eval_order"), d.get("eval_order") + "차","-")+"</td>");
				sb.append("<td>" + d.get("eval_user_name") + "</td>");
				sb.append("<td class=c>" + d.get("upd_datm") + "</td>");

				for(int ii=0; ii<itemSize; ii++) {
					JSONObject dd = (JSONObject) itemData.get(ii);
					sb.append("<td class=r>&nbsp;"+d.get("item_score_"+dd.get("item_code"))+"</td>");
				}

				String bestWorst = (d.get("best_cnt").toString().equals("1")) ? "<font color=blue>ⓑ</font>" : (d.get("worst_cnt").toString().equals("1")) ? "<font color=red>ⓦ</font>" : "";
				sb.append("<td class=r>"+bestWorst + ComLib.toINN(d.get("eval_score")) +"<font color=#arraaaaa>/</font>"+ ComLib.toINN(d.get("exam_score_tot")) +"<font color=#aaaaaa>/</font>"+ ComLib.toINN(d.get("add_score_tot"))+"</td>");
				sb.append("<td>" + d.get("eval_comment") + "</td>");
				sb.append("<td>" + d.get("eval_text") + "</td>");
			}

		}
		if(data.size()>0){
			sb.append
				("<tr><td class=sum colspan="+(8+itemSize)+" style=text-align:left><b>총계</b></td>").append
				("<td class=sum><font color=blue>"+sum_best_cnt+"</font><font color=#aaaaaa>/</font><font color=red>"+ sum_worst_cnt +"</font><font color=#aaaaaa>/</font>"+ ComLib.round((double)sum_eval_score/sum_eval_cnt,0) +"<font color=#aaaaaa>/</font>"+ ComLib.round((double)sum_exam_score_tot/sum_eval_cnt,0) +"<font color=#aaaaaa>/</font>"+ sum_add_score_tot+"</td><td class=sum colspan=2></td>");
		}
		sb.append("</table>");
		//System.out.println(sb.toString());

		out.print(sb.toString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {

	}
%>
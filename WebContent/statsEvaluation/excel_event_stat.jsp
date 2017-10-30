<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
if(!Site.isPmss(out,"event_stat")) return;

Db db = null;

try {
	Site.setExcelHeader(response, out, "이벤트별통계");

	db = new Db(true);

	// get parameter
	String showType = CommonUtil.getParameter("showType","garo");
	String sort_idx = CommonUtil.getParameter("sort_idx", "event_code");
	String sort_dir = CommonUtil.getParameter("sort_dir", "down");
	String sort_idx2 = CommonUtil.getParameter("sort_idx2", "eval_order");
	String sort_dir2 = CommonUtil.getParameter("sort_dir2", "up");
	String eval_date1 = CommonUtil.getParameter("eval_date1");
	String eval_date2 = CommonUtil.getParameter("eval_date2");
	String event_code = CommonUtil.getParameter("event_code");
	String sheet_code = CommonUtil.getParameter("sheet_code");
	int eval_order_max = ComLib.getPI(request,"eval_order_max");

	sort_dir  = ("down".equals(sort_dir)) ? "desc" : "asc";
	sort_dir2 = ("down".equals(sort_dir2)) ? "desc" : "asc";

	StringBuffer sb = new StringBuffer();

	sb.append("<table border='1' bordercolor='#bbbbbb'>");
	sb.append("<tr align='center'>");
	sb.append("<td class=th>이벤트 명</td>");
	sb.append("<td class=th>문항수/배점</td>");
	sb.append("<td class=th>가중치</td>");
	if(showType.equals("garo")){
		for(int i=1; i <= eval_order_max; i++){
			sb.append("<td class=th>"+i+"차</td>");
		}
	}
	else{
		sb.append("<td class=th>평가차수</td>");
	}
	sb.append("<td class=th>평균점수</td>");
	sb.append("<td class=th>평가수</td>");
	sb.append("<td class=th>총점</td>");
	sb.append("<td class=th>항목점수</td>");
	sb.append("<td class=th>가중치점수</td>");
	sb.append("<td class=th>베스트</td>");
	sb.append("<td class=th>워스트</td>");
	sb.append("</tr>");

	Map<String, Object> argMap = new HashMap<String, Object>();

	argMap.put("eval_date1",eval_date1.replace("-", ""));
	argMap.put("eval_date2",eval_date2.replace("-", ""));
	argMap.put("event_code",event_code);
	argMap.put("sheet_code",sheet_code);
	argMap.put("sort_idx", sort_idx);
	argMap.put("sort_dir", sort_dir);
	argMap.put("sort_idx2", sort_idx2);
	argMap.put("sort_dir2", sort_dir2);
	argMap.put("eval_order_max", eval_order_max);

	// record select
	String dbXmlName = (showType.equals("garo")) ? "stat_event.selectListAllOrder" : "stat_event.selectList";
	List<Map<String, Object>> list = db.selectList(dbXmlName, argMap);

	int sum_tot_eval_cnt = 0;
	int sum_tot_exam_score = 0;
	int sum_tot_add_score = 0;
	int sum_tot_eval_score = 0;
	int sum_tot_best_cnt = 0;
	int sum_tot_worst_cnt = 0;

	int sum_tot[] = ComLib.makeIntArray(eval_order_max,0);
	int cnt_tot[] = ComLib.makeIntArray(eval_order_max,0);

	int sum1_tot=0, cnt1_tot=0;
	int sum2_tot=0, cnt2_tot=0;
	int sum3_tot=0, cnt3_tot=0;
	int sum4_tot=0, cnt4_tot=0;
	int sum5_tot=0, cnt5_tot=0;

	for(Map<String, Object> item : list) {
		// 총계 저장
		sum_tot_eval_cnt	+= ComLib.toINN(item.get("tot_eval_cnt"));
		sum_tot_exam_score	+= ComLib.toINN(item.get("tot_exam_score"));
		sum_tot_add_score	+= ComLib.toINN(item.get("tot_add_score"));
		sum_tot_eval_score	+= ComLib.toINN(item.get("tot_eval_score"));
		sum_tot_best_cnt	+= ComLib.toINN(item.get("tot_best_cnt"));
		sum_tot_worst_cnt	+= ComLib.toINN(item.get("tot_worst_cnt"));

		if(showType.equals("garo")){
			for(int i=1; i <= eval_order_max; i++) {
				sum_tot[i-1] += ComLib.toINN(item.get("sum"+i));
				cnt_tot[i-1] += ComLib.toINN(item.get("cnt"+i));
			}
		}
		sb.append("<tr align=right>");
		sb.append("<td>" + item.get("event_name") + "</td>");
		sb.append("<td>" + item.get("item_cnt") + "/" + item.get("tot_score") + "</td>");
		sb.append("<td>" + item.get("add_score") + "</td>");

		if(showType.equals("garo")){
			for(int i=1; i <= eval_order_max; i++) {
				sb.append("<td>" + ((item.get("cnt"+i).toString().equals("0")) ? "-" : ComLib.calcRound(item.get("sum"+i), item.get("cnt"+i), 2)) + "</td>");
			}
		}
		else{
			sb.append("<td>" + item.get("eval_order")+"차" + "</td>");
		}
		sb.append("<td>" + ((item.get("tot_eval_cnt").equals("0")) ? "0" : ComLib.calcRound(item.get("tot_eval_score"), item.get("tot_eval_cnt"), 2)) + "</td>");
		sb.append("<td>" + item.get("tot_eval_cnt") + "</td>");
		sb.append("<td>" + item.get("tot_eval_score") + "</td>");
		sb.append("<td>" + item.get("tot_exam_score") + "</td>");
		sb.append("<td>" + item.get("tot_add_score") + "</td>");
		sb.append("<td>" + item.get("tot_best_cnt") + "</td>");
		sb.append("<td>" + item.get("tot_worst_cnt") + "</td>");
		sb.append("</tr>");
	}

	if(list.size()>0) {
		sb.append("<tr>");
		sb.append("<td class=sum colspan=3 style=text-align:center><b>총계</b></td>");

		if(showType.equals("garo")){
			for(int i=0; i < eval_order_max; i++) {
				sb.append("<td class=sum>" + ((cnt_tot[i]==0) ? "-" : ComLib.round((double)sum_tot[i]/cnt_tot[i],2)) + "</td>");
			}
		}
		else{
			sb.append("<td class=sum></td>");
		}
		sb.append("<td class=sum>" + ((sum_tot_eval_cnt>0) ? ComLib.round((double)sum_tot_eval_score/sum_tot_eval_cnt,2) : 0) + "</td>");
		sb.append("<td class=sum>" + sum_tot_eval_cnt + "</td>");
		sb.append("<td class=sum>" + sum_tot_eval_score + "</td>");
		sb.append("<td class=sum>" + sum_tot_exam_score + "</td>");
		sb.append("<td class=sum>" + sum_tot_add_score + "</td>");
		sb.append("<td class=sum>" + sum_tot_best_cnt + "</td>");
		sb.append("<td class=sum>" + sum_tot_worst_cnt + "</td>");
		sb.append("</tr>");
	}
	sb.append("</table>");
	out.print(sb.toString());
} catch(Exception e) {
	logger.error(e.getMessage());
	out.println("ERROR :: "+e);
} finally {
	if(db!=null) db.close();
}
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"dept_stat","")) return;

	Db db = null;

	try {
		Site.setExcelHeader(response, out, "부서별통계");

		db = new Db(true);

		// get parameter
		String groupDepth = CommonUtil.getParameter("groupDepth","1");
		String showType = CommonUtil.getParameter("showType","garo");
		String sort_idx = CommonUtil.getParameter("sort_idx", "bpart_name");
		String sort_dir = CommonUtil.getParameter("sort_dir", "up");
		String eval_date1 = CommonUtil.getParameter("eval_date1");
		String eval_date2 = CommonUtil.getParameter("eval_date2");
		String event_code = CommonUtil.getParameter("event_code");
		String sheet_code = CommonUtil.getParameter("sheet_code");
		String bpart_code = CommonUtil.getParameter("bpart_code");
		String mpart_code = CommonUtil.getParameter("mpart_code");
		String spart_code = CommonUtil.getParameter("spart_code");
		String eval_user_name = CommonUtil.getParameter("eval_user_name");
		int eval_order_max = ComLib.getPI(request,"eval_order_max");

		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		StringBuffer sb = new StringBuffer();
		sb.append("<table border='1' bordercolor='#bbbbbb'>");
		sb.append("<tr align='center'>");
		sb.append("<td class=th>대분류</td>");
		sb.append("<td class=th>중분류</td>");
		if(groupDepth.equals("1")){
			sb.append("<td class=th>소분류</td>");
		}
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

		// search
		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("eval_date1",eval_date1.replace("-", ""));
		argMap.put("eval_date2",eval_date2.replace("-", ""));
		argMap.put("event_code",event_code);
		argMap.put("sheet_code",sheet_code);
		argMap.put("bpart_code",bpart_code);
		argMap.put("mpart_code",mpart_code);
		argMap.put("spart_code",spart_code);
		argMap.put("eval_user_name",eval_user_name);
		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);
		argMap.put("eval_order_max", eval_order_max);

		String dbXmlName = (groupDepth.equals("1")) ?
				(showType.equals("garo")) ? "stat_dept.selectListAllOrder1" : "stat_dept.selectList1" :
				(showType.equals("garo")) ? "stat_dept.selectListAllOrder2" : "stat_dept.selectList2" ;
		List<Map<String, Object>> list = db.selectList(dbXmlName, argMap);

		int sum_tot_eval_cnt = 0;
		int sum_tot_exam_score = 0;
		int sum_tot_add_score = 0;
		int sum_tot_eval_score = 0;
		int sum_tot_best_cnt = 0;
		int sum_tot_worst_cnt = 0;

		int sum_tot[] = ComLib.makeIntArray(eval_order_max,0);
		int cnt_tot[] = ComLib.makeIntArray(eval_order_max,0);

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
			sb.append("<td align=left>" + item.get("bpart_name") + "</td>");
			sb.append("<td align=left>" + item.get("mpart_name") + "</td>");
			if(groupDepth.equals("1")){
				sb.append("<td align=left>" + item.get("spart_name") + "</td>");
			}
			//sb.append("<td>" + item.get("bpart_name")+"<font color=gray> > </font>"+item.get("mpart_name")+"<font color=gray> > </font>"+item.get("spart_name") + "</td>");
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
			int colspan = (groupDepth.equals("1")) ? 3 : 2;
			sb.append("<tr>");
			sb.append("<td class=sum colspan="+colspan+" style=text-align:center><b>총계</b></td>");
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
	} finally {
		if(db!=null) db.close();
	}
%>

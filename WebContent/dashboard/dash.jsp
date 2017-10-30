<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	// DB Connection Object
	Db db = null;

	try {
		// DB Connection
		db = new Db(true);

		// get parameter
		int svr_idx = CommonUtil.getParameterInt("svr_idx", "0");
		String abort_flag = CommonUtil.getParameter("abort_flag", "N");

		//
		Map<String, Object> argMap = new HashMap<String, Object>();
		Map<String, Object> curdata = new HashMap();
		int svr_cnt = 0;
		String today = DateUtil.getToday("yyyy-MM-dd");

		// 관제 서버목록 조회
		List<Map<String, Object>> list = db.selectList("dashboard.selectMonSystem", argMap);
		svr_cnt = list.size();
		if(svr_cnt<1) {
			out.print(CommonUtil.getErrorMsg("NO_DATA"));
			return;
		}

		// 현재 선택된 서버 데이터 저장
		for(int i=0;i<svr_cnt;i++) {
			if(i==svr_idx) {
				curdata = list.get(i);
				break;
			}
		}

		// 선택된 서버 데이터가 없는 경우
		if(curdata.isEmpty()) {
			out.print(CommonUtil.getErrorMsg("NO_DATA") + "[2]");
			return;
		}

		//
		String cur_mon_system = curdata.get("mon_system").toString();
		String cur_mon_name = curdata.get("mon_name").toString();
		String cur_mon_cpu = curdata.get("mon_cpu").toString();
		String cur_mon_mem = curdata.get("mon_mem").toString();
		String cur_mon_hdd = curdata.get("mon_hdd").toString();
		String cur_mon_process = curdata.get("mon_process").toString();

		// 선택된 서버 정보 차트 데이터 생성
		String cur_chart_data = "";
		cur_chart_data += "CPU:" + cur_mon_cpu;
		cur_chart_data += ",MEM:" + cur_mon_mem;
		cur_chart_data += "," + cur_mon_hdd;

		// 모니터링 로그 조회
		argMap.put("top_cnt", "20");
		argMap.put("log_date1", today.replace("-", ""));
		argMap.put("log_date2", today.replace("-", ""));
		argMap.put("mon_system", cur_mon_system);

		List<Map<String, Object>> loglist = db.selectList("dashboard.selectLogListAll", argMap);

		// 실시간 모니터링
		argMap = new HashMap();

		List<Map<String, Object>> monlist = db.selectList("dashboard.selectMonitoring", argMap);
%>
<form id="frm" name="frm">
<input type="hidden" name="svr_cnt" value="<%=svr_cnt%>"/>
<input type="hidden" name="svr_chart" value="<%=cur_chart_data%>"/>
	<div class="cont_cont">
		<div class="cont_left">
			<ul class="svr_list list-inline">
<%
		// 관제 서버목록
		for(int i=0;i<svr_cnt;i++) {
			String mon_name = list.get(i).get("mon_name").toString();
			String mon_cpu = list.get(i).get("mon_cpu").toString();
			String mon_mem = list.get(i).get("mon_mem").toString();
			String flag_desc = list.get(i).get("flag_desc").toString();

			String mon_hdd = "";
			if(!"".equals(list.get(i).get("mon_hdd").toString())) {
				String tmp_hdd[] = list.get(i).get("mon_hdd").toString().split(",");
				for(int j=0;j<tmp_hdd.length;j++) {
					mon_hdd += "<p>HDD["+tmp_hdd[j].substring(0,1)+"]: "+tmp_hdd[j].substring(2)+"%</p>";
				}
			}
%>
				<li style="<%=(i==svr_idx) ? "border: 1px solid #4CB848;" : ""%>">
					<div class="svr_img">
						<a href="javascript:getDashSvrData('<%=i%>');"><img src="../img/svr_<%=flag_desc%>.jpg"/></a>
						<div class="svr_name"><%=mon_name%></div>
					</div>
					<div class="svr_info">
						<p>CPU: <%=mon_cpu%>%</p>
						<p>MEM: <%=mon_mem%>%</p>
						<%=mon_hdd%>
					</div>
				</li>
<%		} %>
			</ul>
		</div>
		<div class="cont_right">
			<div class="svr_det_name"><strong><%=cur_mon_name%></strong></div>
			<div class="svr_det_chart"><div id="svr_chart"></div></div>
			<div class="process_list">
				<table class="table table-bordered table-default">
					<thead>
						<tr align="center">
							<td style="width: 70%;">프로세스명</td>
							<td style="width: 30%;">실행 유무</td>
						</tr>
					</thead>
					<tbody>
<%
		// 프로세스 목록
		if(!"".equals(cur_mon_process)) {
			String tmp_process[] = cur_mon_process.split(",");
			for(int i=0;i<tmp_process.length;i++) {
%>
						<tr align="center">
							<td><%=tmp_process[i].substring(1)%></td>
							<td><%=("O".equals(tmp_process[i].substring(0,1)) ? "정상" : "미실행")%></td>
						</tr>
<%
			}
		}
%>
					</tbody>
				</table>
			</div>
			<div class="today_tit clearfix clearboth">
				<i class="fa fa-volume-up blue" aria-hidden="true"></i> [<%=today%>] 모니터링
			</div>
			<div class="today_hist">
				<table class="table table-bordered table-default">
					<thead>
						<tr align="center">
							<td style="width: 80px;">날짜</td>
							<td style="width: 70px;">시간</td>
							<td style="width: 100px;">대상</td>
							<td>내용</td>
							<td style="width: 80px;">장애등급</td>
						</tr>
					</thead>
					<tbody>
<%
		// 모니터링 이력
		if(loglist.size()>0) {
			for(int i=0;i<loglist.size();i++) {
				String mon_date = loglist.get(i).get("mon_date").toString();
				String mon_time = loglist.get(i).get("mon_time").toString();
				String mon_name = loglist.get(i).get("mon_name").toString();
				String mon_alram = loglist.get(i).get("mon_alram").toString();
				String flag_desc = loglist.get(i).get("flag_desc").toString();

				mon_date = mon_date.substring(0, 4) + "-" + mon_date.substring(4, 6) + "-" + mon_date.substring(6, 8);
				mon_time = mon_time.substring(0, 2) + ":" + mon_time.substring(2, 4) + ":" + mon_time.substring(4, 6);
%>
						<tr align="center">
							<td><%=mon_date%></td>
							<td><%=mon_time%></td>
							<td><%=mon_name%></td>
							<td><%=mon_alram%></td>
							<td><img src="../img/icon_<%=flag_desc%>.jpg"/></td>
						</tr>
<%
			}
		}
%>
					</tbody>
				</table>
			</div>
			<div class="realtime_tit">
				<i class="fa fa-volume-up blue" aria-hidden="true"></i> 실시간 모니터링
			</div>
			<div class="realtime_hist">
				<table class="table table-bordered table-default">
					<thead>
						<tr align="center">
							<td style="width: 80px;">날짜</td>
							<td style="width: 70px;">시간</td>
							<td style="width: 100px;">대상</td>
							<td>내용</td>
							<td style="width: 80px;">장애등급</td>
						</tr>
					</thead>
					<tbody>
<%
		// 실시간 모니터링
		if(monlist.size()>0) {
			for(int i=0;i<monlist.size();i++) {
				String mon_date = monlist.get(i).get("mon_date").toString();
				String mon_time = monlist.get(i).get("mon_time").toString();
				String mon_name = monlist.get(i).get("mon_name").toString();
				String mon_alram = monlist.get(i).get("mon_alram").toString();
				String flag_desc = monlist.get(i).get("flag_desc").toString();

				mon_date = mon_date.substring(0, 4) + "-" + mon_date.substring(4, 6) + "-" + mon_date.substring(6, 8);
				mon_time = mon_time.substring(0, 2) + ":" + mon_time.substring(2, 4) + ":" + mon_time.substring(4, 6);
%>
						<tr align="center">
							<td><%=mon_date%></td>
							<td><%=mon_time%></td>
							<td><%=mon_name%></td>
							<td><%=mon_alram%></td>
							<td><img src="../img/icon_<%=flag_desc%>.jpg"/></td>
						</tr>
<%
			}
		}
%>
					</tbody>
				</table>
			</div>
		</div>
		<div class="clearfix"></div>
	</div>
</form>
<%
		// 실시간 모니터링
		if(monlist.size()>0 && "N".equals(abort_flag)) {
			out.print("<div id=\"error-message\" title=\"Error message\">\n");
			out.print("	<div id=\"tabs\">\n");
			out.print("		<ul>\n");

			int loop_cnt = 0;
			for(int i=0;i<svr_cnt;i++) {
				if(!"000".equals(list.get(i).get("mon_flag"))) {
					out.print("<li><a href=\"#tabs-" + loop_cnt + "\">" + list.get(i).get("mon_name").toString() + "</a></li>\n");
					loop_cnt++;
				}
			}

			out.print("		</ul>\n");

			loop_cnt = 0;
			for(int i=0;i<svr_cnt;i++) {
				if(!"000".equals(list.get(i).get("mon_flag"))) {
					out.print("<div id=\"tabs-" + loop_cnt + "\">\n");
					out.print("	<table class=\"table table-bordered table-error\">\n");
					out.print("		<thead>\n");
					out.print("			<tr align=\"center\">\n");
					out.print("				<td style=\"width: 80px;\">시간</td>\n");
					out.print("				<td>내용</td>\n");
					out.print("				<td style=\"width: 80px;\">장애등급</td>\n");
					out.print("			</tr>\n");
					out.print("		</thead>\n");
					out.print("		<tbody>\n");

					for(int j=0;j<monlist.size();j++) {
						if(list.get(i).get("mon_system").toString().equals(monlist.get(j).get("mon_system").toString())) {
							String mon_time = monlist.get(j).get("mon_time").toString();
							String mon_alram = monlist.get(j).get("mon_alram").toString();
							String flag_desc = monlist.get(j).get("flag_desc").toString();

							mon_time = mon_time.substring(0, 2) + ":" + mon_time.substring(2, 4) + ":" + mon_time.substring(4, 6);

							out.print("<tr align=\"center\">\n");
							out.print("	<td>" + mon_time + "</td>\n");
							out.print("	<td>" + mon_alram + "</td>\n");
							out.print("	<td><img src=\"../img/icon_" + flag_desc + ".jpg\"/></td>\n");
							out.print("</tr>\n");
						}
					}

					out.print("		</tbody>\n");
					out.print("	</table>\n");
					out.print("</div>\n");

					loop_cnt++;
				}
			}

			out.print("	</div>\n");
			out.print("</div>\n");
		}
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
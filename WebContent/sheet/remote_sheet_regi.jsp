<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"","json")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");

		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		Map<String,Object> argMap = new HashMap<String,Object>();

		if("step1".equals(step)) {
			// update의 경우 데이터를 조회하여 step1 데이터를 json으로 생성하고 또한 전체 데이터에 대한 세션 생성 (sheet_regi_data)
			// get parameter
			String sheet_code = CommonUtil.getParameter("sheet_code");

			// 파라미터 체크
			if(!CommonUtil.hasText(sheet_code)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// 사용 중인 이벤트가 있는 경우 수정 불가
			int used_cnt = db.selectOne("event.selectUsedSheetCnt", sheet_code);
			if(used_cnt>0) {
				Site.writeJsonResult(out, false, "해당 시트를 사용하는 이벤트가 있습니다. 수정하실 수 없습니다.");
				return;
			}

			JSONObject json = new JSONObject();
			JSONObject sessJson = new JSONObject();

			List<String> cate_list = new ArrayList<String>();
			Map<String,Object> resmap = new HashMap<String,Object>();
			Map<String, Object> catemap = new LinkedHashMap<String, Object>();

			List<Map<String, Object>> sess_cate_list = new ArrayList<Map<String, Object>>();
			List<Map<String, Object>> sess_item_list = new ArrayList<Map<String, Object>>();
			List<Map<String, Object>> sess_exam_list = new ArrayList<Map<String, Object>>();
			Map<String, Object> sess_catemap = new LinkedHashMap<String, Object>();

			Map<String,Object> tmpmap = new HashMap<String, Object>();

			// 기존 시트 기본정보 조회
			resmap = db.selectOne("sheet.selectItem", sheet_code);

			// 기존 시트 데이터 조회
			list = db.selectList("sheet.sheetView", sheet_code);

			String tmp_item_code = "";
			int it_idx = 0;
			int ex_idx = 0;

			for(Map<String, Object> item : list) {
				// step 1
				catemap.put(item.get("cate_code").toString(), item.get("cate_code"));

				// session
				// cate
				sess_catemap.put(item.get("cate_code").toString(), item.get("cate_code"));
				sess_catemap.put(item.get("cate_pcode").toString(), item.get("cate_pcode"));

				// item
				if(!tmp_item_code.equals(item.get("item_code").toString())) {
					tmpmap = new HashMap<String, Object>();
					tmpmap.put("code", item.get("item_code"));
					tmpmap.put("name", item.get("item_name"));
					tmpmap.put("cate_code", item.get("cate_code"));

					sess_item_list.add(it_idx, tmpmap);
					it_idx++;
				}

				tmp_item_code = item.get("item_code").toString();

				// exam
				tmpmap = new HashMap<String, Object>();
				tmpmap.put("code", item.get("exam_code"));
				tmpmap.put("name", item.get("exam_name"));
				tmpmap.put("item_code", item.get("item_code"));
				tmpmap.put("cate_code", item.get("cate_code"));
				tmpmap.put("score", item.get("exam_score"));
				tmpmap.put("add", item.get("add_score"));
				tmpmap.put("default_yn", item.get("default_yn"));

				sess_exam_list.add(ex_idx, tmpmap);
				ex_idx++;
			}

			// session 데이터 생성
			int ca_idx = 0;
			for(String key : sess_catemap.keySet()) {
				tmpmap = new HashMap<String, Object>();
				tmpmap.put("code", key);

				sess_cate_list.add(ca_idx, tmpmap);
				ca_idx++;
			}
			sessJson.put("step", "1");
			sessJson.put("sheet_code", sheet_code);
			sessJson.put("sheet_name", resmap.get("sheet_name"));
			sessJson.put("use_yn", resmap.get("use_yn"));
			sessJson.put("cate", sess_cate_list);
			sessJson.put("item", sess_item_list);
			sessJson.put("exam", sess_exam_list);

			// session 생성
			session.setAttribute("sheet_sheet_code", sheet_code);
			session.setAttribute("sheet_regi_data", sessJson.toJSONString());

			// step 1 json 데이터 생성
			// cate_code
			int n = 0;
			for(String key : catemap.keySet()) {
				cate_list.add(n, key);
				n++;
			}

			json.put("sheet_name", resmap.get("sheet_name"));
			json.put("use_yn", resmap.get("use_yn"));
			json.put("cate_code", cate_list);

			out.print(json.toJSONString());
		} else if("step2".equals(step)) {
			// get parameter
			String cate_code = CommonUtil.getParameter("cate_code");
			String item_depth = CommonUtil.getParameter("item_depth");

			// 파라미터 체크
			if(!CommonUtil.hasText(cate_code) || !CommonUtil.hasText(item_depth)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				argMap.put("cate_code",cate_code);
			argMap.put("item_depth",item_depth);
			argMap.put("use_yn","1");

			list = db.selectList("item.selectList", argMap);

				JSONObject json = new JSONObject();
			JSONObject sessJson = new JSONObject();
			JSONParser jsonParser = new JSONParser();

			// 선택된 item 조회
			String _SHEET_REGI_DATA = (String) session.getAttribute("sheet_regi_data");
			sessJson = (JSONObject) jsonParser.parse(_SHEET_REGI_DATA);

			json.put("item", list);
			json.put("selitem", (JSONArray) sessJson.get("item"));

			out.print(json.toJSONString());
		} else if("step3".equals(step)) {
			// get parameter
			String cate_code = CommonUtil.getParameter("cate_code");
			String parent_code = CommonUtil.getParameter("parent_code");
			String item_depth = CommonUtil.getParameter("item_depth");

			// 파라미터 체크
			if(!CommonUtil.hasText(cate_code) || !CommonUtil.hasText(item_depth)) {
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

				JSONObject json = new JSONObject();
			JSONObject sessJson = new JSONObject();
			JSONObject itemJson = new JSONObject();
			JSONParser jsonParser = new JSONParser();

			// 선택된 item 조회
			String _SHEET_REGI_DATA = (String) session.getAttribute("sheet_regi_data");
			sessJson = (JSONObject) jsonParser.parse(_SHEET_REGI_DATA);

			// parent_code가 없는 경우 카테고리별 첫번째 code 셋팅
			if("".equals(parent_code)) {
				JSONArray jsonArr = (JSONArray) sessJson.get("item");
				if(jsonArr!=null) {
					for(int i=0;i<jsonArr.size();i++) {
						JSONObject jsonItem = (JSONObject) jsonArr.get(i);
						if(cate_code.equals(jsonItem.get("cate_code"))) {
							parent_code = jsonItem.get("code").toString();
							break;
						}
					}
				}
			}

				argMap.put("cate_code",cate_code);
			argMap.put("parent_code",parent_code);
			argMap.put("item_depth",item_depth);
			argMap.put("use_yn","1");

			list = db.selectList("item.selectList", argMap);

				json.put("item", (JSONArray) sessJson.get("item"));
			json.put("exam", list);
			json.put("selexam", (JSONArray) sessJson.get("exam"));

			out.print(json.toJSONString());
		} else {
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
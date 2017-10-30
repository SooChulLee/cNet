<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"sheet","json")) return;

	Db db = null;

	try {
		db = new Db();

		// get parameter
		String step = CommonUtil.getParameter("step");

		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		Map<String, Object> map = new HashMap<String, Object>();

		if("step1".equals(step)) {
			// get parameter
			String cate_codes = CommonUtil.getParameter("cate_codes");
			String sheet_name = CommonUtil.getParameter("sheet_name");
			String use_yn = CommonUtil.getParameter("use_yn");

			// 파라미터 체크
			if(!CommonUtil.hasText(cate_codes) || !CommonUtil.hasText(sheet_name) || !CommonUtil.hasText(use_yn)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			// 기존 저장된 시트 데이터 세션 (시트 수정일 경우 생성된 세션)
			String _SHEET_REGI_DATA = CommonUtil.ifNull((String) session.getAttribute("sheet_regi_data"));

			JSONObject json = new JSONObject();
			JSONParser jsonParser = new JSONParser();

			if(!"".equals(_SHEET_REGI_DATA)) {
				json = (JSONObject) jsonParser.parse(_SHEET_REGI_DATA);
			}

			// cate_codes loop
			String arr_cate_code[] = cate_codes.split(",");
			String arr_cate_code_front_prev = "";

			int n = 0;
			for(int i=0;i<arr_cate_code.length;i++) {
				String arr_cate_code_front = arr_cate_code[i].substring(0, 2);
				//상위 카테고리를 입력 하는 기능인데 카테고리 추가시에 사용 된다. -----
				if(!arr_cate_code_front_prev.equals(arr_cate_code_front)) {
					map = new HashMap();
					map.put("code", arr_cate_code_front + "00");
					list.add(n++, map);
				}//---------------------------------------------------------
				map = new HashMap();
				map.put("code", arr_cate_code[i]);
				list.add(n++, map);
				arr_cate_code_front_prev = arr_cate_code_front;
			}

			// json 데이터 생성
			json.put("step", "1");
			json.put("sheet_name", sheet_name);
			json.put("use_yn", use_yn);
			json.put("cate", list);

			// 입력 데이터 세션 생성
			session.setAttribute("sheet_regi_data", json.toJSONString());

		} else if("step2".equals(step)) {
			// get parameter
			String proc = CommonUtil.getParameter("proc");
			String item_list = CommonUtil.getParameter("item_list");

			// 기존 저장된 시트 데이터 세션
			String _SHEET_REGI_DATA = (String) session.getAttribute("sheet_regi_data");

			// 파라미터 체크
			if(!"reset".equals(proc) && !CommonUtil.hasText(item_list) && !CommonUtil.hasText(_SHEET_REGI_DATA)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			// &quot; -> " 로 replace
			item_list = "{\"item\":" + CommonUtil.toTextHTML(item_list) + "}";

			JSONObject json = new JSONObject();
			JSONObject newJson = new JSONObject();
			JSONParser jsonParser = new JSONParser();

			json = (JSONObject) jsonParser.parse(_SHEET_REGI_DATA);
			newJson = (JSONObject) jsonParser.parse(item_list);

			JSONArray jsonArr = (JSONArray) json.get("item");
			JSONArray newJsonArr = (JSONArray) newJson.get("item");

			if("insert".equals(proc)) {
			   	if(jsonArr!=null) {
			   		// 기존 데이터와 신규 데이터의 code 값을 비교하여 동일한 값이 없을 경우만 추가
					for(int i=0; i<newJsonArr.size(); i++){
						boolean flag = true;
						JSONObject newJsonItem = (JSONObject) newJsonArr.get(i);

						for(int j=0; j<jsonArr.size(); j++){
							JSONObject jsonItem = (JSONObject) jsonArr.get(j);

							if(newJsonItem.get("code").equals(jsonItem.get("code"))) {
								flag = false;
								break;
							}
						}

						if(flag) {
							jsonArr.add(newJsonItem);
						}
					}
			   	} else {
			   		json.put("item", newJsonArr);
			   	}
			} else if ("delete".equals(proc)) {
			   	if(jsonArr!=null) {
			   		// 기존 데이터와 신규 데이터의 code 값을 비교하여 동일한 값이 있을 경우 삭제
					for(int i=0; i<newJsonArr.size(); i++){
						JSONObject newJsonItem = (JSONObject) newJsonArr.get(i);

						for(int j=0; j<jsonArr.size(); j++){
							JSONObject jsonItem = (JSONObject) jsonArr.get(j);

							if(newJsonItem.get("code").equals(jsonItem.get("code"))) {
								jsonArr.remove(j);
								break;
							}
						}
					}
			   	}
			} else if ("reset".equals(proc)) {
				json.remove("item");
			} else {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			// step 업데이트
			json.put("step", "2");

			// 입력 데이터 세션 생성
			session.setAttribute("sheet_regi_data", json.toJSONString());
		} else if("step3".equals(step)) {
			// get parameter
			String proc = CommonUtil.getParameter("proc");
			String exam_list = CommonUtil.getParameter("exam_list");

			// 기존 저장된 시트 데이터 세션
			String _SHEET_REGI_DATA = (String) session.getAttribute("sheet_regi_data");

			// 파라미터 체크
			if(!"reset".equals(proc) && !CommonUtil.hasText(exam_list) && !CommonUtil.hasText(_SHEET_REGI_DATA)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			// &quot; -> " 로 replace
			exam_list = "{\"exam\":" + CommonUtil.toTextHTML(exam_list) + "}";

				JSONObject json = new JSONObject();
			JSONObject newJson = new JSONObject();
			JSONParser jsonParser = new JSONParser();

				json = (JSONObject) jsonParser.parse(_SHEET_REGI_DATA);
			newJson = (JSONObject) jsonParser.parse(exam_list);

			JSONArray jsonArr = (JSONArray) json.get("exam");
			JSONArray newJsonArr = (JSONArray) newJson.get("exam");

			if("insert".equals(proc)) {
			   	if(jsonArr!=null) {
			   		// 기존 데이터와 신규 데이터의 code 값을 비교하여 동일한 값이 없을 경우만 추가
					for(int i=0; i<newJsonArr.size(); i++){
						boolean flag = true;
						JSONObject newJsonItem = (JSONObject) newJsonArr.get(i);
						for(int j=0; j<jsonArr.size(); j++){
							JSONObject jsonItem = (JSONObject) jsonArr.get(j);

							if(newJsonItem.get("code").equals(jsonItem.get("code"))) {
								flag = false;
								break;
							}
						}

						if(flag) {
							jsonArr.add(newJsonItem);
						}
					}
			   	} else {
			   		json.put("exam", newJsonArr);
			   	}
			} else if ("delete".equals(proc)) {
			   	if(jsonArr!=null) {
			   		// 기존 데이터와 신규 데이터의 code 값을 비교하여 동일한 값이 있을 경우 삭제
					for(int i=0; i<newJsonArr.size(); i++){
						JSONObject newJsonItem = (JSONObject) newJsonArr.get(i);

						for(int j=0; j<jsonArr.size(); j++){
							JSONObject jsonItem = (JSONObject) jsonArr.get(j);

							if(newJsonItem.get("code").equals(jsonItem.get("code"))) {
								jsonArr.remove(j);
								break;
							}
						}
					}
			   	}
			} else if ("reset".equals(proc)) {
				json.remove("exam");
			} else {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			// step 업데이트
			json.put("step", "3");

			// 입력 데이터 세션 생성
			session.setAttribute("sheet_regi_data", json.toJSONString());
			
		} else if("finish".equals(step)) {
			// 기존 저장된 시트 데이터 세션
			String _SHEET_REGI_DATA = (String) session.getAttribute("sheet_regi_data");
			String _SHEET_SHEET_CODE = CommonUtil.ifNull((String) session.getAttribute("sheet_sheet_code"));

			// 파라미터 체크
			if(!CommonUtil.hasText(_SHEET_REGI_DATA)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			Map<String, Object> argMap = new HashMap<String, Object>();
			String client_ip = request.getRemoteAddr();

			if(!"".equals(_SHEET_SHEET_CODE)) {
				// 사용 중인 이벤트가 있는 경우 수정 불가
				int used_cnt = db.selectOne("event.selectUsedSheetCnt", _SHEET_SHEET_CODE);
				if(used_cnt>0) {
					throw new Exception("N:해당 시트를 사용하는 이벤트가 있습니다. 수정하실 수 없습니다.");
				}

				// 기존 데이터 삭제
				// 시트 삭제
				int del_cnt = db.delete("sheet.deleteSheet", _SHEET_SHEET_CODE);
				if(del_cnt<1) {
					throw new Exception("삭제에 실패했습니다.");
				}

				// 시트 평가항목 삭제
				int del_item_cnt = db.delete("sheet.deleteSheetItem", _SHEET_SHEET_CODE);
				if(del_item_cnt<1) {
					throw new Exception("삭제에 실패했습니다.");
				}

				// session 삭제
				session.removeAttribute("sheet_sheet_code");
			}

			// parsing 하기 위한 data 필드 추가
			//_SHEET_REGI_DATA = "{\"data\":" + _SHEET_REGI_DATA + "}";

			JSONParser jsonParser = new JSONParser();

			JSONObject jsonData 	= (JSONObject) jsonParser.parse(_SHEET_REGI_DATA);
			//JSONObject jsonData = (JSONObject) json.get("data");

			JSONArray jsonCateArr = (JSONArray) jsonData.get("cate");//카테고리 (선택된 카테고리 키만 들어온다.)
			JSONArray jsonItemArr = (JSONArray) jsonData.get("item");//평가질문 (카테고리를 삭제하면 여기에는 그 값이 현재 존재함)
			JSONArray jsonExamArr = (JSONArray) jsonData.get("exam");//평가답변 (모든 답변이 존재함)

			argMap.put("sheet_name",jsonData.get("sheet_name").toString());
			argMap.put("item_cnt",jsonItemArr.size());
			argMap.put("tot_score","0");
			argMap.put("add_score","0");
			argMap.put("default_yn","n");
			argMap.put("sheet_etc","");
			argMap.put("use_yn",jsonData.get("use_yn").toString());
			argMap.put("regi_ip",client_ip);
			argMap.put("regi_id",_LOGIN_ID);

			// sheet insert
			int ins_cnt = db.insert("sheet.insertSheet", argMap);
			if(ins_cnt<1) {
				throw new Exception("등록에 실패했습니다.");
			}

			// get inserted primary key
			String sheet_code = argMap.get("sheet_code").toString();

			// sheet item insert
			
			//항목질문배열을 조사하여 카테고리배열 의 cate_code가 없는 것은 제거한다.
			if(jsonCateArr!=null && jsonItemArr!=null) {
				for(int i=0;i<jsonItemArr.size();i++) {
					JSONObject jsonItem = (JSONObject) jsonItemArr.get(i);
					boolean isExistInCate = false;
					for(int ii=0;ii<jsonCateArr.size();ii++) {
						JSONObject jsonCate = (JSONObject) jsonCateArr.get(ii);
						if(jsonItem.get("cate_code").equals(jsonCate.get("code"))) {isExistInCate=true;break;}
					}
					if(!isExistInCate) jsonItemArr.remove(i);
				}
			}

			
			int upd_cnt = 0;
			//항목답변배열에서 항목질문코드와 비교하여 있는 것만 입력 한다.
			if(jsonItemArr!=null && jsonExamArr!=null) {
				for(int ii=0;ii<jsonItemArr.size();ii++) {
					JSONObject jsonItem = (JSONObject) jsonItemArr.get(ii);
					for(int i=0;i<jsonExamArr.size();i++) {
						JSONObject jsonExam = (JSONObject) jsonExamArr.get(i);
						if(jsonItem.get("code").equals(jsonExam.get("item_code"))){
							argMap = new HashMap();
							argMap.put("sheet_code",sheet_code);
							argMap.put("cate_code",jsonExam.get("cate_code"));
							argMap.put("item_code",jsonExam.get("item_code"));
							argMap.put("exam_code",jsonExam.get("code"));
							argMap.put("exam_score",jsonExam.get("score"));
							argMap.put("add_score",jsonExam.get("add"));
							argMap.put("default_yn",ComLib.toNN(jsonExam.get("default_yn"),"n"));
		
							int tmp_upd_cnt = db.insert("sheet.insertSheetItem", argMap);
							upd_cnt += tmp_upd_cnt;
						}
					}
				}
			}

			if(upd_cnt<1) {
				throw new Exception("업데이트에 실패했습니다.");
			}

			// sheet tot_score, add_score update
			upd_cnt = 0;
			Map<String, Object> resmap = db.selectOne("sheet.selectTotAddScore", sheet_code);
			if(resmap!=null) {
				// sheet update
				argMap = new HashMap();
				argMap.put("tot_score",Integer.parseInt(resmap.get("tot_score").toString()));
				argMap.put("add_score",Integer.parseInt(resmap.get("add_score").toString()));
				argMap.put("upd_ip",client_ip);
				argMap.put("upd_id",_LOGIN_ID);
				argMap.put("sheet_code",sheet_code);

				upd_cnt = db.update("sheet.updateSheet", argMap);
			}

			// session 삭제
			session.removeAttribute("sheet_regi_data");
		} else {
			throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
		}

		// commit
		db.commit();

		Site.writeJsonResult(out,true);
	} catch(Exception e) {
		if(db!=null) db.rollback();
		Site.writeJsonResult(out,e);
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"eval","json")) return;

	Db db = null;

	try {
		db = new Db();

		Map<String, String> h = ComLib.getParameters(request);

		//이의신청(이의대기)
		if(h.get("act").equals("claim")){
			h.put("claim_status", "a");//이의등록 상태로 등록
			int cnt = db.insert("eval_claim.insertEvalResultClaim", h);
			if(cnt==0) {
				throw new Exception("이의신청 등록시 평가테이블 등록에 실패했습니다.");
			}

			//평가테이블의 상태값 업데이트
			h.put("eval_status", "a");//이의등록 상태로 바꿈
			cnt = db.update("eval_claim.updateEvalResultByClaim", h);
			if(cnt==0) {
				throw new Exception("이미 이의신청이 등록 된 상태 입니다.\\n\\n확인하세요.");
			}
		}
		//이의접수
		else if(h.get("act").equals("claimRecv")){
			//이의신청 테이블에 처리정보 업데이트
			int cnt = db.update("eval_claim.updateEvalResultClaim", h);
			if(cnt==0) {
				throw new Exception("이의접수 처리중 이의신청테이블 등록에 실패했습니다.");
			}

			//평가테이블의 상태값 업데이트
			//반려이면 완료(9), 접수이면 접수(d)
			String eval_status = (h.get("claim_status").equals("f")) ? "9" : h.get("claim_status");
			h.put("eval_status", eval_status);
			cnt = db.update("eval_claim.updateEvalResultByClaim", h);
			if(cnt==0) {
				throw new Exception("이의접수 처리중 평가테이블 등록에 실패했습니다.");
			}
		}
		//이의처리
		else if(h.get("act").equals("claimProc")){
			//이의신청 테이블에 처리정보 업데이트
			int cnt = db.update("eval_claim.updateEvalResultClaim", h);
			if(cnt==0) {
				throw new Exception("이의처리 처리중 이의신청테이블 등록에 실패했습니다.");
			}

			//평가테이블의 상태값 업데이트
			h.put("eval_status", "9");//완료 상태로 바꿈
			cnt = db.update("eval_claim.updateEvalResultByClaim", h);
			if(cnt==0) {
				throw new Exception("이의처리 처리중 평가테이블 등록에 실패했습니다.");
			}
		}
		else{
			Site.writeJsonResult(out,false,"act 파라미터값 오류 : "+h.get("act"));
			return;
		}

		Site.writeJsonResult(out,true);

	} catch(Exception e) {
		if(db!=null) db.rollback();
		Site.writeJsonResult(out,e);
	} finally {
		if(db!=null) db.close();
	}
%>
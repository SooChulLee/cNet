package com.cnet.crec.common;

import java.util.HashMap;

public class Finals {
	//개발 여부 (개발에 필요한 여러 세팅을 한다)
	public static boolean 			isDev = true;

	//프로그램 메인 타이틀
	public static final String		MAIN_TITLE_LOGIN = "<img alt='image' src='img/logo/logo_ktcs.png' />";
	public static final String		MAIN_TITLE_TOP   = "<img alt='image' src='../img/logo/logo_ktcs.png' />";
	//public static final String	MAIN_TITLE_TOP   = "<span style='font-size:24px;font-weight:bold;'>KT114</span>";

	//평가 최대 차수 (최대 16까지 가능하게 코딩 됨)
	public static int 				EVAL_ORDER_MAX = 10;
	//미디어 서버 URL
	public static String 			MEDIA_SERVER_URL = (!isDev) ? "http://192.168.0.61:8888" : "http://192.168.0.115:8888"; //운영 : 개발
	//평가수행 프로그램명 (평가자가 아니면 평가수행 메뉴 안보이게 하기 위함 (top.jsp)
	public static final String		EVAL_PROGRAM = "/eval.jsp";

	//백업 DB 존재 유무
	public static final boolean		isExistBackupServer = true;
	//청취/다운 사유입력 유무
	public static final boolean		isExistPlayDownReason = false;
	//다중다운로드
	public static final boolean		isExistMultiDownload = false;
	//필수중단
	public static final boolean		isExistPilsooJungdan = false;
	//부분녹취하기 (Player.jsp Player_ie8.jsp)
	public static final boolean		isExistPartRecord = false;
	//평가 완료하기 버튼
	public static final boolean		isExistEvalFinish = false;
	
	//S : 공통코드 ==============================================================================================
	//공통코드 의 값 구하기
	public static String getValue(HashMap<String, String> h, Object key){
		return (h==null) ? "no Object" : (h.get(key)==null) ? key.toString() : h.get(key.toString()).toString();
	}

	public static HashMap<String, String> hEvalStatus			= new HashMap<String, String>();
	public static HashMap<String, String> hEvalStatusHtml		= new HashMap<String, String>();
	public static HashMap<String, String> hEvalStatusOption1	= new HashMap<String, String>();
	public static HashMap<String, String> hClaimStatus			= new HashMap<String, String>();
	public static HashMap<String, String> hClaimStatusHtml		= new HashMap<String, String>();
	public static HashMap<String, String> hUsedCode				= new HashMap<String, String>();
	
	//공통코드 및 값 로딩
	public static void setApplicationVariable(){
		setApplicationVariable(false);
	}
	public static void setApplicationVariable(boolean isForce){
		if (hEvalStatus.isEmpty() || isForce){
			//평가상태 : tbl_eval_event_agent_list.eval_status
			//평가수행 > 평가대상자 목록 : 평가상태	//평가수행 > 상담이력 목록, 평가결과 조회 목록 						//평가결과 조회 목록 > 검색조건 : 평가상태
			hEvalStatus.put("","미평가");		hEvalStatusHtml.put("","-");
			hEvalStatus.put("0","미평가");		hEvalStatusHtml.put("0","-");
			hEvalStatus.put("1","진행중");		hEvalStatusHtml.put("1","<font color=gray>진행</font>");		hEvalStatusOption1.put("1","진행");	
			hEvalStatus.put("2","평가저장");		hEvalStatusHtml.put("2","저장");								hEvalStatusOption1.put("2","평가");
			hEvalStatus.put("9","평가완료");		hEvalStatusHtml.put("9","<font color=blue>완료</font>");		hEvalStatusOption1.put("9","완료");
			hEvalStatus.put("a","이의대기");		hEvalStatusHtml.put("a","<font color=red>이의</font>대기");	hEvalStatusOption1.put("a","이의대기");
			hEvalStatus.put("d","이의접수");		hEvalStatusHtml.put("d","<font color=red>이의접수</font>");	hEvalStatusOption1.put("d","이의접수");

			hClaimStatus.put("a", "이의대기");				hClaimStatusHtml.put("a", "<font color=red>이의</font>대기");
			hClaimStatus.put("b", "접수자 이의신청 반려");		hClaimStatusHtml.put("b", "접수자 이의신청 <font color=red>반려");
			hClaimStatus.put("d", "이의접수");				hClaimStatusHtml.put("d", "<font color=red>이의접수</font>");          
			hClaimStatus.put("f", "평가자 이의신청 반려");		hClaimStatusHtml.put("f", "평가자 이의신청 <font color=red>반려</font>");
			hClaimStatus.put("g", "평가자 이의신청 접수");		hClaimStatusHtml.put("g", "평가자 이의신청 <font color=blue>접수</font>");


			hUsedCode.put("0", "사용안함");
			hUsedCode.put("1", "사용");
		}
	}
	//E : 공통코드 ==============================================================================================
}
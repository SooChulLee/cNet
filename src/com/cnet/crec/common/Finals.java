package com.cnet.crec.common;

import java.util.HashMap;

public class Finals {
	//���� ���� (���߿� �ʿ��� ���� ������ �Ѵ�)
	public static boolean 			isDev = true;

	//���α׷� ���� Ÿ��Ʋ
	public static final String		MAIN_TITLE_LOGIN = "<img alt='image' src='img/logo/logo_ktcs.png' />";
	public static final String		MAIN_TITLE_TOP   = "<img alt='image' src='../img/logo/logo_ktcs.png' />";
	//public static final String	MAIN_TITLE_TOP   = "<span style='font-size:24px;font-weight:bold;'>KT114</span>";

	//�� �ִ� ���� (�ִ� 16���� �����ϰ� �ڵ� ��)
	public static int 				EVAL_ORDER_MAX = 10;
	//�̵�� ���� URL
	public static String 			MEDIA_SERVER_URL = (!isDev) ? "http://192.168.0.61:8888" : "http://192.168.0.115:8888"; //� : ����
	//�򰡼��� ���α׷��� (���ڰ� �ƴϸ� �򰡼��� �޴� �Ⱥ��̰� �ϱ� ���� (top.jsp)
	public static final String		EVAL_PROGRAM = "/eval.jsp";

	//��� DB ���� ����
	public static final boolean		isExistBackupServer = true;
	//û��/�ٿ� �����Է� ����
	public static final boolean		isExistPlayDownReason = false;
	//���ߴٿ�ε�
	public static final boolean		isExistMultiDownload = false;
	//�ʼ��ߴ�
	public static final boolean		isExistPilsooJungdan = false;
	//�κг����ϱ� (Player.jsp Player_ie8.jsp)
	public static final boolean		isExistPartRecord = false;
	//�� �Ϸ��ϱ� ��ư
	public static final boolean		isExistEvalFinish = false;
	
	//S : �����ڵ� ==============================================================================================
	//�����ڵ� �� �� ���ϱ�
	public static String getValue(HashMap<String, String> h, Object key){
		return (h==null) ? "no Object" : (h.get(key)==null) ? key.toString() : h.get(key.toString()).toString();
	}

	public static HashMap<String, String> hEvalStatus			= new HashMap<String, String>();
	public static HashMap<String, String> hEvalStatusHtml		= new HashMap<String, String>();
	public static HashMap<String, String> hEvalStatusOption1	= new HashMap<String, String>();
	public static HashMap<String, String> hClaimStatus			= new HashMap<String, String>();
	public static HashMap<String, String> hClaimStatusHtml		= new HashMap<String, String>();
	public static HashMap<String, String> hUsedCode				= new HashMap<String, String>();
	
	//�����ڵ� �� �� �ε�
	public static void setApplicationVariable(){
		setApplicationVariable(false);
	}
	public static void setApplicationVariable(boolean isForce){
		if (hEvalStatus.isEmpty() || isForce){
			//�򰡻��� : tbl_eval_event_agent_list.eval_status
			//�򰡼��� > �򰡴���� ��� : �򰡻���	//�򰡼��� > ����̷� ���, �򰡰�� ��ȸ ��� 						//�򰡰�� ��ȸ ��� > �˻����� : �򰡻���
			hEvalStatus.put("","����");		hEvalStatusHtml.put("","-");
			hEvalStatus.put("0","����");		hEvalStatusHtml.put("0","-");
			hEvalStatus.put("1","������");		hEvalStatusHtml.put("1","<font color=gray>����</font>");		hEvalStatusOption1.put("1","����");	
			hEvalStatus.put("2","������");		hEvalStatusHtml.put("2","����");								hEvalStatusOption1.put("2","��");
			hEvalStatus.put("9","�򰡿Ϸ�");		hEvalStatusHtml.put("9","<font color=blue>�Ϸ�</font>");		hEvalStatusOption1.put("9","�Ϸ�");
			hEvalStatus.put("a","���Ǵ��");		hEvalStatusHtml.put("a","<font color=red>����</font>���");	hEvalStatusOption1.put("a","���Ǵ��");
			hEvalStatus.put("d","��������");		hEvalStatusHtml.put("d","<font color=red>��������</font>");	hEvalStatusOption1.put("d","��������");

			hClaimStatus.put("a", "���Ǵ��");				hClaimStatusHtml.put("a", "<font color=red>����</font>���");
			hClaimStatus.put("b", "������ ���ǽ�û �ݷ�");		hClaimStatusHtml.put("b", "������ ���ǽ�û <font color=red>�ݷ�");
			hClaimStatus.put("d", "��������");				hClaimStatusHtml.put("d", "<font color=red>��������</font>");          
			hClaimStatus.put("f", "���� ���ǽ�û �ݷ�");		hClaimStatusHtml.put("f", "���� ���ǽ�û <font color=red>�ݷ�</font>");
			hClaimStatus.put("g", "���� ���ǽ�û ����");		hClaimStatusHtml.put("g", "���� ���ǽ�û <font color=blue>����</font>");


			hUsedCode.put("0", "������");
			hUsedCode.put("1", "���");
		}
	}
	//E : �����ڵ� ==============================================================================================
}
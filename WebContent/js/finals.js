var fn = new Object();
//undefined 미평가임 : 서버측 쿼리문에서 tbl_eval_event_result_list 에 평가가 없는 경우 outer join 시 eval_status가 "x" 로 넘어옴
fn.eval_status_htm		= {"x":"<font color=gray>-</font>","0":"<font color=gray>미평가</font>","1":"<font color=gray>진행</font>","2":"등록","9":"<font color=blue>완료</font>","a":"<font color=red>이의</font>대기","d":"<font color=red>이의접수</font>"};
fn.event_status			= {"2":"진행중","5":"마감","9":"종료"};
fn.event_status.colModel= [{"2":"진행중"}, {"5":"마감"}, {"9":"종료"}]
fn.claim_status			= {"a":"<font color=red>이의</font>대기","b":"접수자 이의신청 <font color=red>반려</font>","d":"<font color=red>이의접수</font>","f":"평가자 이의신청 <font color=red>반려</font>","g":"평가자 이의신청 <font color=blue>접수</font>"};

fn.usedCode				= {"0":"사용안함","1":"사용"};		//default_used, order_used, use_yn_desc
fn.usedCode.colModel	= [{"0":"사용안함"}, {"1":"사용"}];	//default_used, order_used, use_yn_desc

//공통코드 값 구하기
fn.getValue = function(name,key){
	return toNN(fn[name][key],key);
}
var n = '\n';
var comm = new Object();

comm.subWinPlusHeight = 29;//winSub의 타이틀 및 가장자리 영역 높이

function trim(val){
	if(val=='') return "";
	else{
		val = lTrim(val);
		val = rTrim(val);
		return val;
	}
}
function lTrim(val){
	if( val != null && val != ""){
		var search = 0;
		while ( val.charAt(search)==" "){
			search = search + 1;
		}
		val = val.substring(search, (val.length));
	}
	return val;
}
function rTrim(val){
	if( val != null && val != ""){
		search = val.length - 1;
		while (val.charAt(search)==" "){
			search = search - 1;
		}
		val = val.substring(0, search + 1);
	}	return val;
}
function trimObj(obj){
	obj.value = trim(obj.value);
	return obj.value;
}
function lTrimObj(obj){
	obj.value = lTrim(obj.value);
	return obj.value;
}
function rTrimObj(obj){
	obj.value = rTrim(obj.value);
	return obj.value;
}
// replace(/변수/g, '') <- 이게 처리가 안되어서 아래 만듬
function replaceAll(baseStr, fromStr, toStr) {
	return baseStr.split(fromStr).join(toStr);
}

function fillString(fillStr, len){
	var sReturn = "";
	if(len<0) return "";
	for(var i=0;i<len;i+=fillStr.toString().length){sReturn+=fillStr.toString();}
	return sReturn.substring(0,len);
}
function fillRight(baseStr,fillStr,len){
	if(baseStr.toString().length > len) return baseStr;
	return baseStr + fillString(fillStr,len-baseStr.toString().length);
}
function fillLeft(baseStr,fillStr,len){
	if(baseStr.toString().length > len) return baseStr;
	return fillString(fillStr,len-baseStr.toString().length)+baseStr;
}
function isIn(){
	var baseStr = arguments[0];
	for(var i=1;i<arguments.length;i++){
		if(baseStr==arguments[i]) return true;
	}
	return false;
}
function isInArray(){
	var baseArray = arguments[0];
	if(!baseArray) return false;
	for (var i=0; i<baseArray.length; i++){
		for (var j=1; j<arguments.length; j++){
			if(!(arguments[j] instanceof Array)){
				if(baseArray[i]==arguments[j]) return true;
			}
			else{
				for (var key in arguments[j]){
					if(baseArray[i]==arguments[j][key]) return true;
				}
				return false;
			}
		}
	}
	return false;
}
function isNothing(val){//undefined,null,'' -> true
	return (val==undefined || val==null || val.toString()=='' || val.toString().toLowerCase()=='null');
}
function toNN(baseStr,nullTo){
	nullTo = (isNothing(nullTo)) ? "" : nullTo;
	return (isNothing(baseStr)) ? nullTo : baseStr;
}
function isNot(val){// undefined,null,'',0,false -> true
	return (isNothing(val) || val=='0' || val==false);
}
function toNot(val){// undefined,'', 0과 false 는 ''을 리턴
	return (isNot(val)) ? '' : val;
}
function strTo(baseStr,fromStr,toStr){
	return (baseStr==fromStr) ? toStr : baseStr;
}
//null이 아닐때와 null일때 값 결정
function nvl2(baseStr,notNullTo,nullTo){
	return (isNothing(baseStr)) ? nullTo : notNullTo;
}
//.1 -> 0.1로 바꾸기
function toNumStr(val){
	try{return (isNothing(val)) ? '' : parseFloat(out_comma(val));}catch(e){return val;}
}
function toNumber(val){
	try{return (isNot(val)) ? 0 : parseFloat(out_comma(val));}catch(e){return 0;}
}
// 새로운창을 스크린 중앙으로 띄울때 left값을 구해 준다.
function getCenterX(winWidth){
	var x = Math.ceil( (window.screen.width  - winWidth) / 2 );
	return ((x < 0) ? 0 : x) ;
}

// 새로운창을 스크린 중앙으로 띄울때 top값을 구해 준다.
function getCenterY(winHeight){
	winHeight=parseFloat(winHeight)+100;
	var y = Math.ceil( (window.screen.height - winHeight) / 2 );
	return (y < 0) ? 0 : y;
}

// imbeded 창을 Body 중앙으로 띄울때 left값을 구해 준다.
function getBodyCenterX(winWidth){
	var curBody = E('curBody');
	if(winWidth=='100%') return (curBody) ? parseInt(curBody.style.padding) : 0;
	var x = (curBody) ? (curBody.align=='right') ? (document.body.scrollWidth - curBody.scrollWidth) + Math.ceil( (parseFloat(curBody.scrollWidth)  - winWidth) / 2 ) :
				Math.ceil( (parseFloat(curBody.scrollWidth)  - winWidth) / 2 ) :
			Math.ceil( (parseFloat(document.body.scrollWidth)  - winWidth) / 2 );
	return ((x < 0) ? 0 : x) ;
}

// imbeded 창을 Body 중앙으로 띄울때 top값을 구해 준다.
function getBodyCenterY(winHeight){
	winHeight=parseFloat(winHeight)+100;
	var y = (E('curBody')) ? Math.ceil( (parseFloat(document.body.scrollHeight) - winHeight) / 2 ) : Math.ceil( (parseFloat(document.body.scrollHeight) - winHeight) / 2 );//if(E('curBody')) y = Math.ceil( (parseFloat(E('curBody').scrollHeight)  - winHeight) / 2 );
	return (y < 0) ? 0 : y;
}

function resizeHeight(obj,minHeight){
	minHeight = toNN(minHeight,0);
	//alert(obj.clientHeight+" : "+obj.offsetHeight+" : "+obj.scrollHeight);
	obj.style.height=Math.max(minHeight, obj.scrollHeight+2);
}

function openCalendarModal(obj,act){
	window_style = "dialogWidth=210px; dialogHeight=222px; center=yes; border=thin; status=yes; help=no; scroll=no";
	dateVal=window.showModalDialog('/common/function/calendarModal.jsp?selDate='+obj.value,'_calendar',window_style);
	if(dateVal=='' || dateVal) obj.value=dateVal;
}
comm.calendarWidth  = 240;
comm.calendarHeight = 220;
function openCalendarUp(obj,afterAct){
	openCalendar(obj,afterAct,'U');
}
function openCalendar(obj,afterAct,showWhere,notShowAlpha,notBtnDel,addDay){
	openCalendarWhere(obj,showWhere,afterAct,notShowAlpha,notBtnDel,addDay);
}
function openCalendarWhere(obj,showWhere,afterAct,notShowAlpha,notBtnDel,addDay){
	showWhere = strTo(toNN(showWhere, "R"),"U","UR");
	notShowAlpha = (notShowAlpha) ? true : false;
	var objName;
	var selDate = (!addDay) ? obj.value : dateToStr(getGapDate(obj.value,addDay));
	var y = (showWhere.indexOf('U')>-1) ? findPosY(obj,0-comm.calendarHeight-comm.subWinPlusHeight-1) : findPosY(obj,obj.offsetHeight+1);//1은 사이띄움
	var x = (showWhere.indexOf('R')>-1) ? findPosX(obj) : (showWhere.indexOf('L')>-1) ? findPosX(obj,obj.offsetWidth-comm.calendarWidth) : (showWhere.indexOf('C')>-1) ? findPosX(obj,(obj.offsetWidth-comm.calendarWidth)/2) : findPosX(obj,showWhere);// showWhere -> addValue
	showPopupPage('',toNN(afterAct),'달력','/common/function/calendar.jsp?obj=parent.'+getFormObjName(obj)+'&selDate='+selDate+'&notBtnDel='+toNN(notBtnDel),y,x,comm.calendarWidth,comm.calendarHeight,notShowAlpha);
}
comm.afterClosePopupPage = "";//popup 창을 닫고 나서 행해야 할 내용을 저장
function showPopupPage(act,afterCloseAct,title,url,top,left,width,height){//창내에서 팝업을 뛰운다.
	if(act==''){
		E('winSubTitle').innerHTML = title;
		if(url!='') ifSub.location = url;
		if(comm.afterClosePopupPage) try{eval(comm.afterClosePopupPage);}catch(e){}
		comm.afterClosePopupPage	= afterCloseAct;
		comm.afterCloseSubPage		= comm.afterClosePopupPage;	//팝업이 따로 생성되면 삭제
	}
	else if(act=='none'){
		if(comm.afterClosePopupPage) try{eval(comm.afterClosePopupPage);}catch(e){}
		comm.afterClosePopupPage	= "";
		comm.afterCloseSubPage		= "";	//팝업이 따로 생성되면 삭제
	}
	showSubPage(act,top,left,width,height);
}
comm.afterCloseSubPage = "";//winSub 창을 닫고 나서 행해야 할 내용을 저장
function showSubPage(act,top,left,width,height){
	alphaWindow.style.display=act;
	if(act==''){
		top		= (top=='center') ? getBodyCenterY(document.body.scrollHeight) : (top!='0' && !top)   ? gSubTop  : top;
		width	= (width) ? width : (gSubWidth) ? gSubWidth : document.body.scrollWidth-34;
		left	= (left=='center') ? (width=='100%') ? 0 : getBodyCenterX(width) : (left!='0' && !left) ? gSubLeft : left;
		//left	= (left=='center') ? getBodyCenterX(document.body.scrollWidth) : (left!='0' && !left) ? gSubLeft : left;

		E('winSub').style.top	= top;
		E('winSub').style.left	= left;
		E('ifSub').style.width	= width;
		//E('ifSub').width		= width;
		if(height){
			E('ifSub').style.height	= height;
			//E('ifSub').height		= height;
		}
		E('winSub').style.display= act;
	}
	else if(act=='none'){
		winSub.style.display= act;
		E('winSubTitle').innerHTML = '';
		if(comm.afterCloseSubPage) try{eval(comm.afterCloseSubPage);}catch(e){}
		comm.afterCloseSubPage	= "";
		comm.afterClosePopupPage	= "";		//팝업이 따로 생성되면 삭제
		ifSub.location = 'about:blank';
		E('ifSub').style.height	= '50px';
		try{optimizeResize();}catch(e){}
	}
}
function getFormObjName(obj){
	if(!obj) return "";
	if(!obj.name){
		//문자열로 들어 온 경우
		try{
			obj = (E(obj)) ? E(obj) : eval(obj);
			return (obj) ? getFormObjName(obj) : "";
		}
		catch(e){return ""}
	}
	else{
		//Object로 들어 온 경우
		try{
			var tObj = eval(obj.form.name+"."+obj.name);
			var objName;
			if(tObj.length){
				for(var i=0;i<tObj.length;i++){
					if(obj==tObj[i]){
						objName = obj.form.name+"."+obj.name+"["+i+"]";
						break;
					}
				}
			}
			else{
				objName = obj.form.name+"."+obj.name;
			}
			return objName;
		}catch(e){
			return "";
		}
	}
}
//문자열이던 오브젝트건 상관 않고 오브젝트 구하기
function getObj(obj){
	if(typeof(obj)=='object') return obj;
	else{
		try{
			var o = E(obj);
			if(typeof(o)=='object') return o;
			var o = eval(obj);
			if(typeof(o)=='object') return o;
			else return "";
		}
		catch(e){return ""}
	}
}
function openWindow(url,target, width, height, center, toolbar, menubar, statusbar, scrollbar, resizable){
	try{
		var strCenter = "";
		toolbar_str = toolbar ? 'yes' : 'no';
		menubar_str = menubar ? 'yes' : 'no';
		statusbar_str = statusbar ? 'yes' : 'no';
		scrollbar_str = scrollbar ? 'yes' : 'no';
		resizable_str = resizable ? 'yes' : 'no';
		if(center) strCenter = ', top='+getCenterY(height)+', left='+getCenterX(width)
		var win = window.open(url, target, 'width='+width+',height='+height+',toolbar='+toolbar_str+',menubar='+menubar_str+',status='+statusbar_str+',scrollbars='+scrollbar_str+',resizable='+resizable_str + strCenter);
		win.focus();
	}catch(e){}
}
function openCaseWindow(vCase,url,target,width,height){
	try{
		if	 (vCase==1)
			win = openWindow(url,target,width,height,1,0,0,0,1,0);
		else if(vCase==2)
			win = openWindow(url,target,width,height,1,0,0,1,1,0);
		else if(vCase==3)
			win = openWindow(url,target,width,height,0,0,0,0,1,0);
		else if(vCase==4)
			win = openWindow(url,target,width,height,0,0,0,0,1,0);
		win.focus();
		return win;
	}catch(e){}
}
function openWinCenter(URL,width,height,target){
	try{
		if(!target){
			target=URL.replace(/\//g,"");
			target=target.replace(/\./g,"");
			target=target.replace(/\?/g,"");
			target=target.replace(/\&/g,"");
			target=target.replace(/\=/g,"");
		}
		win_center=window.open(URL,target,'toolbar=0,location=0,directory=0,status=0,menubar=0,scrollbars=1,resizable=0, width='+width+', height='+height+', top='+getCenterY(height)+', left='+getCenterX(width));
		win_center.focus();
		//return win_center;
	}catch(e){}
}
function openWinModal(obj,URL,width,height){
	window_style = "dialogWidth="+width+"px; dialogHeight="+height+"px; center=yes; border=thin; status=no; help=no; scroll=no";
	val=window.showModalDialog(URL,'_modal',window_style);
	if(val) obj.value=val;
	return val;
}
//사용자ID 유효성 체크
function chkLoginId(idObj, oldId){
	var allowStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
	var idcheck;
	var firstStr = idObj.value.substring(0,1);

	if(idObj.value!=oldId && (!isNaN(firstStr) || firstStr.isIn('_','-'))){
		alert("ID는 영문단어로 시작하여야 합니다.");
		idObj.select();
		return  false;
	}
	for (i=0; i< idObj.value.length; i++){
		idcheck = idObj.value.charAt(i);
		for (j=0;  j< allowStr.length; j++)
		if (idcheck==allowStr.charAt(j))	break;

		if (j==allowStr.length){
			alert("ID는 영문 , 숫자 , '-' , '_' 만 사용가능합니다.");
			idObj.select();
			return false;
		}
	}
	if((idObj.value.length <4 ) || (idObj.value.length > idObj.maxLength )){
		alert ("ID는 4자리 ~ "+idObj.maxLength+"자리 를 입력하세요.");
		idObj.select();
		return false;
	}
	return true;
}
function chkNumberKeyUp(obj){
	if(	(48 <= event.keyCode && event.keyCode <= 57)		//키보드 0-9
		 ||(96 <= event.keyCode && event.keyCode <= 105)	//숫자패드 0 -9
		 || event.keyCode.isIn(8,46)						// 백스페이스 , Del
		){
		var a=out_comma(obj.value);
		obj.value=in_comma(a);
	}
}
function chkNumberKeyDown(obj){
	chkNumber(obj);
}
function toUpperCaseKeyUp(obj){
	//	//a:65 ~ z:90 -> 영문 대문자로 바꾸기
	if(65 <= event.keyCode && event.keyCode <= 90){
		obj.value = obj.value.toUpperCase();
	}
}

function chkNumber(obj){
	var isOk = false;
	if(event.shiftKey) isOk = false;
	else if(event.keyCode.isIn(109,189)){
		// 숫자패드 - , 키보드 -
		//맨앞에만 - 들어가게 한다
		isOk = (obj.value=='');
	}
	else if(
		(  (48 <= event.keyCode && event.keyCode <= 57) || (96 <= event.keyCode && event.keyCode <= 105)  ) //키보드 0-9 , 숫자패드 0 -9
		|| event.keyCode.isIn(13,8,9,46,35,36,37,39)		// Enter , 백스페이스 , Tab , Del , End , Home , 커서키 ← , →
		|| (event.ctrlKey && event.keyCode.isIn(67,86,65))	// CTRL + c , v (붙여넣기) , a (모두선택)
	   ) isOk = true;
	else isOk = false;

	eventReturnValue(isOk);
	//alert(event.keyCode)
}
//0과 양수만 입력 가능
//사용법 : onKeyDown=chkPlusNumber(this);
function chkPlusNumber(obj){
	if(event.keyCode.isIn(109,189)) eventReturnValue(false);	//숫자패드 - , 키보드 -
	else chkNumber(obj);
}
function chkFloatNumber(obj){
	if(event.keyCode.isIn(190,110)){
		//키보드 . , 숫자패드 .
		if(obj.value=='' || obj.value.indexOf('.')>-1)	eventReturnValue(false);
		else											eventReturnValue(true);
	}
	else chkPlusNumber(obj);
}

//콤마 빼기
function out_comma(str){
	comm_str = String(str);
	return comm_str.replace(/,/g,"");
}
//콤마 넣기
function in_comma(str){
	if(isNothing(str)) return "";
	uncomm_str = out_comma(String(str));
	var sign = "";
	var lowDot = "";
	if(uncomm_str.substring(0,1)=="-"){
		sign = "-";
		uncomm_str = uncomm_str.substr(1)
	}
	if(uncomm_str.indexOf('.')>-1){
		lowDot = uncomm_str.substr(uncomm_str.indexOf('.'));
		uncomm_str = uncomm_str.substring(0,uncomm_str.indexOf('.'));
	}

	comm_str = "";
	loop_j = uncomm_str.length - 3;
	for(j=loop_j; j>=1 ; j=j-3){
		comm_str=","+uncomm_str.substring(j,j+3)+comm_str;
	}
	comm_str = uncomm_str.substring(0,j+3)+comm_str;
	return sign + comm_str + lowDot;
}

//숫자값 체크(소숫점 불가)
function isNumber(str){
	for(var i = 0 ; i < str.length ; i++ ){
	if(str.substring(i, i+1) < '0' || str.substring(i, i+1) > '9')
		return false;
	}
	return true;
}
//Object 길이 구하기
function getObjLen(obj){
	var len = 0;
	if		(typeof(obj)=='object') {for(var i in obj) len++;}
	else if	(typeof(obj)=='string') {len = obj.length;}
	else {len = obj.toString().length;}
	return len;
}
//Object type 구하기
function getObjType(obj){
	var oType = (obj.type) ? obj.type.toUpperCase() : obj[0].type.toUpperCase();
	return (oType.indexOf('SELECT')==0) ? 'SELECT' : oType;
}
function getObjName(obj){
	var objName;
	try{objName = (obj[0].name) ? obj[0].name : obj.name}catch(e){objName = obj.name;}
	return objName;
}

// 글자 바이트수  계산
function getByteLen(obj){
	var byteLen = 0;
	var objVal = (obj.value!=undefined) ? obj.value : obj;
	try{objVal = objVal.replace(/\r\n/g,"\n");}catch(e){}
	if(objVal==null) return 0;
	for(var i=0; i<objVal.length; i++){
		var c = escape(objVal.charAt(i));
		if(c.length==1) byteLen++;
		else if(c.indexOf("%u") != -1) byteLen += 2;
		else if(c.indexOf("%") != -1) byteLen += c.length/3;
	}
	return byteLen;
}
function getTextByByteLen(txt,len){
	var byteLen = 0;
	var objVal = txt.replace(/\r\n/g,"\n");
	if(objVal==null) return "";
	for(var i=0; i<objVal.length; i++){
		var c = escape(objVal.charAt(i));
		if(c.length==1) byteLen ++;
		else if(c.indexOf("%u") != -1) byteLen += 2;
		else if(c.indexOf("%") != -1) byteLen += c.length/3;
		if(byteLen>len) return txt.substring(0,i);
	}
	return txt;
}
function getTextDotByByteLen(txt,len){
	var text = getTextByByteLen(txt,len);
	return (text!=txt) ? text.substring(0,text.length-1)+"…" : text;
}
function monthCheck(fromDate, toDate){
	fromDate = fromDate.replace(/\./g,"");
	toDate = toDate.replace(/\./g,"");
	return (toDate.substring(0,4) - fromDate.substring(0,4)) * 1200 + (toDate.substr(4) - fromDate.substr(4));
}


//S : 라디오(radio) , 체크박스(checkbox) 관련 ------------------------------------

//체크박스 체크 토글
function checkToggle(obj){
	var idName = (obj.name) ? obj.name : obj.id;
	var objs = (obj.length) ? obj : Es(idName);
	var isCheck = objs[0].checked;
	checkObject(objs,isCheck);
}
//체크박스 체크
function checkObject(obj,isCheck){
	isCheck = (isCheck==undefined) ? true : isCheck;
	if(obj.length) for(var i=0;i<obj.length;i++) obj[i].checked = isCheck;
	else obj.checked = isCheck;
}
//체크박스 체크하기
function checkObjectByValue(){
	var obj = arguments[0];
	for(var i=1;i<arguments.length;i++){
		if(arguments[i] instanceof Array){
			for(var ii=0;ii<arguments[i].length;ii++) {checkObjectByValue(obj,arguments[i][ii]);}
		}
		else{
			if(obj.length) for(var ii=0;ii<obj.length;ii++) {obj[ii].checked = (obj[ii].value==arguments[i]);}
			else {obj.checked = (obj.value==arguments[i]);}
		}
	}
}
//값으로 라디오 버튼 등을 클릭하기
function clickObjectByValue(obj,val){
	var clickObj;
	if(obj.length) {for(var i=0;i<obj.length;i++) {if(obj[i].value==val){clickObj=obj[i];break;}}}
	else if(obj.value==val)	{clickObj = obj;}
	if(clickObj) {clickObj.click();}
}
function getSelectedRadioValue(obj){
	for(var i=0;i<obj.length;i++){
		if(obj[i].checked) return obj[i].value;
	}
	return "";
}
function getSelectedRadioIndex(obj){
	for(var i=0;i<obj.length;i++){
		if(obj[i].checked) return i;
	}
	return -1;
}
function getObjectByValue(obj,val){
	for(var i=0;i<obj.length;i++){
		if(obj[i].value==val) return obj[i];
	}
	return "";
}

// radio버튼 select 되지 않은 것들 disabled 처리
function setDisabledNotSelect(obj){
	for(var i=0;i<obj.length;i++){obj[i].disabled=!obj[i].checked;}
}

// 선택되지 않은 버튼 안보이게 처리
function setHideNotSelectButton(obj){
	var objs = (obj.length) ? obj : Es(obj.name);
	for(var i=0;i<objs.length;i++) {objs[i].style.display = (objs[i].className.substr(objs[i].className.length-1)=="S") ? '' : 'none';}
}

//E : 라디오(radio) , 체크박스(checkbox) 관련 ------------------------------------

// 콤보박스에서 해당값외는 모두 삭제하기
function removeOtherOptions(obj,val){
	if(val=='') return;
	for(var i=obj.length-1;i>=0;i--) if(obj.options[i].value!=val) obj.remove(i);
}

// 선택되지 않은 버튼 disabled 처리
function setDisabledNotSelectButton(obj){
	var objs = (obj.length) ? obj : Es(obj.name);
	for(var i=0;i<objs.length;i++) {objs[i].disabled = (objs[i].className.substr(objs[i].className.length-1)!="S");}
}

function openHelpWin(url){
	openWindow(url,'_help', 1014, 650, 1, 0, 0, 1, 1, 0);
}
//'-' 비허용
function chkPhoneNumber(obj){
	if(event.keyCode==109 || event.keyCode==189) eventReturnValue(false);	//숫자패드 - , 키보드 -
	else chkNumber(obj);

}
//'-' 허용
function chkNumberHypon(obj){
	if(event.keyCode==109 || event.keyCode==189){
		if(obj.value=='')	eventReturnValue(false);
		else				eventReturnValue(true);
	}
	else chkNumber(obj);
}
function chkPhoneNumberNoCopy(obj){
	if(event.ctrlKey && (event.keyCode==67 || event.keyCode==88)) eventReturnValue(false);  // CTRL + c,x
	else chkPhoneNumber(obj);
}
function chkDateRange(fromDate,toDate,month,isNotChkInput){
	if(!month) month=1;
	if(!isNotChkInput && (fromDate=="" || toDate=="")){
		alert("검색기간을 선택하세요");
		return false;
	}
	if(fromDate > toDate){
		alert('시작날짜가 끝날짜 이후 날짜 입니다.\n\n다시 입력 하세요.');
		return false;
	}
	var dayGap = monthCheck(fromDate, toDate);
	if(dayGap >= 100*month){
		alert('검색범위가 너무 큽니다. \n\n'+month+'개월 이하 검색가능합니다.');
		return false;
	}
	else return true;
}
function openLeftFull(width,url,winName,resizable){
	try {
		var height = screen.availHeight-70;
		if(!resizable) resizable='yes';
		if(resizable=='no') height += 2;
		var win = window.open(url,"_"+winName,'resizable='+resizable+',scrollbars=no,status=no,width=' + width + ',height=' + height + ',top=0 ,left=0');
		win.focus();
	}
	catch(e){}
}
function openRightFull(width,url,winName,resizable){
	try {
		var height = screen.availHeight-70;
		var left = screen.availWidth - width - 10;
		if(!resizable) resizable='yes';
		if(resizable=='no') height += 2;
		var win = window.open(url,"_"+winName,'resizable='+resizable+',scrollbars=no,status=no,width=' + width + ',height=' + height + ',top=0 ,left='+left);
		win.focus();
	}
	catch(e){}
}
function openCenterFull(width,url,winName,resizable,scroll){
	try {
		var height = screen.availHeight-70;
		var left = (screen.availWidth - width - 10)/2;
		if(!resizable) resizable='yes';
		if(resizable=='no') height += 2;
		var win = window.open(url,"_"+winName,'resizable='+resizable+',scrollbars='+scroll+',status=no,width=' + width + ',height=' + height + ',top=0 ,left='+left);
		win.focus();
	}
	catch(e){}
}

// 오브젝트 top값 구하기
function getObjectTop(obj){
	if(obj.offsetParent==document.body)
		return parseFloat(obj.offsetTop);
	else
		return parseFloat(obj.offsetTop) + getObjectTop(obj.offsetParent);
}

// 오브젝트 left값 구하기
function getObjectLeft(obj){
	if(obj.offsetParent==document.body)
		return parseFloat(obj.offsetLeft);
	else
		return parseFloat(obj.offsetLeft) + getObjectLeft(obj.offsetParent);
}

function setRemoveHypon(obj){
	try{
		obj.value=removeHypon(obj.value);
		obj.select();
		try{obj.focus();}catch(e){};
	}
	catch(e){}
}

//'-' 제거
function removeHypon(val){
	comm_str = String(val);
	return comm_str.replace(/-/g,"");
}

//전화번호에 '-'넣기
function getPhoneFormat(phone){
	if(isNothing(phone)) return "";
	phone = removeHypon(trim(toNN(phone)));
	var phoneLen = phone.length;
	try{
		if(phoneLen<6 || 12<phoneLen) return phone;
		if(phoneLen==10 && phone.substr(0,1)=="1") return phone.substr(0,5)+"-"+phone.substr(5);//지능망번호 16666-16666(헛수번호 인정)
		var s3,s2,s1;
		s3 = phone.substr(phoneLen-4);
		s2 = phone.substr(0,phoneLen-4);
		if(phoneLen<9) return s2+"-"+s3;
		if(phone.substr(0,1)!="0") return phone;
		s1 = (phone.substr(0,2)=="02") ? "02" :
			 (phone.substr(0,3).isIn("013","050")) ? phone.substr(0,4) :
			 (phoneLen==12) ? phone.substr(0,4) : phone.substr(0,3);
		return s1 +"-"+ s2.substr(s1.length) +"-"+ s3;
	}
	catch(e){
		return phone;
	}
}
function getPhoneFormatHide(phone){
	try{
		phone = getPhoneFormat(phone);
		phone = phone.substr(0,phone.length-7)+"**"+phone.substr(phone.length-5);
		return phone;
	}
	catch(e){
		return phone;
	}
}
function getPhoneFormatHideHtml(phone){
	try{
		phone = getPhoneFormat(phone);
		phone = phone.substr(0,phone.length-7)+"<font color=#aaaaaa>**</font>"+phone.substr(phone.length-5);
		return phone;
	}
	catch(e){
		return phone;
	}
}

function setPhoneFormat(obj){
	obj.value = getPhoneFormat(obj.value);
}

//휴대폰번호 체크
function isHandphoneNumber(phoneNumber){
	try{
		formatNumber = getPhoneFormat(phoneNumber);
		var chkPhone =/^0[1-9][0-9]{1,2}-[0-9][0-9]{2,3}-[0-9]{4}$/;
		if(chkPhone.test(formatNumber)){
			firstNum = formatNumber.split("-")[0];
			var handphoneFirst ="|010|011|016|017|018|019|013|";
			if(handphoneFirst.indexOf("|"+firstNum+"|")>-1) return true;
			else	return false;
		}
		else return false;
	}
	catch(e){
		return false;
	}
}

//전화번호 체크 : 지역번호 유효성 체크
function isPhoneNumber(pNum){
	try{
		var formatNumber = getPhoneFormat(pNum);
		var chkPhone  =/^0[1-9][0-9]{0,2}-[0-9][0-9]{2,3}-[0-9]{4}$/;
		var chkPhone2 =/^1[0-9]{3}-[0-9]{4}$/; //지능망번호 허용
		if(chkPhone.test(formatNumber)){
			var firstNum = formatNumber.split("-")[0];
			//서울 02 경기 031 인천 032 강원 033 충남 041 대전 042 충북 043 부산 051 울산 052 대구 053 경북 054 경남 055 전남 061 광주 062 전북 063 제주 064
			var phoneFirst =
				"|02|031|032|033|041|042|043|051|052|053|054|055|061|062|063|064"+//지역번호
				"|050|0500|0501|0502|0503|0504|0505|0506|0507|0508|0509"+
				"|013|0130|0131|0132|0133|0134|0135|0136|0137|0138|0139"+
				"|030|060|070|080"+		//030:통합메시징,050:평생번호, 060:녹음한음성정보
				"|010|011|016|017|018|019|";
			return (phoneFirst.indexOf("|"+firstNum+"|")>-1);
		}
		else if(chkPhone2.test(formatNumber)){
			return true;
		}
		else return false;
	}
	catch(e){
		return false;
	}
}

//전화번호 체크 : 지역번호 유효성 체크 안함
function isPhoneNumberLowChk(pNum){
	try{
		var formatNumber = getPhoneFormat(pNum);
		var chkPhone  =/^0[1-9][0-9]{0,2}-[0-9][0-9]{2,3}-[0-9]{4}$/;
		var chkPhone2 =/^1[0-9]{3,4}-[0-9]{4,5}$/; //지능망번호 허용
		if(chkPhone.test(formatNumber)){
			return (formatNumber.substr(0,1)=="0");
		}
		else if(chkPhone2.test(formatNumber)){
			return true;
		}
		else return false;
	}
	catch(e){
		return false;
	}
}
//전화번호 체크 : 자릿수만 체크함
function isPhoneNumberLowChk2(phoneNumber){
	try{
		formatNumber = getPhoneFormat(phoneNumber);
		//var chkPhone =/^0[1-9][0-9]{0,2}-[1-9][0-9]{2,3}-[0-9]{4}$/;
		var chkPhone =/^[0-9]{0,4}[-]{0,1}[0-9]{3,4}-[0-9]{4}$/;
		if(chkPhone.test(formatNumber)){
			return true;
		}
		else return false;
	}
	catch(e){
		return false;
	}
}
function isBirthDate(birth){
	if(birth=="000000") return true;
	var chkBirth =/^[0-9]{6}$/;
	if(chkBirth.test(birth)){
		var year2 = Number((new Date()).getYear())%100;
		birth = (Number(birth.substr(0,2))>year2) ? "19"+birth : "20"+birth;
		var tmpBirth = dateToStr(strToDate(birth),'yyyyMMdd');
		return (birth==tmpBirth);
	}
	else return false;
}
function isJuminHypon(jumin){
	if(jumin=="000000-0000000") return true;
	var chkJuminNo =/^[0-9]{6}-[0-9]{7}$/;
	if(chkJuminNo.test(jumin)) return isJumin(jumin.substr(0, jumin.indexOf("-")), jumin.substr(jumin.indexOf("-")+1));
	else return false;
}
function isJumin(jumin1, jumin2){
	var retValue = chkJumin(jumin1, jumin2);
	if(retValue==1) return true;
	else			 return false;
}
function chkJumin(jumin1, jumin2){
	if(jumin1=='000000'&&jumin2=='0000000') return true;
	/*
	* 주민번호체크 스크립트
	* 리턴값
	* 1 : 정상 주민등록번호
	* 0 : 비정상 주민등록번호
	* -1 : 입력인수 숫자 아님
	* -2 : 입력인수 길이 맞지 않음
	* -3 : 입력인수 1~4값 아님
	* -4 : 입력인수 정상적인 생년월일 아님
	* -5 : 입력인수의 날짜가 오늘(시스템날짜)보다 이후
	*/
	var tmp, y, m, d, sum = 0;
	var date, now = new Date();
	var numArr = new Array(13);
	var mulNum = new Array(2,3,4,5,6,7,8,9,2,3,4,5);
	if(isFinite(jumin1) && isFinite(jumin2)){
		if(jumin1.length==6 && jumin2.length==7){
			for(var i=0;i<6;i++) numArr[i] = parseFloat(jumin1.charAt(i));
			for(var i=0;i<7;i++) numArr[6+i] = parseFloat(jumin2.charAt(i));
			if((numArr[6] > 0) && (numArr[6] < 5) ){
				y = numArr[0]*10+numArr[1];
				m = numArr[2]*10+numArr[3];
				d = numArr[4]*10+numArr[5];

				y += (numArr[6] < 3) ? 1900 : 2000;

				date = new Date(y, m-1, d);
				if((date.getYear()%100==y%100) && (date.getMonth()==m-1) && (date.getDate()==d)){
					if(date.getTime() < now.getTime()){
						for(var i=0;i<12;i++) sum += numArr[i]*mulNum[i];
						tmp = sum%11;

						if(tmp==0) tmp = 10;
						else if(tmp==1) tmp = 11;

						if((11-tmp)==numArr[12]) return 1;
						else return 0;
					}
					else return -5;
				}
				else return -4;
			}
			else return -3;
		}
		else return -2;
	}
	else return -1;
}

//사업자 번호 체크
function isBusinessNoHypon(bizNo){
	if(bizNo=="000-00-00000")	return true;
	var chkBizNo =/^[0-9]{3}-[0-9]{2}-[0-9]{5}$/;
	if(chkBizNo.test(bizNo)) return isBusinessNo(bizNo);
	else return false;
}
function isBusinessNo(bizNo){
	bizNo = removeHypon(bizNo);

	if(bizNo.length != 10)		return false;
	if(!isNumber(bizNo))		return false;

	var calStr1 = "13713713", biVal = 0,tmpCal;
	var calLast = bizNo.substring(9,10);

	for(var i=0; i < 8; i++){
		biVal = biVal + (parseFloat(bizNo.substring(i,i+1)) * parseFloat(calStr1.substring(i,i+1))) % 10;
	}
	tmpCal = parseFloat(bizNo.substring(8,9)) * 5 + "0";
	chkVal = parseFloat(tmpCal.substring(0,1)) + parseFloat(tmpCal.substring(1,2));
	chkDigit = (10 - (biVal + chkVal) % 10) % 10;

	if(calLast != chkDigit)	return false;
	else						return true;
}

//iFrame크기를 내용의 크기로 자동 변경
 comm.resize_cnt = 0
function optimizeResize(plus,isForce){
	if(document.body.scrollHeight > 50){
		plus = (!plus) ? 0 : plus;
		if(window!=parent.window){
			var thisWin =  parent.document.getElementsByName(window.name)[0];
			if(thisWin.tagName.toUpperCase()!='IFRAME') return;
			var prntHeight = parseFloat(parent.document.body.scrollHeight);
			self.resizeTo(document.body.offsetWidth, 50);
			thisWin.style.height='50px';
			self.resizeTo(document.body.offsetWidth, parseFloat(document.body.scrollHeight)+plus);
			thisWin.style.height=parseFloat(document.body.scrollHeight)+plus+'px';
			if(prntHeight<parseFloat(parent.document.body.scrollHeight)){
				//서브창으로 인해 부모창이 더 커진 경우 아래 여백을 10 더 주기 위함
				try{
					try{parent.optimizeResize(10);}catch(e){}
					parent.alphaWindow.style.height = parseFloat(parent.document.body.scrollHeight)+plus +'px';
				}catch(e){}
			}
			else{
				try{parent.optimizeResize();}catch(e){}
			}
		}
		else if(isForce){
			self.resizeTo(document.body.offsetWidth,'50');
			self.resizeTo(document.body.offsetWidth, parseFloat(document.body.scrollHeight)+plus);
		}
	}
	else{
		if(++comm.resize_cnt <50) setTimeout("optimizeResize("+plus+","+isForce+")",10);
	}
}
function optimizeResizeBoth(plus,isForce){
	if(document.body.scrollHeight > 50){
		plus = (!plus) ? 0 : plus;
		if(window!=parent.window){
			var thisWin =  parent.document.getElementsByName(window.name)[0];
			if(thisWin.tagName.toUpperCase()!='IFRAME') return;
			var prntHeight = parseFloat(parent.document.body.scrollHeight);
			self.resizeTo(50, 50);
			thisWin.style.width='50px';
			thisWin.style.height='50px';
			self.resizeTo(document.body.offsetWidth, parseFloat(document.body.scrollHeight)+plus);
			thisWin.style.height=parseFloat(document.body.scrollHeight)+plus+'px';
			thisWin.style.width=parseFloat(document.body.scrollWidth)+'px';
			if(prntHeight<parseFloat(parent.document.body.scrollHeight)){
				//서브창으로 인해 부모창이 더 커진 경우 아래 여백을 10 더 주기 위함
				try{
					try{parent.optimizeResize(10);}catch(e){}
					parent.alphaWindow.style.height = parseFloat(parent.document.body.scrollHeight)+10+'px';
				}catch(e){}
			}
			else{
				try{parent.optimizeResize();}catch(e){}
			}
		}
		else if(isForce){
			self.resizeTo(50,50);
			self.resizeTo(document.body.offsetWidth, parseFloat(document.body.scrollHeight)+plus);
		}
	}
	else{
		if(++comm.resize_cnt <50) setTimeout("optimizeResizeBoth("+plus+","+isForce+")",10);
	}
}
function optimizeResizeHeight(plus,isParent){
	isParent = (isParent) ? true : false;
	plus = (!plus) ? 0 : plus;
	if(document.body.scrollHeight > 50){
		if(window!=top.window){
			try{
				parent.E(window.name).style.height = document.body.scrollHeight + plus;
				if(isParent) parent.optimizeResizeHeight();
			}catch(e){}
		}
	}
	else{
		if(++comm.resize_cnt <50) setTimeout("optimizeResizeHeight("+plus+","+isParent+")",10);
	}
}
function chgObjAttr(obj,attr){
	var type = obj.type.toLowerCase();
	if(type.indexOf('text')!=0 && type.indexOf('select')!=0 && type.indexOf('textarea')!=0){
		alert("Not supported '"+type+"' type !");
		return;
	}

	if(attr=="readonly"){
		if(type.indexOf('select')==0){
			obj.disabled = true;
		}
		else{
			obj.disabled = false;
			obj.readOnly = true;
			obj.style.backgroundColor = "#e5e5e5";
		}
	}
	else if(attr=="disabled"){
		if(type.indexOf('select')==0){
			obj.disabled = true;
		}
		else{
			obj.disabled = false;
			obj.readOnly = true;
			obj.style.backgroundColor = "#dddddd";
		}
	}
	else if(attr=="write"){
		obj.disabled = false;
		obj.readOnly = false;
		obj.style.backgroundColor = "#ffffff";
	}
	else{
		alert("Wrong attribute '"+attr+"' !");
	}
}
function chgBG(obj,isFocus,afterAct){
	if(obj.readOnly || obj.disabled){window.focus();return;}
	chgForceBG(obj,isFocus);
	if(afterAct){
		var actStr = afterAct.replace(/\|s\|/g,'');
		obj.value =
			(actStr=='num')  ? (isFocus) ? out_comma(obj.value) : in_comma(obj.value) :
			(actStr=='tel')  ? (isFocus) ? removeHypon(obj.value) : getPhoneFormat(obj.value) :
			obj.value;

		if(isFocus && afterAct.indexOf('|s|')>-1 && (!obj.state || obj.state.indexOf('|ns|')==-1)) obj.select();
	}
	obj.state = '';
}
// readOnly 상관없이 무조건 배경색 바꿈
function chgForceBG(obj,isFocus){
	if(isFocus)	{
		//orderText는 글자색이 파란색이다.
		var textColor = (obj.className.indexOf("orderText")>=0) ? "#0000ff" : "#333333";
		obj.style.backgroundColor = '#ffdfe1'; obj.style.color=textColor;
	}
	else{
		var textColor = (obj.className.indexOf("orderText")>=0) ? "#0000ff" : "#333333";
		obj.style.backgroundColor = '#ffffff'; obj.style.color=textColor;
	}
}
// X축 위치구하기
function findPosX(obj,addValue){
	var curLeft = 0;
	if(obj.offsetParent){
		do{
			curLeft += obj.offsetLeft;
			//alert(obj.id+" : "+obj.tagName+" : "+obj.offsetLeft)
			obj = obj.offsetParent;
		}while(obj);
	}
	else if(obj.x){
		curLeft += obj.x;
	}
	if(addValue) curLeft += addValue;
	//alert(curLeft)
	return curLeft;
}
// Y축 위치구하기
function findPosY(obj,addValue){
	var curTop = 0;
	if(obj.offsetParent){
		do{
			curTop += obj.offsetTop;
			obj = obj.offsetParent;
		}while(obj);
	}
	else if(obj.y){
		curTop += obj.y;
	}
	if(addValue) curTop += addValue;
	return curTop;
}
//깜박임 -------------------------------------------------
comm.blinkTime = new Object();
function blink(layerName,on_time,off_time){
	if(E(layerName).style.visibility=="hidden"){
		E(layerName).style.visibility="visible";
		comm.blinkTime[layerName] = setTimeout("blink('"+layerName+"',"+on_time+","+off_time+")",on_time);
	}
	else{
		E(layerName).style.visibility="hidden";
		comm.blinkTime[layerName] = setTimeout("blink('"+layerName+"',"+on_time+","+off_time+")",off_time);
	}
}
function stopBlink(layerName,isView){
	clearTimeout(comm.blinkTime[layerName]);
	if(isView) E(layerName).style.visibility = 'visible';
	else E(layerName).style.visibility = 'hidden';
}
// display 숨김버젼 --------------------------------------
function blink2(layerName,on_time,off_time){
	if(E(layerName).style.display=="none"){
		E(layerName).style.display="";
		comm.blinkTime[layerName] = setTimeout("blink2('"+layerName+"',"+on_time+","+off_time+")",on_time);
	}
	else{
		E(layerName).style.display="none";
		comm.blinkTime[layerName] = setTimeout("blink2('"+layerName+"',"+on_time+","+off_time+")",off_time);
	}
}
function stopBlink2(layerName,isView){
	clearTimeout(comm.blinkTime[layerName]);
	if(isView) E(layerName).style.display = '';
	else E(layerName).style.display = 'none';
}
//--------------------------------------------------------

// BY BYUNGSUNG
function checkIDType(obj,strMsg){
	if(true==isSpace(obj)){
		alert (strMsg +  '반드시 입력하셔야 합니다.');
		try{obj.focus();}catch(e){};
		return false;
	}

	if( true==isSpecialKey(obj) ){
		alert (strMsg +  ' 특수문자를 입력하실 수 없습니다. ');
		try{obj.focus();}catch(e){};
		obj.select();
		return false;
	}

	if( true==checkCode(obj) ){
		alert ( strMsg + ' 특수문자를 입력하실 수 없습니다. ');
		try{obj.focus();}catch(e){};
		obj.select();
		return false;
	}

	if( false==checkRange(obj, 4, 20) ){
		alert ( strMsg + ' 영/숫자 4~20자 이내로 입력하세요.   ');
		try{obj.focus();}catch(e){};
		obj.select();
		return false;
	}
	return true;
}

function chkName(obj, str){
	if(true==isSpace(obj)){	//입력유무체크
		alert (str + ' 반드시 입력하셔야 합니다.');
		try{obj.focus();}catch(e){};
		return false;
	}

	if( true==isSpecialKey(obj) ){
		alert ( ' 특수문자는 입력하실 수 없습니다 ');
		try{obj.focus();}catch(e){};
		obj.select();
		return false;
	}

	if( false==checkRange(obj, 4, 10) ){
		alert (' 기입하신 ' + str + '이 너무 짧거나 깁니다. ' );
		try{obj.focus();}catch(e){};
		obj.select();
		return false;
	}

	if( check_format(obj.value.toLowerCase(),"0123456789abcdefghijklmnopqrstuvwxyz")){
		alert ( ' 한글로 입력해 주세요. ' );
		try{obj.focus();}catch(e){};
		obj.select();
		return false;
	}
	return true;
}
function chkEmailAlert(obj,isOption){
	var emailType = chkEmailType(trimObj(obj));

	if(!isOption && emailType==0){
		alert('[EMail]을 입력하세요.');
		try{obj.focus();}catch(e){}
		return false;
	}

	if(emailType==-1){
		alert ('[EMail]에 특수 문자는 입력하실 수 없습니다.');
		try{obj.focus();}catch(e){}
		return false;
	}

	if(emailType==-2){
		alert ('[EMail] 주소가 정확하지 않습니다.');
		try{obj.focus();}catch(e){}
		return false;
	}
	return true;
}

function isEmail(val,isOption){
	var emailType = chkEmailType(val);
	if(emailType==1)					return true;
	else if(isOption && emailType==0)	return true;
	else								return false;
}

function chkEmailType(val){
	if(val=='')							return 0;
	if(isSKey4Email(val))				return -1;
	if(val.indexOf(".")==-1 || val.indexOf("@")==-1) 	return -2;
	if(val.indexOf(".")==val.length-1 || val.lastIndexOf("@")==val.length-1 || val.indexOf("@")!=val.lastIndexOf("@")) 	return -2;
	return 1;
}

function check_format(tmpValues,strFormat){
	for(var i=0; i<tmpValues.length;i++){
		ch=strFormat.indexOf(tmpValues.charAt(i));
		if(ch=='-1')	return false;
	}
	return true;
}

function checkRange(obj, fromLen, toLen, act){
	toLen = (isNothing(toLen)) ? 4000 : toLen;
	var objValue = obj.value;
	if	 (act=='hypon-') objValue = removeHypon(obj.value);
	else if(act=='comma-') objValue = out_comma(obj.value);
	var sum = getByteLen(objValue);
	return (fromLen <= sum && sum <= toLen );
}

function checkLength(obj, fromLen, toLen, word, act){
	if(!checkRange(obj, fromLen, toLen, act)){
		var msg = (fromLen==toLen) ? "["+word+"] 항목은 "+fromLen+" Byte 입니다." : "["+word+"] 항목은 "+fromLen+" ~ "+toLen+" Byte 까지입니다.";
		alert(msg);
		try{obj.focus();}catch(e){};
		return false;
	}
	return true;
}
function chkValidityAlert(obj, fromLen, word, act){
	if(act!='noTrim') trimObj(obj);
	if(act=='phone'){
		if(fromLen>0 && obj.value==''){
			alert("["+word+"] 항목을 입력하세요.");
			try{obj.focus();}catch(e){}
			return false;
		}
		else if(!isPhoneNumberLowChk(obj.value)){
			alert("잘못된 전화번호 형식입니다.");
			try{try{obj.focus();}catch(e){};obj.select();}catch(e){}
			return false;
		}
	}
	else if(act=='bizNo'){
		if (!isBusinessNoHypon(obj.value)){
			alert("잘못된 사업자번호 형식입니다.\n\n["+word+"] 항목을 '-' 까지 정확히 입력하세요.");
			try{obj.focus();}catch(e){}
			return false;
		}
	}
	else if(!checkRange(obj, fromLen, obj.maxLength, act)){
		var msg = (fromLen==obj.maxLength) ? "["+word+"] 항목은 "+fromLen+"Byte 입니다." : word+" 항목은 "+fromLen+" ~ "+obj.maxLength+" Byte 까지입니다.";
		alert(msg);
		try{obj.focus();}catch(e){}
		return false;
	}
	else if(fromLen<0 && obj.value==""){
		alert("["+word+"] 항목을 입력하세요.");
		try{obj.focus();}catch(e){}
		return false;
	}
	return true;
}
// 글자수 계산
function chkLenOnKeyUp(obj,pByte,cntLabel){
	var memoCnt= getByteLen(obj.value);
	cntLabel.innerHTML = memoCnt;

	if(memoCnt>pByte){
		var title = toNN(obj.alt,obj.title);
		alert("["+title+"] 항목은 "+pByte+"Byte 까지 쓰실 수 있습니다.");
		obj.value = getTextByByteLen(obj.value,pByte);
		cntLabel.innerHTML = getByteLen(obj.value);
		try{obj.focus();}catch(e){};
		return false;
	}else{
		return true;
	}
}

//폼에 속하는 오브젝트들을 submit 전에 enable 시켰다가 끝나면 disabled 시킨다.
comm.formElementDsbls = [];
function setFormElementsEnable(form,isEnable){
	var eIdx = 0;
	if(isEnable){
		for(var i=0;i<form.elements.length;i++){
			if(form.elements[i].disabled){
				comm.formElementDsbls[eIdx++] = form.elements[i];
				form.elements[i].disabled = false;
			}
			// select Element는 하부 option 하나하나 disabled 체크
			if(form.elements[i].type.toLowerCase().indexOf('select')==0){
				for(var ii=0;ii<form.elements[i].length;ii++){
					//alert(form.elements[i].name+"["+ii+"] : "+form.elements[i][ii].disabled)
					if(form.elements[i][ii].disabled){
						comm.formElementDsbls[eIdx++] = form.elements[i][ii];
						form.elements[i][ii].disabled = false;
					}
				}
			}
		}
	}
	else{
		for(var i=0;i<comm.formElementDsbls.length;i++){
			comm.formElementDsbls[i].disabled = true;
		}
		comm.formElementDsbls = [];
	}
}

//form 동적 생성
//예) makeFormAndGo("f1","/abc/def.jsp",{'param1':'aa', 'param2':'bb'});
function makeFormAndGo(formName, action, target, args){
	var f;
	if(!E("formName")){
		f = document.createElement('form');
		f.name = formName;
	}
	else{
		f = E("formName");
	}
	f.method = 'post';
	f.action = action;
	f.target = target;

	for(name in args){
		var input = document.createElement('input');
		input.type = 'hidden';
		input.name = name;
		input.value = args[name];
		f.appendChild(input);
	}
	document.body.appendChild(f);
	f.submit();
};

function isEqual(obj1,obj2,strMst){
	if(obj1.value != obj2.value){
		alert(strMst+' 서로 같지 않습니다..\n확인하시고 다시 입력해주십시요.');
		obj1.focus();
		obj1.select();
		return false;
	}
	else  return true;
}

function chkValueNull(obj, word){
	if(obj.value==""){
		alert(word);
		try{obj.focus();}catch(e){};
		return false;
	}
	return true;
}

function isSpace(obj){
	if(obj.value=="") return true;
	else return false;
}

function isSpecialKey(obj){
	for(var i = 0; i < obj.value.length; i++){
		var k = obj.value.charCodeAt(i) ;
		if( k >= 33 && k <= 47 )
			return true;
		else if( k >= 58 && k <= 64 )
			return true;
		else if( k >= 91 && k <= 96 )
			return true;
		else if( k >= 123 && k <= 126 )
			return true;
	}
	return false;
}

function isSKey4Email(val){
	for(var i = 0; i < val.length; i++){
		var k = val.charCodeAt(i) ;
		if( k>=33 && k<45)
			return true;
		else if( k==47 )
			return true;
		else if( k >= 58 && k < 64 )
			return true;
		else if( k >= 91 && k <= 94 )
			return true;
		else if( k==96 )
			return true;
		else if( k >= 123 && k <= 126 )
			return true;
		else
			return false;
	}
}

function checkCode(obj){
	for(var i = 0; i < obj.value.length; i++){
		var k = obj.value.charCodeAt(i) ;
		if(k < 33 || k > 127)
			return true;
	}
}

function chgTrBgClass(obj,isOver,cNameOver){//속도가 느림
	if(obj.className=='trSel') return;
	if(comm.selTrObj==obj) return;
	if(!cNameOver) cNameOver = 'bgGe';
	if(comm.oldTrObj != obj){
		if(isOver) obj.className=cNameOver;
		else obj.className='bgW';
	}
}
function chgTrBg(obj,isOver,overColor){
	if(comm.selTrObj==obj) return;
	overColor = toNN(overColor,"#e4e4e4");
	if(comm.oldTrObj != obj){
		obj.style.backgroundColor= (isOver) ? overColor : '#ffffff';
	}
}
function selTrBgClass(obj){//chgTrBgClass와 같이 써야 함
	try{
		if(!comm.selTrObj){
			obj.className = "trSel";
		}
		else if(comm.selTrObj != obj){
			obj.className = "trSel";
			comm.selTrObj.className = "bgW";
		}
		comm.selTrObj = obj;
	}
	catch(e){comm.selTrObj = obj};
}
function selTrBg(obj,bgColor){// chgTrBg와 같이 써야 함
	bgColor = toNN(bgColor,"#ffff00");
	try{
		if(!comm.selTrObj){
			obj.style.backgroundColor = bgColor;
		}
		else if(comm.selTrObj != obj){
			obj.style.backgroundColor = bgColor;
			comm.selTrObj.style.backgroundColor = "#ffffff";
		}
		comm.selTrObj = obj;
	}
	catch(e){comm.selTrObj = obj};
}
function unSelTrBg(bgColor){
	bgColor = (!bgColor) ? "#ffffff" : bgColor
	try{comm.selTrObj.style.backgroundColor = bgColor;}catch(e){}
	comm.selTrObj = '';
}
function selTrBgFg(obj,bgColor,fgColor,isBold){// chgTrBg와 같이 써야 함
	bgColor = (!bgColor) ? "#ffff00" : bgColor
	try{
		obj.style.backgroundColor = bgColor;
		obj.style.color = fgColor;
		obj.style.fontWeight = (isBold) ? "bold" : "lighter";
		if(comm.selTrObj && comm.selTrObj != obj){
			comm.selTrObj.style.backgroundColor	= "#ffffff";
			comm.selTrObj.style.color			= "#333333";
			comm.selTrObj.style.fontWeight		= "lighter";
		}
		comm.selTrObj = obj;
	}
	catch(e){comm.selTrObj = obj};
}
function isValidMaxLen(obj, removeStr){
	var objVal = (obj.value!=undefined) ? obj.value : obj;
	objVal = (removeStr) ? replaceAll(objVal,removeStr,'') : objVal;
	return (!obj.maxLength || obj.maxLength<0) ? true : (getByteLen(objVal)<=obj.maxLength);
}

function chkMaxLenAlert(obj,isTrim, removeStr){
	var fieldKind = (obj.kind) ? obj.kind : "";
	if(fieldKind.indexOf('|phone|')>-1) return true;
	if(isTrim) trimObj(obj);
	if(!isValidMaxLen(obj, removeStr)){
		var title = toNN(obj.alt,obj.title);
		alert('입력길이가 초과 하였습니다!\n\n['+title+'] 항목의 최대 입력 가능 길이는 '+obj.maxLength+'Byte 입니다\n\n( 현재 입력 한 길이 : '+getByteLen(obj.value)+'Byte )');
		try{obj.focus();}catch(e){};
		return false;
	}
	else return true;
}

function chkElementAlert(obj, removeStr){
	var objs = document.getElementsByName(getObjName(obj));
	var type = (obj.type) ? obj.type.toLowerCase() : objs[0].type.toLowerCase();
	if(type.indexOf('checkbox')==0 || type.indexOf('radio')==0){
		var required = (objs[0].className.indexOf("required")>-1) ? true : (objs[0].required==undefined) ? false : (objs[0].required.toString()=='') ? true : objs[0].required;
		if(required){
			var title	= toNN(objs[0].alt,objs[0].title);
			for(var i=0;i<objs.length;i++) if(objs[i].checked) return true;
			alert('['+title+'] 항목은 필수선택 입니다.');
			return false;
		}
	}
	else{
		//alert("obj.name="+obj.name)
		var required = (obj.className.indexOf("required")>-1) ? true : (obj.required==undefined) ? false : (obj.required.toString()=='') ? true : obj.required;
		var title	= toNN(obj.alt,obj.title);
		if(required){

			if(type.indexOf('select')==0){
				if(obj.value==''){
					alert('['+title+'] 항목은 필수선택 입니다.');
					try{obj.focus();}catch(e){}
					return false;
				}
				else return true;
			}
			else if(type.indexOf('hidden')==0){
				if(obj.value.length==0){
					alert('['+title+'] 항목은 필수입력이나 HIDDEN 필드 입니다.\n\n개발업체에 문의 하세요.');
					return false;
				}
				else return true;
			}
			else if(obj.value==''){
				alert('['+title+'] 항목은 필수입력 입니다.');
				if(!obj.readOnly) obj.focus();
				return false;
			}
		}
		removeStr = (removeStr!=undefined) ? removeStr : (title.isIn("전화","전화번호","대표번호","대표전화번호","일반전화","일반전화번호","휴대폰","휴대폰번호","휴대전화","휴대전화번호","팩스","팩스번호","FAX")) ? "-" : removeStr;
		return chkMaxLenAlert(obj, false, removeStr);
	}
	return true;
}

function chkFormElement(form){
	var prevElementName;
	for(var i=0;i<form.elements.length;i++){
		//alert(form.elements.length+"/"+i+"="+form.elements[i].name)
		if(form.elements[i].name!="") {
			if(prevElementName!=form.elements[i].name){
				if(!chkElementAlert(form.elements[i])) return false;
			}
			prevElementName = form.elements[i].name;
		}
	}
	return true;
}

function getObjIndex(obj){
	var objs = Es(obj.name);
	var idx=-1;
	for(var i=0;i<objs.length;i++){
		if(objs[i]==obj){idx = i;break;}
	}
	return idx;
}

// 기본 maxVal이 100% 이나 절대값이 더 큰 값이 있으면 그것이 100%가 되게 그래프 표시
function setGraph(cell,barImage,maxVal,imgSrc){
	if(cell.length>0){
		maxVal = getDivMaxAbsVal(cell,maxVal);
		var value;
		for(var i=0;i<cell.length;i++){
			value = parseFloat(out_comma(cell[i].innerText));
			barImage[i].src = (value<0) ? '/img/bar/barBlack.gif' : imgSrc;
			barImage[i].style.width = Math.abs(value/maxVal*100)+'%';
		}
	}
	return maxVal;
}
// maxVal 단위 아이콘 갯수와 그래프로 표시하기
function setGraphWithIcon(cell,barImage,barIcon,maxVal,imgSrc){
	if(barImage.length>0){
		for(var i=0;i<barImage.length;i++){
			var barLength = parseFloat(parseFloat(out_comma(cell[i].innerText))%maxVal)/maxVal*100;
			var iconCnt = Math.abs(parseFloat(parseFloat(out_comma(cell[i].innerText))/maxVal));
			var iconSrc;
			if(barLength<0){
				barImage[i].src='/img/bar/barBlack.gif';
				iconSrc = "<img src=/img/icon/blackX.gif>";
			}
			else{
				barImage[i].src=imgSrc;
				iconSrc = "<img src=/img/icon/greenPlus.gif>";
			}
			barImage[i].style.width = Math.abs(barLength)+'%';

			var tStr;
			for(var ii=0;ii<iconCnt;ii++)	tStr += iconSrc;
			barIcon[i].innerHTML = tStr;
		}
	}
}
function getDivMaxAbsVal(cell,maxVal){
	maxVal = (!maxVal) ? 0 : maxVal;
	if(cell.length>0){
		var value;
		for(var i=0;i<cell.length;i++){
			value = parseFloat(out_comma(cell[i].innerText));
			maxVal = (Math.abs(value) > maxVal) ? Math.abs(value) : maxVal;
		}
	}
	return maxVal;
}
function showElements(elmt,obj){
	obj.blur();
	var visibility = (obj.checked) ? 'visible' : 'hidden';
	if(elmt.length){
		for(var i=0;i<elmt.length;i++){
			elmt[i].style.visibility = visibility;
		}
	}
	else{
		elmt.style.visibility = visibility;
	}
}
function sleep(msecs){
	var start = new Date().getTime();
	var cur = start;
	while (cur - start < msecs){
		cur = new Date().getTime();
	}
}
function getSecondsInterval(fromDate, toDate){
	fromDate = (fromDate instanceof Date) ? fromDate : strToDate(fromDate);
	toDate   = (toDate   instanceof Date) ? toDate   : strToDate(toDate);
	return (fromDate.getTime() - toDate.getTime()) / 1000;
}
function getDaysInterval(fromDate, toDate){
	return getSecondsInterval(fromDate, toDate)/60/60/24;
}
//날짜사이 시간을 포맷팅 해서 보여준다. HH:mm:ss(앞에 타임이 없으면 한자리면 한자리로 보여준다.)
function getTimeInterval(fromDate, toDate, isSec){
	//isSec=true;
	if (isNothing(fromDate) || isNothing(toDate)) return "<font color=gray>-</font>";

	fromDate = (fromDate instanceof Date) ? fromDate : strToDate(fromDate);
	toDate   = (toDate   instanceof Date) ? toDate   : strToDate(toDate);
	var totSec = (fromDate.getTime() - toDate.getTime()) / 1000;
	var sign = (totSec>=0) ? "" : "-";
	totSec = (sign=="") ? totSec : totSec*(-1);
	var hour = parseInt(totSec/60/60);
	var min  = parseInt(totSec/60) - (hour*60);
	var sec = totSec - (hour*60*60) - (min*60);
	var fTimeSec = ((hour==0) ? '' : hour+":") + ((hour==0 && min==0) ? '' : ((hour==0) ? min : fillLeft(min,'0',2))+":") + ((hour==0 && min==0) ? sec : fillLeft(sec,'0',2))
	var fTimeMin = ((hour==0) ? '' : hour+":") + ((hour==0) ? min : fillLeft(min,'0',2));
	return (isSec) ? sign+fTimeSec : sign+fTimeMin;
}
//function getTimeSecInterval(fromDate, toDate){
//	//isSec=true;
//	if (isNothing(fromDate) || isNothing(toDate)) return "<font color=gray>-</font>";
//
//	fromDate = (fromDate instanceof Date) ? fromDate : strToDate(fromDate);
//	toDate   = (toDate   instanceof Date) ? toDate   : strToDate(toDate);
//	var totSec = (fromDate.getTime() - toDate.getTime()) / 1000;
//	var sign = (totSec>=0) ? "" : "-";
//	totSec = (sign=="") ? totSec : totSec*(-1);
//	var hour = parseInt(totSec/60/60);
//	var min  = parseInt(totSec/60) - (hour*60);
//	var sec = totSec - (hour*60*60) - (min*60);
//	var fTimeSec = ((hour==0) ? '' : hour+":") + ((hour==0 && min==0) ? '' : ((hour==0) ? min : fillLeft(min,'0',2))) + ((hour==0 && min==0) ? sec : (hour>0) ? '' : ":"+fillLeft(sec,'0',2));
//	return sign+fTimeSec;
//}
function strToDate(str){ //2013.02.11 21:30:11
	str = str.replace(/ /g,'').replace(/\./g,'').replace(/\-/g,'').replace(/\:/g,'');
	str = fillRight(str,'0',14);
	var d = new Date(str.substring(0,4),Number(str.substring(4,6))-1,str.substring(6,8),str.substring(8,10),str.substring(10,12),str.substring(12,14));
	return d;
}
function dateToStr(date,format){
	format = (format) ? format : 'yyyy.MM.dd';
	if(!date) date = new Date();
	return date.format(format);
}
function strToDateFormat(dateStr,format){
	return dateToStr(strToDate(dateStr),format);
}
//parseInt('09') -> 0 , parseFloat('09') -> 9로 변환됨
function secToPassDayStr(sec, isBeforeAfterStr){
	if(isNaN(sec)) return sec;

	var tailStr="", beforeAfterStr="", rtnStr="";
	if (sec<0) {
		sec = sec*(-1);
		beforeAfterStr = (isBeforeAfterStr) ? "-" : "";//전
		tailStr = "↓";
	}
	else{
		beforeAfterStr = (isBeforeAfterStr) ? "" : "";//후
		tailStr = "↑";
	}

	try{
		var date = new Date(new Date(2001,0,1).getTime()+(parseFloat(sec)*1000));//2001-01-01 00:00:00
		//alert(date.format("yyyy-MM-dd HH:mm:ss"))

		if(date.format("yyyyMMdd")=="20010101"){
			rtnStr  = (date.format("m")=="0") ? date.format("s초") : (date.format("s")=="0") ? date.format("m분") : date.format("m분s초");
			//rtnStr += beforeAfterStr;
		}
		else if(date.format("yyyyMM")=="200101"){
				rtnStr = (parseFloat(date.format("dd"))-1)+"일";
		}
		else if(date.format("yyyy")=="2001"){
			tailStr = (date.format("dd")=="01") ? "" : tailStr;
			rtnStr = (parseFloat(date.format("MM"))-1)+"달"+tailStr;
		}
		else {
			tailStr = (date.format("MMdd")=="0101") ? "" : tailStr;
			rtnStr = (parseFloat(date.format("yyyy"))-2001)+"년"+tailStr;
		}
	}catch(e){rtnStr = "("+sec+")";}
	return beforeAfterStr + rtnStr;
}

function dayToPassDayStr(day, isBeforeAfterStr){
	if(isNaN(day)) return day;
	return secToPassDayStr(parseFloat(day)*24*60*60, isBeforeAfterStr);
}

function secToTimeFormat(sec,format,isNotFull){
	if(!isNumber(sec)) return sec;
	var rtnStr = "";
	format = toNN(format,"HH:mm:ss");
	try{
		var date = new Date(new Date(2000,0,0).getTime()+(parseFloat(sec)*1000));//1999-12-31 00:00:00
		rtnStr = date.format(format);
		if(isNotFull){
			if(rtnStr.indexOf("0:")==0 ) rtnStr = rtnStr.substr(2);//시=0
			if(rtnStr.indexOf("00:")==0) rtnStr = rtnStr.substr(3);//시=00
			if(rtnStr.indexOf("0:")==0 ) rtnStr = rtnStr.substr(2);//분=0
			if(rtnStr.indexOf("00:")==0) rtnStr = rtnStr.substr(3);//분=00
			if(rtnStr.indexOf(":")==-1 ) rtnStr = parseFloat(rtnStr);
		}
	}catch(e){rtnStr = sec;}
	return rtnStr;
}
function dayToTime(day,format){
	try{
		var sec = day*24*60*60;
		date = new Date(new Date(2000,01,01).getTime()+(parseFloat(sec)*1000));
		var days = date.format('yyyyMMdd');
		return date.format('HH:mm:ss');
	}catch(e){return day;}
}
function showBox(objId,isShow,baseObj,posInfo,width){
	var box = (!!objId && typeof objId=="string") ? E(objId) : objId;
	if(!box) return;
	if(!isShow){
		box.style.display= "none";
		box.style.visibility= "hidden";
	}
	else{
		if(width) box.style.width = width;
		//T : Top , B : Bottom , L : Left , R : Right , S : Start , E : End;
		box.style.display= "";
		if(isNothing(baseObj)){
			if(typeof(baseObj)=='string'){
				box.style.pixelLeft		= baseObj;//x
				box.style.pixelTop		= posInfo;//y
			}
			else{
				var x =
					(posInfo.isIn('TL-S','BL-S')) ? findPosX(baseObj) - 1 :
					(posInfo=='TL-E') ? findPosX(baseObj) - box.offsetWidth :
					(posInfo=='TR-S') ? findPosX(baseObj) + baseObj.offsetWidth :
					(posInfo.isIn('TR-E','BR-E')) ? findPosX(baseObj) + baseObj.offsetWidth - box.offsetWidth + 1 : findPosX(baseObj)-1;
				var y = (posInfo.isIn('TL-S','TL-E','TR-S','TR-E')) ? findPosY(baseObj)-1 : (posInfo.isIn('BL-S','BR-E')) ? findPosY(baseObj)+baseObj.offsetHeight : findPosY(baseObj)-1;
				box.style.pixelLeft		= x;
				box.style.pixelTop		= y;
			}
		}
		box.style.visibility= "visible";
	}
}
document.writeln("<div id=infoBox style=display:none;visibility:hidden></div>");
function showInfoBox(isShow,baseObj,contents,posInfo,plusX,plusY,width){
	if(isShow && !isNothing(contents)){
		plusX = toNN(plusX,0);
		plusY = toNN(plusY,0);
		if(width) infoBox.style.width = width;
		infoBox.style.display		= "";
		infoBox.innerHTML			= contents;
		//T : Top , B : Bottom , L : Left , R : Right , S : Start , E : End;
		var x =
			(posInfo.isIn('TL-S','BL-S')) ? findPosX(baseObj) - 1 :
			(posInfo=='TL-E') ? findPosX(baseObj) - infoBox.offsetWidth :
			(posInfo=='TR-S') ? findPosX(baseObj) + baseObj.offsetWidth :
			(posInfo.isIn('TR-E','BR-E')) ? findPosX(baseObj) + baseObj.offsetWidth - infoBox.offsetWidth + 1 : findPosX(baseObj)-1;
		var y = (posInfo.isIn('TL-S','TL-E','TR-S','TR-E')) ? findPosY(baseObj)-1 : (posInfo.isIn('BL-S','BR-E')) ? findPosY(baseObj)+baseObj.offsetHeight : findPosY(baseObj)-1;
		//alert(posInfo.isIn('BL-S','BR-E')+" : "+findPosY(baseObj)+" : "+baseObj.offsetHeight+" : "+y)
		infoBox.style.pixelLeft		= x + plusX;
		infoBox.style.pixelTop		= y + plusY;
		infoBox.style.display		= "";
		infoBox.style.visibility	= "visible";
	}
	else{
		infoBox.innerHTML		= "";
		infoBox.style.display	= "none";
		infoBox.style.visibility= "hidden";
	}
}
function showInfoBoxByVal(isShow,v){
	//o:object , x:plusX, y:plusY, w:width, c:contents

	v.o = (!!v.o && typeof v.o=="string") ? E(v.o) : v.o;

	if(v.w) infoBox.style.width = v.w;
	if(isShow && !isNothing(v.c)){
		v.x = (!v.x) ? 0 : v.x;
		v.y = (!v.y) ? 0 : v.y;
		var x = (v.o) ? findPosX(v.o,v.x) : v.x;
		var y = (v.o) ? findPosY(v.o,v.y) : v.y;
		infoBox.style.left		= x;
		infoBox.style.top		= y;

		infoBox.innerHTML		= v.c;
		infoBox.style.visibility= "visible";
		infoBox.style.display	= "";
	}
	else if(!isShow) {
		infoBox.innerHTML		= "";
		infoBox.style.visibility= "hidden";
		infoBox.style.display	= "none";
	}
}

document.writeln("<div id=textBox onmouseout='showTextAll()' style=display:none;visibility:hidden></div>");
function showTextAll(obj,contents){
	if(!obj){
		try{
			textBox.innerHTML		= "";
			textBox.style.visibility= "hidden";
			textBox.style.display	= "none";
		}
		catch(e){}
	}
	else if(!isNothing(contents)){
		//alert(obj.parentElement.parentElement.parentElement.className)
		textBox.onclick		 = function(){obj.parentElement.click();}
		textBox.oncontextmenu	= obj.parentElement.oncontextmenu;
		textBox.style.cursor	= obj.parentElement.style.cursor;
		textBox.style.left		= findPosX(obj,-1);
		textBox.style.top		= findPosY(obj,-1);
		textBox.style.height	= parseInt(obj.offsetHeight)+2;
		textBox.style.paddingTop= Math.max(parseInt(obj.offsetHeight-18),0)/2+2;
		//alert(textBox.style.paddingTop)
		textBox.style.paddingLeft= parseFloat(textBox.style.paddingTop);
		textBox.innerHTML		= contents;
		textBox.style.visibility= "visible";
		textBox.style.display	= "";
	}
}
function showTextAllTd(obj,contents){
	if(!obj){
		try{
			textBox.innerHTML		= "";
			textBox.style.visibility= "hidden";
			textBox.style.display	= "none";
		}
		catch(e){}
	}
	else if(!isNothing(contents)){
		//var tableClassName = obj.parentElement.parentElement.parentElement.className;
		//var addH = (tableClassName.indexOf("t21")>-1) ? 1 : (tableClassName.indexOf("t23")>-1) ? 1 : 0;//공통모듈이 아님
		textBox.onclick		 = function(){obj.click();}
		textBox.oncontextmenu	= obj.oncontextmenu;
		textBox.style.cursor	= obj.style.cursor;
		textBox.style.left		= findPosX(obj,0);
		textBox.style.top		= findPosY(obj,-1);
		textBox.style.height	= parseInt(obj.offsetHeight)+1;
		textBox.style.paddingTop= Math.max(parseInt(obj.offsetHeight-19),0)/2+2;
		textBox.style.paddingLeft= textBox.style.paddingTop;
		textBox.innerHTML		= contents;
		textBox.style.visibility= "visible";
		textBox.style.display	= "";
	}
}

document.writeln("<div id=copyBox onmouseover='comm.isCopyBoxOver=true' onmouseout='comm.isCopyBoxOver=false' style=display:none;visibility:hidden></div>");
comm.isCopyBoxOver	= false;
comm.reserveCopyStr	= "";
function showCopyBox(isShow){
	if(!isShow || isShow=='x'){
		if(isShow=='x') comm.isCopyBoxOver = false;
		if(comm.isCopyBoxOver) return;
		try{
			copyBox.innerHTML		= "";
			copyBox.style.visibility= "hidden";
			copyBox.style.display	= "none";
		}
		catch(e){}
	}
	else{
		var obj = event.srcElement;

		var objType = obj.tagName.toLowerCase()+'/'+toNN(obj.type).toLowerCase();
		copyBox.innerHTML = "";
		if(document.selection.createRange().text!=""){
			comm.reserveCopyStr = document.selection.createRange().text;
			copyBox.innerHTML = "<div><a href=\"javascript:copyString(comm.reserveCopyStr);showCopyBox('x');\" class=copyBox>복사</a></div>";
		}

		if(objType.isIn('input/text','textarea/textarea') && !obj.readOnly && !obj.disabled){
			if(window.clipboardData.getData('Text')!=""){
				copyBox.innerHTML += "<div><a href=\"javascript:showCopyBox('x');\" class=copyBox id=lnkPaste>맨뒤에 붙여넣기</a></div>";
				lnkPaste.onclick = function(){pasteClipboardTo(obj);}
			}

		}
		//copyBox.innerHTML +="<div onclick=document.location.reload()>새로고침</div>";

		if(copyBox.innerHTML!=""){
			copyBox.style.display	= "";
			copyBox.style.left		= window.event.clientX;//-(copyBox.scrollWidth/2)
			copyBox.style.top		= window.event.clientY - (copyBox.scrollHeight/2);
			copyBox.style.visibility= "visible";
			copyBox.style.display	= "";
			//copyBox.focus();
		}
		else{
			showCopyBox(false);
		}
	}
}
//S : 복사 및 붙여넣기 ---------------------------------------------
function selectTextCopy(){
	//alert(document.selection.createRange().text);
	document.selection.createRange().execCommand("copy");
}
function bodyTextCopy(){
	//alert(document.body.createTextRange().text);
	document.body.createTextRange().execCommand("copy");
}
function copyString(val){
	window.clipboardData.setData('Text',val);
}
function pasteClipboardTo(obj){
	obj.value += window.clipboardData.getData('Text');
}
//E : 복사 및 붙여넣기 ---------------------------------------------

function getElementValuesToArray(obj,isChecked){
	var aVal = new Array();
	var idx = 0;
	var isSet = false;
	if(obj.length){
		for(var i=0;i<obj.length;i++){
			isSet = (isChecked==undefined) ? true : (isChecked) ? obj[i].checked : !obj[i].checked;
			if(isSet) aVal[idx++] = obj[i].value;
		}
	}
	else{
		isSet = (isChecked==undefined) ? true : (isChecked) ? obj.checked : !obj.checked;
		if(isSet) aVal[0] = obj.value;
	}
	return aVal;
}
function setYearObj(obj,fromYear,toYear,endStr){
	endStr = toNN(endStr);
	var i=0;
	for(;fromYear<=toYear-i;i++){
		obj.options[i] = new Option((toYear-i)+endStr,toYear-i);
	}
	obj.length = i;
}
function writeYear(fromYear,toYear,endStr){
	endStr = toNN(endStr);
	for(var i=0;fromYear<=toYear-i;i++){
		document.writeln('<option value='+(toYear-i)+'>'+(toYear-i)+endStr+'</option>');
	}
}
function sum(){
	for (var rSum = 0, i = 0, len = arguments.length; i < len; i++){
		rSum += arguments[i];
	}
	return rSum;

}
function getTax(money){
	return 0; //현재 세금 계산 안하는 것으로 함
	money = (money=='') ? 0 : parseInt(out_comma(money));
	var incTax   = parseInt(money * 0.03 / 10) * 10;	//소득세
	var resTax   = parseInt(incTax * 0.1 / 10) * 10;	//주민세
	return (incTax + resTax);
}
//object의 내용을 복사해서 넘겨준다.(구조까지 모두 복사 ??? - 예:filter)
function clone(obj){
	if(obj==null || typeof(obj) != 'object') return obj;
	var cObj = obj.constructor();// changed
	for(var key in obj){
		if(obj.hasOwnProperty(key)){
			cObj[key] = clone(obj[key]);
		}
	}
	return cObj;
}
//값만 복사
function cloneObj(obj){
	var o = new Object();
	for(var key in obj){
		o[key] = (typeof(obj[key])=="object" && obj[key] != null) ?  cloneObj(obj[key]) : obj[key];
	}
	return o;
}

function objToStr(o) {
	if (isNothing(o)) return o;

	var parse = function(_o) {
		var a = [], t;
		for (var p in _o) {
			t = _o[p];
			a[a.length] =
				(t && typeof(t)=="object") ? (t.join==undefined) ? p + ":{" + arguments.callee(t).join(",") + "}" : "[" + arguments.callee(t).join(",") + "]" : //Array
				(typeof(t)=="string") ? [ p + ":\"" + t.toString().replace(/\"/g,"\\\"") + "\"" ] : [ p + ":" + t];
		}
		return a;
	};
	try{return(JSON.stringify(o));}
	catch(e){return (typeof(o)=="object") ? (o.join) ? "[" + parse(o).join(",") + "]" : "{" + parse(o).join(",") + "}" : o;}
}

function objToStr2(o){
	if (isNothing(o)) return o;
	try{
		return(JSON.stringify(o));
	}
	catch(e){
		var string = [];
		if(typeof(o)=="object"){
			if(o.join==undefined){
				string.push("{");
				var cnt = 0;
				for (prop in o){
					string.push(((++cnt==1) ? "" : ","), prop, ":", objToStr2(o[prop]));
				}
				string.push("}");
			}
			else{//Array
				string.push("[")
				var cnt = 0;
				for(prop in o){
					string.push(((++cnt==1) ? "" : ","), objToStr2(o[prop]));
				}
				string.push("]")
			}
		}
		else if(typeof(o)=="string"){
			string.push("\""+o.replace(/\"/g,"\\\"")+"\"");
		}
		else if(typeof(o)=="function"){
			string.push(o.toString())
		}
		else {
			string.push(o)
		}
		return string.join("");
	}
}
function strToObj(str){
	try{
		eval("var x = "+ str +";");
		return x;
	}
	catch(e){return str;}
}

//스트링 아스크코드 반환
function asc(str){
	return str.charCodeAt(0);
}
//아스키코드를 케릭터로
function chr(ascii){
	return String.fromCharCode(ascii);
}
function displayElements(name,disp){
	for(var i=0;i<Es(name).length;i++){
		Es(name)[i].style.display = disp;
	}
}
function toggleDisplay(obj){
	obj.style.display = (obj.style.display=='none') ? '' : 'none';
}
//object의 보다 정확한 타입을 얻을 때 사용.
function getType(obj){
	var objectName = Object.prototype.toString.call(obj);
	var match = /\[object (\w+)\]/.exec(objectName);
	return match[1].toLowerCase();
}
function getSortArrayArgOnlyOne(property){
	var sortOrder = 1;
	if(property.toString().substr(0,1)=="-"){ //if(property[0]=="-"){
		sortOrder = -1;
		property = property.substr(1);
	}
	return function (a,b){
		var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
		return result * sortOrder;
	}
}
function getSortArrayArg(){
	var props = arguments;
	return function (obj1, obj2){
		var i = 0, result = 0, numberOfProperties = props.length;
		while(result==0 && i < numberOfProperties){
			result = getSortArrayArgOnlyOne(props[i])(obj1, obj2);
			i++;
		}
		return result;
	}
}
function findArrayIdx(src, pos, val){
	for (var idx in src){if(src[idx][pos]==val) return idx;}
	return -1;
}
function findArrayUpdateIdx(src, pos, val){
	var idx = findArrayIdx(src, pos, val);
	return (idx!=-1) ? idx : src.length;
}
//검색된 Array 전체를 리턴함 ( by Reference로 동작을 안하는거 같음 : 샘플로 만들면 동작함)
function findArray(source, key, value, type){
	return source.filter(function(obj){
		return (!type || type=="=") ? (obj[key]==value) : (type=="x") ? (obj[key] != value) : (type=="l") ? (obj[key].indexOf(value)==0) : (type=="r") ? (obj[key].indexOf(value)==obj[key].length-value.length) : (type=="i") ? (obj[key].indexOf(value)>-1) : false;
	});
}
function toEncDec(iStr,iKey){
	//return iStr;
	var sLen = iStr.length;
	var kLen = iKey.length;
	var txt = "";
	for(var i=0;i<sLen;i++) txt += String.fromCharCode(iStr.charCodeAt(i) ^ iKey.charCodeAt(i%kLen));//아스키코드를 케릭터로
	return txt;
}
function toEncDec2(iStr,iKey){
	var len = iStr.length;
	var key = fillRight("",iKey,len);
	var txt = "";
	for(var i=0;i<len;i++){
		txt += String.fromCharCode(iStr.charCodeAt(i) ^ key.charCodeAt(i));//아스키코드를 케릭터로
	}
	return txt;
}

//setTimeout('searchAddress("'+cvtToScriptValue(obj.value)+'")',100);
function cvtToScriptValue(baseStr){
	if(baseStr==null) return "";
	baseStr = baseStr.replace(/\\/g,"\\\\");
	baseStr = baseStr.replace(/\"/g,"\\\"");
	baseStr = baseStr.replace(/\'/g,"\\'");
	baseStr = baseStr.replace(/\r\n/g,"\\n");
	baseStr = baseStr.replace(/\n/g,"\\n");
	return baseStr;
}

// 스크립트 ",' 안에서 argument 전달 될때, 그 속에 ",' 가 있는 경우
//예 : document.writeln("<div onclick=\"alert('"+cvtToScriptFuncArgValue(aa.a)+"')\">클릭</div>");
function cvtToScriptFuncArgValue(baseStr){
	if (baseStr==null) return "";
	baseStr = baseStr.replace(/\\/g,"\\\\");//	baseStr = baseStr.replace(/\\/g,"&#92;&#92;");
	baseStr = baseStr.replace(/\"/g,"&#92;&#34;");
	baseStr = baseStr.replace(/\'/g,"&#92;&#39;");
	baseStr = baseStr.replace(/\r\n/g,"\\n");
	baseStr = baseStr.replace(/\r/g,"\\n");
	baseStr = baseStr.replace(/\n/g,"\\n");
	return baseStr;
}
function goURL(url){
	document.location = url;
}
//쿠키값 저장
function setCookie(name, value, saveDay){
	var expDay = new Date();
	expDay.setDate( expDay.getDate() + saveDay );
	delCookie(name);
	document.cookie = name+"="+escape(value)+"; path=/; expires=" + expDay.toGMTString() + ";"
}
//쿠키값 획득
function getCookie(name) {
	var allcookies = document.cookie;
	var cookies = allcookies.split("; ");
	for (var i=0; i < cookies.length; i++) {
		var keyValue = cookies[i].split("=");
		if (keyValue[0]==name) {
			return unescape(keyValue[1]);
		}
	}
	return "";
}
//쿠키값 삭제
function delCookie(name) {
	var expDay = new Date();
	expDay.setDate(expDay.getDate()-1); //하루 전으로 날짜 변경
	document.cookie = name + "=; path=/; expires=" + expDay.toGMTString();
}

//URL 파일이름 가져오기
function getFileName(){
	try{
		var url = document.location.toString();
		url =(url.indexOf("?")==-1) ? url : url.substring(0,url.indexOf("?"));
		return url.substring(url.lastIndexOf("/")+1);
	}catch(e){
		return "";
	}
}
function getFolderName(seq){
	try{
		var tmpStr = document.location.toString().replace(/http:\/\//g,"").split("/");
		if( seq>tmpStr.length-2 || (-1)*(tmpStr.length-2)>seq ) return '';
		return (seq>=0) ? tmpStr[seq] : tmpStr[tmpStr.length+seq-1];
	}
	catch(e){return "";}
}

//맨상단으로 이동
function goPageTop(){
	window.scrollTo(0,0);
}

function addOnloadEvent(fe){
	if (window.addEventListener){
		 window.addEventListener("load", fe, false)
	}
	else{
		window.attachEvent("onload", fe)
	}
}

function E(id){
	return (document.getElementById(id)) ? document.getElementById(id) : document.getElementsByName(id)[0];
}
function Es(name){
	return document.getElementsByName(name);
}
function eventReturnValue(isReturn){
	if(!isReturn) if(event.preventDefault){event.preventDefault();}else{event.returnValue = false;}
}

//반올림 함수 (digits:표시할 소숫자리)
function round(n, digits) {
	n = parseFloat(n);
	digits = (digits==undefined) ? 0 : parseFloat(digits);
	
	if (digits >= 0) return parseFloat(n.toFixed(digits)); // 소수부 반올림
	digits = Math.pow(10, digits); // 정수부 반올림
	var t = Math.round(n * digits) / digits;
	return parseFloat(t.toFixed(0));
}
function alertErrMsg(title,e){
	alert(
		nvl2(title,title+' ☞\n\n','')+
		'name : '+e.name+'\n'+
		'number : '+e.number+'\n'+
		//'description : '+e.description+'\n'+
		'message : '+e.message+'\n'
	);
}

comm.AjaxScriptId = "AjaxScriptId";
function gotoAjax(url){
	//호출을 receiveF에서 하니 appendChild 시 화면이 움직여서 ifAjax.gotoAjax 이런식으로 호출 했음
	var hl = document.getElementsByTagName("head").item(0);
	//alert(hl.innerHTML)

	if(document.getElementById(comm.AjaxScriptId)) hl.removeChild(document.getElementById(comm.AjaxScriptId));
	var now = new Date()
	var noCacheIE = "&noCacheIE="+ now.getTime();
	var scriptObj = document.createElement("script");
	scriptObj.setAttribute("type", "text/javascript");
	scriptObj.setAttribute("src", url + noCacheIE);
	scriptObj.setAttribute("id", comm.AjaxScriptId);
	hl.style.display="none";
	hl.appendChild(scriptObj);
}
function gotoAjaxJson(aUrl, callback){
	$.ajax({
		type: "get",
		url: aUrl,
		contentType: "application/json;charset=euc-kr",
		dataType: "json",
		error: function(xhr, status, error) {
			alert("Ajax Error!!\nstatus : "+status+"\nerror : "+objToStr(error));
		},
		success: function(jData){
			eval(callback+"(jData)");
		}
	});
}
function gotoAjaxXml(aUrl, callback){
	$.ajax({
		type: "get",
		url: aUrl,
		contentType: "text/xml;charset=euc-kr",
		dataType: "xml",
		error: function(xhr, status, error) {
			alert("AjaxXml Error!!\nstatus : "+status+"\nerror : "+objToStr(error));
		},
		success: function(xml){
			eval(callback+"(xml)");
		}
	});
}

Date.prototype.format = function(f){
	if(!this.valueOf()) return " ";
	var weekName = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
	var d = this;

	return f.replace(/(yyyy|yy|MM|dd|E|HH|H|hh|h|mm|m|ss|s|a\/p)/gi, function($1){
		switch ($1){
			case "yyyy": return d.getFullYear();
			case "yy": return (d.getFullYear() % 1000).zf(2);
			case "MM": return (d.getMonth() + 1).zf(2);
			case "dd": return d.getDate().zf(2);
			case "E" : return weekName[d.getDay()];
			case "HH": return d.getHours().zf(2);
			case "H" : return d.getHours().zf(1);
			case "hh": return ((h = d.getHours() % 12) ? h : 12).zf(2);
			case "h" : return ((h = d.getHours() % 12) ? h : 12).zf(1);
			case "mm": return d.getMinutes().zf(2);
			case "m" : return d.getMinutes().zf(1);
			case "ss": return d.getSeconds().zf(2);
			case "s" : return d.getSeconds().zf(1);
			case "a/p": return d.getHours() < 12 ? "오전" : "오후";
			default: return $1;
		}
	});
};
String.prototype.string = function(len){var s = '', i = 0; while (i++ < len){ s += this; } return s;};
String.prototype.zf = function(len){return "0".string(len - this.length) + this;};
Number.prototype.zf = function(len){return this.toString().zf(len);};

Number.prototype.isIn = function(inStrs){
	for (var i=0; i<arguments.length; i++){
		if(!(arguments[i] instanceof Array)){
			if(this==arguments[i]) return true;
		}
		else{
			for (var key in arguments[i]){
				if(this==arguments[i][key]) return true;
			}
			return false;
		}
	}
	return false;
}
String.prototype.isIn = function(inStrs){
	for (var i=0; i<arguments.length; i++){
		if(!(arguments[i] instanceof Array)){
			if(this==arguments[i]) return true;
		}
		else{
			for (var key in arguments[i]){
				if(this==arguments[i][key]) return true;
			}
			return false;
		}
	}
	return false;
}

/*
//하위 브라우저에서는 아래 기본이 아닌듯
if(!Array.prototype.filter){
	Array.prototype.filter = function (fn, context){
		var i,value,result = [],length;

		if(!this || typeof fn !== 'function' || (fn instanceof RegExp)){
			throw new TypeError();
		}

		length = this.length;

		for (i = 0; i < length; i++){
			if(this.hasOwnProperty(i)){
				value = this[i];
				if(fn.call(context, value, i, this)){
					result.push(value);
				}
			}
		}
		return result;
	};
}
*/

/*
Array.prototype.isIn = function(inStrs){
	for (var i=0; i<this.length; i++){
		for (var j=0; j<arguments.length; j++){
			if(!(arguments[j] instanceof Array)){
				if(this[i]==arguments[j]) return true;
			}
			else{
				for (var key in arguments[j]){
					if(this[i]==arguments[j][key]) return true;
				}
				return false;
			}
		}
	}
	return false;
}
*/

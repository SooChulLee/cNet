/* ------------------------------------------------------ */
// 개 발  업 체 : Initech Co., Ltd.
// 개   발   자 : Seon Jong, Kim.
// 최초작성일자 : 2006. 10. 04
// 최종변경일자 : 2007. 10. 04
// 최종변경일자 : 2009. 03. 16 - IE8용 모듈 별도 배포
/* ------------------------------------------------------ */

//INISAFE Web 7.0 Client 설치 관련 환경 설정------------------------------------------------------------------
var InstallVersion = "7,0,0,32";		//INISAFE Web Client 7.0 Installer 버전
var IE8InstallVersion = "7,0,0,35";		//INISAFE Web Client 7.0 Installer 버전
var RebootURL = location.href;		//최초 설치되는 PC는 IE가 재부팅 됨, 이때 이동할 페이지
var RebootMode = 1;					//IE가 재부팅 될때 현재 진행중인 창만 닫을 경우 0, 진행중인 창과 동일한 프로세스까지 모두 닫을 경우 1
var NoReboot = 0;				// 설치후 브라우저 리부트 사용 : 0, 리부트 사용안함 : 1

//멀티 핸드쉐이킹이 제대로 이루어지고 있는지 호스트 별로 모니터링 함
//설치 페이지 내에 상태를 기록할 객체가 있어야 함 예 : <div id="mshStatus"></div>
var shttpMultiServerStatusCheck = true;

//동시에 헨드쉐이킹(SSO)을 수행할 리스트(현재 접속한 서버는 안넣어도 됨)
var shttpMultiServerList = new Array(
	);

//클라이언트를 다운로드 받을 수 있는 주소들("http://" 를 제외한 주소를 쓰세요.)
var DownloadURLs = new Array(
					location.host + "/shttp/install"
	);

//다운로드 인덱스 생성(렌덤) 및 결정
var DownloadIndex = parseInt(Math.random() * DownloadURLs.length);
var DownloadRoot = DownloadURLs[DownloadIndex];

//DLL 및 Plugin 다운로드 URL
var VcsURL = "http://" + DownloadRoot + "/dll/INIS70.vcs";		//INIS70.vcs 다운로드 URL
var CharsetURL = "http://" + DownloadRoot + "/dll/Charset.vcs";	//Charset 과 관련된 URL
var DllURL = "http://" + DownloadRoot + "/dll/";				//DLL 파일을 다운로드 받는 URL
var ExeURL = "http://" + DownloadRoot + "/down/INIS70.exe"		//수동 설치파일 다운로드 받는 URL

//IE8 용 DLL 및 Plugin 다운로드 URL
var IE8VcsURL = "http://" + DownloadRoot + "/dll_ie8/INIS70.vcs";		//INIS70.vcs 다운로드 URL
var IE8CharsetURL = "http://" + DownloadRoot + "/dll_ie8/Charset.vcs";	//Charset 과 관련된 URL
var IE8DllURL = "http://" + DownloadRoot + "/dll_ie8/";				//DLL 파일을 다운로드 받는 URL
var IE8ExeURL = "http://" + DownloadRoot + "/down_ie8/INIS70.exe"		//수동 설치파일 다운로드 받는 URL

//브라우저 환경 체크
var appEnvCheck = 1;		//0 : 체크 안함, 1 : 체크 함
var IEVersion = "5.5"		//접속 가능한 IE 버전(체크 안할시 빈문자열 또는 주석 설정)
var XMLHTTPVersion = "3"	//접속 가능한 XMLHTTP 버전(체크 안할시 빈문자열로 또는 주석 설정)

// SOE VISTA 여부 체크
var isSoeVista = false;
checkSoeVista();


//디버깅
//document.write("클라이언트 모듈 다운로드 경로 : http://" + DownloadRoot);
//------------------------------------------------------------------------------------------------------------

//클라이언트 모듈 설치 오류시 사용자에게 알려줌
function install_error(){
	var errorMsg = "사용자 요청 또는 오류에 의해 암호화 모듈이 설치(또는 업데이트)되지 않았습니다.\r\n\r\n -. 본 사이트는 암호화 모듈이 설치되어야만 이용하실 수 있습니다.\r\n -. 고객님의 정보 보호를 위해 암호화 모듈을 설치해 주시기 바랍니다.\r\n -. 암호화 모듈 설치가 안될 경우 설치화면에 안내를 참조하시기 바랍니다.\r\n -. 윈도우즈 XP 서비스 팩2 사용자는 상단에 설치 탭을 클릭하십시오.\r\n -. 권한이 제한된 사용자의 경우 반드시 관리자(Administrator) 계정으로 설치하시기 바랍니다.";

	try{
		if(typeof(InstallFail)=='function'){
			InstallFail(errorMsg);
			return;
		}
	}
	catch(e){}

	document.body.onload = "";
	alert(errorMsg);
}

//플래쉬를 뿌려주는 함수
function swf(src,w,h){
	html = '';
	html += '<object type="application/x-shockwave-flash" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0" id="param" width="'+w+'" height="'+h+'">';
	html += '<param name="movie" value="'+src+'">';
	html += '<param name="wmode" value="transparent">';
	html += '<param name="quality" value="high">';
	html += '<param name="bgcolor" value="#ffffff">';
	html += '<param name="swliveconnect" value="true">';
	html += '<embed src="'+src+'" quality=high bgcolor="#ffffff" width="'+w+'" height="'+h+'" swliveconnect="true" id="param" name="param" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer"><\/embed>';
	html += '<\/object>';
	document.write(html);
}

//클라이언트 Installer ActiveX 를 설치하는 페이지
function client_install(){
	if(isSoeVista) { // SOE Vista인 경우 cab 버전 32로 간다.
		document.write("<OBJECT ID='INISAFELoader' CLASSID='CLSID:39461460-2552-4D51-A062-3AB6A7B902E9' width=0 height=0 CodeBase='http://" + DownloadRoot + "/down/INIS70.cab#version=" + InstallVersion + "' OnError='install_error();' OnErrorUpdate='install_error();' style='position:absolute;top:0;left:0'><PARAM name='RebootURL' value='"+RebootURL+"'></PARAM><PARAM name='RebootMode' value='"+RebootMode+"'></PARAM><PARAM name='NoReboot' value='"+NoReboot+"'></PARAM></OBJECT>");
	}
	else { // 나머지는 모두 35버전
		document.write("<OBJECT ID='INISAFELoader' CLASSID='CLSID:39461460-2552-4D51-A062-3AB6A7B902E9' width=0 height=0 CodeBase='http://" + DownloadRoot + "/down_ie8/INIS70.cab#version=" + IE8InstallVersion + "' OnError='install_error();' OnErrorUpdate='install_error();' style='position:absolute;top:0;left:0'><PARAM name='RebootURL' value='"+RebootURL+"'></PARAM><PARAM name='RebootMode' value='"+RebootMode+"'></PARAM><PARAM name='NoReboot' value='"+NoReboot+"'></PARAM></OBJECT>");
	}
}

//수동 설치 프로그램 다운로드
function download_setup(){
	if(isSoeVista) {
		location.href = ExeURL;
	}
	else {
		location.href = IE8ExeURL;
	}
	return false;
}

//INISAFE Web v7 Client 를 사용가능한 환경인지 체크함
function isPossibleApp(){
	if(appEnvCheck==0)
		return true;

	var userAgent = window.clientInformation.userAgent;
	var spos = userAgent.indexOf("MSIE");

	//브라우저 검사
	if(spos<0){
		alert("본 사이트는 Microsoft Internet Explorer 계열만 사용 가능합니다.\r\n\r\n현재 사용중인 브라우저 정보 : " + userAgent);
		return false;
	}
	else{
		if(typeof(IEVersion)!="undefined" && IEVersion!=""){
			spos += 5;
			var epos = userAgent.indexOf(";", spos);
			var ver = userAgent.substring(spos, epos);

			if(ver < IEVersion){
				alert("본 사이트는 Microsoft Internet Explorer " + IEVersion + " 이상만 사용 가능합니다.\r\n현재 창을 닫고 윈도우 업데이트 사이트(update.microsoft.com)를 통해 IE 최신 버전을 설치하시기 바랍니다.");
				return false;
			}
		}
	}

	//64비트 운영체제로 접근하는지 체크함
	if(userAgent.indexOf("Win64")>=0){
		alert("본 사이트는 64 Bit 모드로는 사용하실 수 없습니다. 32 Bit 호환 모드로 접속하세요.");
		return false;
	}

	//XMLHTTP 설치 여부 검사
	if(typeof(XMLHTTPVersion)!="undefined" && XMLHTTPVersion!=""){
		try{
			var xml = new ActiveXObject("Msxml2.XMLHTTP." + XMLHTTPVersion + ".0");
		}
		catch(e){
			if(confirm("본 사이트는 Web 2.0 서비스를 위해 Microsoft XMLHTTP " + XMLHTTPVersion + ".0 이상을 필요로 합니다.\r\nMicrosoft XMLHTTP " + XMLHTTPVersion + ".0 설치 프로그램을 다운로드 받으시겠습니까?")){
				alert("설치 후 현재 창을 닫고 새로 접속하시기 바랍니다.");
				location.href="http://" + DownloadRoot + "/down/msxml" + XMLHTTPVersion + ".msi";
				return false;
			}

			return false;
		}
	}

	return true;
}

function checkSoeVista()
{
    // 2009/03/26 IP대역에 따른 보안모듈 다운로드
    var clientIP = '';
    var today = '';

    try {
        var cookieValue = "";
        var cookieName = "secip=";
        var allcookies = document.cookie;
        var pos = allcookies.indexOf(cookieName);
        if(pos != -1) {
            var start = pos + cookieName.length;
            var end = allcookies.indexOf(";", start);
            if(end == -1) end = allcookies.length;
            cookieValue = allcookies.substring(start, end);
            cookieValue = decodeURIComponent(cookieValue);
            var values = cookieValue.split("|");
            clientIP = values[0];
            today = values[1];
        }
    }catch(e) {
    }

    var aSOEProxyIP = new Array(
          "192.193.81.41"
        , "192.193.81.42"
        , "192.193.81.70"
        , "192.193.81.71"
        , "192.193.83.41"
        , "192.193.83.42"
        , "192.193.83.70"
        , "192.193.83.71"
    );

    for(var i=0; i<aSOEProxyIP.length; i++) {
        if(aSOEProxyIP[i] == clientIP) {
            if(window.navigator.appVersion.indexOf("NT 6") > 0) {
                isSoeVista = true;
            }
        }
    }

}

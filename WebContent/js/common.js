String.prototype.trim =	function() {
	return this.replace(/(^\s*)|(\s*$)/g, "");
};

// checked form	value 추출
var getCheckedValue = function(obj) {
	var val	= "";
	obj.each(function() {
		if($(this).prop("checked")) {
			val	+= ","+$(this).val();
		}
	});

	return val.substring(1);
};

// form	serializeArray() 데이터를 json data로 변환
var arrToJson =	function(form){
	var json = {};
	$.each(form, function(idx, ele){
		json[ele.name] = ele.value;
	});

	return json;
};

// json	value count
var getJsonValCnt =	function(data) {
	var cnt	= 0;
	$.each(data, function(key, val){
		if(val!="")	cnt++;
	});
	return cnt;
};

// 8자리 숫자 -> yyyy.mm.dd
var getDateToNum = function(str, delimeter) {
	if(str.length!=8) {
		return str;
	}
	return str.substr(0,4) + delimeter + str.substr(4,2) + delimeter + str.substr(6,2);
}

// 초 ->	HH:mm:ss
var getHmsToSec = function(sec) {
	var h =	Math.floor(sec/3600);
	var m =	Math.floor(sec%3600/60);
	var s =	Math.floor(sec%60);

	return ((h<10) ? "0"+h : h)	+ ":" +	((m<10)	? "0"+m	: m) + ":" + ((s<10) ? "0"+s : s);
};

//초	-> mm:ss
var getMsToSec = function(sec) {
	var m =	Math.floor(sec/60);
	var s =	Math.floor(sec%60);

	return ((m<10) ? "0"+m : m)	+ ":" +	((s<10)	? "0"+s	: s);
};

// 시분초 유효성 체크
var isValidHms = function(str) {
	var arr	= str.split(":");

	if(arr.length!=3) return false;

	var h =	parseInt(arr[0]);
	var m =	parseInt(arr[1]);
	var s =	parseInt(arr[2]);

	return (h>=0 &&	h<=24) && (m>=0	&& m<60) &&	(s>=0 && s<60);
};

// 문자열이	cipher 자릿수만큼 연속된 문자열인지 여부 확인
var checkStraightStr = function(str, cipher) {
	str	= str.toLowerCase();

	// 문자열 길이 -	연속되는 자릿수 + 1 만큼만 loop --> 비교할 대상이 있는 만큼만 loop
	for(var i=0;i<(str.length-cipher+1);i++) {
		var cnt	= 0;
		var o =	"";
		// 현재 문자의 achii	값과 이전 achii	값을 뺀 값이	1이면	연속되는 문자열
		for(var j=0;j<cipher;j++) {
			var ac = str.substr(i+j, 1).charCodeAt(0);

			if(j>0 && ac-o==1) {
				cnt=cnt+1;
			}
			o =	ac;
		}

		// 연속되는	문자열이 cipher-1만큼	있다면	비교 기준 문자에서 지정한 자릿수만큼 연속되는 문자열로 판명
		if(cnt-cipher+1==0) {
			return true;
			break;
		}
	}
	return false;
};

// 문자열 역순 정렬
var getReverseStr =	function(str)
{
	var reverse_str	= "";
	for(var i =	str.length;	0<=i; i--) {
		reverse_str	= reverse_str +	str.charAt(i);
	}
	return reverse_str;
};

// 비밀번호	유효성	검사
var checkPasswd = function(id, pass, rtnMsg) {
	// 비밀번호	유효성	검사 추가
	var exp_space =	/[\s]/gi;
	var exp_en = /[a-zA-Z]/gi;
	var exp_num	= /[0-9]/gi;
	var exp_eq = /(\w)\1{2}/gi;
	//var exp_sp = /[\{\}\[\]\/?.,;:|\)*~`!^\-_+<>@\#$%&\\\=\(]/gi;
	var exp_sp = /[\{\}\[\]\/?.,|\)*~`!^\-_+@\#$&\\\(]/gi;
	var exp_no_sp =	/["':;<>%\=]/gi;
	var cb_cnt = 0;
	var msg	= "";

	if(pass.length<10 || pass.length>30	|| exp_space.test(pass)) {
		msg	= "비밀번호를 공백없이 10자리 이상 30자리 이하로 입력해 주십시오.";
	} else if(pass.indexOf(id) > -1) {
		msg	= "비밀번호에 아이디를 사용할 수	없습니다.";
	} else if(exp_no_sp.test(pass)) {
		msg	= "특정 특수문자는	사용하실 수 없습니다. [ \" %	' :	; <	= >	]";
	} else if(exp_eq.test(pass)) {
		msg	= "비밀번호는 동일	문자/숫자를 3회 이상 사용하실 수	없습니다.";
	} else if(checkStraightStr(pass, 3)) {
		msg	= "비밀번호는 연속된 문자/숫자를	3회 이상 사용하실 수 없습니다.";
	} else if(checkStraightStr(getReverseStr(pass),	3)) {
		msg	= "비밀번호는 역순으로 연속된 문자/숫자를 3회	이상 사용하실	수 없습니다.";
	} else {
		if(exp_en.test(pass)) {	cb_cnt++; }
		if(exp_num.test(pass)) { cb_cnt++; }
		if(exp_sp.test(pass)) {	cb_cnt++; }

		if(cb_cnt<2) {
			msg	= "비밀번호를 영문/숫자/특수문자	중 2가지 이상을 조합하여 입력해 주십시오.";
		}
	}

	if(rtnMsg) {
		return msg;
	} else {
		if(msg!="") {
			alert(msg);
			return false;
		} else {
			return true;
		}
	}
};

// open	popup
var openPopup =	function (mypage,myname,w,h,scroll,pos){
	var win=null;
	if(pos=='random'){LeftPosition=(screen.width)?Math.floor(Math.random()*(screen.width-w)):100;TopPosition=(screen.height)?Math.floor(Math.random()*((screen.height-h)-75)):100;}
	if(pos=='center'){LeftPosition=(screen.width)?(screen.width-w)/2:100;TopPosition=(screen.height)?(screen.height-h-100)/2:100;}
	else if((pos!='center' && pos!='random') ||	pos==null){LeftPosition=0;TopPosition=0}

	settings='width='+w+',height='+h+',top='+TopPosition+',left='+LeftPosition+',scrollbars='+scroll+',location=no,directories=no,status=no,menubar=no,toolbar=no,resizable=no';
	win=window.open(mypage,myname,settings);

	if(win==null){ alert("팝업 차단기능을 해제한 후 다시	시도해	주십시오."); }
	if(win.focus){win.focus();}
};

// popup window	auto resize
var popResize =	function (divId) {
	var strWidth;
	var strHeight;

	//innerWidth / innerHeight / outerWidth	/ outerHeight 지원 브라우저
	if (window.innerWidth && window.innerHeight	&& window.outerWidth &&	window.outerHeight) {
		strWidth = $("#"+divId).outerWidth() + (window.outerWidth -	window.innerWidth);
		strHeight =	$("#"+divId).outerHeight() + (window.outerHeight - window.innerHeight);
	} else {
		var strDocumentWidth = $(document).outerWidth();
		var strDocumentHeight =	$(document).outerHeight();

		window.resizeTo(strDocumentWidth, strDocumentHeight);

		var strMenuWidth = strDocumentWidth	- $(window).width();
		var strMenuHeight =	strDocumentHeight -	$(window).height();

		strWidth = $("#"+divId).outerWidth() + strMenuWidth;
		strHeight =	$("#"+divId).outerHeight() + strMenuHeight;
	}

	//resize
	window.resizeTo(strWidth, strHeight);
	window.focus();
}

// bar graph
var barChart = function(chartID, chartNm, chartTick, chartData) {
	$.jqplot(chartID, [chartData], {
		title: chartNm,
		animate: true,
		seriesDefaults: {
			renderer:$.jqplot.BarRenderer,
			rendererOptions: {
				varyBarColor: true,
				barMargin: 10
			},
			pointLabels: {
				show: true
			}
		},
		grid: {
			//background: "#FFFFFF",
			gridLineColor: "#BFBFBF",
			drawBorder:	false
		},
		axes:{
			xaxis:{
				renderer:$.jqplot.CategoryAxisRenderer,
				ticks: chartTick,
				drawMajorGridlines:	true,
				tickOptions:{
					textColor: "#333333",
					showMarker:	false
				}
			},
			yaxis:{
				min: 0,
				drawMajorGridlines:	true,
				tickOptions: {
					formatString: "%'d",
					textColor: "#333333",
					showMarker:	false
				}
			}
		}
	});
};

// 파라미터	암호화
var getEncData = function(str, flag) {
	var enc_data = "";

	$.ajax({
		type: "POST",
		url: "../common/get_enc_data.jsp",
		data: "info="+encodeURIComponent(str)+"&flag="+flag,
		//data:	"info="+str+"&flag="+flag,
		async: false,
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code=="OK") {
				enc_data = dataJSON.data;
			} else {
				enc_data = "";
			}
		},
		error:function(req,status,err){
			enc_data = "";
		}
	});

	return enc_data;
};

//청취 플레이어
var playRecFile = function(rec_datm, local_no, rec_filename, rec_keycode, loc){
	rec_datm = rec_datm.replace(/\s|-|:|\./gi,"");
	var info = getEncData(rec_datm + "|" + local_no + "|" + rec_filename + "|" + rec_keycode, "1");

	if(isExistPlayDownReason){
		openPopup("../rec_search/player_reason.jsp?loc="+toNN(loc)+"&info="+encodeURIComponent(info),"_player","556","260","yes","center");//사유입력
	}
	else{
		openPopup("../rec_search/player.jsp?loc="+toNN(loc)+"&info="+encodeURIComponent(info),"_player","556","376","yes","center");
	}
}
var playRecFileByIdx = function(rowIndx,loc){
	var rowData	= $grid.pqGrid("getRowData", { rowIndxPage:	rowIndx	});
	playRecFile(rowData["rec_datm"],rowData["local_no"],rowData["rec_filename"],rowData["rec_keycode"],loc);
};
var playRecFileByRecSeq = function(rec_seq,loc){
	if(isExistPlayDownReason){
		openPopup("../rec_search/player_reason.jsp?loc="+loc+"&rec_seq="+rec_seq,"_player","556","260","yes","center");//사유입력
	}
	else{
		openPopup("../rec_search/player.jsp?loc="+loc+"&rec_seq="+rec_seq,"_player","556","376","yes","center");
	}
}

//다중청취 플레이어
var playRecFileMulti = function(loc) {
	var selarray = $grid.pqGrid('selection', { type: 'row', method: 'getSelection' });
	var len = selarray.length;
	if(len==0){
		alert("먼저 왼쪽체크박스를 선택 후 다중청취를 클릭하세요!");
		return;
	}

	var info = "";
	for (var i=0; i < len; i++) {
		var rowData = selarray[i].rowData;
		var rec_datm = rowData["rec_datm"].replace(/\s|-|:|\./gi,"");
		//다중 구분자는 탭문자임
		// 녹취일시 | 내선번호 | 녹취파일명 | 녹취 CON ID | 통화시간 | 상담원명
		info += "\t" + getEncData(rec_datm + "|" + rowData["local_no"] + "|" + rowData["rec_filename"] + "|" + rowData["rec_keycode"] + "|" + rowData["rec_call_time"] + "|" + rowData["user_name"], "1");
	}
	info = info.substr(1);

	if(isExistPlayDownReason){
		//openPopup("../rec_search/player_reason.jsp?loc="+loc+"&info="+encodeURIComponent(info),"_player","556","260","yes","center");//사유입력
		openPopup("about:blank","_player","556","260","yes","center");//사유입력
		makeFormAndGo("fPlay","../rec_search/player_reason.jsp","_player",{"loc":toNN(loc), "info":info})
	}
	else{
		//openPopup("../rec_search/player.jsp?loc="+loc+"&info="+encodeURIComponent(info),"_player","556","376","yes","center");
		openPopup("about:blank","_player","556","376","yes","center");
		makeFormAndGo("fPlay","../rec_search/player.jsp","_player",{"loc":toNN(loc), "info":info})
	}
};

//연관콜 청취 플레이어 연결
var playRecFileLink = function(rec_datm, local_no, rec_filename, rec_keycode) {
	rec_datm = rec_datm.replace(/\s|-|:|\./gi,"");
	var info = getEncData(rec_datm + "|" + local_no	+ "|" +	rec_filename + "|" + rec_keycode, "1");
	if(isExistPlayDownReason){
		location.replace("../rec_search/player_reason.jsp?info="+encodeURIComponent(info));
	}
	else{
		location.replace("../rec_search/player.jsp?info="+encodeURIComponent(info));
	}
};

//다운로드
var downloadRecFile = function(rowIndx) {
	var rowData	= $grid.pqGrid("getRowData", { rowIndxPage:	rowIndx	});
	var rec_datm = rowData["rec_datm"].replace(/\s|-|:|\./gi,"");
	//20170908 현원희 수정 : custom_fld_04 추가
	var info = getEncData(rec_datm + "|" + rowData["local_no"] + "|" + rowData["rec_filename"] + "|" + toNN(rowData["custom_fld_04"]), "1");
	if(isExistPlayDownReason){
		openPopup("../rec_search/download_reason.jsp?info="+encodeURIComponent(info),"_download","556","260","yes","center");
	}
	else{
		hiddenFrame.location = "../rec_search/download.jsp?info="+encodeURIComponent(info);
	}
	//$("#hiddenFrame").prop("src",	"download.jsp?rec_datm="+rec_datm+"&local_no="+rowData["local_no"]+"&rec_filename="+rowData["rec_filename"]);
	//openPopup("../rec_search/download_reason.jsp?rec_datm="+rec_datm+"&local_no="+rowData["local_no"]+"&rec_filename="+encodeURIComponent(rowData["rec_filename"]),"_download","556","260","yes","center");
};

var downloadRecFile2 = function(getRowIndx) {

	var info = getEncData(getRowIndx, "1");

	if(isExistPlayDownReason){
		openPopup("../rec_search/download_reason2.jsp?info="+encodeURIComponent(info),"_download","556","260","yes","center");
	}
	else{
		hiddenFrame.location = "../rec_search/download2.jsp?info="+encodeURIComponent(info);
	}

};

//공통코드 조회 후	select box setting
var getCommCodeToForm =	function(parent_code, targ_fn_name,	targ_fd_name) {
	if(parent_code=="") {
		return;
	}

	// 청취/다운로드 사유 코드
	$.ajax({
		type: "POST",
		url: "../common/get_common_code_list.jsp",
		data: "parent_code="+parent_code+"&code_depth=2",
		async: false,
		dataType: "json",
		success:function(dataJSON){
			var obj	= $("#"	+ targ_fn_name + " select[name=" + targ_fd_name	+ "]");

			obj.html("<option value=''>선택</option>");

			if(dataJSON.code!="ERR") {
				if(dataJSON.data.length>0) {
					var html = "";
					for(var i=0;i<dataJSON.data.length;i++) {
						html +=	"<option value='" +	dataJSON.data[i].comm_code + "'>" +	dataJSON.data[i].code_name + "</option>";
					}
					obj.append(html);
				} else {
					alert("코드 데이터가 없습니다.");
					return false;
				}
			} else {
				alert(dataJSON.msg);
				return false;
			}
		},
		error:function(req,status,err){
			alert("에러가 발생하였습니다.	[" + req.responseText +	"]");
			return false;
		}
	});
};

/* grid	function start */
// grid	전역변수
var $grid;

//기본 데이터 모델	속성 리턴
var getBaseGridDM =	function(page_id) {
	var dataModel = {
		location: "remote",
		sorting: "remote",
		//sortDir: "down",
		dataType: "JSON",
		method:	"POST",
		curPage: "1",
		getUrl: function(ui){
			var data = arrToJson($("#search").serializeArray());
			data.cur_page =	ui.pageModel.curPage;
			data.top_cnt = ui.pageModel.rPP;
			data.sort_idx =	toNN(ui.dataModel.sortIndx);
			data.sort_dir =	toNN(ui.dataModel.sortDir,"up");

			return { url: "remote_"+page_id+".jsp",	data: data }
		},
		getData: function (dataJSON, textStatus, jqXHR) {
			if(dataJSON.code=="ERR") {
				alert(dataJSON.msg);
				return false;
			} else {
				//alert(objToStr(dataJSON))
				var $tit = $(this).find(".pq-toolbar input[name=toolbar_title]");
				$tit.val("전체: "	+ dataJSON.totalRecords);

				return { totalPages: dataJSON.totalPages, curPage: dataJSON.curPage, totalRecords: dataJSON.totalRecords, data:	dataJSON.data };
			}
		}
	};

	return dataModel;
};

//기본 grid option 리턴	(페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부,	신규등록 사용여부, 수정 사용여부)
var getBaseGridOption =	function(page_id, paging_yn, excel_yn, new_yn, edit_yn) {
	var gridOpt	= {
		width: "100%",
		flexHeight:	true,
		scrollModel: { autoFit:	false },
		numberCell: { show:	false },
		editable: false,
		collapsible: false,
		wrap: false,
		showTitle: false,
		toolbar	: {	items: [
						// 전체 건수 표시
						{ type:	"textbox", attr: "name='toolbar_title'"	}
				  ]},
	};

	// 페이징 사용여부
	if(paging_yn=="Y") {
		gridOpt.pageModel = { type:	"remote", rPP: 20, strRpp: "{0}", strDisplay:"{0} to {1} of {2}" };
	}

	// 엑셀다운로드 사용여부
	if(excel_yn=="Y") {
		gridOpt.toolbar.items.push(
			// 엑셀다운로드 버튼 추가
			{ type:	"button", icon:	"ui-icon-excel", label:	"엑셀", style: 'float: right;	margin-right: 5px;', listeners:	[{
					"click": function () {
						var cur_page = $grid.pqGrid("option","pageModel.curPage");
						var top_cnt	= $grid.pqGrid("option","pageModel.rPP");
						var sort_idx = $grid.pqGrid("option","dataModel.sortIndx");
						var sort_dir = $grid.pqGrid("option","dataModel.sortDir");
						$("#hiddenFrame").prop("src", "excel_" + page_id + ".jsp?"+$("#search").serialize()+"&cur_page="+cur_page+"&top_cnt="+top_cnt+"&sort_idx="+sort_idx+"&sort_dir="+sort_dir);
					}
				}]
			}
		);
	}
	else if(excel_yn=="YY") {
		//페이징이 없는 모든 데이터가 그리드에 존재하는 경우 엑셀은 이 것을 사용한다.(예 : 통계)
		gridOpt.toolbar.items.push(
			// 엑셀다운로드 버튼 추가
			{ type:	"button", icon:	"ui-icon-excel", label:	"엑셀", style: 'float: right;	margin-right: 5px;', listeners:	[{
					"click": function () {
						var data = $grid.pqGrid("option","dataModel.data");
						var args = {"data":objToStr(data)};
						makeFormAndGo("fExcel", "excel_" + page_id + ".jsp", "hiddenFrame", args);
					}
				}]
			}
		);
	}

	if(edit_yn=="Y") {
		gridOpt	= $.extend({}, gridOpt, {
			editable: true,
			track: true,
			hoverMode: "cell",
			editModel: {
				saveKey: $.ui.keyCode.ENTER,
			},
			quitEditMode: function (evt, ui) {
				if (evt.keyCode	!= $.ui.keyCode.ESCAPE) {
					$grid.pqGrid("saveEditCell");
				}
			},
			refresh: function () {
				$("#grid").find(".btn_delete")
				.unbind("click")
				.bind("click", function	(evt) {
					var $tr	= $(this).closest("tr");
					var rowIndx	= $grid.pqGrid("getRowIndx", { $tr:	$tr	}).rowIndx;

					deleteRow(page_id, rowIndx);
				});
			},
			cellBeforeSave:	function (evt, ui) {
				var isValid	= $grid.pqGrid("isValid", ui);
				if (!isValid.valid) {
					evt.preventDefault();
					return false;
				}
			},
		});

		gridOpt.toolbar.items.push(
			{ type:	'button', icon:	'ui-icon-cancel', label: '취소', style: 'float: right; margin-right: 5px;', listeners: [{
					"click": function () {
							$grid.pqGrid("rollback");
						}
				}]
			},
			{ type:	'button', icon:	'ui-icon-disk',	label: '일괄수정', style: 'float: right; margin-right: 5px;', listeners: [{
				"click": function () {
						updateChanges(page_id);
					}
				}]
			}
		);
	}

	// 신규등록	사용여부
	if(new_yn=="Y") {
		gridOpt.toolbar.items.push(
			{ type:	"button", icon:	"ui-icon-document",	label: "신규등록", style:	'float:	right; margin-right: 5px;',	attr: "data-toggle='modal'", listeners:	[{
					"click": function () {
						$("#modalRegiForm form")[0].reset();	// 기존 입력값 reset
						$("#modalRegiForm").modal("toggle");
					}
				}]
			}
		);
	}

	return gridOpt;
};

//일괄수정 버튼 클릭시 실행
var updateChanges =	function(page_id) {
	//attempt to save editing cell.
	if ($grid.pqGrid("saveEditCell") === false) {
		return false;
	}

	var isDirty	= $grid.pqGrid("isDirty");
	if (!isDirty) {
		alert("수정된 내용이 없습니다.");
		return false;
	}

	if (confirm("정말로 수정하시겠습니까?")) {
		var changes	= $grid.pqGrid("getChanges", { format: "byVal" });

		$.ajax({
			type: "POST",
			url: "remote_" + page_id + "_proc.jsp",
			async: false,
			dataType: "json",
			data: { step: "update", data_list: JSON.stringify(changes.updateList) },
			success: function (dataJSON) {
				//alert(objToStr(dataJSON));
				if(dataJSON.code=="OK") {
					if(dataJSON.msg!="") {alert(dataJSON.msg);}
					$grid.pqGrid("commit", { type: "update", rows: changes.updateList });
					$grid.pqGrid("refreshDataAndView");

					// tree가 존재한다면 데이터 수정 후	tree reload
					//if($("#tree").length>0) {
					if(dataJSON.tree!=undefined	&& dataJSON.tree.refresh=="true") {
						$("#tree").jstree(true).refresh();
					}
				} else {
					alert(dataJSON.msg);
					$grid.pqGrid("refreshDataAndView");
					//$grid.pqGrid("rollback");
				}
			},
			error:function(req,status,err){
				alert("에러가 발생하였습니다.\n\nreq : " + req.responseText+"\nerr : "+err+"\nstatus : "+status);
				$grid.pqGrid("rollback");
			},
			beforeSend:	function () {
				$grid.pqGrid("showLoading");
			},
			complete: function () {
				$grid.pqGrid("hideLoading");
			},
		});
	} else {
		$grid.pqGrid("rollback");
	}
};

// delete row
var deleteRow =	function(page_id, rowIndx) {
	$grid.pqGrid("addClass", { rowIndx:	rowIndx, cls: 'pq-row-delete' });

	if (confirm("정말로 삭제하시겠습니까?")) {
		var recIndx	= $grid.pqGrid("getRecId", { rowIndx: rowIndx });
		var rowData	= $grid.pqGrid("getRowData", { rowIndxPage:	rowIndx	});

		$.ajax({
			type: "POST",
			url: "remote_" + page_id + "_proc.jsp",
			async: false,
			dataType: "json",
			data: {	step: "delete",	row_id:	recIndx	},
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					$grid.pqGrid("deleteRow", {	rowIndx: rowIndx, effect: true });
					alert("정상적으로 삭제되었습니다.");
					$grid.pqGrid("commit");
					$grid.pqGrid("refreshDataAndView");

					// tree가 존재한다면 데이터 삭제 후	tree reload
					//if($("#tree").length>0) {
					if(dataJSON.tree!=undefined	&& dataJSON.tree.refresh=="true") {
						$("#tree").jstree(true).refresh();
					}
				} else {
					alert(dataJSON.msg);
					$grid.pqGrid("refreshDataAndView");
					//$grid.pqGrid("removeClass", { rowIndx: rowIndx,	cls: 'pq-row-delete' });
					//$grid.pqGrid("rollback");
				}
			},
			error:function(req,status,err){
				alert("에러가 발생하였습니다.	[" + req.responseText +	"]");
				$grid.pqGrid("removeClass", { rowIndx: rowIndx,	cls: 'pq-row-delete' });
				$grid.pqGrid("rollback");
			},
			/*beforeSend: function () {
				$grid.pqGrid("showLoading");
			},
			complete: function () {
				$grid.pqGrid("hideLoading");
			},*/
		});
	}
	else {
		$grid.pqGrid("removeClass", { rowIndx: rowIndx,	cls: 'pq-row-delete' });
	}
}

//위 평션 에서 recIndx 가 제대로 안구해 지는 현상이 있는 페이지 있음 (예 : 평가결과조회 (eval_result.jsp))
//해당 row의 모든 Data 를 구해서 parameter로 삭제 페이지에 넘긴다.
var deleteRowByData =	function(page_id, rowIndx) {
	$grid.pqGrid("addClass", { rowIndx:	rowIndx, cls: 'pq-row-delete' });

	if (confirm("정말로 삭제하시겠습니까?")) {
		var data	= $grid.pqGrid("getRowData", { rowIndxPage:	rowIndx	});
		data.step	= "delete";

		$.ajax({
			type: "POST",
			url: "remote_" + page_id + "_proc.jsp",
			async: false,
			dataType: "json",
			data: data,
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					$grid.pqGrid("deleteRow", {	rowIndx: rowIndx, effect: true });
					alert("정상적으로 삭제되었습니다.");
					$grid.pqGrid("commit");
					$grid.pqGrid("refreshDataAndView");

					// tree가 존재한다면 데이터 삭제 후	tree reload
					//if($("#tree").length>0) {
					if(dataJSON.tree!=undefined	&& dataJSON.tree.refresh=="true") {
						$("#tree").jstree(true).refresh();
					}
				} else {
					alert(dataJSON.msg);
					$grid.pqGrid("refreshDataAndView");
					//$grid.pqGrid("removeClass", { rowIndx: rowIndx,	cls: 'pq-row-delete' });
					//$grid.pqGrid("rollback");
				}
			},
			error:function(req,status,err){
				alert("에러가 발생하였습니다.	[" + req.responseText +	"]");
				$grid.pqGrid("removeClass", { rowIndx: rowIndx,	cls: 'pq-row-delete' });
				$grid.pqGrid("rollback");
			},
		});
	}
	else {
		$grid.pqGrid("removeClass", { rowIndx: rowIndx,	cls: 'pq-row-delete' });
	}
}
/* grid	function end */

// 조직도 중분류/소분류 조회
var chgPartCode = function(obj) {
	var form_obj = obj.parents("form");
	var field_name = obj.attr("name");
	var perm_check = (form_obj.find("input[name=perm_check]")) ? form_obj.find("input[name=perm_check]").val() : "";
	//var perm_check = ($("#search input[name=perm_check]")) ? $("#search	input[name=perm_check]").val() : "";

	var part_depth		= (field_name=="bpart_code")	? 2 : 3;
	var target_field	= (part_depth==2) ?	"mpart_code" : "spart_code";
	var target_name		= (part_depth==2) ? "중분류" : "소분류";

	var bpart_code		= toNN(form_obj.find("select[name=bpart_code]").val());
	var mpart_code		= toNN((part_depth==3) ? form_obj.find("select[name=mpart_code]").val() : "");

	form_obj.find("select[name=" + target_field	+ "]").html("<option value=''>"	+ target_name +	"</option>");
	//대분류 바꾸는 경우 소분류도 초기화 한다.
	if(part_depth==2){
		form_obj.find("select[name=spart_code]").html("<option value=''>소분류</option>");
	}
	if(obj.val()=="") return;

	$.ajax({
		type: "POST",
		url: "../common/get_user_group_code_list.jsp",
		data: "bpart_code="+bpart_code+"&mpart_code="+mpart_code+"&part_depth="+part_depth+"&perm_check="+perm_check,
		async: false,
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code!="ERR") {
				if(dataJSON.data.length>0) {
					var html = "";
					var code = "";
					for(var i=0;i<dataJSON.data.length;i++) {
						code = (target_field=="mpart_code")	? dataJSON.data[i].mpart_code :	dataJSON.data[i].spart_code;
						html +=	"<option value='" +	code + "'>"	+ dataJSON.data[i].part_name + "</option>";
					}
					form_obj.find("select[name=" + target_field	+ "]").append(html);
				} else {
					alert(target_name +	"가 데이터가	없습니다.");
					return false;
				}
			} else {
				alert(dataJSON.msg);
				return false;
			}
		},
		error:function(req,status,err){
			alert("에러가 발생하였습니다.	[" + req.responseText +	"]");
			return false;
		}
	});
}

// datepicker option
var dp_option = {
		dateFormat: 'yy-mm-dd',
		prevText: '이전 달',
		nextText: '다음 달',
		monthNames: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		dayNames: ['일','월','화','수','목','금','토'],
		dayNamesShort: ['일','월','화','수','목','금','토'],
		dayNamesMin: ['일','월','화','수','목','금','토'],
		showMonthAfterYear: true,
		yearSuffix: '년',
		//showOn: "button",
		//buttonText: "<i class='fa fa-calendar'></i>",
};

// 추후 total.js와 합쳐야 함
$(function() {
	try{$(".datepicker").datepicker(dp_option);}catch(e){};

	// 달력 아이콘 클릭 시 오픈
	$(".btn-datepicker").click(function() {
		$(this).parents(".input-group").children(".datepicker").datepicker("show");
	});

	/* 비밀번호 변경 */
	$("#passwdUpd button[name=modal_regi]").click(function() {
		if(!$("#passwdUpd input[name=user_id]").val().trim()) {
			alert("상담원ID를 입력해 주십시오.");
			$("#passwdUpd input[name=user_id]").focus();
			return false;
		}
		if(!$("#passwdUpd input[name=user_pass]").val().trim()) {
			alert("현재 비밀번호를	입력해	주십시오.");
			$("#passwdUpd input[name=user_pass]").focus();
			return false;
		}
		if(!$("#passwdUpd input[name=new_pass]").val().trim()) {
			alert("변경 비밀번호를	입력해	주십시오.");
			$("#passwdUpd input[name=new_pass]").focus();
			return false;
		}
		if(!$("#passwdUpd input[name=new_pass_re]").val().trim()) {
			alert("변경 비밀번호 (재확인)을 입력해 주십시오.");
			$("#passwdUpd input[name=new_pass_re]").focus();
			return false;
		}
		if($("#passwdUpd input[name=new_pass]").val().trim()!=$("#passwdUpd	input[name=new_pass_re]").val().trim()) {
			alert("변경 비밀번호와	변경 비밀번호	(재확인)이 일치하지	않습니다.");
			$("#passwdUpd input[name=new_pass]").focus();
			return false;
		}
		if($("#passwdUpd input[name=user_pass]").val().trim()==$("#passwdUpd input[name=new_pass]").val().trim()) {
			alert("현재 비밀번호와	동일한	비밀번호 입니다.");
			$("#passwdUpd input[name=new_pass]").focus();
			return false;
		}
		if(!checkPasswd($("#passwdUpd input[name=user_id]").val().trim(), $("#passwdUpd	input[name=new_pass]").val().trim(), false)) {
			$("#passwdUpd input[name=new_pass]").focus();
			return false;
		}

		// 호출되는	페이지에 따른	경로 설정 (top / index)
		var type = $(this).attr("prop");
		var url_prefix = (type=="U") ? "../" : "./";

		$.ajax({
			type: "POST",
			url: url_prefix	+ "common/passwd_update.jsp",
			async: false,
			data: "step=update&type="+type+"&"+$("#passwdUpd").serialize(),
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					alert("정상적으로 변경되었습니다.");
					if(type=="U") {
						$("#modalPasswdForm").modal("hide");
					} else {
						$("#modalPasswdForm").dialog("close");
					}
				} else {
					alert(dataJSON.msg);
					return false;
				}
			},
			error:function(req,status,err){
				alert("에러가 발생하였습니다.	[" + req.responseText +	"]");
				return false;
			}
		});
	});

	/* 검색 영역에서 조직도 조회 */
	$("#search select[name=bpart_code],	#search	select[name=mpart_code]").change(function(){chgPartCode($(this));});

	/* grid	start */
	// grid	데이터	조회 함수
	var search = function() {
		//공통모듈 실행하기 전에 해당페이지 펑션 체크 (유효성 체크등..)
		var isContinue = true;
		try{isContinue = beforeSearchFunc()}catch(e){}
		if(!isContinue) return;

		// 1번 page로	초기화
		$grid.pqGrid("option", "pageModel.curPage",	1);
		$grid.pqGrid("refreshDataAndView");
	};
	// 조회 버튼 클릭	시 데이터 조회
	$("#search button[name=btn_search]").click(function() {
		search();
	});
	// 엔터키가	눌러졌을 경우	데이터	조회 실행
	$("#search input, #search select").keyup(function(e) {
		if(e.keyCode==13) {
			search();
		}
	});
	/* grid	end	*/

	// 취소 버튼 클릭	시 페이지 재	연결
	$("#search button[name=btn_cancel]").click(function() {
		var url	= $(location).attr("href").replace("#none",	"");
		location.replace(url);
	});
});

function alertJsonErr(req,status,err){
	try{
		//isDebug common.jsp에 넣아야 함
		if (isDebug) {
			alert("Ajax Error!!\nreq : "+status+"\nreq : "+status+"\nerror : "+objToStr(err));
		}
		else{
			alert("Ajax Error!!\nstatus : "+status+"\nerror : "+objToStr(err));
		}
	}
	catch(e){
		alert("Ajax Error!!\nstatus : "+status+"\nerror : "+objToStr(err));
	}
}
function alertJsonErrSite(aCallback, req,status,err){
	try{
		//isDebug common.jsp에 넣아야 함
		if (isDebug) {
			alert(aCallback + " Error!!\nreq : "+status+"\nreq : "+status+"\nerror : "+objToStr(err));
		}
		else{
			alert(aCallback + " Error!!\nstatus : "+status+"\nerror : "+objToStr(err));
		}
	}
	catch(e){
		alert(aCallback + " Error!!\nstatus : "+status+"\nerror : "+objToStr(err));
	}
}

function goToAjaxSite(aUrl, aData, aCallback){
	$.ajax({
		type: "POST",
		url: aUrl,
		async: false,
		data: aData,
		dataType: "json",
		success:function(dataJSON){
			if (dataJSON.code=="OK") {
				eval(aCallback+"(dataJSON)");
				return true;
			} else {
				alert(aCallback+" :: "+dataJSON.msg);
				return false;
			}
		},
		error:function(req,status,err){
			alertJsonErrSite(aCallback, req,status,err);
			return false;
		}
	});
}

// colModel의 dataIndx로 배열번호 구하기
function getIdxColModel(colModel, dataIndx){
	for(var i=0, len=colModel.length; i < len; i++){
		if (colModel[i].dataIndx==dataIndx) return i;
	}
	return -1;
}
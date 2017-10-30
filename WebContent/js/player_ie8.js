var waveform;
var wave_w = 534;
var wave_h = 80;
var wave_data = [];

var player;
var timer;
var duration = 0;
var rate = 1;

$(function(){
	var html = "";
	var fft_url = file_url.replace(".wav","."+fft_ext);

	if(wave_type=="img") {
		// get wave form image
		html += "<wave style='position: relative; width: "+wave_w+"px; height: "+wave_h+"px; background-color: #171A20; display: block;'>";
		html += "	<img id='wave_img' src='../rec_search/player_waveform.jsp?url=" + encodeURIComponent(fft_url) + "'/>";
		//html += "	<wave style='position: absolute; top: 0; left: 0; bottom: 0; width: 0; overflow: hidden; border-right: 1px solid #ff8b00; box-sizing: border-box; background-color: #ff8b00; opacity: 0.3;'></wave>";
		html += "	<wave style='position: absolute; top: 0; left: 0; bottom: 0; width: 0; overflow: hidden; border-right: 1px solid #FF3131; box-sizing: border-box; background-color: #666666; opacity: 0.8;'></wave>";
		html += "</wave>";

		$("#waveform").html(html);
	} else if(wave_type=="img2") {
		// get wave form image
		html += "<wave style='position: relative; width: "+wave_w+"px; height: "+wave_h+"px; background-color: #171A20; display: block;'>";
		html += "	<img id='wave_img' src='" + fft_url + "'/>";
		//html += "	<wave style='position: absolute; top: 0; left: 0; bottom: 0; width: 0; overflow: hidden; border-right: 1px solid #ff8b00; box-sizing: border-box; background-color: #ff8b00; opacity: 0.3;'></wave>";
		html += "	<wave style='position: absolute; top: 0; left: 0; bottom: 0; width: 0; overflow: hidden; border-right: 1px solid #FF3131; box-sizing: border-box; background-color: #666666; opacity: 0.8;'></wave>";
		html += "</wave>";

		$("#waveform").html(html);
	} else {
		// get wave form data
		$.ajax({
			type: "GET",
			url: fft_url,
			async: false,
			dataType: "text",
			success:function(data){
				//console.log(data);
				if(data.toLowerCase().indexOf("error")<0) {
					wave_data = eval("[" + data + "]");
				} else {
					alert("미디어 서버에 오류가 발생하였습니다.");
					self.close();
					return false;
				}
			},
			error:function(req,status,err){
				alert("미디어 서버 연결에 실패했습니다.");
				self.close();
				return false;
			}
		});

		// wave form
		waveform = new Waveform({
			container: document.getElementById("waveform"),
			width: wave_w,
			height: wave_h,
			data: wave_data,
			innerColor: "#00FFFF",
			outerColor: "#171A20",
			progressColor: "#808080",
			cursorColor: "#FF3131",
			interpolate: true
		});
	}

	// player set
	html = "";
	html += "<object width='" + wave_w + "' height='45' id='player' name='player' classid='CLSID:6BF52A52-394A-11D3-B153-00C04F79FAA6' codebase='http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=5,1,52,701' standby='Loading Microsoft Windows Media Player components...' type='application/x-wav'>";
	html += "	<param name='url' value='" + file_url + "' />";
	html += "	<param name='AutoSize' value='true' />";
	//html += "	<param name='AutoStart' value='true' />";
	html += "	<param name='AutoStart' value='false' />";
	html += "	<param name='Balance' value='0' />";
	html += "	<param name='CurrentMarker' value='0' />";
	html += "	<param name='CurrentPosition' value='0' />";
	html += "	<param name='DisplaySize' value='0' />";
	html += "	<param name='EnableContextMenu' value='false' />";
	html += "	<param name='Enabled' value='true' />";
	html += "	<param name='InvokeURLs' value='true' />";
	html += "	<param name='Mute' value='false' />";
	html += "	<param name='PlayCount' value='0' />";
	html += "	<param name='Rate' value='1.0' />";
	html += "	<param name='ShowAudioControls' value='true' />";
	html += "	<param name='ShowControls' value='true' />";
	html += "	<param name='ShowDisplay' value='false' />";
	html += "	<param name='ShowStatusBar' value='false' />";
	html += "	<param name='ShowTracker' value='false' />";
	html += "	<param name='StretchToFit' value='true' />";
	html += "	<param name='TransparentAtStart' value='false' />";
	html += "	<param name='Volume' value='100' />";
	html += "</object>";

	$("#outer_player").html(html);

	// player instance
	player = document.getElementById("player");

	// forward
	$("#btn_forward").on("click", function(){
		var sec = getSec($("input[name=move_time]").val(), $("select[name=move_unit]").val());
		onForward(sec);
	});

	// backward
	$("#btn_backward").on("click", function(){
		var sec = getSec($("input[name=move_time]").val(), $("select[name=move_unit]").val());
		onBackward(sec);
	});

	// speed change
	$(".btn_speed").on("click", function() {
		var sp = $(this).attr("prop");

		// 기존 speed 버튼 class 초기화
		$(".btn_speed").each(function(n) {
			$(".btn_speed").eq(n).removeClass("btn-success");
			$(".btn_speed").eq(n).addClass("btn-primary");
		});

		// 선택된 speed class 설정
		$(this).removeClass("btn-primary");
		$(this).addClass("btn-success");

		//
		setRate(sp);
	});

	// wave form click
	$("#waveform").bind("mousedown", function(event){
		var ex = event.pageX;
		var offset = $(this).offset();
		var w = ex-offset.left;

		if(duration>0) {
			var cur_sec = ((duration) * (w/wave_w).toFixed(5)).toFixed(0);

			// seek
			seekTo(cur_sec);

			// marking
			if($("#ui-marking") && $("#ui-marking").hasClass("show")) {
				var mk_name = $("#marking input[name=mk_name]");
				var mk_stime = $("#marking input[name=mk_stime]");
				var mk_etime = $("#marking input[name=mk_etime]");
				var cur_sec_his = getHmsToSec(cur_sec);

				if(mk_stime.val()=="") {
					mk_stime.val(cur_sec_his);
				} else {
					mk_etime.val(cur_sec_his);
				}
			}

			// part
			if($("#ui-part") && $("#ui-part").hasClass("show")) {
				var pa_stime = $("#part input[name=pa_stime]");
				var pa_etime = $("#part input[name=pa_etime]");
				var cur_sec_his = getHmsToSec(cur_sec);

				if(pa_stime.val()=="") {
					pa_stime.val(cur_sec_his);
				} else {
					pa_etime.val(cur_sec_his);
				}
			}



		}
	});

	// space bar keydown event
	$(document).keydown(function (event){
		if(event.which==32) {
			event.preventDefault();
			playPause();
		}
	});

	// player start
	if(wave_type=="img") {
		$("#wave_img").error(function(eventData) {
			$(this).hide();
			$("#waveform > wave").append("<div class=\"errmsg\">파형 이미지 생성에 실패했습니다.</div>");
			player.controls.play();
		});

		$("#wave_img").load(function() {
			player.controls.play();
		});
	} else if(wave_type=="img2") {
		$("#wave_img").error(function(eventData) {

			player.controls.play();
		});

		$("#wave_img").load(function() {
			player.controls.play();
		});
	} else {
		player.controls.play();
	}
});

//play & pause
function playPause() {
	if(player.playState==1 || player.playState==2) {
		// 기존 배속 설정
		setRate(rate);

		player.controls.play();
	} else {
		player.controls.pause();
	}
}

//set duration second
function setDuration() {
	duration = player.currentMedia.duration;
	//
	$("#tot_time").html(getMsToSec(duration.toFixed(0)));
}

// timeupdate
function onProgress() {
	setDuration();

	// 기존 timer가 존재한다면 clear
	if(timer) {
		clearInterval(timer);
	}

	timer = setInterval(function(){
		$("wave > wave").css("width", (player.controls.currentPosition/duration*100).toFixed(5)+"%");
		console.log(player.controls.currentPosition);

		// 현재 play time 표시
		$("#cur_time").html(getMsToSec(player.controls.currentPosition));
	}, 100);
}

// pause
function onPause() {
	clearInterval(timer);
}

// stop
function onStop() {
	clearInterval(timer);

	// waveform reset
	$("wave > wave").css("width", "0px");
}

// forward
function onForward(sec) {
	player.controls.currentPosition += parseInt(sec);
}

// backward
function onBackward(sec) {
	player.controls.currentPosition -= parseInt(sec);
}

// 청취끝남
function onEnd() {
	goNextPlay();
}

// set rate
function setRate(sp) {
	player.settings.rate = parseFloat(sp);
	//
	rate = sp;
}

// seek
function seekTo(pos) {
	player.controls.currentPosition = pos;

	// waveform
	$("wave > wave").css("width", (pos/duration*100).toFixed(5)+"%");
}

// return second
function getSec(time, unit) {
	return (unit=="M") ? time*60 : time;
}

//marking play
var playMarking = function(start_sec, end_sec) {
	var interval = (end_sec - start_sec) * 1000;

	player.controls.currentPosition = parseInt(start_sec);
	player.controls.play();

	// duration 동안 play 후 pause
	setTimeout(function() {
		player.controls.pause();
	}, interval);
};
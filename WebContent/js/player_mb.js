var waveform;
var wave_w = 534;
var wave_h = 80;
var wave_data;

var duration = 0;

$(function () {	
	// get wave data
	$.ajax({
		type: "GET",
		url: file_url.replace(".wav",".fft"),
		async: false,
		dataType: "text",
		success:function(data){  
			console.log(data);
			if(data.toLowerCase().indexOf("error")<0) {
				wave_data = data.split(",");	
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
	
	var wf_options = {
			container: "#waveform",
			waveColor: "#A8DBA8",
			progressColor: "#FF8B00",
			cursorColor: "#FF8B00",
			cursorWidth: 1,	  
			backgroundColor: "#4F4E65",
			height: wave_h,
			backend: "MediaElement"			
		};
		
	waveform = WaveSurfer.create(wf_options);
	waveform.load(file_url, wave_data);	
	
	waveform.on("ready", function () {
		// duration display
		duration = parseInt(waveform.getDuration());
		$(".jp-duration").html(getMsToSec(duration));
		
		waveform.play();
	});	
	
	// play progress
	waveform.on("audioprocess", function (sec) {
		// current time display
		$(".jp-current-time").html(getMsToSec(parseInt(sec)));
		
		// progress bar move	
		var perc = (sec/duration).toFixed(5);
		$(".jp-progress-slider").slider("value", perc);
	});	
	
	// play & pause button click
	$(".jp-playpause").click(function(){
		waveform.playPause();
	});
	
	// stop button click
	$(".jp-stop").click(function(){
		waveform.stop();
	});
	
	// repeat button click
	$(".jp-repeat").click(function(){
		$(this).toggleClass("ui-state-active");
	});		
		
	// play event
	waveform.on("play", function () {
		$(".jp-play").css("display", "none");
		$(".jp-pause").css("display", "block");
	});
	
	// pause event
	waveform.on("pause", function () {
		$(".jp-play").css("display", "block");
		$(".jp-pause").css("display", "none");		
	});	
	
	// play finish event
	waveform.on("finish", function () {
		if($(".jp-repeat").hasClass("ui-state-active")) {
			waveform.play(0);
		} else {
			$(".jp-play").css("display", "block");
			$(".jp-pause").css("display", "none");				
		}
	});
	
	// space bar keydown event
	$(document).keydown(function (event){
		if(event.which==32) {
			event.preventDefault();
			waveform.playPause();
		}
	});	
	
	// mute button click
	$(".jp-mute").click(function(){
		waveform.setVolume(0);
		$(".jp-volume-slider").slider("value", 0);
	});
	
	// volume-max button click
	$(".jp-volume-max").click(function(){
		waveform.setVolume(1);
		$(".jp-volume-slider").slider("value", 1);
	});	
	
	// create the progress slider control
	$(".jp-progress-slider").slider({
		animate: "fast",
		max: 1,			
		range: "min",
		step: 0.00001,
		value : 0,
		slide: function(event, ui) {
			var sec = parseInt((ui.value).toFixed(5)*duration);
			if(sec>0) {
				waveform.play(sec);
			}
		}
	});
	
	// create the volume slider control
	$(".jp-volume-slider").slider({
		animate: "fast",
		max: 1,
		range: "min",
		step: 0.01,
		value : 0.5,
		slide: function(event, ui) {
			waveform.setVolume(ui.value);
		}
	});
	
	// play rate change
	$("#ui-speed li").click(function(){
		var speed = $(this).attr("prop");
		
		waveform.setPlaybackRate(speed);
		$("#speed").html(speed + "x");
	});	
	
	// waveform click
	waveform.on("seek", function (progress) {
		if(progress==0) return;
					
		// marking			
		if($("#ui-marking") && $("#ui-marking").hasClass("show")) {			
			var mk_name = $("#marking input[name=mk_name]");
			var mk_stime = $("#marking input[name=mk_stime]");
			var mk_etime = $("#marking input[name=mk_etime]");
			var cur_sec_his = getHmsToSec(parseInt(waveform.getCurrentTime()));
			
			if(mk_stime.val()=="") {
				mk_stime.val(cur_sec_his);
			} else {
				mk_etime.val(cur_sec_his);
			}												
		}
	});
	
	// hover states of the buttons
	$(".jp-gui ul li").hover(
		function() { $(this).addClass('ui-state-hover'); },
		function() { $(this).removeClass('ui-state-hover'); }
	);	
});

// marking play
var playMarking = function(start_sec, end_sec) {	
	waveform.play(parseInt(start_sec), parseInt(end_sec));
};
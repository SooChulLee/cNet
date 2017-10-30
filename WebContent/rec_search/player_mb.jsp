<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!--플레이어 영역-->	
<div id="player" class="jp-jplayer"></div>
<div id="jp_container_1">
	<div class="jp-gui ui-widget">
		<ul>
			<li class="jp-marking ui-state-default ui-corner-all"><a href="javascript:;" class="jp-marking ui-icon ui-icon-pin-s" tabindex="1" title="marking">marking</a></li>
			<li class="jp-playpause">
				<ul>		
					<li class="jp-play ui-state-default ui-corner-all"><a href="javascript:;" class="jp-play ui-icon ui-icon-play" tabindex="1" title="play">play</a></li>
					<li class="jp-pause ui-state-default ui-corner-all"><a href="javascript:;" class="jp-pause ui-icon ui-icon-pause" tabindex="1" title="pause">pause</a></li>
				</ul>
			</li>
			<li class="jp-stop ui-state-default ui-corner-all"><a href="javascript:;" class="jp-stop ui-icon ui-icon-stop" tabindex="1" title="stop">stop</a></li>
			<li class="jp-repeat ui-state-default ui-corner-all"><a href="javascript:;" class="jp-repeat ui-icon ui-icon-refresh" tabindex="1" title="repeat">repeat</a></li>
			<li class="jp-mute"><a href="javascript:;" class="jp-mute ui-icon ui-icon-volume-off" tabindex="1" title="mute">mute</a></li>
			<li class="jp-unmute ui-state-active"><a href="javascript:;" class="jp-unmute ui-icon ui-icon-volume-off" tabindex="1" title="unmute">unmute</a></li>
			<li class="jp-volume-max"><a href="javascript:;" class="jp-volume-max ui-icon ui-icon-volume-on" tabindex="1" title="max volume">max volume</a></li>
		</ul>
		<!--speed 영역-->					
		<div class="ibox-tools">
			<div class="dropdown">
				<button class="btn btn-speed dropdown-toggle" type="button" id="btn_speed" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><span id="speed">1.0x</span> <span class="caret"></span>
				</button>
				<ul id="ui-speed" class="dropdown-menu" aria-labelledby="btn_speed">
					<li prop="0.5"><a href="#">0.5x</a></li>
					<li prop="1.0"><a href="#">1.0x</a></li>
					<li prop="1.5"><a href="#">1.5x</a></li>
					<li prop="2.0"><a href="#">2.0x</a></li>
				</ul>
			</div>					
		</div>	
		<!--speed 영역 끝-->				
		<div class="jp-progress-slider"></div>
		<div class="jp-volume-slider"></div>
		<div class="jp-current-time"></div>
		<div class="jp-duration"></div>
		<div class="jp-clearboth"></div>
	</div>
	<div class="jp-no-solution">
		<span>Update Required</span>
		To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.
	</div>
</div>
<!--플레이어 영역 끝-->
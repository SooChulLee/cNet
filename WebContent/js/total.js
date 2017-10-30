$(function() {
	// Add body-small class if window less than 768px
	if ($(this).width()<769) {
		$('body').addClass('body-small');
	} else {
		$('body').removeClass('body-small');
	}  
	
	// Minimalize menu when screen is less than 768px
	$(window).bind("resize", function() {
		if ($(this).width() < 769) {
			$('body').addClass('body-small');
		} else {
			$('body').removeClass('body-small');
		}   
	});	
		   
	// MetsiMenu (left menu)
	$('#side-menu').metisMenu();		 

	// Collapse ibox function (검색창 열기/닫기)
	$('.collapse-link').click( function() {
		var ibox = $(this).closest('div.ibox');
		var button = $(this).find('i');
		var content = ibox.find('div.ibox-content');
		content.slideToggle(200);
		button.toggleClass('fa-chevron-up').toggleClass('fa-chevron-down');
		//ibox.toggleClass('').toggleClass('border-bottom');
		setTimeout(function () {
			//ibox.resize();
			//ibox.find('[id^=map-]').resize();
		}, 50);
	});
	
	// Collapse ibox function (검색창 열기/닫기)
	$('.collapse-link2').click( function() {
		var ibox = $(this).closest('div.ibox');
		var button = $(this).find('i');
		var content = ibox.find('div.ibox-content-util-buttons');
		//var content = ibox.find('div.ibox-content');
		content.slideToggle(200);
		button.toggleClass('fa-caret-up').toggleClass('fa-caret-down');
		ibox.toggleClass('').toggleClass('border-bottom');  
	});	

	// Close ibox function
	$('.close-link').click( function() {
		var content = $(this).closest('div.ibox');
		content.remove();
	});

	// Close menu in canvas mode
	$('.close-canvas-menu').click( function() {
		$("body").toggleClass("mini-navbar");
		SmoothlyMenu();
	});
   
	// Minimalize menu (left menu 줄이기)
	$('.navbar-minimalize').click(function () {
		$("body").toggleClass("mini-navbar");		
		/*
		// left mini menu 여부 쿠키 생성
		if($("body").hasClass("mini-navbar")) {			
			$.cookie("ck_mini_var_yn", "1", { path: "/" });			
		} else {
			$.cookie("ck_mini_var_yn", "0", { path: "/" });
		} 
		*/	   
		SmoothlyMenu(); 
		
		// 0.5초 후 grid size 변경
		window.setTimeout( function(){
			$("#grid").pqGrid("refreshDataAndView");
		}, 500);						
	});
	
	/*
	// 이전에 left menu가 mini-var 형태라면 기존대로 유지
	if($.cookie("ck_mini_var_yn")=="1") { 
		$('body').addClass('mini-navbar');
		$('#side-menu').removeAttr('style');			
	}
	*/	

	// Move modal to body
	// Fix Bootstrap backdrop issue with animation.css
	$('.modal').appendTo("body");  
	
	// grid가 리플레시 될때 height 조정
	/*$("#grid").on("pqgridload", function() {
		fix_height("");
	});*/
	
	// height auto resize
	$(".wrapper-content").resize(function() {
		fix_height($(".wrapper-content").height());
	});
	   
	// load ajax를 사용했을 경우 height 조정
	/*$("#treeDiv1, #treeDiv2").resize(function() {
		var heigh = ($("#treeDiv1").height()>$("#treeDiv2").height()) ? $("#treeDiv1").height() : $("#treeDiv2").height();		
		fix_height($(".wrapper-content").height() + heigh);
	});*/		 

	// tooltips
	$('.tooltip').tooltip({
		selector: "[data-toggle=tooltip]",
		container: "body"
	});
	
	// popover
	$("[data-toggle=popover]").popover();   
	
	// template color 변경
	$("select[name=template_color]").on("change", function(){
		var color = $(this).val();		
		// color cookie 생성
		$.cookie("ck_template_color", color, { path: "/" });
		
		location.reload();
	});
	
	// template color 설정
	$("select[name=template_color]").val($.cookie("ck_template_color"));  
});

//Full height of sidebar
function fix_height(heigh) {
	if((heigh+169)<$(window).height()) {
		var agent = navigator.userAgent.toLowerCase();
		var add_heigh = 0;

		/*if($(window).height()-heigh<80) {
			if(agent.indexOf("trident")!=-1) {
				add_heigh = 100 + (80-($(window).height()-heigh));
			} else {
				//add_heigh = 105;
				add_heigh = 100 + (80-($(window).height()-heigh));
			}
		}*/
				
		$("#page-wrapper").css("min-height", ($(window).height()+add_heigh) + "px");
	} else {	
		$("#page-wrapper").css("min-height", (heigh+169) + "px");
	} 		
}

// For demo purpose - animation css script
function animationHover(element, animation){
	element = $(element);
	element.hover(
		function() {
			element.addClass('animated ' + animation);
		},
		function(){
			//wait for animation to finish before removing classes
			window.setTimeout( function(){
				element.removeClass('animated ' + animation);
			}, 2000);
		});
}

function SmoothlyMenu() {		
	if (!$('body').hasClass('mini-navbar') || $('body').hasClass('body-small')) {
		// Hide menu in order to smoothly turn on when maximize menu
		$('#side-menu').hide();
		// For smoothly turn on menu
		setTimeout(
			function () {
				$('#side-menu').fadeIn(500);
			}, 100);
	} else if ($('body').hasClass('fixed-sidebar')) {
		$('#side-menu').hide();
		setTimeout(
			function () {
				$('#side-menu').fadeIn(500);
			}, 300);
	} else {
		// Remove all inline style from jquery fadeIn function to reset menu state
		$('#side-menu').removeAttr('style');				
	}
}
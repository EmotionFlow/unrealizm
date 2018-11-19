var getBgImage = (function() {
	var func;
	if (document.documentElement.currentStyle) {
		func = function(element) {
			var val = element.currentStyle.backgroundImage;
			return val.replace( /(url\(|\)|")/g, '' );
		}
	} else if (window.getComputedStyle) {
		func = function(element) {
			var val = document.defaultView.getComputedStyle( element, null ).getPropertyValue('background-image');
			return val.replace( /(url\(|\)|")/g, '' );
		}
	}
	return func;
})();

$(function() {
	var loadCount = 0;
	var imgLength = $(".IllustThumbImg, .IllustItemUserThumb, .UserInfoUserThumb, .UserInfo").size() + $("img").size();
	if(imgLength==0) {
		$("#HeaderSlider").css({"width": "100%"});
	} else {
		$(".IllustThumbImg, .IllustItemUserThumb, .UserInfoUserThumb, .UserInfo").each(function() {
			var src = getBgImage(this);
			if (src!=='' && src!='none') {
				$("<img>").attr("src", src).load(function() {
					loadCount++;
					$("#HeaderSlider").css({"width": (loadCount / imgLength) * 100 + "%"});
				}).error(function() {
					loadCount++;
					$("#HeaderSlider").css({"width": (loadCount / imgLength) * 100 + "%"});
				});
			} else {
				loadCount++;
				$("#HeaderSlider").css({"width": (loadCount / imgLength) * 100 + "%"});
			}
		});
		$("img").each(function() {
			var src = $(this).attr("src");
			if (src!=='' && src!='none') {
				$("<img>").attr("src", src).load(function() {
					loadCount++;
					$("#HeaderSlider").css({"width": (loadCount / imgLength) * 100 + "%"});
				}).error(function() {
					loadCount++;
					$("#HeaderSlider").css({"width": (loadCount / imgLength) * 100 + "%"});
				});
			} else {
				loadCount++;
				$("#HeaderSlider").css({"width": (loadCount / imgLength) * 100 + "%"});
			}
		});
	}
});

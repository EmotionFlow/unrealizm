$(function() {
	var loadCount = 0;
	var imgLength = $("img").size();
	$("img").each(function() {
		var src = $(this).attr("src");
		$("<img>").attr("src", src).load(function() {
			loadCount++;
			$("#HeaderSlider").css({
				"width": (loadCount / imgLength) * 100 + "%" //読み込まれた画像の数を画像全体で割り、%としてローディングバーのwidthに設定
			});
		});
	});
});



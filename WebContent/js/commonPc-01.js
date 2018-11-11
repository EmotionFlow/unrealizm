$(function(){var a=0,b=$("img").size();$("img").each(function(){var c=$(this).attr("src");$("<img>").attr("src",c).load(function(){a++;$("#HeaderSlider").css({width:a/b*100+"%"})})})});

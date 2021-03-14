<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.cache.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.settlement.*"%>
<%@page import="jp.pipa.poipiku.settlement.epsilon.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(Util.isSmartPhone(request)) {%>
<link href="/js/slick/slick-theme.css" rel="stylesheet" type="text/css">
<link href="/js/slick/slick.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/js/slick/slick.min.js"></script>
<script>
$(function(){
	$('.EventItemList').slick({
		autoplay:true,
		autoplaySpeed:2000,
		dots:true,
		infinite: true,
		slidesToShow: 1,
		variableWidth: true,
		centerMode: true,
		centerPadding: '10px',
	});
	$('.EventItemList').css({'opacity': '1'});
});
</script>
<%}%>
<ul class="EventItemList">
	<li class="EventItem">
		<a href="/event/20190901/TopPcV.jsp">
			<img class="EventBanner" src="/event/20190901/banner_odai.png" />
		</a>
	</li>

	<li class="EventItem">
		<a href="/UploadTextPcV.jsp">
			<img class="EventBanner" src="/img/banner_2020_10_25_text-post.png" />
		</a>
	</li>

	<li class="EventItem End">
		<a href="/NewArrivalPcV.jsp?CD=29">
			<img class="EventBanner" src="/event/2021_02_18_blskip/poipiku_blskip_bn.png" />
		</a>
	</li>

	<li class="EventItem End">
		<a class="EventBanner NoBgRed End" style="padding: 5px;" href="/NewArrivalPcV.jsp?CD=28">
			<div style="text-align: center; font-size: 26px; font-weight: bold; line-height: 40px">祝！200万ユーザ突破</div>
			<div style="text-align: center; font-size: 16px; line-height: 20px;">どうか祝ってやって下さいm(_ _)m</div>
			<div style="text-align: center; font-size: 13px; line-height: 20px;">抽選で100名様にポイパス1ヶ月分プレゼント</div>
		</a>
	</li>
</ul>

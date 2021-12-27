<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.cache.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.settlement.*"%>
<%@page import="jp.pipa.poipiku.settlement.epsilon.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
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
<ul class="EventItemList">
	<li class="EventItem">
		<a class="EventBanner" style="padding: 5px; overflow: hidden; color: #aaa; background-color: #000;" href="/NewArrivalAppV.jsp?ID=27">
			<div style="text-align: center; font-size: 20px; line-height: 30px;"><%=_TEX.T("Category.LimitedTime")%></div>
			<div style="text-align: center; font-size: 30px; font-weight: bold; line-height: 52px"><%=_TEX.T("Category.C27")%></div>
		</a>
	</li>

	<li class="EventItem">
		<a class="EventBanner" style="padding: 5px; overflow: hidden; background-color: #18a926;" href="https://kakenee.com/">
			<div style="text-align: center; font-size: 15px; line-height: 18px;">小説執筆応援プラットフォーム</div>
			<div style="text-align: center; font-size: 35px; font-weight: bold; line-height: 42px">Kakenee</div>
			<div style="text-align: center; font-size: 20px; line-height: 22px;">公開中</div>
		</a>
	</li>

	<li class="EventItem">
		<a href="/event/20190901/TopV.jsp">
			<img class="EventBanner" src="/event/20190901/banner_odai.png" />
		</a>
	</li>

	<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF) {%>
	<li class="EventItem">
		<a href="/MyEditSettingPassportAppV.jsp">
			<img class="EventBanner" src="/img/poipiku_passport_banner_01.png" />
		</a>
	</li>
	<%}%>

<!--
	<li class="EventItem">
		<a href="/NewArrivalPcV.jsp?CD=13">
			<img class="EventBanner" src="/event/20191026_halloween/banner_halloween_2021.png" />
		</a>
	</li>

	<li class="EventItem End">
		<a href="/NewArrivalV.jsp?CD=29">
			<img class="EventBanner" src="/event/2021_02_18_blskip/poipiku_blskip_bn.png" />
		</a>
	</li>

	<li class="EventItem End">
		<a class="EventBanner NoBgRed" style="padding: 5px;" href="/NewArrivalV.jsp?CD=28">
			<div style="text-align: center; font-size: 26px; font-weight: bold; line-height: 40px">祝！200万ユーザ突破</div>
			<div style="text-align: center; font-size: 16px; line-height: 20px;">どうか祝ってやって下さいm(_ _)m</div>
			<div style="text-align: center; font-size: 13px; line-height: 20px;">抽選で100名様にポイパス1ヶ月分プレゼント</div>
		</a>
	</li>
-->
</ul>

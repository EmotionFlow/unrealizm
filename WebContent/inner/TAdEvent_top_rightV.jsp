<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.cache.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.settlement.*"%>
<%@page import="jp.pipa.poipiku.settlement.epsilon.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<ul class="EventItemList">
	<!--
	<li class="EventItem">
		<a href="/event/20191026_halloween/TopV.jsp">
			<img class="EventBanner" src="/event/20191026_halloween/banner_halloween_2020.png" />
		</a>
	</li>
	-->

	<li class="EventItem Start">
		<a class="EventBanner NoBgGold" href="/event/20201226_best1/TopV.jsp" style="padding: 30px 0 0 0; text-align: center;">
			<div style="line-height: 16px;">お正月だし2020年を振り返ろう！</div>
			<h3 style="font-weight: bold; font-size: 17px;">「2020年ベスト1」</h3>
			<div style="line-height: 16px;">豪華賞品を用意して開催中！詳細はこちら</div>
		</a>
	</li>

	<li class="EventItem">
		<a href="/event/20190901/TopV.jsp">
			<img class="EventBanner" src="/event/20190901/banner_odai.png" />
		</a>
	</li>

	<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && checkLogin.m_nUserId!=315) {%>
	<li class="EventItem">
		<a href="/MyEditSettingPassportAppV.jsp" class="EventBanner NoBgBle" style="padding: 8px; background: #b3dced; background: -moz-linear-gradient(-45deg, #b3dced 0%, #29b8e5 50%, #bce0ee 100%); background: -webkit-linear-gradient(-45deg, #b3dced 0%,#29b8e5 50%,#bce0ee 100%); background: linear-gradient(135deg, #b3dced 0%,#29b8e5 50%,#bce0ee 100%); filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#b3dced', endColorstr='#bce0ee',GradientType=1 );">
			<div><img style="height: 30px;" src="/img/poipiku_passport_logo_60.png" /></div>
			<h3 style="font-weight: bold  text-align: center; font-size: 17px; line-height: 25px;">ポイパスはじめました</h3>
			<div style="line-height: 20px;">アプリからのご加入は準備中です。</div>
		</a>
	</li>
	<%}%>
</ul>

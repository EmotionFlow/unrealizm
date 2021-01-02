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
		<a href="/event/20191026_halloween/TopPcV.jsp">
			<img class="EventBanner" src="/event/20191026_halloween/banner_halloween_2020.png" />
		</a>
	</li>
	-->
	<!--
	<li class="EventItem">
		<a class="EventBanner NoBgRed" style="padding: 5px;" href="/NewArrivalPcV.jsp?CD=27">
			<div style="text-align: center; font-size: 16px; line-height: 20px;">12月31日限定カテゴリ</div>
			<div style="text-align: center; font-size: 26px; font-weight: bold; line-height: 32px">「煩悩を晒せ」</div>
			<div style="text-align: center; font-size: 14px; line-height: 16px;">今年の煩悩の集大成いとして、「目指せたった1日で煩悩投稿108枚」！</div>
		</a>
	</li>
	-->

	<li class="EventItem">
		<a class="EventBanner NoBgGold" style="padding: 5px;" href="/NewArrivalPcV.jsp?CD=20">
			<div style="text-align: center; font-size: 16px; line-height: 23px;">過去の年賀状を引っ張り出してきて<br />出した気になろう！</div>
			<div style="text-align: center; font-size: 26px; font-weight: bold; line-height: 32px">「使いまわし年賀状」</div>
		</a>
	</li>

	<li class="EventItem">
		<a href="/event/20201226_best1/TopPcV.jsp">
			<img class="EventBanner" src="/event/20201226_best1/poipiku_2020best1_bn.png" />
		</a>
	</li>

	<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && checkLogin.m_nUserId!=315) {%>
	<li class="EventItem">
		<a href="/MyEditSettingPcV.jsp?MENUID=POIPASS" class="EventBanner NoBgBlue" style="padding: 8px;">
			<div><img style="height: 30px;" src="/img/poipiku_passport_logo_60.png" /></div>
			<h3 style="font-weight: bold  text-align: center; font-size: 17px; line-height: 25px;">ポイパスはじめました</h3>
			<div style="line-height: 20px;">ご加入ご検討いただけますと幸いです</div>
		</a>
	</li>
	<%}%>

	<li class="EventItem">
		<a href="/UploadTextPcV.jsp">
			<img class="EventBanner" src="/img/banner_2020_10_25_text-post.png" />
		</a>
	</li>

	<li class="EventItem">
		<a href="/event/20190901/TopPcV.jsp">
			<img class="EventBanner" src="/event/20190901/banner_odai.png" />
		</a>
	</li>
</ul>

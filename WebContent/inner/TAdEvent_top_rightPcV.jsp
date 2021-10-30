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
		<a href="/NewArrivalPcV.jsp?CD=13">
			<img class="EventBanner" src="/event/20191026_halloween/banner_halloween_2021.png" />
		</a>
	</li>

<!--
	<li class="EventItem">
		<a class="EventBanner" style="padding: 5px; background: #333; color: #fff; font-family: yumincho, 游明朝, 游明朝体, yu mincho, ヒラギノ明朝 pron, hiragino mincho pron, hiraminpron-w3, hiraminpron-w6, ヒラギノ明朝 pro, hiragino mincho pro, hiraminpro-w3, hiraminpro-w6, hg明朝e, hgp明朝e, hgs明朝e, hgminchoe, hgpminchoe, hgsminchoe, hg明朝b, hgp明朝b, hgs明朝b, hgminchob, hgpminchob, hgsminchob, 平成明朝, 平成明朝 std, 平成明朝 pro, heisei mincho, heisei mincho std, heisei mincho pro, ipa明朝, ipamincho, Georgia, georgia ref, times new roman, SerifJP, serif;" href="/UploadTextPcV.jsp">
			<div style="text-align: center; font-size: 34px; font-weight: bold; line-height: 62px">縦書き10万文字</div>
			<div style="text-align: center; font-size: 16px; line-height: 20px;">小説(β)提供開始</div>
		</a>
	</li>

	<li class="EventItem">
		<a class="EventBanner NoBgRed" style="padding: 5px;" href="/NewArrivalRequestCreatorPcV.jsp">
			<div style="text-align: center; font-size: 22px; font-weight: bold; line-height: 22px">ポイパスあげると<br />ポイパスもらる！</div>
			<div style="text-align: center; font-size: 12px; line-height: 20px;">おふせ開始記念！6/30までにおふせした人全員に</div>
			<div style="text-align: center; font-size: 12px; line-height: 20px;">ポイパス1ヶ月分をプレゼント！</div>
		</a>
	</li>
-->

	<li class="EventItem">
		<a href="/event/20190901/TopPcV.jsp">
			<img class="EventBanner" src="/event/20190901/banner_odai.png" />
		</a>
	</li>
</ul>

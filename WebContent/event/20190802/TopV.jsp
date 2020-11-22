<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - PonQコラボ開催中</title>
		<style>
			.Wrapper {position: relative;}
			.SettingListItem a {color: #fff; text-decoration: underline; font-weight: bold;}
			.SettingListItem a:hover {color: #5db;}
			.AnalogicoInfo {display: none;}
			.SettingList .SettingListItem .SettingListTitle {text-align: center; font-size: 20x; font-weight: bold; margin: 20px 0 0 0;}
			.SettingList .SettingListItem {margin: 0 0 20px 0;}
			.AudioPlayer {width: 162px; height: 30px; position: absolute;}
			.MoviePlayer {width: 322px; height: 160px; position: absolute;}
			<%if(!Util.isSmartPhone(request)){%>
			.Wrapper {
				width: 360px;
				min-height: 60px;
				position: relative;
			}
			.SettingList {
				max-width: 360px;
			}
			.SettingList .SettingListItem .SettingListTitle {font-size: 24px;}
			.SettingBody {font-size: 20px;}
			<%}%>
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>

		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingBody">
					<img id="MainImage" style="width: 100%;" usemap="#MapLinks" src="/event/20190802/main-2.png" />
					<map name="MapLinks">
						<area shape="rect" coords="0, 638, 180, 683" onclick="$('html, body').animate({scrollTop:824});">
						<area shape="rect" coords="180, 638, 360, 683" onclick="$('html, body').animate({scrollTop:1145});">
						<area shape="rect" coords="0, 683 180, 733" onclick="$('html, body').animate({scrollTop:1984});">
						<area shape="rect" coords="180, 683 360, 733" onclick="$('html, body').animate({scrollTop:2619});">
						<area shape="rect" coords="0, 733 180, 783" onclick="$('html, body').animate({scrollTop:3424});">
						<area shape="rect" coords="180, 733 360, 783" onclick="$('html, body').animate({scrollTop:3745});">
						<area shape="rect" coords="0, 783 180, 823" onclick="$('html, body').animate({scrollTop:4214});">

						<area shape="circle" href="/event/20190802/godya_pro.png" coords="100, 1297, 70">
						<area shape="circle" href="/event/20190802/mashu_pro.png" coords="260, 1297, 70">
						<area shape="circle" href="/event/20190802/banhel_pro.png" coords="100, 1486, 70">
						<area shape="circle" href="/event/20190802/berial_pro.png" coords="260, 1486, 70">
						<area shape="circle" href="/event/20190802/dolce_pro.png" coords="100, 1674, 70">
						<area shape="circle" href="/event/20190802/mikan_pro.png" coords="260, 1674, 70">
						<area shape="circle" href="/event/20190802/tosaka_pro.png" coords="100, 1862, 70">

						<area shape="rect" href="/event/20190802/april_tachie.png" coords="19, 3098, 341, 3245">

						<area shape="rect" href="https://apps.apple.com/jp/app/ponq-%E3%81%BD%E3%82%93%E3%81%8D%E3%82%85%E3%83%BC/id1434815149" coords="19, 4440, 341, 4520">
						<area shape="rect" href="https://play.google.com/store/apps/details?id=jp.co.gochipon.live&hl=ja" coords="19, 4535, 341, 4615">
					</map>
				</div>
				<div class="AuidioList">
					<audio class="AudioPlayer" preload="auto" controls="controls" style="left: 20px; top: 1375px;">
						<source class="player" src="/event/20190802/mc_voice/godya.mp3" type="audio/mp3">
					</audio>
					<audio class="AudioPlayer" preload="auto" controls="controls" style="left: 190px; top: 1375px;">
						<source class="player" src="/event/20190802/mc_voice/mashu.mp3" type="audio/mp3">
					</audio>
					<audio class="AudioPlayer" preload="auto" controls="controls" style="left: 20px; top: 1563px;">
						<source class="player" src="/event/20190802/mc_voice/banhel.mp3" type="audio/mp3">
					</audio>
					<audio class="AudioPlayer" preload="auto" controls="controls" style="left: 190px; top: 1563px;">
						<source class="player" src="/event/20190802/mc_voice/berial.mp3" type="audio/mp3">
					</audio>
					<audio class="AudioPlayer" preload="auto" controls="controls" style="left: 20px; top: 1751px;">
						<source class="player" src="/event/20190802/mc_voice/dolce.mp3" type="audio/mp3">
					</audio>
					<audio class="AudioPlayer" preload="auto" controls="controls" style="left: 190px; top: 1751px;">
						<source class="player" src="/event/20190802/mc_voice/miikan.mp3" type="audio/mp3">
					</audio>
					<audio class="AudioPlayer" preload="auto" controls="controls" style="left: 20px; top: 1940px;">
						<source class="player" src="/event/20190802/mc_voice/tosaka.mp3" type="audio/mp3">
					</audio>
				</div>
				<div class="MovieList">
					<iframe class="MoviePlayer" style="left: 19px; top: 3255px;" width="322" height="160" src="https://www.youtube.com/embed/dIEvR2GQa9I" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
				</div>
			</div>
		</article>
	</body>
</html>
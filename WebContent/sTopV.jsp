<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ include file="/TopC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

TopCParam cParam = new TopCParam();
cParam.GetParam(request);

TopC cResults = new TopC();
cResults.SELECT_MAX_GALLERY = 20;
boolean bRtn = cResults.GetResults(cParam);
%>
<!DOCTYPE html>
<html style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<script type="text/javascript" src="/js/jquery.simplyscroll.min.js"></script>
		<title><%=_TEX.T("THeader.Title")%></title>

		<script>
			$(function() {
				$('#loopSlide').simplyScroll({
					autoMode : 'loop',
					speed : 1,
					frameRate : 24,
					horizontal : true,
					pauseOnHover : true,
					pauseOnTouch : true
				});
			});
		</script>
		<style>
			.simply-scroll-container {position: relative;}
			.simply-scroll-clip {position: relative; overflow: hidden;}
			.simply-scroll-list {display: block; float: left; width: 100%; list-style: none; overflow: hidden;margin: 0;padding: 0;}
			.simply-scroll-list li {display: block; float: left;}
			.simply-scroll-list li a {display: block; float: left; width: 90px; height: 90px; margin: 0 3px 0 0;}
			.simply-scroll-list li img {display: block; width: 90px; height: 90px;}
			.IllustThumb .IllustThumbImg {width: 90px; height: 90px;}
		</style>
	</head>

	<body style="margin:0; padding:0; height: 100%; color: #fff;">
		<div style="width: 100%; min-height: 100%; background-image: url('/img/pc_top_bg.jpg'); background-size: cover; background-repeat: no-repeat; background-position: center center;">
			<div style="text-align: center;">
				<img style="margin: 20% 0 15% 0;" src="/img/pc_top_title.jpg" />
			</div>
			<div style="width: 95%; margin: 0 auto 30px auto; text-align: center; font-size: 12px; text-shadow: 0 0 8px #000;">
				「ポイピク」はアナログイラストを愛する人のためのSNSアプリです。 お気に入りの作品やちょっとした落書きなど、なんでもカメラで撮って気軽に投稿してみましょう。きっとあなたのイラストの世界観を楽しみにしている人が待っています！
			</div>
			<div style="text-align: center;">
				<a href="https://itunes.apple.com/jp/app/analogico/id1074955216?mt=8" style="display:inline-block;overflow:hidden;background:url(https://linkmaker.itunes.apple.com/images/badges/en-us/badge_appstore-lrg.svg) no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; "></a>
				<a href="https://play.google.com/store/apps/details?id=jp.pipa.analogico2&utm_source=global_co&utm_medium=prtnr&utm_content=Mar2515&utm_campaign=PartBadge&pcampaignid=MKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1" style="display:inline-block;overflow:hidden; background:url('https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png') no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; background-size: 158px;"></a>
			</div>
			<div style="margin: 30px 0 0 0; padding-bottom: 50px;">
				<ul id="loopSlide">
					<%for(CContent cContent : cResults.m_vContentList) {%>
					<li>
						<a class="IllustThumb" href="/<%=cContent.m_nUserId%>/<%=cContent.m_nContentId%>.html">
							<img class="IllustThumbImg" src="<%=Common.GetUrl(cContent.m_strFileName)%>_360.jpg">
						</a>
					</li>
					<%}%>
				</ul>
			</div>
		</div>
	</body>
</html>
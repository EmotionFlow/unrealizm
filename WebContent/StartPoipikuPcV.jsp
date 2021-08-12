<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin();
String strFileUrl = "/img/poipiku_icon_512x512_2.png";
%>
<!DOCTYPE html>
<html style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<meta name="twitter:card" content="summary_large_image" />
		<meta name="twitter:site" content="@pipajp" />
		<meta property="og:url" content="https://poipiku.com/" />
		<meta property="og:title" content="<%=_TEX.T("THeader.Title")%>" />
		<meta property="og:description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<meta property="og:image" content="<%=Common.GetPoipikuUrl(strFileUrl)%>" />
		<title><%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript" src="/js/jquery.simplyscroll.min.js"></script>
		<style>
			.Wrapper {width: 100%; color: #fff; background: #fff; height: auto;}
			.Wrapper.ThumbList {width: 100%; display: flex; align-content: center; justify-content: center; background: #fff;}
			.AnalogicoDesc {display: block;width: 80%; margin: 0 auto; padding: 15px 0; box-sizing: border-box; text-align: center; font-size: 24px; color: #fff; font-weight: bold;}
			.AnalogicoDesc.Title {display: flex; flex-flow: column; align-items: center; justify-content: center;}
			.TopTitleLogo {width: 100px; height: 100px; border-radius: 30px; padding: 10px; background: #fff; box-sizing: border-box;}
			.TopTitleLogo .TopTitleLogoImg {width: 100%;}
			.TopTitleInfo {font-size: 15px; margin: 10px 0 0 0;}
			.TopTitleInfoSub {font-size: 14px; margin: 10px 0 0 0;}
			.AnalogicoLogin {margin: 0 0 10px 0;}
			.AnalogicoTerm {display: block;width: 100%; padding: 0; box-sizing: border-box; text-align: center; font-size: 13px; line-height: 28px; color: #fff; font-weight: normal; text-decoration: underline;}
			.AnalogicoStart {text-align: center; margin: 30px 0 0 0; padding: 0 0 10px 0;}
			.IllustThumb .IllustThumbImg {width: 100%; height: 100%;}
			.AnalogicoInfo {display: none;}

			.PoipikuInfo {display: flex; flex-flow: row wrap; flex: 0 0 100%; margin: 0 auto; justify-content: space-around; background-color: #fff; color: #3498db; padding: 15px 0;box-sizing: border-box;}
			.PoipikuInfoTitle {display: block; padding: 30px 0; text-align: center; font-size: 30px; font-weight: bold; flex: 1 1 100%;}
			.PoipikuInfo .PoipikuDesc {display: block; flex: 0 0 300px; padding: 20px; box-sizing: border-box; background-color: #3498db; color: #fff; margin: 15px 0;}
			.PoipikuInfo .PoipikuDesc .PoipikuDescImg {display: block; width: 100%;}
			.PoipikuInfo .PoipikuDesc .DescTitle {font-size: 17px; margin: 0 0 15px 0; font-weight: bold;}
			.PoipikuInfo .PoipikuDesc .DescTitle .DescSubTitle {font-size: 15px; font-weight: normal;}


			.poipikuDesc.TextOnly {height: auto;}
			.poipikuDesc .DescTitle {font-size: 18px; font-weight: bold;}

			.TopBanner {display: block; width: 350px; margin: 0 auto 20px auto;}
			.AnalogicoInfo.Title {display: block; padding: 10px 0;}
			.AnalogicoInfo.Flyer {display: flex; align-content: center; justify-content: center;}
			.AnalogicoInfo.Flyer.Omote {padding: 0; background-color: #232323;}
			.AnalogicoInfo.Flyer.Ura {padding: 10px 0; background-color: #fff;}
			.PoipikuFlyerImgFrame {display: flex; flex: 0 0 100%;}
			.PoipikuFlyerImgFrame .PoipikuFlyerImg {width: 100%; height: 100%;}

			<%if(Util.isSmartPhone(request)) {%>
			<%} else {%>
			.TopTitleLogo {display: inline; width: 120px; height: auto;}
			.TopTitleInfo {font-size: 22px; margin: 20px 0 0 0;}
			.TopTitleInfoSub {font-size: 14px; margin: 10px 0 0 0;}
			.AnalogicoDesc {display: block; width: 800px;}
			.TopBanner {display: block; width: 600px; margin: 0 auto 30px auto;}
			.PoipikuInfo {flex: 0 0 990px; padding: 10px 15px;}
			.PoipikuInfo .PoipikuDesc {margin: 10px 0;}
			.PoipikuInfo .PoipikuDesc.Full {flex: 0 0 620px; padding: 45px;}
			.AnalogicoInfo.Title {padding: 100px 0;}
			.AnalogicoInfo.Flyer.Ura {padding: 50px 0;}
			.PoipikuFlyerImgFrame {flex: 0 0 990px;}
			<%}%>
		</style>

		<script type="text/javascript">
		$(function(){
			//$('#MenuHome').addClass('Selected');
			if($('#login_from_twitter_tmenupc_callback_00')){
				$('#login_from_twitter_tmenupc_callback_00').val("/");
			}
			if($('#login_from_twitter_tmenupc_callback_01')){
				$('#login_from_twitter_tmenupc_callback_01').val("/");
			}
		});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<section class="AnalogicoInfo Flyer Omote">
				<div class="PoipikuFlyerImgFrame">
					<img class="PoipikuFlyerImg" src="//img.poipiku.com/img/PoipikuInfo_2020_03_07/poipiku_flyer_b8.png" />
				</div>
			</section>
			<section class="AnalogicoInfo Flyer Ura">
				<div class="PoipikuFlyerImgFrame">
					<img class="PoipikuFlyerImg" loading="lazy" src="//img.poipiku.com/img/PoipikuInfo_2020_03_07/poipiku_flyer_ura12.png" />
				</div>
			</section>
			<section class="AnalogicoInfo Title">
				<div class="AnalogicoDesc Title">
					<div>
						<img class="TopTitleLogo" loading="lazy" src="//img.poipiku.com/img/poipiku_icon_512x512_2.png" alt="<%=_TEX.T("THeader.Title")%>">
					</div>
					<h1 class="TopTitleInfo"><%=_TEX.T("THeader.Title.Desc")%></h1>
					<!--
					<h2 class="TopTitleInfoSub"><%=_TEX.T("THeader.Title.DescSub")%></h2>
					-->
				</div>
				<div class="AnalogicoInfoRegist">
					<form method="post" name="login_from_twitter_startpoipikupcv_00" action="/LoginFormTwitter.jsp">
						<input id="login_from_twitter_startpoipikupcv_callback_00" type="hidden" name="CBPATH" value="" />
						<a class="BtnBase Rev AnalogicoInfoRegistBtn LoginButton" href="javascript:login_from_twitter_startpoipikupcv_00.submit()">
							<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login")%>
						</a>
					</form>
				</div>
				<div class="AnalogicoInfoRegist">
					<a class="RegistByMainLink" href="/MyHomePcV.jsp">
						<span class="typcn typcn-mail"></span> <%=_TEX.T("Poipiku.Info.Login.Mail")%>
					</a>
				</div>
				<div class="AnalogicoStart" style="margin-top: 0;">
					<a class="AnalogicoTerm" href="/RulePcS.jsp"><%=_TEX.T("Footer.Term")%></a>
					<a class="AnalogicoTerm" href="/PrivacyPolicyPcS.jsp"><%=_TEX.T("Footer.PrivacyPolicy")%></a>
				</div>
			</section>
		</article>

		<article class="Wrapper ThumbList">
			<section class="PoipikuInfo">

				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" loading="lazy" src="//img.poipiku.com/img/PoipikuInfo_2020_03_07/iPhone01_sc_02.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" loading="lazy" src="//img.poipiku.com/img/PoipikuInfo_2020_03_07/iPhone01_sc_03.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" loading="lazy" src="//img.poipiku.com/img/PoipikuInfo_2020_03_07/iPhone01_sc_04.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" loading="lazy" src="//img.poipiku.com/img/PoipikuInfo_2020_03_07/iPhone01_sc_05.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" loading="lazy" src="//img.poipiku.com/img/PoipikuInfo_2020_03_07/iPhone01_sc_06.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" loading="lazy" src="//img.poipiku.com/img/PoipikuInfo_2020_03_07/iPhone01_sc_07.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" loading="lazy" src="//img.poipiku.com/img/PoipikuInfo_2020_03_07/iPhone01_sc_08.png" />
				</div>

				<div class="PoipikuDesc Full">
					<div class="DescTitle">
						<%=_TEX.T("StartPoipiku.Desc01.Title")%>
						<div class="DescSubTitle">
							<%=_TEX.T("StartPoipiku.Desc01.TitleSub")%>
						</div>
					</div>
					<div class="DescTitle">
						<%=_TEX.T("StartPoipiku.Desc02.Title")%>
						<div class="DescSubTitle">
							<%=_TEX.T("StartPoipiku.Desc02.TitleSub")%>
						</div>
					</div>
					<div class="DescTitle">
						<%=_TEX.T("StartPoipiku.Desc03.Title")%>
						<div class="DescSubTitle">
							<%=_TEX.T("StartPoipiku.Desc03.TitleSub")%>
						</div>
					</div>
					<div class="DescTitle">
						<%=_TEX.T("StartPoipiku.Desc04.Title")%>
						<div class="DescSubTitle">
							<%=_TEX.T("StartPoipiku.Desc04.TitleSub")%>
						</div>
					</div>
				</div>
			</section>
		</article>

		<article class="Wrapper">
			<section class="AnalogicoInfo" style="display: block; padding: 100px 0;">
				<div class="AnalogicoDesc Title">
						<%=_TEX.T("StartPoipiku.LetsStart")%>
				</div>
				<div class="AnalogicoInfoRegist">
					<a class="BtnBase Rev AnalogicoInfoRegistBtn LoginButton" href="/LoginFormTwitter.jsp?CBPATH=">
						<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login")%>
					</a>
				</div>
				<div class="AnalogicoInfoRegist">
					<a class="RegistByMainLink" href="/MyHomePcV.jsp">
						<span class="typcn typcn-mail"></span> <%=_TEX.T("Poipiku.Info.Login.Mail")%>
					</a>
				</div>
				<div class="AnalogicoStart" style="margin-top: 0;">
					<a class="AnalogicoTerm" href="/RulePcS.jsp"><%=_TEX.T("Footer.Term")%></a>
					<a class="AnalogicoTerm" href="/PrivacyPolicyPcS.jsp"><%=_TEX.T("Footer.PrivacyPolicy")%></a>
				</div>
			</section>
		</article>
		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>

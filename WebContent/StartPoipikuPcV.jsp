<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
String strFileUrl = "/img/PoipikuInfo_2019_01_12/SS01.png";
%>
<!DOCTYPE html>
<html style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<meta name="twitter:card" content="summary_large_image" />
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:title" content="<%=_TEX.T("THeader.Title")%>" />
		<meta name="twitter:description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<meta name="twitter:image" content="<%=Common.GetPoipikuUrl(strFileUrl)%>" />
		<meta property="og:type" content="article" />
		<meta property="og:url" content="https://poipiku.com/StartPoipikuPcV.jsp" />
		<meta property="og:title" content="<%=_TEX.T("THeader.Title")%>" />
		<meta property="og:description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<meta property="og:image" content="<%=Common.GetPoipikuUrl(strFileUrl)%>" />
		<title><%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript" src="/js/jquery.simplyscroll.min.js"></script>
		<style>
			.Wrapper {width: 100%; color: #fff; background: #5bd; height: auto;}
			.AnalogicoDesc {display: block;width: 80%; margin: 0 auto; padding: 15px 0; box-sizing: border-box; text-align: center; font-size: 24px; color: #fff; font-weight: bold;}
			.TopTitleLogo {display: inline; width: auto; height: 28px;}
			.TopTitleInfo {font-size: 15px; margin: 10px 0 0 0;}
			.TopTitleInfoSub {font-size: 14px; margin: 10px 0 0 0;}
			.AnalogicoLogin {margin: 0 0 10px 0;}
			.AnalogicoTerm {display: block;width: 100%; padding: 0; box-sizing: border-box; text-align: center; font-size: 13px; line-height: 28px; color: #fff; font-weight: normal; text-decoration: underline;}
			.AnalogicoStart {text-align: center; margin: 30px 0 0 0; padding: 0 0 10px 0;}
			.IllustThumb .IllustThumbImg {width: 100%; height: 100%;}
			.AnalogicoInfo {display: none;}

			.PoipikuInfo {display: flex; flex-flow: row wrap; width: 100%; margin: 0 auto; justify-content: space-around; background-color: #b8d6e0; color: #5bd;padding: 15px 0;box-sizing: border-box;}
			.PoipikuInfoTitle {display: block; padding: 30px 0; text-align: center; font-size: 30px; font-weight: bold; flex: 1 1 100%;}
			.PoipikuInfo .PoipikuDesc {display: block; flex: 0 0 300px; padding: 20px; box-sizing: border-box; background-color: #5bd; color: #fff; margin: 15px 0;}
			.PoipikuInfo .PoipikuDesc .PoipikuDescImg {display: block; width: 100%;}
			.PoipikuInfo .PoipikuDesc .DescTitle {font-size: 17px; margin: 0 0 15px 0; font-weight: bold;}
			.PoipikuInfo .PoipikuDesc .DescTitle .DescSubTitle {font-size: 15px; font-weight: normal;}


			.poipikuDesc.TextOnly {height: auto;}
			.poipikuDesc .DescTitle {font-size: 18px; font-weight: bold;}

			.TopBanner {display: block; width: 350px; margin: 0 auto 20px auto;}

			<%if(Util.isSmartPhone(request)) {%>
			<%} else {%>
			.TopTitleLogo {display: inline; width: 120px; height: auto;}
			.TopTitleInfo {font-size: 22px; margin: 20px 0 0 0;}
			.TopTitleInfoSub {font-size: 14px; margin: 10px 0 0 0;}
			.AnalogicoDesc {display: block; width: 800px;}
			.TopBanner {display: block; width: 600px; margin: 0 auto 30px auto;}
			.PoipikuInfo {padding: 10px 15px;}
			.PoipikuInfo .PoipikuDesc {margin: 10px 0;}
			.PoipikuInfo .PoipikuDesc.Full {flex: 0 0 620px; padding: 45px;}
			<%}%>
		</style>

		<script type="text/javascript">
		$(function(){
			//$('#MenuHome').addClass('Selected');
		});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<section class="AnalogicoInfo" style="display: block;">
				<div class="AnalogicoDesc Title">
					<div style="margin : 0;">
						<img class="TopTitleLogo" src="/img/pc_top_title_W.jpg" alt="<%=_TEX.T("THeader.Title")%>">
					</div>
					<h1 class="TopTitleInfo"><%=_TEX.T("THeader.Title.Desc")%></h1>
					<h2 class="TopTitleInfoSub"><%=_TEX.T("THeader.Title.DescSub")%></h2>
				</div>
				<div class="AnalogicoInfoRegist">
					<a class="BtnBase Rev AnalogicoInfoRegistBtn" href="/LoginFormTwitterPc.jsp">
						<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login")%>
					</a>
				</div>
				<div class="AnalogicoInfoRegist">
					<a class="BtnBase Rev AnalogicoInfoRegistBtn" href="/MyHomePcV.jsp">
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
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2019_01_12/SS01.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2019_01_12/SS02.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2019_01_12/SS03.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2019_01_12/SS04.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2019_01_12/SS05.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2019_01_12/SS06.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2019_01_12/SS07.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2019_01_12/SS08.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2019_01_12/SS09.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2019_01_12/SS10.png" />
				</div>

				<div class="PoipikuDesc Full">
					<div class="DescTitle">
						転載対策もOK！
						<div class="DescSubTitle">
							転載禁止表示と右クリック禁止対策
						</div>
					</div>
					<div class="DescTitle">
						動くイラストもOK！
						<div class="DescSubTitle">
							アニメーションGIFにもフル対応
						</div>
					</div>
					<div class="DescTitle">
						ポイピクの活動を定期ツイート！
						<div class="DescSubTitle">
							週1回もしくは毎日の指定時間に定期ツイート ＆ 古い定期ツイート自動削除でTwitterの画像一覧が埋まらない
						</div>
					</div>
					<div class="DescTitle">
						イラストSNS11年の運営実績
						<div class="DescSubTitle">
							2007年から手書きブログを開始し、イラストSNS運営実績は11年。
							安心してご利用ください。
						</div>
					</div>
				</div>
			</section>
		</article>

		<article class="Wrapper">
			<section class="AnalogicoInfo" style="display: block;">
				<div class="AnalogicoDesc Title">
						さあ、はじめよう！
				</div>
				<div class="AnalogicoInfoRegist">
					<a class="BtnBase Rev AnalogicoInfoRegistBtn" href="/LoginFormTwitterPc.jsp">
						<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login")%>
					</a>
				</div>
				<div class="AnalogicoInfoRegist">
					<a class="BtnBase Rev AnalogicoInfoRegistBtn" href="/MyHomePcV.jsp">
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
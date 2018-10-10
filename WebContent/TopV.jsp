<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(cCheckLogin.m_bLogin) {
	response.sendRedirect("/MyHomePcV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript" src="/js/jquery.simplyscroll.min.js"></script>
		<style>
			body {padding-top: 83px !important;}

			.Wrapper {width: 100%; color: #fff; background: #5bd; height: auto;}
			.AnalogicoDesc {display: block;width: 100%; padding: 30px 0 0 0; box-sizing: border-box; text-align: center; font-size: 16px; line-height: 28px; color: #fff; font-weight: normal;}
			.AnalogicoLogin {margin: 0 0 10px 0;}
			.AnalogicoTerm {display: block;width: 100%; padding: 0; box-sizing: border-box; text-align: center; font-size: 13px; line-height: 28px; color: #fff; font-weight: normal; text-decoration: underline;}
			.AnalogicoStart {text-align: center; margin: 30px 0 0 0; padding: 0 0 30px 0;}
			.IllustThumb .IllustThumbImg {width: 100%; height: 100%;}
			.AnalogicoInfo {display: none;}
			.FooterAd {display: none;}

			.PoipikuInfo {display: flex; flex-flow: row wrap; width: 100%; margin: 0 auto; justify-content: space-around; background-color: #fafafa; color: #5bd;padding: 15px 0;}
			.PoipikuInfoTitle {display: block; padding: 30px 0; text-align: center; font-size: 30px; font-weight: bold; flex: 1 1 100%;}
			.PoipikuInfo .PoipikuDesc {display: block; flex: 0 0 300px; padding: 20px; box-sizing: border-box; background-color: #5bd; color: #fff; margin: 15px 0;}
			.PoipikuInfo .PoipikuDesc .PoipikuDescImg {display: block; width: 100%;}
			.PoipikuInfo .PoipikuDesc .DescTitle {font-size: 18px; margin: 0 0 15px 0; font-weight: bold;}
			.PoipikuInfo .PoipikuDesc .DescTitle .DescSubTitle {font-size: 16px; font-weight: normal;}


			.poipikuDesc.TextOnly {height: auto;}
			.poipikuDesc .DescTitle {font-size: 18px; font-weight: bold;}

			.TopBanner {display: block; width: 350px; margin: 0 auto 20px auto;}

			<%if(Util.isSmartPhone(request)) {%>
			<%} else {%>
			.TopBanner {display: block; width: 600px; margin: 0 auto 30px auto;}
			<%}%>
		</style>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>
	</head>

	<body>
		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem Selected" href="/"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
				<a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
				<a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
				<a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
			<h1 class="AnalogicoDesc Title">
				<div class="TopBanner">
					<img style="width: 100%;" src="/img/2018_09_30_top_banner.png" />
				</div>
				放置絵ポイポイ<br />
				練習ポイポイ<br />
				らくがきポイポイ<br />
				進捗ポイポイ<br />
				<br />
				イラストポイポイSNS「ポイピク」
			</h1>
			<div class="AnalogicoStart">
				<a class="BtnBase Rev AnalogicoLogin" href="/LoginFormTwitterPc.jsp">
					<span class="typcn typcn-social-twitter"></span> Twitterで新規登録/ログイン
				</a>
				<a class="AnalogicoTerm" href="/RulePcS.jsp"><%=_TEX.T("Footer.Term")%></a>
				<a class="AnalogicoTerm" href="/GuideLinePcV.jsp"><%=_TEX.T("Footer.GuideLine")%></a>
				<a class="AnalogicoTerm" href="/PrivacyPolicyPcS.jsp"><%=_TEX.T("Footer.PrivacyPolicy")%></a>

				<div class="LinkApp" style="float: none;">
					<a href="https://itunes.apple.com/us/app/ポイピク/id1436433822?l=ja&ls=1&mt=8" target="_blank" style="display:inline-block;overflow:hidden;background:url(https://linkmaker.itunes.apple.com/images/badges/en-us/badge_appstore-lrg.svg) no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; "></a>
					<a href="https://play.google.com/store/apps/details?id=jp.pipa.poipiku" target="_blank" style="display:inline-block;overflow:hidden; background:url('https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png') no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; background-size: 158px;"></a>
				</div>
			</div>
		</div>



		<div class="Wrapper ThumbList">
			<div class="PoipikuInfo">
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo/SS01.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo/SS02.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo/SS03.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo/SS03-2.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo/SS04.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo/SS05.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo/SS06.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo/SS07.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo/SS08.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo/SS09.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo/SS10.png" />
				</div>

				<div class="PoipikuDesc">
					<div class="DescTitle">
						転載対策もOK！
						<div class="DescSubTitle">
							転載禁止表示と右クリック禁止対策済み
						</div>
					</div>
					<div class="DescTitle">
						動くイラストもOK！
						<div class="DescSubTitle">
							アニメーションGIFにもフル規格で対応。フレームレートが途中で変わるような特殊なGIFも大丈夫
						</div>
					</div>
					<div class="DescTitle">
						ポイピクの活動をTwitterで定期お知らせ！
						<div class="DescSubTitle">
							週1回もしくは毎日の時間指定で定期ツイートできる ＆ 古い定期ツイートを自動削除するからTwitterの画像一覧が定期ツイートで埋まらない
						</div>
					</div>
					<div class="DescTitle">
						表示が速い！
						<div class="DescSubTitle">
							月間2億PVを支える手書きブログのテクノロジを投入。独自の高速プラットフォームで可能な限りサーバ側で処理して端末に負荷をかけないから、古いスマホやPCでも高速表示
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="Wrapper">
			<div class="AnalogicoDesc Title">
					さあ、はじめよう！
			</div>
			<div class="AnalogicoStart" style="margin-top: 0; padding-top: 30px;">
				<a class="BtnBase Rev AnalogicoLogin" href="/LoginFormTwitterPc.jsp">
					<span class="typcn typcn-social-twitter"></span> Twitterで新規登録/ログイン
				</a>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
IllustViewPcC results = new IllustViewPcC();
results.selectMaxGallery = 6;
results.getParam(request);

if(!results.getResults(checkLogin)) {
	if (results.m_bBlocked || results.m_bBlocking) {
		response.sendRedirect(String.format("/%d/", results.ownerUserId));
	} else if (results.m_nNewContentId==null || results.m_nNewContentId==results.contentId) {
		response.sendRedirect("/NotFoundPcV.jsp");
	} else {
		response.sendRedirect(Common.GetUnrealizmUrl(String.format("/%d/%d.html", results.ownerUserId, results.m_nNewContentId)));
	}
	return;
}

if(results.m_cContent.m_nPublishId!=Common.PUBLISH_ID_ALL && Util.isBot(request)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

boolean isApp = false;
ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

// R18によるアドの切り替え
g_nSafeFilter = results.m_cContent.getAdSwitchId();

results.m_cContent.setThumb();
final String strFileUrl = results.m_cContent.thumbImgUrl;
final boolean bHidden = results.m_cContent.isHideThumbImg;	// テキスト用カバー画像表示フラグ

String strDesc = Util.deleteCrLf(results.m_cContent.title);
strDesc = (strDesc.isEmpty())?Util.deleteCrLf(results.m_cContent.m_strDescription):strDesc;
String strTitle = CTweet.generateState(results.m_cContent, _TEX) +  CTweet.generateFileNum(results.m_cContent, _TEX) + " " + Util.subStrNum(strDesc, 15) + " " + String.format(_TEX.T("Tweet.Title"), results.m_cContent.m_cUser.m_strNickName) + " | " + _TEX.T("THeader.Title");;
String strUrl = "https://unrealizm.com/"+results.m_cContent.m_nUserId+"/"+results.m_cContent.m_nContentId+".html";
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
g_bShowAd = (results.m_cUser.m_nPassportId==Common.PASSPORT_OFF || results.m_cUser.m_nAdMode==CUser.AD_MODE_SHOW);

if (results.m_bRequestClient) {
	results.m_cContent.setRequestImgThumb();
}

//ツイッターカード用:作者の言語でツイッターカードを作るためのResourceBundleControl
ResourceBundleControl _TEX_TWEET = new ResourceBundleControl(SupportedLocales.findLocale(CacheUsers0000.getInstance().getUser(results.m_cContent.m_nUserId).langId));

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%@ include file="/inner/ad/TAdIllustViewPcHeader.jsp"%>
		<%@ include file="/inner/TCreditCard.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<%@ include file="/inner/TReplyEmoji.jsp"%>
		<%@ include file="/inner/TSendGift.jsp"%>
		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<%if(results.m_cContent.isTwitterCardThumbnail()){%>
		<meta name="twitter:card" content="summary_large_image" />
		<meta name="twitter:image" content="<%="https://img.unrealizm.com" + strFileUrl%>" />
		<%}else{%>
		<meta name="twitter:card" content="summary" />
		<meta name="twitter:image" content="https://img.unrealizm.com/img/icon-512x512.png" />
		<%}%>
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:title" content="<%=CTweet.generateMetaTwitterTitle(results.m_cContent, _TEX_TWEET)%>" />
		<meta name="twitter:description" content="<%=CTweet.generateMetaTwitterDesc(results.m_cContent, _TEX_TWEET)%>" />
		<link rel="canonical" href="<%=strUrl%>" />
		<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />
		<title><%=Util.toDescString(strTitle)%></title>
		<script type="application/ld+json">
		{
			"@context":"http://schema.org",
			"@type":"ItemList",
			"itemListElement":[
				{"@type":"ListItem", "position":1, "url":"<%=strUrl%>",
				 "name": "<%=Util.toDescString(strTitle)%>",
				 <%if(results.m_cContent.isTweetWithThumbnail()){%>
				 "image": "<%="https://img.unrealizm.com" + strFileUrl%>"
				 <%}else{%>
				 "image": "https://unrealizm.com/img/icon-512x512.png"
				 <%}%>
				}
			]
		}
		</script>

		<script type="text/javascript">
			$(function(){
				$('#MenuNew').addClass('Selected');
				$(document).on('click', '.PrivateIcon', (ev) => {
					DispMsg("<%=_TEX.T("IllustView.IconMsg.Private")%>");
				});
				$(document).on('click', '.OutOfPeriodIcon', (ev) => {
					DispMsg("<%=_TEX.T("IllustView.IconMsg.OutOfPeriod")%>");
				});
			});
		</script>

		<%@ include file="/inner/TDeleteContent.jsp"%>
		<%@ include file="/inner/TDispRequestTextDlg.jsp"%>
		<%@ include file="/inner/TRetweetContent.jsp"%>
		<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>
		<script type="text/javascript">
			$(function(){
				<%if(!results.m_bOwner){%>
				$('body, .Wrapper').each(function(index, element){
					$(element).on("drag dragstart",function(e){return false;});
				});
				<%}%>
				$("#AnalogicoInfo .AnalogicoInfoSubTitle").html('<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(results.m_cUser.m_strNickName), results.m_nContentsNumTotal)%>');
				<%if(!Util.isSmartPhone(request)) {%>
				$("#AnalogicoInfo .AnalogicoMoreInfo").html('<%=_TEX.T("Unrealizm.Info.RegistNow")%>');
				<%}%>

				<%if(!bHidden && results.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {%>
				var frame_height = $('#IllustItemText_'+ <%=results.m_cContent.m_nContentId%> ).height();
				var text_height = $('#IllustItemText_'+ <%=results.m_cContent.m_nContentId%> + ' .IllustItemThumbText').height();
				if(frame_height>=text_height) {
					$('.IllustItemExpandBtn').hide();
				}
				<%}%>
			});
		</script>
		<style>
            .RelatedItemList {
                display: flex;
                margin: 0 0 7px 0;
                box-sizing: border-box;
                width: 600px;
                flex-direction: row;
                flex-wrap: wrap;
			}
			.Wrapper.ViewPc {justify-content: center; margin: 20px 0 0 0;}
			.Wrapper.ViewPc .PcSideBar .FixFrame {position: sticky; top: 81px;}
			.Wrapper.ViewPc .PcSideBar .PcSideBarItem:last-child {position: static;}
			.IllustItem.Password .IllustItemThumb {min-height: 240px;}
			.Wrapper.ViewPc .IllustItemList.Related {width: 100%; flex: 0 0 100%;}
			<%if(!results.m_cUser.m_strHeaderFileName.isEmpty()){%>
			.UserInfo {background-image: url('<%=Common.GetUrl(results.m_cUser.m_strHeaderFileName)%>');}
			<%}%>

		</style>

		<%if(results.m_cUser.m_nPassportId>=Common.PASSPORT_ON && !results.m_cUser.m_strBgFileName.isEmpty()) {%>
		<style>
			body {
				background-image: url('<%=Common.GetUrl(results.m_cUser.m_strBgFileName)%>');
				background-repeat: repeat;
				background-position: 50% top;
				background-attachment: fixed;
			}
		</style>
		<%}%>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper" style="width: 100%;">
			<div class="UserInfo">
				<%@ include file="inner/IllustVBlockButton.jsp"%>
				<div class="UserInfoBg"></div>
				<section class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(results.m_cUser.m_strFileName)%>')" href="/<%=results.m_cUser.m_nUserId%>/"></a>
					<h2 class="UserInfoUserName"><a href="/<%=results.m_cUser.m_nUserId%>/"><%=results.m_cUser.m_strNickName%></a></h2>
					<%if(!results.m_cUser.m_strProfile.isEmpty()) {%>
					<%if(results.twitterScreenName != null && !results.twitterScreenName.isEmpty()) {%>
					<h3 class="UserInfoProfile"><a class="fab fa-twitter" target="_blank" href="https://twitter.com/<%=results.twitterScreenName%>">@<%=results.twitterScreenName%></a></h3>
					<%}%>
					<h3 class="UserInfoProfile"><%=Common.AutoLink(Util.toStringHtml(results.m_cUser.m_strProfile), results.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
					<%}%>
					<span class="UserInfoCmd">
						<%
						String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
								URLEncoder.encode(String.format("%s%s %s #%s",
										results.m_cUser.m_strNickName,
										_TEX.T("Twitter.UserAddition"),
										String.format(_TEX.T("Twitter.UserPostNum"), results.m_nContentsNumTotal),
										_TEX.T("Common.HashTag")), "UTF-8"),
								URLEncoder.encode("https://unrealizm.com/"+results.m_cUser.m_nUserId+"/", "UTF-8"));
						%>
						<%if(!checkLogin.m_bLogin) {%>
						<a class="BtnBase UserInfoCmdFollow" href="/"><%=_TEX.T("IllustV.Follow")%></a>
						<%} else if(results.m_bOwner) {
							// 何も表示しない
						} else if(results.m_bBlocking){%>
						<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=results.m_cUser.m_nUserId%>" style="display: none;" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=results.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<%} else if(results.m_bBlocked){%>
						<%} else if(results.m_bFollow){%>
						<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=results.m_cUser.m_nUserId%> Selected" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=results.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Following")%></span>
						<%} else {%>
						<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=results.m_cUser.m_nUserId%>" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=results.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<%}%>

						<%@ include file="inner/IllustBrowserVRequestButton.jsp"%>
						<%@include file="inner/IllustBrowserVGiftButton.jsp"%>

						<span class="IllustItemCommandSub">
							<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>" target="_blank"></a>
						</span>
					</span>

					<%@ include file="/inner/TWaveButtons.jsp"%>

				</section>
				<section class="UserInfoState">
					<%@include file="inner/IllustBrowserVUserInfoState.jsp"%>
				</section>
			</div>
		</article>

		<article class="Wrapper ViewPc GridList">
			<section id="IllustItemList" class="IllustItemList">
				<%= CCnv.Content2Html(
						results.m_cContent, checkLogin, CCnv.MODE_PC, _TEX,
						vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_WVIEW,
						results.m_bOwner?CCnv.PageCategory.MY_ILLUST_LIST:CCnv.PageCategory.DEFAULT)%>

				<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd && false) {%>
				<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%;">
					<%@ include file="/inner/ad/TAdGridPc336x280_mid_1.jsp"%>
				</span>
				<%}%>
			</section>
		</article>

		<article class="Wrapper GridList">
			<section id="IllustThumbList" class="IllustItemList2Column">
				<%for(CContent cContent: results.contentList) {%>
					<%=CCnv.Content2Html2Column(cContent, checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
				<%}%>

				<%if(!results.m_vRelatedContentList.isEmpty()) {%>
				<h2 class="IllustItemListRelatedTitle"><%=_TEX.T("IllustV.Related")%></h2>
					<%for(CContent cContent: results.m_vRelatedContentList) {%>
						<%=CCnv.Content2Html2Column(cContent, checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
					<%}%>
				<%}%>

				<%if (results.m_vRecommendedList.size() > 0) {%>
				<h2 class="IllustItemListRelatedTitle"><%=_TEX.T("IllustV.Recommended")%></h2>
					<%for(CContent cContent: results.m_vRecommendedList) {%>
						<%=CCnv.Content2Html2Column(cContent, checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
					<%}%>
				<%}%>

				<!--
				<nav class="PageBar">
					<%//if(bSmartPhone) {%>
					<%//=CPageBar.CreatePageBarSp("/IllustViewPcV.jsp", String.format("&ID=%d&TD=%d", results.m_nUserId, results.m_nContentId), results.m_nPage, results.m_nContentsNum, results.SELECT_MAX_GALLERY)%>
					<%//}else{%>
					<%//=CPageBar.CreatePageBarPc("/IllustViewPcV.jsp", String.format("&ID=%d&TD=%d", results.m_nUserId, results.m_nContentId), results.m_nPage, results.m_nContentsNum, results.SELECT_MAX_GALLERY)%>
					<%//}%>
				</nav>
				-->
			</section>
		</article>

		<%@ include file="/inner/TShowDetail.jsp"%>
		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>

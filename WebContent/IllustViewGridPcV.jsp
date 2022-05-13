<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
IllustViewPcC cResults = new IllustViewPcC();
cResults.selectMaxGallery = 6;
cResults.getParam(request);

if(!cResults.getResults(checkLogin)) {
	if (cResults.m_bBlocked || cResults.m_bBlocking) {
		response.sendRedirect(String.format("/%d/", cResults.ownerUserId));
	} else if (cResults.m_nNewContentId==null || cResults.m_nNewContentId==cResults.contentId) {
		response.sendRedirect("/NotFoundPcV.jsp");
	} else {
		response.sendRedirect(Common.GetPoipikuUrl(String.format("/%d/%d.html", cResults.ownerUserId, cResults.m_nNewContentId)));
	}
	return;
}

if(cResults.m_cContent.m_nPublishId!=Common.PUBLISH_ID_ALL && Util.isBot(request)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

boolean isApp = false;

// R18によるアドの切り替え
switch(cResults.m_cContent.m_nPublishId) {
case Common.PUBLISH_ID_R18:
case Common.PUBLISH_ID_R18G:
	g_nSafeFilter = Common.AD_ID_R18;
	break;
default:
	g_nSafeFilter = Common.AD_ID_ALL;
	break;
}

String strFileUrl = "";
boolean bHidden = false;	// テキスト用カバー画像表示フラグ
switch(cResults.m_cContent.m_nPublishId) {
	case Common.PUBLISH_ID_R15:
	case Common.PUBLISH_ID_R18:
	case Common.PUBLISH_ID_R18G:
	case Common.PUBLISH_ID_PASS:
	case Common.PUBLISH_ID_LOGIN:
	case Common.PUBLISH_ID_FOLLOWER:
	case Common.PUBLISH_ID_T_FOLLOWER:
	case Common.PUBLISH_ID_T_FOLLOWEE:
	case Common.PUBLISH_ID_T_EACH:
	case Common.PUBLISH_ID_T_LIST:
		if (cResults.m_cContent.publishAllNum == 0) {
			strFileUrl = Common.PUBLISH_ID_FILE[cResults.m_cContent.m_nPublishId];
			bHidden = true;
		} else {
			strFileUrl = cResults.m_cContent.m_strFileName + "_640.jpg";
			bHidden = false;
		}
		break;
	case Common.PUBLISH_ID_HIDDEN:
		strFileUrl="/img/poipiku_icon_512x512_2.png";
		break;
	case Common.PUBLISH_ID_ALL:
	default:
		if (cResults.m_cContent.m_strFileName.isEmpty()) {
			strFileUrl = "/img/poipiku_icon_512x512_2.png";
		} else {
			strFileUrl = cResults.m_cContent.m_strFileName + "_640.jpg";
		}
		break;
}


String strDesc = Util.deleteCrLf(cResults.m_cContent.title);
strDesc = (strDesc.isEmpty())?Util.deleteCrLf(cResults.m_cContent.m_strDescription):strDesc;
String strTitle = CTweet.generateState(cResults.m_cContent, _TEX) +  CTweet.generateFileNum(cResults.m_cContent, _TEX) + " " + Util.subStrNum(strDesc, 15) + " " + String.format(_TEX.T("Tweet.Title"), cResults.m_cContent.m_cUser.m_strNickName) + " | " + _TEX.T("THeader.Title");;
String strUrl = "https://poipiku.com/"+cResults.m_cContent.m_nUserId+"/"+cResults.m_cContent.m_nContentId+".html";
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
g_bShowAd = (cResults.m_cUser.m_nPassportId==Common.PASSPORT_OFF || cResults.m_cUser.m_nAdMode==CUser.AD_MODE_SHOW);

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
		<%if(cResults.m_cContent.isTwitterCardThumbnail()){%>
		<meta name="twitter:card" content="summary_large_image" />
		<%}else{%>
		<meta name="twitter:card" content="summary" />
		<%}%>
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:title" content="<%=CTweet.generateMetaTwitterTitle(cResults.m_cContent, _TEX)%>" />
		<meta name="twitter:description" content="<%=CTweet.generateMetaTwitterDesc(cResults.m_cContent, _TEX)%>" />
		<%if(cResults.m_cContent.isTwitterCardThumbnail()){%>
		<meta name="twitter:image" content="<%="https://img.poipiku.com" + strFileUrl%>" />
		<%}else{%>
		<meta name="twitter:image" content="https://img.poipiku.com/img/poipiku_icon_512x512_2.png" />
		<%}%>
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
				 <%if(cResults.m_cContent.isTweetWithThumbnail()){%>
				 "image": "<%="https://img.poipiku.com" + strFileUrl%>"
				 <%}else{%>
				 "image": "https://poipiku.com/img/poipiku_icon_512x512_2.png"
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
				<%if(!cResults.m_bOwner){%>
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
				<%}%>
				$("#AnalogicoInfo .AnalogicoInfoSubTitle").html('<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal)%>');
				<%if(!Util.isSmartPhone(request)) {%>
				$("#AnalogicoInfo .AnalogicoMoreInfo").html('<%=_TEX.T("Poipiku.Info.RegistNow")%>');
				<%}%>

				<%if(!bHidden && cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {%>
				var frame_height = $('#IllustItemText_'+ <%=cResults.m_cContent.m_nContentId%> ).height();
				var text_height = $('#IllustItemText_'+ <%=cResults.m_cContent.m_nContentId%> + ' .IllustItemThumbText').height();
				if(frame_height>=text_height) {
					$('.IllustItemExpandBtn').hide();
				}
				<%}%>
			});
		</script>
		<style>
			.RelatedItemList {display: block; margin: 0 15px 15px 15px; box-sizing: border-box; float: left;}
			.Wrapper.ViewPc {flex-flow: row-reverse wrap;}
			.Wrapper.ViewPc .PcSideBar .FixFrame {position: sticky; top: 81px;}
			.Wrapper.ViewPc .PcSideBar .PcSideBarItem:last-child {position: static;}
			.IllustItem.Password .IllustItemThumb {min-height: 240px;}
			.Wrapper.ViewPc .IllustItemList.Related {width: 100%; flex: 0 0 100%;}
			<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
			.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
			<%}%>

		</style>

		<%if(cResults.m_cUser.m_nPassportId>=Common.PASSPORT_ON && !cResults.m_cUser.m_strBgFileName.isEmpty()) {%>
		<style>
			body {
				background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strBgFileName)%>');
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
			<div class="UserInfo Float">
				<%@ include file="inner/IllustVBlockButton.jsp"%>
				<div class="UserInfoBg"></div>
				<section class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
					<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>
					<%if(!cResults.m_cUser.m_strProfile.isEmpty()) {%>
					<%if(cResults.twitterScreenName != null && !cResults.twitterScreenName.isEmpty()) {%>
					<h3 class="UserInfoProfile"><a class="fab fa-twitter" target="_blank" href="https://twitter.com/<%=cResults.twitterScreenName%>">@<%=cResults.twitterScreenName%></a></h3>
					<%}%>
					<h3 class="UserInfoProfile"><%=Common.AutoLink(Util.toStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
					<%}%>
					<span class="UserInfoCmd">
						<%
						String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
								URLEncoder.encode(String.format("%s%s %s #%s",
										cResults.m_cUser.m_strNickName,
										_TEX.T("Twitter.UserAddition"),
										String.format(_TEX.T("Twitter.UserPostNum"), cResults.m_nContentsNumTotal),
										_TEX.T("Common.HashTag")), "UTF-8"),
								URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8"));
						%>
						<%if(!checkLogin.m_bLogin) {%>
						<a class="BtnBase UserInfoCmdFollow" href="/"><%=_TEX.T("IllustV.Follow")%></a>
						<%} else if(cResults.m_bOwner) {
							// 何も表示しない
						} else if(cResults.m_bBlocking){%>
						<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" style="display: none;" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<%} else if(cResults.m_bBlocked){%>
						<%} else if(cResults.m_bFollow){%>
						<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%> Selected" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Following")%></span>
						<%} else {%>
						<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
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

			<aside class="PcSideBar" style="margin-top: 30px;">
				<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
				<div class="PcSideBarItem">
					<%@ include file="/inner/ad/TAdHomePc300x250_top_right.jsp"%>
				</div>
				<%}%>

				<div class="PcSideBarItem">
					<%@ include file="/inner/TAdEvent_top_rightPcV.jsp"%>
				</div>

				<div class="FixFrame">
					<div class="PcSideBarItem">
						<div class="UserInfo" style="border: none;">
							<div class="UserInfoBgImg"></div>
							<div class="UserInfoBg"></div>
							<div class="UserInfoUser">
								<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
								<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>
								<h3 class="UserInfoProfile"><%=Common.AutoLink(Util.toStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
								<span class="UserInfoCmd">
									<%if(!checkLogin.m_bLogin) {%>
									<a class="BtnBase UserInfoCmdFollow" href="/"><%=_TEX.T("IllustV.Follow")%></a>
									<%} else if(cResults.m_bOwner) {%>
									<%} else if(cResults.m_bBlocking){%>
									<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock Selected" onclick="UpdateBlock()"></span>
									<%} else if(cResults.m_bBlocked){%>
									<%} else if(cResults.m_bFollow){%>
									<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%> Selected" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Following")%></span>
									<%} else {%>
									<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
									<%}%>
								</span>
							</div>
						</div>
					</div>

					<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
					<div class="PcSideBarItem">
						<%@ include file="/inner/ad/TAdHomePc300x600_bottom_right.jsp"%>
					</div>
					<%}%>
				</div>
			</aside>

			<section id="IllustItemList" class="IllustItemList">
				<%= CCnv.Content2Html(
						cResults.m_cContent, checkLogin, CCnv.MODE_PC, _TEX,
						vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_WVIEW,
						cResults.m_bOwner?CCnv.PageCategory.MY_ILLUST_LIST:CCnv.PageCategory.DEFAULT)%>

				<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
				<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%;">
					<%@ include file="/inner/ad/TAdGridPc336x280_mid_1.jsp"%>
				</span>
				<%}%>

				<div class="RelatedItemList">
					<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
						CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
					<%
						}
					%>
				</div>

				<%if(!cResults.m_vRelatedContentList.isEmpty()) {%>
				<h2 class="IllustItemListRelatedTitle"><%=_TEX.T("IllustV.Related")%></h2>
				<div class="RelatedItemList">
					<%for(CContent cContent: cResults.m_vRelatedContentList) {%>
						<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
					<%}%>
				</div>
				<%}%>

				<%if (cResults.m_vRecommendedList.size() > 0) {%>
				<h2 class="IllustItemListRelatedTitle"><%=_TEX.T("IllustV.Recommended")%></h2>
				<div class="RelatedItemList">
						<%for(CContent cContent: cResults.m_vRecommendedList) {%>
						<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
						<%}%>
				</div>
				<%}%>

				<!--
				<nav class="PageBar">
					<%//if(bSmartPhone) {%>
					<%//=CPageBar.CreatePageBarSp("/IllustViewPcV.jsp", String.format("&ID=%d&TD=%d", cResults.m_nUserId, cResults.m_nContentId), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
					<%//}else{%>
					<%//=CPageBar.CreatePageBarPc("/IllustViewPcV.jsp", String.format("&ID=%d&TD=%d", cResults.m_nUserId, cResults.m_nContentId), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
					<%//}%>
				</nav>
				-->
			</section>
		</article>

		<%@ include file="/inner/TShowDetail.jsp"%>
		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>

<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
boolean isApp = false;

IllustListC results = new IllustListC();
results.getParam(request);
results.SELECT_MAX_GALLERY = 45;
if(results.m_nUserId==-1) {
	results.m_nUserId = checkLogin.m_nUserId;
}
if(!results.getResults(checkLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

String strUrl = "https://unrealizm.com/"+results.m_cUser.m_nUserId+"/";
String strTitle = Util.toStringHtml(String.format(_TEX.T("IllustListPc.Title"), results.m_cUser.m_strNickName)) + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(results.m_cUser.m_strNickName), results.m_nContentsNumTotal);
String strFileUrl = "/img/icon-512x512.png";
g_bShowAd = (results.m_cUser.m_nPassportId==Common.PASSPORT_OFF || results.m_cUser.m_nAdMode==CUser.AD_MODE_SHOW);

ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
		<%@ include file="/inner/TCreditCard.jsp"%>
		<%@ include file="/inner/TSendGift.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<%@ include file="/inner/TReplyEmoji.jsp"%>
		<%@ include file="/inner/TDeleteContent.jsp"%>

		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<meta name="twitter:card" content="summary" />
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:image" content="<%="https:" + Common.GetUrl(results.m_cUser.m_strFileName)%>" />
		<meta property="og:url" content="<%=strUrl%>" />
		<meta property="og:title" content="<%=Util.toDescString(strTitle)%>" />
		<meta property="og:description" content="<%=Util.toDescString(strDesc)%>" />
		<meta property="og:image" content="<%=Common.GetUnrealizmUrl(strFileUrl)%>" />
		<title><%=Util.toDescString(strTitle)%></title>

		<script type="text/javascript">
		$(function(){
			<%if(results.m_bOwner) {%>
			$('#MenuMe').addClass('Selected');
			<%} else {%>
			$('#MenuNew').addClass('Selected');
			<%}%>
		});

		$(function(){
			updateCategoryMenuPos(0);

			$("#AnalogicoInfo .AnalogicoInfoSubTitle").html('<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(results.m_cUser.m_strNickName), results.m_nContentsNumTotal)%>');
			<%if(!bSmartPhone) {%>
			$("#AnalogicoInfo .AnalogicoMoreInfo").html('<%=_TEX.T("Unrealizm.Info.RegistNow")%>');
			<%}%>
			/*
			$(window).bind("scroll.slideHeader", function() {
				$('.UserInfo.Float').css('background-position-y', $(this).scrollTop()/5 + 'px');
			});
			*/
		});
		</script>

		<style>
		<%if(!results.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(results.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		<%if(!bSmartPhone) {%>
		@media screen and (min-width:1090px){
		.Wrapper.ThumbList {width: 1090px;}
		}
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

		<article class="Wrapper" style="width: 100%;">
			<%@ include file="/inner/TUserInfo.jsp"%>
		</article>

		<article class="Wrapper ThumbList">
			<%if(results.m_vCategoryList.size()>0) {%>
			<nav id="TagMenu" class="TagMenu">
				<a class="BtnBase TagBtn <%if(results.m_strTagKeyword.isEmpty()){%> Selected<%}%>" href="/<%=results.m_nUserId%>/">
					<i class="fas fa-tag TagIcon"></i><%=_TEX.T("Category.All")%></a>
				<%for(CTag cTag : results.m_vCategoryList) {%>
				<a class="BtnBase TagBtn <%if(cTag.m_strTagTxt.equals(results.m_strTagKeyword)){%> Selected<%}%>" href="/IllustListPcV.jsp?ID=<%=results.m_nUserId%>&KWD=<%=URLEncoder.encode(cTag.m_strTagTxt, "UTF-8")%>"><%=Util.toDescString(cTag.m_strTagTxt)%></a>
				<%}%>
			</nav>
			<%}%>

			<section id="IllustThumbList" class="IllustItemList2Column">
				<%for(CContent cContent: results.contentList) {%>
					<%=CCnv.Content2Html2Column(cContent, checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
				<%}%>
			</section>

			<nav class="PageBar" style="margin-bottom: 4px;">
				<%=CPageBar.CreatePageBarSp("/IllustListPcV.jsp", String.format("&ID=%d&KWD=%s", results.m_nUserId, URLEncoder.encode(results.m_strTagKeyword, "UTF-8")), results.m_nPage, results.m_nContentsNum, results.SELECT_MAX_GALLERY)%>
			</nav>

			<section id="IllustItemListRelatedUser" class="IllustItemList Related User" style="height: auto">
				<header class="SearchResultTitle" style="overflow: unset; height: auto; padding: 0;">
					<div class="IllustItem" style="background: rgba(255,255,255,0.90); margin: 0; width: 100%; border: none; border-radius: 0; min-height: auto;">
						<div class="IllustItemUser" style="padding: 6px 8px 6px 8px; border: none;">
							<a class="IllustItemUserThumb" href="/<%=results.m_cUser.m_nUserId%>/" style="background-image: url('<%=Common.GetUrl(results.m_cUser.m_strFileName)%>_120.jpg')"></a>
							<h2 class="IllustItemUserName">
								<a href="/<%=results.m_cUser.m_nUserId%>/"><%=Util.toStringHtml(results.m_cUser.m_strNickName)%></a>
							</h2>
							<%@ include file="inner/TFollowButton.jsp"%>
						</div>
					</div>
				</header>
			</section>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>

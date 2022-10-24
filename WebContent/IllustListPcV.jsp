<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>

<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/IllustListGridPcV.jsp").forward(request,response);
	return;
}

boolean isApp = false;

IllustListC cResults = new IllustListC();
cResults.getParam(request);
cResults.SELECT_MAX_GALLERY = 45;
if(cResults.m_nUserId==-1) {
	cResults.m_nUserId = checkLogin.m_nUserId;
}
if(!cResults.getResults(checkLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

String strUrl = "https://unrealizm.com/"+cResults.m_cUser.m_nUserId+"/";
String strTitle = Util.toStringHtml(String.format(_TEX.T("IllustListPc.Title"), cResults.m_cUser.m_strNickName)) + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal);
String strFileUrl = "/img/poipiku_icon_512x512_2.png";
g_bShowAd = (cResults.m_cUser.m_nPassportId==Common.PASSPORT_OFF || cResults.m_cUser.m_nAdMode==CUser.AD_MODE_SHOW);

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
		<meta name="twitter:image" content="<%="https:" + Common.GetUrl(cResults.m_cUser.m_strFileName)%>" />
		<meta property="og:url" content="<%=strUrl%>" />
		<meta property="og:title" content="<%=Util.toDescString(strTitle)%>" />
		<meta property="og:description" content="<%=Util.toDescString(strDesc)%>" />
		<meta property="og:image" content="<%=Common.GetUnrealizmUrl(strFileUrl)%>" />
		<title><%=Util.toDescString(strTitle)%></title>

		<script type="text/javascript">
		$(function(){
			<%if(cResults.m_bOwner) {%>
			$('#MenuMe').addClass('Selected');
			<%} else {%>
			$('#MenuNew').addClass('Selected');
			<%}%>
		});

		$(function(){
			updateCategoryMenuPos(0);

			$("#AnalogicoInfo .AnalogicoInfoSubTitle").html('<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal)%>');
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
		<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		<%if(!bSmartPhone) {%>
		@media screen and (min-width:1090px){
		.Wrapper.ThumbList {width: 1090px;}
		}
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


		<article class="Wrapper" style="width: 100%;">
			<div class="UserInfo Float">
				<%@ include file="/inner/TUserInfo.jsp"%>
			</div>
		</article>

		<article class="Wrapper ThumbList">

			<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
			<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin: 12px 0 0 0;">
				<%@ include file="/inner/ad/TAdHomeSp300x100_top.jsp"%>
			</span>
			<%}%>

			<%if(cResults.m_vCategoryList.size()>0) {%>
			<nav id="TagMenu" class="TagMenu">
				<a class="BtnBase TagBtn <%if(cResults.m_strTagKeyword.isEmpty()){%> Selected<%}%>" href="/<%=cResults.m_nUserId%>/">
					<i class="fas fa-tag TagIcon"></i><%=_TEX.T("Category.All")%></a>
				<%for(CTag cTag : cResults.m_vCategoryList) {%>
				<a class="BtnBase TagBtn <%if(cTag.m_strTagTxt.equals(cResults.m_strTagKeyword)){%> Selected<%}%>" href="/IllustListPcV.jsp?ID=<%=cResults.m_nUserId%>&KWD=<%=URLEncoder.encode(cTag.m_strTagTxt, "UTF-8")%>"><%=Util.toDescString(cTag.m_strTagTxt)%></a>
				<%}%>
			</nav>
			<%}%>

			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%if(cContent.pinOrder == 1){%>
					<%= CCnv.Content2Html(
							cContent, checkLogin, CCnv.MODE_SP,
							_TEX, Emoji.getDefaultEmoji(checkLogin.m_nUserId), CCnv.VIEW_DETAIL, CCnv.SP_MODE_WVIEW,
							cResults.m_bOwner ? CCnv.PageCategory.MY_ILLUST_LIST : CCnv.PageCategory.DEFAULT)%>
					<%}else{%>
						<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
					<%}%>
					<%if(nCnt==8 && bSmartPhone && !checkLogin.m_bLogin) {%><div class="SideBarMid" style="padding: 15px 0 10px 0"><%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%></div><%}%>
					<%if(nCnt==14 && bSmartPhone) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp"%><%}%>
					<%if(nCnt==29 && bSmartPhone) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp"%><%}%>
				<%}%>
			</section>

			<nav class="PageBar" style="margin-bottom: 4px;">
				<%=CPageBar.CreatePageBarSp("/IllustListPcV.jsp", String.format("&ID=%d&KWD=%s", cResults.m_nUserId, URLEncoder.encode(cResults.m_strTagKeyword, "UTF-8")), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</nav>

			<section id="IllustItemListRelatedUser" class="IllustItemList Related User" style="height: auto">
				<header class="SearchResultTitle" style="overflow: unset; height: auto; padding: 0;">
					<div class="IllustItem" style="background: rgba(255,255,255,0.90); margin: 0; width: 100%; border: none; border-radius: 0; min-height: auto;">
						<div class="IllustItemUser" style="padding: 6px 8px 6px 8px; border: none;">
							<a class="IllustItemUserThumb" href="/<%=cResults.m_cUser.m_nUserId%>/" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>_120.jpg')"></a>
							<h2 class="IllustItemUserName">
								<a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=Util.toStringHtml(cResults.m_cUser.m_strNickName)%></a>
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

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(Util.isBot(request)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

IllustViewPcC results = new IllustViewPcC();
results.getParam(request);
if(!results.getResults(checkLogin)) {
	if (results.m_bBlocked || results.m_bBlocking) {
		response.sendRedirect(String.format("/IllustListAppV.jsp?ID=%d", results.ownerUserId));
	} else if (results.m_nNewContentId==null || results.m_nNewContentId==results.contentId) {
		response.sendRedirect("/NotFoundV.jsp");
	} else {
		response.sendRedirect(Common.GetUnrealizmUrl(String.format("/IllustViewAppV.jsp?ID=%d&TD=%d", results.ownerUserId, results.m_nNewContentId)));
	}
	return;
}

//R18によるアドの切り替え
g_nSafeFilter = results.content.getAdSwitchId();

results.content.setThumb();
final String strFileUrl = results.content.thumbImgUrl;
final boolean bHidden = results.content.isHideThumbImg;	// テキスト用カバー画像表示フラグ

String strTitle = CTweet.generateMetaTwitterTitle(results.content, _TEX);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
g_bShowAd = (results.m_cUser.m_nPassportId==Common.PASSPORT_OFF || results.m_cUser.m_nAdMode==CUser.AD_MODE_SHOW);

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%@ include file="/inner/TCreditCard.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<%@ include file="/inner/TReplyEmoji.jsp"%>
		<%@ include file="/inner/TSendGift.jsp"%>
		<title><%=Util.toDescString(strTitle)%></title>

		<%@ include file="/inner/TDeleteContent.jsp"%>
		<%@ include file="/inner/TDispRequestTextDlg.jsp"%>
		<%@ include file="/inner/TRetweetContent.jsp"%>
		<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>

		<script type="text/javascript">
			$(function(){
				$(document).on('click', '.PrivateIcon', (ev) => {
					DispMsg("<%=_TEX.T("IllustView.IconMsg.Private")%>");
				})
				$(document).on('click', '.OutOfPeriodIcon', (ev) => {
					DispMsg("<%=_TEX.T("IllustView.IconMsg.OutOfPeriod")%>");
				})

				$('body, .Wrapper').each(function(index, element){
					$(element).on("drag dragstart",function(e){return false;});
				});

				<%if(!bHidden && results.content.m_nEditorId==Common.EDITOR_TEXT) {%>
				var frame_height = $('#IllustItemText_'+ <%=results.content.m_nContentId%> ).height();
				var text_height = $('#IllustItemText_'+ <%=results.content.m_nContentId%> + ' .IllustItemThumbText').height();
				if(frame_height>=text_height) {
					$('.IllustItemExpandBtn').hide();
				}
				<%}%>
			});
		</script>

		<style>
			.IllustItemList.Related {margin-bottom: 6px;}
			.IllustItemList.Related .SearchResultTitle {height: auto; margin: 10px 0 0 0; line-height: normal;}
			.IllustItemList.Related .SearchResultTitle .Keyword {display: block;}
			.IllustItemList.Related .SearchResultTitle .IllustItem {margin-bottom: 0;}
			.IllustItemList.Related .AutoLink {display: block; float: left; background-color: #ffffff; color: #3498db; font-size: 15px; line-height: 34px; padding: 0 18px; margin: 4px 2px 0 2px; border-radius: 6px;}
			.FooterAd {display: block; float: left; width: 100%; margin: 0 auto; box-sizing: border-box;}
			.FooterAd .SideBarMid {isplay: block; float: left; width: 100%; height: auto;}
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
		<%{%>
		<article class="Wrapper">
			<div class="UserInfo">
				<%@include file="inner/IllustBrowserVGiftButton.jsp"%>
				<%@ include file="inner/IllustVBlockButton.jsp"%>
				<div class="UserInfoBg"></div>
				<section class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(results.m_cUser.m_strFileName)%>')" href="/IllustListAppV.jsp?ID=<%=results.m_cUser.m_nUserId%>"></a>
					<h2 class="UserInfoUserName"><a href="/IllustListAppV.jsp?ID=<%=results.m_cUser.m_nUserId%>"><%=results.m_cUser.m_strNickName%></a></h2>
					<h3 class="UserInfoProfile"><%=Common.AutoLink(Util.toStringHtml(results.m_cUser.m_strProfile), results.m_cUser.m_nUserId, CCnv.MODE_SP)%></h3>
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
						<%if(results.m_bOwner) {%>
						&nbsp;
						<%} else if(results.m_bBlocking){%>
						<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=results.m_cUser.m_nUserId%>" style="display: none;" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=results.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<%} else if(results.m_bBlocked){%>
						<%} else if(results.m_bFollow){%>
						<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=results.m_cUser.m_nUserId%> Selected" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=results.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Following")%></span>
						<%} else {%>
						<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=results.m_cUser.m_nUserId%>" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=results.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<%}%>

						<%@ include file="inner/IllustBrowserVRequestButton.jsp"%>

						<%if(!results.m_bOwner) {%>
						<span class="IllustItemCommandSub">
							<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>"></a>
						</span>
						<%}%>
					</span>
					<%@ include file="/inner/TWaveButtons.jsp"%>
				</section>
				<section class="UserInfoState">
					<a class="UserInfoStateItem Selected" href="/IllustListAppV.jsp?ID=<%=results.m_cUser.m_nUserId%>">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
						<span class="UserInfoStateItemNum"><%=results.m_nContentsNumTotal%></span>
					</a>
					<a class="UserInfoStateItem" href="/FollowListAppV.jsp">
						<%if(!results.m_bBlocked) {%>
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follow")%></span>
						<span class="UserInfoStateItemNum"><%=results.m_cUser.m_nFollowNum%></span>
						<%}%>
					</a>
					<a class="UserInfoStateItem" href="/FollowerListAppV.jsp">
						<%if(!results.m_bBlocked) {%>
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follower")%></span>
						<span class="UserInfoStateItemNum"><%=results.m_cUser.m_nFollowerNum%></span>
						<%}%>
					</a>
				</section>
			</div>
		</article>
		<%}%>

		<article class="Wrapper ViewPc">
			<section id="IllustItemList" class="IllustItemList">
				<%=CCnv.Content2Html(results.content, checkLogin, CCnv.MODE_SP,
						_TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_APP,
						results.m_bOwner?CCnv.PageCategory.MY_ILLUST_LIST:CCnv.PageCategory.DEFAULT)%>
			</section>

			<%@ include file="/inner/TAdEvent_top_rightV.jsp"%>
		</article>

		<article class="Wrapper">
			<section id="IllustItemList" class="IllustItemList Related">
				<%for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
					CContent content = results.contentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(content, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_APP, _TEX)%>
				<%
					}
				%>
			</section>
		</article>

		<%if(!results.m_vRelatedContentList.isEmpty()) {%>
		<article class="Wrapper">
			<section id="IllustItemList" class="IllustItemList Related">
				<header class="SearchResultTitle" style="box-sizing: border-box; padding: 0 5px; float: none;">
					<h2 class="Keyword">
						<%
							String keyword = RelatedContents.getTitleTag(results.content.m_nContentId);
						%>
						<a class="AutoLink" href="/SearchIllustByTagV.jsp?KWD=<%=URLEncoder.encode(keyword, "UTF-8")%>">#<%=keyword%></a>
					</h2>
				</header>
				<%
					for(int nCnt=0; nCnt<results.m_vRelatedContentList.size(); nCnt++) {
						CContent content = results.m_vRelatedContentList.get(nCnt);
				%>
					<%=CCnv.toThumbHtml(content, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_APP, _TEX)%>
				<%}%>
			</section>
		</article>
		<%}%>

		<%@ include file="/inner/TShowDetail.jsp"%>
	</body>
</html>

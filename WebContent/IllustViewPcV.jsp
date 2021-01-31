<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/IllustViewGridPcV.jsp").forward(request,response);
	return;
}

IllustViewPcC cResults = new IllustViewPcC();
cResults.SELECT_MAX_GALLERY = 6;
cResults.getParam(request);

if(!cResults.getResults(checkLogin)) {
	if(cResults.m_nNewContentId==null || cResults.m_nNewContentId==cResults.m_nContentId) {
		response.sendRedirect("/NotFoundPcV.jsp");
	}else{
		response.sendRedirect(Common.GetPoipikuUrl(String.format("/%d/%d.html", cResults.m_nUserId, cResults.m_nNewContentId)));
	}
	return;
}
if(cResults.m_cContent.m_nPublishId!=Common.PUBLISH_ID_ALL && Util.isBot(request)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

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
	strFileUrl = Common.PUBLISH_ID_FILE[cResults.m_cContent.m_nPublishId];
	bHidden = true;
	break;
case Common.PUBLISH_ID_ALL:
case Common.PUBLISH_ID_HIDDEN:
default:
	strFileUrl = cResults.m_cContent.m_strFileName;
	if(strFileUrl.isEmpty()) strFileUrl="/img/poipiku_icon_512x512_2.png";
	break;
}

String strDesc = Util.deleteCrLf(cResults.m_cContent.m_strDescription);
String strTitle = CTweet.generateState(cResults.m_cContent, _TEX) +  CTweet.generateFileNum(cResults.m_cContent, _TEX) + " " + Util.subStrNum(strDesc, 10) + " " + String.format(_TEX.T("Tweet.Title"), cResults.m_cContent.m_cUser.m_strNickName) + " | " + _TEX.T("THeader.Title");;
String strUrl = "https://poipiku.com/"+cResults.m_cContent.m_nUserId+"/"+cResults.m_cContent.m_nContentId+".html";
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%@ include file="/inner/ad/TAdIllustViewPcHeader.jsp"%>
		<%@ include file="/inner/TSweetAlert.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<meta name="twitter:card" content="summary_large_image" />
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:title" content="<%=CTweet.generateMetaTwitterTitle(cResults.m_cContent, _TEX)%>" />
		<meta name="twitter:description" content="<%=CTweet.generateMetaTwitterDesc(cResults.m_cContent, _TEX)%>" />
		<meta name="twitter:image" content="<%=Common.GetPoipikuUrl(strFileUrl)%>_360.jpg" />
		<link rel="canonical" href="<%=strUrl%>" />
		<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />
		<title><%=Util.toDescString(strTitle)%></title>
		<script type="application/ld+json">
		{
			"@context":"http://schema.org",
			"@type":"ItemList",
			"itemListElement":[
				{"@type":"ListItem", "position":1, "url":"<%=strUrl%>", "name": "<%=Util.toDescString(strTitle)%>", "image": "<%=Common.GetPoipikuUrl(strFileUrl)%>"}
			]
		}
		</script>

		<script type="text/javascript">
			$(function(){
				$('#MenuNew').addClass('Selected');
			});
		</script>

		<%@ include file="/inner/TDeleteContent.jsp"%>

		<script type="text/javascript">
			function UpdateFollow(nUserId, nFollowUserId) {
				var bFollow = $("#UserInfoCmdFollow").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": nUserId, "IID": nFollowUserId },
					"url": "/f/UpdateFollowF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('.UserInfoCmdFollow_'+nFollowUserId).addClass('Selected');
							$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Following")%>");
						} else if(data.result==2) {
							$('.UserInfoCmdFollow_'+nFollowUserId).removeClass('Selected');
							$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Follow")%>");
						} else {
							DispMsg('フォローできませんでした');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function UpdateBlock() {
				var bBlocked = $("#UserInfoCmdBlock").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=checkLogin.m_nUserId%>, "IID": <%=cResults.m_cUser.m_nUserId%>, "CHK": (bBlocked)?0:1 },
					"url": "/f/UpdateBlockF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('.UserInfoCmdBlock').addClass('Selected');
							$('.UserInfoCmdFollow').removeClass('Selected');
							$('.UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
							$('.UserInfoCmdFollow').hide();
							location.reload(true);
						} else if(data.result==2) {
							$('.UserInfoCmdBlock').removeClass('Selected');
							$('.UserInfoCmdFollow').removeClass('Selected');
							$('.UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
							$('.UserInfoCmdFollow').show();
							location.reload(true);
						} else {
							DispMsg('ブロックできませんでした');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			$(function(){
				<%if(!cResults.m_bOwner){%>
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
				<%}%>
				$("#AnalogicoInfo .AnalogicoInfoSubTitle").html('<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal)%>');

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
			.IllustItemList.Related {margin-bottom: 6px;}
			.IllustItemList.Related .SearchResultTitle {height: auto; margin: 10px 0 0 0;}
			.IllustItemList.Related .SearchResultTitle .IllustItem {margin-bottom: 0;}
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

		<%{%>
		<article class="Wrapper" style="width: 100%;">
			<div class="UserInfo Float">
				<div class="UserInfoBg"></div>
				<section class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
					<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>
					<%if(!cResults.m_cUser.m_strProfile.isEmpty()) {%>
					<h3 class="UserInfoProgile"><%=Common.AutoLink(Util.toStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
					<%}%>
					<span class="UserInfoCmd">
						<%
						String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
								URLEncoder.encode(String.format("%s%s %s #%s",
										cResults.m_cUser.m_strNickName,
										_TEX.T("Twitter.UserAddition"),
										String.format(_TEX.T("Twitter.UserPostNum"), cResults.m_nContentsNumTotal),
										_TEX.T("Common.Title")), "UTF-8"),
								URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8"));
						%>
						<%if(!checkLogin.m_bLogin) {%>
						<a id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow" href="/"><%=_TEX.T("IllustV.Follow")%></a>
						<a id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock" href="/"></a>
						<%} else if(cResults.m_bOwner) {
							// 何も表示しない
						} else if(cResults.m_bBlocking){%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" style="display: none;" onclick="UpdateFollow(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock Selected" onclick="UpdateBlock()"></span>
						<%} else if(cResults.m_bBlocked){%>
						<%} else if(cResults.m_bFollow){%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%> Selected" onclick="UpdateFollow(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Following")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock " onclick="UpdateBlock()"></span>
						<%} else {%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" onclick="UpdateFollow(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock" onclick="UpdateBlock()"></span>
						<%}%>
						<span class="IllustItemCommandSub">
							<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>" target="_blank"></a>
						</span>
					</span>
				</section>
				<section class="UserInfoState">
					<a class="UserInfoStateItem Selected" href="/<%=cResults.m_cUser.m_nUserId%>/">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_nContentsNumTotal%></span>
					</a>
				</section>
			</div>
		</article>
		<%}%>

		<article class="Wrapper ViewPc">
			<section id="IllustItemList" class="IllustItemList">
				<%= CCnv.Content2Html(cResults.m_cContent, checkLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult, CCnv.VIEW_DETAIL)%>
			</section>

			<%@ include file="/inner/TAdEvent_top_rightPcV.jsp"%>
<!--
			<nav class="PageBar">
				<%//if(bSmartPhone) {%>
				<%//=CPageBar.CreatePageBarSp("/IllustViewPcV.jsp", String.format("&ID=%d&TD=%d", cResults.m_nUserId, cResults.m_nContentId), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
				<%//}else{%>
				<%//=CPageBar.CreatePageBarPc("/IllustViewPcV.jsp", String.format("&ID=%d&TD=%d", cResults.m_nUserId, cResults.m_nContentId), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
				<%//}%>
			</nav>
-->
		</article>

		<article class="Wrapper GridList">
			<section id="IllustItemList" class="IllustItemList Related User">
				<header class="SearchResultTitle" style="box-sizing: border-box; padding: 0; float: none;">
					<div class="IllustItem ">
						<div class="IllustItemUser">
							<a class="IllustItemUserThumb" href="/<%=cResults.m_cUser.m_nUserId%>/" style="background-image: url('<%=Common.GetUrl(cResults.m_cContent.m_cUser.m_strFileName)%>_120.jpg')"></a>
							<h2 class="IllustItemUserName">
								<a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=Util.toStringHtml(cResults.m_cContent.m_cUser.m_strNickName)%></a>
							</h2>
							<span id="UserInfoCmdFollow"
								class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%> <%=(cResults.m_cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?" Selected":""%>"
								onclick="UpdateFollow(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=(cResults.m_cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?_TEX.T("IllustV.Following"):_TEX.T("IllustV.Follow")%></span>
						</div>
					</div>
				</header>
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
				<%
					}
				%>
			</section>
		</article>

		<%
			if(!cResults.m_vRelatedContentList.isEmpty()) {
		%>
		<article class="Wrapper GridList">
			<section id="IllustItemList" class="IllustItemList Related Tag">
				<header class="SearchResultTitle" style="float: none;">
					<%
						String keyword = RelatedContents.getTitleTag(cResults.m_cContent.m_nContentId);
					%>
					<a class="Keyword" href="/SearchIllustByTagPcV.jsp?KWD=<%=URLEncoder.encode(keyword, "UTF-8")%>">#<%=keyword%></a>
				</header>
				<%
					for(int nCnt=0; nCnt<cResults.m_vRelatedContentList.size(); nCnt++) {
									CContent cContent = cResults.m_vRelatedContentList.get(nCnt);
				%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
				<%}%>
			</section>
		</article>
		<%}%>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
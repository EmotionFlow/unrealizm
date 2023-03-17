<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

IllustListC results = new IllustListC();
results.getParam(request);

if(results.m_nUserId==-1) {
	if(!checkLogin.m_bLogin) {
		getServletContext().getRequestDispatcher("/StartUnrealizmAppV.jsp").forward(request,response);
		return;
	} else {
		results.m_nUserId = checkLogin.m_nUserId;
	}
}

boolean isApp = true;

if(checkLogin.m_nUserId != results.m_nUserId) {
	// 他人のリスト
	results.m_bDispUnPublished = false;
} else {
	// 自分のリスト
	CAppVersion cAppVersion = new CAppVersion(request.getCookies());
	Log.d(String.format("COOKIE: %d", cAppVersion.m_nNum));
	if(cAppVersion.isValid()){
		if(cAppVersion.isAndroid() && cAppVersion.m_nNum >= 225){
			results.m_bDispUnPublished = false;
		} else {
			results.m_bDispUnPublished = true;
		}
	}else{
		// 古いアプリはCookieにバージョン番号が含まれていないため取得できない。
		results.m_bDispUnPublished = true;
	}
}

checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
if(!results.getResults(checkLogin)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}
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
		<title><%=results.m_cUser.m_strNickName%></title>
		<script>
			var g_nPage = 1; // start 1
			var g_strKeyword = '<%=results.m_strTagKeyword%>';
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"ID": <%=results.m_nUserId%>, "KWD": g_strKeyword,  "PG" : g_nPage},
					"url": "/f/IllustListAppF.jsp",
					"success": function(data) {
						if($.trim(data).length>0) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustThumbList").append(data);
							g_bAdding = false;
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
						} else {
							$(window).unbind("scroll.addContents");
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function changeCategory(elm, param) {
				g_nPage = 0;
				g_strKeyword = param;
				g_bAdding = false;
				$("#IllustThumbList").empty();
				$('#CategoryMenu .CategoryBtn').removeClass('Selected');
				$(elm).addClass('Selected');
				updateCategoryMenuPos(300);
				$(window).unbind("scroll.addContents");
				<%if(!results.m_bBlocking && !results.m_bBlocked){%>
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
				addContents();
				<%}%>
			}

			$(function(){
				<%if(!results.m_bBlocking && !results.m_bBlocked){%>
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
				<%}%>
			});

			$(function(){
				updateCategoryMenuPos(0);
			});
		</script>
		<style>
		<%if(!results.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(results.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		.NoContents {display: block; padding: 130px 0; width: 100%; text-align: center;}
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
		<%@ include file="/inner/TAdPoiPassHeaderAppV.jsp"%>

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
							<a class="BtnBase UserInfoCmdFollow" href="myurlscheme://openSetting"><i class="fas fa-cog"></i> <%=_TEX.T("MyEditSetting.Title.Setting")%></a>
							<a class="BtnBase UserInfoCmdFollow" href="<%=strTwitterUrl%>"><i class="fab fa-twitter"></i> <%=_TEX.T("Twitter.Share.MyUrl.Btn")%></a>
						<%} else if(results.m_bBlocking){ // ブロックしている %>
							<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=results.m_cUser.m_nUserId%>"
								  style="display: none;" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=results.m_cUser.m_nUserId%>)">
								<%=_TEX.T("IllustV.Follow")%>
							</span>
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
						<%if(!results.m_bBlocked) {%>
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
						<span class="UserInfoStateItemNum"><%=results.m_nContentsNumTotal%></span>
						<%}%>
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

		<article class="Wrapper">
			<%if(results.m_vCategoryList.size()>0) {%>
			<nav id="CategoryMenu" class="CategoryMenu">
				<span class="BtnBase CategoryBtn <%if(results.m_strTagKeyword.isEmpty()){%> Selected<%}%>" onclick="changeCategory(this, '')"><%=_TEX.T("Category.All")%></span>
				<%for(CTag cTag : results.m_vCategoryList) {%>
				<span class="BtnBase CategoryBtn <%if(cTag.m_strTagTxt.equals(results.m_strTagKeyword)){%> Selected<%}%>" onclick="changeCategory(this, '<%=cTag.m_strTagTxt%>')"><%=Util.toDescString(cTag.m_strTagTxt)%></span>
				<%}%>
			</nav>
			<%}%>

			<section id="IllustThumbList" class="IllustThumbList">
				<%if(checkLogin.m_nUserId != results.m_nUserId){%>
					<%for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
						CContent cContent = results.contentList.get(nCnt);%>
				<%if(cContent.pinOrder == 1){%>
				<%= CCnv.Content2Html(
						cContent, checkLogin, CCnv.MODE_SP,
						_TEX, Emoji.getDefaultEmoji(checkLogin.m_nUserId), CCnv.VIEW_DETAIL, CCnv.SP_MODE_WVIEW,
						results.m_bOwner ? CCnv.PageCategory.MY_ILLUST_LIST : CCnv.PageCategory.DEFAULT)%>
				<%}else{%>

				<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_APP, _TEX)%>
				<%}%>
					<%}%>
				<%}else{%>
					<%if(results.contentList.size()>0){%>
						<%for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
							CContent cContent = results.contentList.get(nCnt);%>
							<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_APP, _TEX)%>
						<%}%>
					<%}else{%>
						<span class="NoContents"><%=_TEX.T("IllustListV.NoContents.Me")%></span>
					<%}%>
				<%}%>
			</section>
		</article>
	</body>
</html>

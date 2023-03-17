<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

MyIllustListC results = new MyIllustListC();
results.getParam(request);
results.SELECT_MAX_GALLERY = 15;

// ログインせずにUIDを指定した場合、間違ってマイボックスのURLを聞いてアクセスしている可能性がある
if(!checkLogin.m_bLogin && results.m_nUserId>=1) {
	response.sendRedirect("/" + results.m_nUserId);
	return;
}

// それ以外の場合でログインしていない場合はログインページへ
if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailV.jsp").forward(request,response);
	return;
}

if(results.m_nUserId < 0){
	// パラメータなしだったら自分のマイボックス
	results.m_nUserId = checkLogin.m_nUserId;
} else if(checkLogin.m_nUserId != results.m_nUserId) {
	// 自分と異なるuserIdが指定されていたら、その人のトップへ遷移。
	response.sendRedirect("/"+results.m_nUserId);
	return;
}

results.m_bDispUnPublished = true;
if (g_isApp) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}
if (!results.getResults(checkLogin) || !results.m_bOwner) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}
String strUrl = "https://unrealizm.com/"+results.m_cUser.m_nUserId+"/";
String strTitle = Util.toStringHtml(String.format(_TEX.T("IllustListPc.Title"), results.m_cUser.m_strNickName)) + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(results.m_cUser.m_strNickName), results.m_nContentsNumTotal);
String strFileUrl = results.m_cUser.m_strFileName;
if(strFileUrl.isEmpty()) strFileUrl="/img/icon-512x512.png";
String strEncodedKeyword = URLEncoder.encode(results.m_strTagKeyword, "UTF-8");

Map<String, String> keyValues;
String strCgiParam = "";
final String thisPagePath = "/MyIllustListV.jsp";
final String myPagePath = "/" + checkLogin.m_nUserId + "/";

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>

		<script>setTimeZoneOffsetCookie();</script>

		<title><%=results.m_cUser.m_strNickName%></title>
		<%@ include file="/inner/TTweetMyBox.jsp"%>
		<%@ include file="/inner/TSwitchUser.jsp"%>
		<%@ include file="/inner/TWaveMessageDlg.jsp"%>

		<%if(!g_isApp){%>
		<script>$(function () {
			$("#MenuSearch").hide();
			$("#MenuUpload").show();
			$("#MenuSettings").show();
			// $("#MenuSwitchUser").show();
		})</script>
		<%}%>

		<script type="text/javascript">
		$(function(){
			$('#MenuMe').addClass('Selected');
			updateTagMenuPos(100);
			<%if (Util.toString(request.getHeader("Referer")).indexOf("MyIllustList") > 0) { %>
			$(window).scrollTop($("#SortFilterMenu").offset().top - 80);
			<%}%>
		});
		</script>

		<style>
		<%if(!results.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(results.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		.HeaderSetting {text-align: center; position: absolute; top: 12px; right: 10px;}
		.NoContents {display: block; padding: 250px 0; width: 100%; text-align: center;}
		.TweetMyBox {padding-top: 5px; text-align: center;}
		.MyBoxSearch {display: flex; flex-flow: row nowrap; text-align: center; width: 300px;}
		.MyBoxSearch .MyBoxSearchBox {display: block; flex: 1 1; height: 26px; width: 152px; padding: 0 5px; box-sizing: border-box; border: solid 1px #3498db; border-radius: 15px 0 0 15px;}
		.MyBoxSearch .MyBoxSearchBtn {display: block; height: 26px; box-sizing: border-box; margin: 0; background-color: #ffffff; color: #3498db; border: solid 1px #3498db; cursor: pointer; border-left: none;line-height: 25px;border-radius: 0 15px 15px 0; font-size: 14px; padding: 0px 6px 0px 4px;}
		.MyBoxSearch .MyBoxSearchBtn:hover {border: solid 1px #fff; background-color: #3498db; color: #000;}
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

		<%@ include file="/inner/MyIllustListSwitchUserList.jsp"%>
		<article class="Wrapper" style="width: 100%;">
			<div class="UserInfo Float">
				<div class="UserInfoBg"></div>
				<section class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(results.m_cUser.m_strFileName)%>')" href="<%=myPagePath%>"></a>
					<h2 class="UserInfoUserName"><a href="<%=myPagePath%>"><%=results.m_cUser.m_strNickName%></a></h2>
					<%if(results.twitterScreenName != null && !results.twitterScreenName.isEmpty()) {%>
					<h3 class="UserInfoProfile"><a class="fab fa-twitter" href="https://twitter.com/<%=results.twitterScreenName%>">@<%=results.twitterScreenName%></a></h3>
					<%}%>
					<h3 class="UserInfoProfile"><%=Common.AutoLink(Util.toStringHtml(results.m_cUser.m_strProfile), results.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
					<span class="UserInfoCmd">
						<span class="TweetMyBox">
							<a id="OpenTweetMyBoxDlgBtn" href="javascript:void(0);" class="BtnBase">
								<i class="fab fa-twitter"></i><%=_TEX.T("MyIllustListV.TweetMyBox")%>
							</a>
						</span>
						<%@ include file="/inner/TUserShareCmd.jsp"%>
					</span>
				</section>

				<section class="UserInfoState">
					<a class="UserInfoStateItem Selected" href="/<%=results.m_cUser.m_nUserId%>/">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
						<span class="UserInfoStateItemNum"><%=results.m_nContentsNumTotal%></span>
					</a>
					<a class="UserInfoStateItem" href="/FollowListPcV.jsp?ID=<%=results.m_cUser.m_nUserId%>">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follow")%></span>
						<span class="UserInfoStateItemNum"><%=results.m_cUser.m_nFollowNum%></span>
					</a>
					<a class="UserInfoStateItem" href="/FollowerListPcV.jsp?ID=<%=results.m_cUser.m_nUserId%>">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follower")%></span>
						<span class="UserInfoStateItemNum"><%=results.m_cUser.m_nFollowerNum%></span>
					</a>
				</section>
			</div>
		</article>

		<article class="Wrapper">
			<% boolean isGridPc = false; %>
			<%@include file="/inner/TSortFilterNavigation.jsp"%>

			<%if(results.m_vCategoryList.size()>0) {%>
			<nav id="TagMenu" class="TagMenu">
				<a class="BtnBase TagBtn <%if(results.m_strTagKeyword.isEmpty()){%> Selected<%}%>" href="<%=thisPagePath%>">
					<i class="fas fa-tag TagIcon"></i><%=_TEX.T("Category.All")%></a>
				<%
					keyValues = results.getParamKeyValueMap();
					keyValues.remove("KWD");
					keyValues.remove("PG");
					strCgiParam = Common.getCgiParamStr(keyValues);
					for(final CTag cTag : results.m_vCategoryList) {%>
				<a class="BtnBase TagBtn <%if(cTag.m_strTagTxt.equals(results.m_strTagKeyword)){%> Selected<%}%>" href="<%=thisPagePath%>?<%=strCgiParam%>&KWD=<%=URLEncoder.encode(cTag.m_strTagTxt, "UTF-8")%>"><%=Util.toDescString(cTag.m_strTagTxt)%></a>
				<%
					}
				%>
			</nav>
			<%}%>

			<section id="IllustThumbList" class="IllustItemList2Column">
				<%if(results.contentList.size()>0){%>
					<% for (CContent content: results.contentList) { %>
						<%=CCnv.Content2Html2Column(content, checkLogin, _TEX)%>
					<%}%>
				<%}else{%>
					<span class="NoContents"><%=_TEX.T("IllustListV.NoContents.Me")%></span>
				<%}%>
			</section>

			<nav class="PageBar">
				<%
					keyValues = results.getParamKeyValueMap();
					keyValues.remove("PG");
					strCgiParam = "&" + Common.getCgiParamStr(keyValues);
				%>
				<%=CPageBar.CreatePageBarSp(thisPagePath, strCgiParam, results.m_nPage, results.m_nContentsNum, results.SELECT_MAX_GALLERY)%>
				<%
					keyValues.clear();
				%>
			</nav>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>

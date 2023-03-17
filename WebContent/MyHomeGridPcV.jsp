<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
boolean isApp = false;

MyHomePcC results = new MyHomePcC();
results.getParam(request);
String cookieLang = Util.getCookie(request, "UR_LANG");
if (cookieLang == null) {
	cookieLang = "ja";
	Util.setCookie(response, "UR_LANG", "ja", Integer.MAX_VALUE);
}
results.cookieLangId = SupportedLocales.findId(cookieLang);

if(!checkLogin.m_bLogin) {
	if(results.n_nUserId>0) {
		response.sendRedirect("/"+results.n_nUserId+"/");
	} else {
		getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	}
	return;
}

results.m_nSelectRecommendedListNum = 10;
results.getResults(checkLogin);

ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<%@ include file="/inner/TReplyEmoji.jsp"%>
		<title><%=_TEX.T("MyHomePc.Title")%> | <%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>

		<%@ include file="/inner/TDeleteContent.jsp"%>
		<%@ include file="/inner/TDispRequestTextDlg.jsp"%>
		<%@ include file="/inner/TRetweetContent.jsp"%>
		<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>

		<script>
		$(function(){
			$('body, .Wrapper').each(function(index, element){
				$(element).on("drag dragstart",function(e){if(!$(e.target).is(".MyUrl")){return false;}});
			});
			<%if(!checkLogin.m_bEmailValid && System.currentTimeMillis() % 100 == 0){%>
			Swal.fire({
				html:
					'<style>' +
					' .RequestEmailMsg {text-align: left; font-size: 19px;}' +
					' .RequestEmailSubmit {margin: 30px auto; padding: 10px 30px; -webkit-tap-highlight-color: rgba(255, 255, 255, 0) !important; -webkit-focus-ring-color: rgba(255, 255, 255, 0) !important; outline: none !important;}' +
					' .RequestEmailLater {width: 100%; text-align: left; font-size: 14px; font-weight: 500; margin: 10px 0 5px 0; padding: 0; font-weight: 400; color: #aaaaaa; background: none; border: none;}' +
					' .swal2-popup .swal2-actions {margin: 0;}' +
					'</style>' +
					'<div class="RequestEmailMsg">' + "<%=_TEX.T("RequestEmail.Msg")%>" + '</div>' +
					'<div><a class="BtnBase ResBtnSetItem Selected RequestEmailSubmit" href="/MyEditSettingPcV.jsp?MENUID=MAIL">' +
					'✉️ <%=_TEX.T("RequestEmail.GoSettingPage")%>' +
					'</a></div>',
				focusConfirm: false,
				showConfirmButton: false,
				showCancelButton: true,
				cancelButtonText: "<%=_TEX.T("RequestEmail.Later")%>",
				buttonsStyling: false,
				cancelButtonClass: "RequestEmailLater",
			})
			<%}%>
		});
		</script>

		<style>
			body {padding-top: 51px !important;}
			.UnrealizmDesc.Event {margin: 10px 0;}
			.RequestEmail {display: block; float: left; width: 100%; margin: 1px 0 0 0; text-decoration: underline; background: #f4f9fb; text-align: center;}
			.UnrealizmDesc.Event {margin: 30px 0 0 0;}
			.Wrapper.ViewPc {flex-flow: row-reverse wrap;}
			.Wrapper.ViewPc .PcSideBar .FixFrame {position: sticky; top: 113px;}
			.Wrapper.ViewPc .PcSideBar .PcSideBarItem:last-child {position: static;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem Selected" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a></li>
				<li><a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a></li>
				<li><a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a></li>
			</ul>
		</nav>

		<%if(results.m_cSystemInfo!=null) {%>
		<div class="SystemInfo" id="SystemInfo_<%=results.m_cSystemInfo.m_nContentId%>">
			<a class="SystemInfoTitle" href="/2/<%=results.m_cSystemInfo.m_nContentId%>.html"><i class="fas fa-bullhorn"></i></a>
			<a class="SystemInfoDate" href="/2/<%=results.m_cSystemInfo.m_nContentId%>.html"><%=(new SimpleDateFormat("YYYY MM/dd")).format(results.m_cSystemInfo.m_timeUploadDate)%></a>
			<a class="SystemInfoDesc" href="/2/<%=results.m_cSystemInfo.m_nContentId%>.html"><%=Util.toStringHtml(Util.replaceCrLf2Space(results.m_cSystemInfo.m_strDescription))%></a>
			<a class="SystemInfoClose" href="javascript:void(0)" onclick="$('#SystemInfo_<%=results.m_cSystemInfo.m_nContentId%>').hide();setCookie('<%=Common.UNREALIZM_INFO%>', '<%=results.m_cSystemInfo.m_nContentId%>')"><i class="fas fa-times"></i></a>
		</div>
		<%}%>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper ViewPc" style="padding-top: 40px">
			<aside class="PcSideBar" style="margin-top: 30px;">
				<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd && false) {%>
				<div class="PcSideBarItem">
					<%@ include file="/inner/ad/TAdHomePc300x250_top_right.jsp"%>
				</div>
				<%}%>

				<div class="PcSideBarItem">
					<%@ include file="/inner/TAdEvent_top_rightPcV.jsp"%>
				</div>

				<div class="PcSideBarItem">
					<div class="PcSideBarItemTitle"><%=_TEX.T("Twitter.Share.MyUrl")%></div>
					<%
					String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
							URLEncoder.encode(String.format("%s%s %s #%s",
									checkLogin.m_strNickName,
									_TEX.T("Twitter.UserAddition"),
									String.format(_TEX.T("Twitter.UserPostNum"), results.m_nContentsNumTotal),
									_TEX.T("Common.HashTag")), "UTF-8"),
							URLEncoder.encode("https://unrealizm.com/"+checkLogin.m_nUserId+"/", "UTF-8"));
					%>
					<div style="text-align: center;">
						<input id="MyUrl" class="MyUrl" type="text" value="https://unrealizm.com/<%=checkLogin.m_nUserId%>/" onclick="this.select(); document.execCommand('copy');" style="box-sizing: border-box; width: 100%; padding: 5px; margin: 0 0 10px 0;" />
						<a class="BtnBase" href="javascript:void(0)" onclick="$('#MyUrl').select(); document.execCommand('Copy');"><i class="far fa-copy"></i> <%=_TEX.T("Twitter.Share.Copy.Btn")%></a>
						<a class="BtnBase" href="<%=strTwitterUrl%>" target="_blank"><i class="fab fa-twitter"></i> <%=_TEX.T("Twitter.Share.MyUrl.Btn")%></a>
					</div>
				</div>

				<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd && false) {%>
				<div class="FixFrame">
					<div class="PcSideBarItem">
						<%@ include file="/inner/ad/TAdHomePc300x600_bottom_right.jsp"%>
					</div>
				</div>
				<%}%>
			</aside>

			<section id="IllustItemList" class="IllustItemList">
				<%if(!(results.followUserNum > 1 || results.m_nContentsNumTotal > 1)) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 50px 10px 50px 10px; text-align: center; box-sizing: border-box;">
					<%=_TEX.T("MyHome.FirstMsg")%>
					<br />
<%--					<a class="BtnBase" href="/how_to/TopPcV.jsp"><%=_TEX.T("HowTo.Title")%></a>--%>
				</div>
				<%}%>

				<% int nCnt=0;
					for(nCnt=0; nCnt<results.contentList.size(); nCnt++) {
					CContent cContent = results.contentList.get(nCnt);%>
					<%= CCnv.Content2Html(cContent, checkLogin, CCnv.MODE_PC, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_WVIEW)%>

					<%if(nCnt==6 && results.m_vRecommendedUserList!=null && !results.m_vRecommendedUserList.isEmpty()) {%>
					<div class="IllustItemListRecommended">
						<h2 class="IllustItemListRecommendedTitle"><%=_TEX.T("MyHome.Recommended.Users")%></h2>
						<%for (CUser recommendedUser: results.m_vRecommendedUserList){%>
						<%=CCnv.toHtmlUserMini(recommendedUser, 0, _TEX, CCnv.SP_MODE_WVIEW)%>
						<%}%>
					</div>
					<%}%>

<%--					<%if(nCnt==7 && results.m_vRecommendedRequestCreatorList!=null && !results.m_vRecommendedRequestCreatorList.isEmpty()) {%>--%>
<%--					<div class="IllustItemListRecommended">--%>
<%--						<h2 class="IllustItemListRecommendedTitle"><%=_TEX.T("MyHome.Recommended.RequestCreators")%></h2>--%>
<%--						<%for (CUser recommendedUser: results.m_vRecommendedRequestCreatorList){%>--%>
<%--						<%=CCnv.toHtmlUserMini(recommendedUser, 0, _TEX, CCnv.SP_MODE_WVIEW)%>--%>
<%--						<%}%>--%>
<%--					</div>--%>
<%--					<%}%>--%>
				<%}%>

				<%if(nCnt<=6 && results.m_vRecommendedUserList!=null && !results.m_vRecommendedUserList.isEmpty()) {%>
				<h2 class="IllustItemListRecommendedTitle"><%=_TEX.T("MyHome.Recommended.Users")%></h2>
				<%for (CUser recommendedUser: results.m_vRecommendedUserList){%>
				<%=CCnv.toHtmlUserMini(recommendedUser, 0, _TEX, CCnv.SP_MODE_WVIEW)%>
				<%}%>
				<%}%>

				<%if(nCnt<=7 && results.m_vRecommendedRequestCreatorList!=null && !results.m_vRecommendedRequestCreatorList.isEmpty()) {%>
				<h2 class="IllustItemListRecommendedTitle"><%=_TEX.T("MyHome.Recommended.RequestCreators")%></h2>
				<%for (CUser recommendedUser: results.m_vRecommendedRequestCreatorList){%>
				<%=CCnv.toHtmlUserMini(recommendedUser, 0, _TEX, CCnv.SP_MODE_WVIEW)%>
				<%}%>
				<%}%>

			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarPc("/MyHomePcV.jsp", "", results.m_nPage, results.m_nContentsNum, MyHomePcC.SELECT_MAX_GALLERY)%>
			</nav>
		</article>

		<%@ include file="/inner/TShowDetail.jsp"%>
		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
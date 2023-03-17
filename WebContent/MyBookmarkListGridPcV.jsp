<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

MyBookmarkC results = new MyBookmarkC();
results.getParam(request);
results.selectMaxGallery = 45;
boolean bRtn = results.getResults(checkLogin);

boolean bSmartPhone = Util.isSmartPhone(request);
boolean isApp = false;
ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdGridPcHeader.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyBookmarkList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 51px !important;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a></li>
				<li><a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a></li>
				<li><a class="TabMenuItem Selected" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper GridList" style="padding-top: 35px">
			<%if(results.contentList.size()<=0) {%>
			<div style="padding: 10px; box-sizing: border-box; text-align: center; font-size: 10px;">
				<%=_TEX.T("MyBookmarkList.LetsMessage")%>
			</div>
			<%}%>

			<section id="IllustThumbList" class="IllustItemList2Column">
				<%for(CContent cContent: results.contentList) {%>
					<%=CCnv.Content2Html2Column(cContent, checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/MyBookmarkListPcV.jsp", "&ID="+checkLogin.m_nUserId, results.page, results.contentsNum, results.selectMaxGallery)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
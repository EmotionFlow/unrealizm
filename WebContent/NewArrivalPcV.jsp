<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/NewArrivalGridPcV.jsp").forward(request,response);
	return;
}

NewArrivalC cResults = new NewArrivalC();
cResults.getParam(request);
cResults.SELECT_MAX_GALLERY = 36;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("NewArrivalPc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
			$('#MenuRecent').addClass('Selected');
		});

		$(function(){
			updateCategoryMenuPos(0);
		});
		</script>
		<style>
			body {padding-top: 83px !important;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a></li>
				<li><a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a></li>
				<li><a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a></li>
				<li><a class="TabMenuItem Selected" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a></li>
				<li><a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a></li>
				<li><a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a></li>
			</ul>
		</nav>

		<article class="Wrapper ThumbList">
			<div id="CategoryMenu" class="CategoryMenu">
				<a class="BtnBase CategoryBtn <%if(cResults.m_nCategoryId<0){%> Selected<%}%>" href="/NewArrivalPcV.jsp"><%=_TEX.T("Category.All")%></a>
				<%for(int nCategoryId : Common.CATEGORY_ID) {%>
				<a class="BtnBase CategoryBtn CC<%=nCategoryId%> <%if(nCategoryId==cResults.m_nCategoryId){%> Selected<%}%>" href="/NewArrivalPcV.jsp?CD=<%=nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></a>
				<%}%>
			</div>

			<div id="IllustThumbList" class="IllustThumbList">
				<%if(!bSmartPhone) {%>
				<%@ include file="/inner/TAdPc300x250_top_right.jsp"%>
				<%}%>
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX)%>
					<%if(nCnt==17) {%>
					<%@ include file="/inner/TAdPc300x250_bottom_right.jsp"%>
					<%}%>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/NewArrivalPcV.jsp", String.format("&CD=%d", cResults.m_nCategoryId), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
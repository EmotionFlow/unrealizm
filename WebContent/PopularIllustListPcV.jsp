<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/PopularIllustListGridPcV.jsp").forward(request,response);
	return;
}

PopularIllustListC cResults = new PopularIllustListC();
cResults.getParam(request);
cResults.SELECT_MAX_GALLERY = 36;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("PopularIllustList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
			$('#MenuHotIllust').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 83px !important;}
		</style>
	</head>

	<body>
		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
				<a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a>
				<a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a>
				<a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
				<a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
				<a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a>
				<a class="TabMenuItem Selected" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jsp"%>

		<div class="Wrapper ThumbList">

			<div id="IllustThumbList" class="IllustThumbList">
				<%if(!bSmartPhone) {%>
				<%@ include file="/inner/TAdPc300x250_top_right.jsp"%>
				<%}%>
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_PC, _TEX)%>
					<%if(nCnt==17) {%>
					<%@ include file="/inner/TAdPc300x250_bottom_right.jsp"%>
					<%}%>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/PopularIllustListPcV.jsp", "", cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
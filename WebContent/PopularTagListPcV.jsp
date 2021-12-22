<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
boolean isApp = false;

CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/PopularTagListGridPcV.jsp").forward(request,response);
	return;
}

PopularTagListC cResults = new PopularTagListC();
cResults.getParam(request);
cResults.selectMaxGallery = 45;
cResults.selectMaxSampleGallery = 45;
cResults.selectSampleGallery = 1;
boolean bRtn = cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("PopularTagList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuNew').addClass('Selected');
			$('#MenuHotTag').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 79px !important;}
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0;}
			.CategoryListItem .CategoryMore {display: block; float: left; width: 100%; text-align: right; font-size: 13px; font-weight: normal; padding: 0 7px; box-sizing: border-box;}
			.SearchResultTitle {margin: 10px 0 0 0;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a></li>
				<li><a class="TabMenuItem Selected" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a></li>
				<li><a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<style>
		</style>

		<article class="Wrapper ThumbList">
			<section class="CategoryListItem">
				<div class="IllustThumbList">
					<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeListWeekly.size(); nCnt++) {
						ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeListWeekly.get(nCnt);
						String strKeyWord = cResults.m_vTagListWeekly.get(nCnt).m_strTagTxt;
						boolean isFollowTag = cResults.m_vTagListWeekly.get(nCnt).isFollow;
					%>
					<%
					String backgroundImageUrl;
					String thumbnailFileName;
					for(CContent content : m_vContentList) {
						thumbnailFileName = content.m_strFileName;
					%>
					<%@include file="inner/TTagThumb.jsp"%>
					<%}%>
					<%}%>
				</div>
			</section>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
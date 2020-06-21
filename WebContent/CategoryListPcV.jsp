<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

CategoryListC cResults = new CategoryListC();
cResults.getParam(request);
cResults.SELECT_SAMPLE_GALLERY = (Util.isSmartPhone(request))?4:8;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("CategoryList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 83px !important;}
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0 0 20px 0;}
			.CategoryTitle {display: block; float: left; width: 100%; margin: 0; padding: 0;}
			.CategoryTitle .Category2 {font-size: 18px; padding: 10px 5px 5px 5px; display: block; font-weight: bold; color: #5bd;}
			.CategoryTitle .Category2 .More {display: block; float: right; font-size: 13px; font-weight: normal; color: #5bd;}

			<%if(Util.isSmartPhone(request)) {%>
			.IllustThumb .Category {top: 3px; left: 3px;font-size: 10px; min-width: 50px; height: 18px; line-height: 18px; max-width: 80px; padding: 0 3px;}
			.IllustThumb {margin: 2px !important; width: 86px; height: 86px;}
			.IllustThumbList {padding: 0;}
			.IllustThumb .IllustThumbImg {width: 84px; height: 84px;}
			<%} else {%>
			.IllustThumb .Category {font-size: 11px; min-width: 50px; height: 20px; line-height: 20px; padding: 0 5px;}
			.IllustThumb {margin: 2px !important; width: 118px; height: 118px;}
			.IllustThumbList {padding: 0 7px;}
			.IllustThumb .IllustThumbImg {width: 116px; height: 116px;}
			.IllustThumb .IllustInfo {padding: 3px 3px 0px 3px;}
			.IllustThumb .IllustInfo .IllustInfoDesc {font-size: 10px; height: 20px; line-height: 20px;}
			<%}%>
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a></li>
				<li><a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a></li>
				<li><a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a></li>
				<li><a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a></li>
				<li><a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a></li>
				<li><a class="TabMenuItem Selected" href="/CategoryListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Category")%></a></li>
				<li><a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a></li>
				<li><a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a></li>
			</ul>
		</nav>

		<article class="Wrapper ThumbList">
			<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeList.size(); nCnt++) {
				ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeList.get(nCnt);
				int nCategoryId = cResults.m_vContentList.get(nCnt);
			%>
			<section class="CategoryListItem">
				<h2 class="CategoryTitle">
					<a class="Category2 C<%=nCategoryId%>" href="/NewArrivalPcV.jsp?CD=<%=nCategoryId%>">
						<span class="Keyword"><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></span>
						<span class="More"><%=_TEX.T("TopV.ContentsTitle.More")%></span>
					</a>
				</h2>
				<div class="IllustThumbList" href="/NewArrivalPcV.jsp?CD=<%=nCategoryId%>">
					<%for(CContent cContent : m_vContentList) {%>
					<%=CCnv.toThumbHtml(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX)%>
					<%}%>
				</div>
			</section>
			<%if((nCnt+1)%5==0) {%>
			<%@ include file="/inner/TAd728x90_mid.jsp"%>
			<%}%>
			<%}%>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
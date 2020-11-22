<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/PopularTagListGridPcV.jsp").forward(request,response);
	return;
}

PopularTagListC cResults = new PopularTagListC();
cResults.getParam(request);
cResults.SELECT_MAX_GALLERY = 50;
cResults.SELECT_MAX_SAMPLE_GALLERY = 50;
cResults.SELECT_SAMPLE_GALLERY = 3;
boolean bRtn = cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html>
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
			body {padding-top: 83px !important;}
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

		<article class="Wrapper ThumbList">
			<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeListWeekly.size(); nCnt++) {
				ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeListWeekly.get(nCnt);
				String strKeyWord = cResults.m_vContentListWeekly.get(nCnt).m_strTagTxt;%>
			<section class="CategoryListItem">
				<header class="SearchResultTitle">
					<a class="Keyword" href="/SearchIllustByTagPcV.jsp?KWD=<%=URLEncoder.encode(strKeyWord, "UTF-8")%>">
						#<%=strKeyWord%>
					</a>
				</header>
				<div class="IllustThumbList">
					<%for(CContent cContent : m_vContentList) {%>
					<%=CCnv.toThumbHtml(cContent, checkLogin.m_nUserId, CCnv.MODE_PC, _TEX)%>
					<%}%>
				</div>
				<a class="CategoryMore" href="/SearchIllustByTagPcV.jsp?KWD=<%=URLEncoder.encode(strKeyWord, "UTF-8")%>">
					<%=_TEX.T("TopV.ContentsTitle.More")%>&nbsp;<i class="fas fa-angle-right"></i>
				</a>
			</section>
			<%if(nCnt==4 || nCnt==9 || nCnt==14 || nCnt==19 || nCnt==24 || nCnt==29 || nCnt==34 || nCnt==39 || nCnt==44) {%>
			<%@ include file="/inner/TAd728x90_mid.jsp"%>
			<%}%>
			<%}%>
		</article>

		<%if(cResults.SELECT_MAX_SAMPLE_GALLERY-cResults.SELECT_MAX_GALLERY>0) {%>
		<article class="Wrapper ItemList">
			<section id="IllustThumbList" class="IllustThumbList" style="padding: 0;">
			<%for(int nCnt=cResults.SELECT_MAX_SAMPLE_GALLERY; nCnt<cResults.m_vContentListWeekly.size(); nCnt++) {
				CTag cTag = cResults.m_vContentListWeekly.get(nCnt);%>
				<%=CCnv.toHtml(cTag, CCnv.MODE_PC, _TEX)%>
				<%if((nCnt+1)%15==0) {%>
				<%@ include file="/inner/TAd728x90_mid.jsp"%>
				<%}%>
			<%}%>
			</section>
		</article>
		<%}%>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
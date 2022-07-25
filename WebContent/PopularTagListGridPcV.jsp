<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
PopularTagListC cResults = new PopularTagListC();
cResults.getParam(request);
cResults.selectMaxGallery = 15;
cResults.selectMaxSampleGallery = 15;
cResults.selectSampleGallery = 6;
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
			$('body, .Wrapper').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){return false;});
			});
			$('#MenuNew').addClass('Selected');
			$('#MenuHotTag').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 79px !important;}
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0;}
			.CategoryListItem .CategoryMore {display: block; float: left; width: 100%; text-align: right; font-size: 13px; font-weight: normal; padding: 0 7px; box-sizing: border-box;}
			.SearchResultTitle {margin: 10px 0 0 5px;}
		</style>
	</head>

	<body>
		<%String searchType = "Contents";%>
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

		<article class="Wrapper GridList">
			<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeListWeekly.size(); nCnt++) {
				ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeListWeekly.get(nCnt);
				CTag tag = cResults.m_vTagListWeekly.get(nCnt);
				String strKeyWord = tag.m_strTagTxt;%>
			<section class="CategoryListItem">
				<header class="SearchGenreTitle">
					<span class="GenreImage" style="background-image: url('<%=Common.GetUrl(tag.m_strImageUrl)%>');"></span>
					<div class="GenreName">
						<h2 class="GenreNameOrg">#<%=tag.m_strTagTxt%></h2>
						<div class="GenreNameTranslate" translate="no">
							<i class="fas fa-language"></i>
							<%if(tag.m_strTagTransTxt!=null){%>
							<%=tag.m_strTagTransTxt%>
							<%}%>
						</div>
					</div>
				</header>
				<div class="IllustThumbList">
					<%for(CContent cContent : m_vContentList) {%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
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

		<%if(cResults.selectMaxSampleGallery -cResults.selectMaxGallery >0) {%>
		<article class="Wrapper ItemList">
			<section id="IllustThumbList" class="IllustThumbList" style="padding: 0;">
			<%for(int nCnt = cResults.selectMaxSampleGallery; nCnt<cResults.m_vTagListWeekly.size(); nCnt++) {
				CTag cTag = cResults.m_vTagListWeekly.get(nCnt);%>
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
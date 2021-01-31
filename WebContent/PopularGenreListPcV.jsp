<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/PopularGenreListGridPcV.jsp").forward(request,response);
	return;
}

PopularGenreListC results = new PopularGenreListC();
results.getParam(request);
results.SELECT_MAX = 45;
boolean bRtn = results.getResults(checkLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("PopularTagList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuGenre').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 79px !important;}

		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem <%if(results.order==0){%>Selected<%}%>" href="/PopularGenreListPcV.jsp"><%=_TEX.T("PopularTagList.TabMenu.Recent")%></a></li>
				<!--
				<li><a class="TabMenuItem <%if(results.order==1){%>Selected<%}%>" href="/PopularGenreListPcV.jsp?OD=0"><%=_TEX.T("PopularTagList.TabMenu.Popular")%></a></li>
				<li><a class="TabMenuItem <%if(results.order==2){%>Selected<%}%>" href="/PopularGenreListPcV.jsp?OD=1"><%=_TEX.T("PopularTagList.TabMenu.Hot")%></a></li>
				-->
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<div class="SearchGenre">
			<div class="SearchEdit">
				<a class="SearchEditCmd PoiPassInline" href="/EditGenreInfoPcV.jsp?ID=<%=checkLogin.m_nUserId%>&GD=-1"><i class="fas fa-pencil-alt"></i><%=_TEX.T("SearchIllustByGenre.New")%></a>
			</div>
		</div>


		<article class="Wrapper ItemList">
			<section id="IllustThumbList" class="IllustThumbList">
			<%for(int nCnt=0; nCnt<results.contents.size(); nCnt++) {
				Genre genre = results.contents.get(nCnt);%>
			<a class="GenreItem" href="SearchIllustByGenrePcV.jsp?GD=<%=genre.genreId%>">
				<span class="GenreImage" style="background-image: url('<%=Common.GetUrl(genre.genreImage)%>');" ></span>
				<span class="GenreInfo">
					<h2 class="GenreTitle"><%=Util.toStringHtml(genre.genreName)%></h2>
					<span class="GenreDesc"><%=Util.toStringHtml(genre.genreDesc)%></span>
					<span class="GenreData">
						<span class="DataItem"><i class="far fa-image"></i> <%=genre.contentNumTotal%></span>
						<span class="DataItem"><i class="fas fa-star"></i> <%=genre.favoNum%></span>
					</span>
				</span>
			</a>
			<%if(nCnt==14) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp"%><%}%>
			<%if(nCnt==29) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp"%><%}%>
			<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/PopularGenreListPcV.jsp", String.format("&OD=%d", results.order), results.m_nPage, results.contentsNum, results.SELECT_MAX)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

PopularGenreListC results = new PopularGenreListC();
results.getParam(request);
results.SELECT_MAX = 70;
boolean bRtn = results.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdGridPcHeader.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("PopularTagList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuGenre').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 79px !important;}
			.SearchGenre .SearchEdit {margin: 0 0 5px 0;}
		</style>
	</head>

	<body>
		<%String searchType = "Contents";%>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem <%if(results.order==0){%>Selected<%}%>" href="/PopularGenreListPcV.jsp"><%=_TEX.T("PopularTagList.TabMenu.Popular")%></a></li>
				<li><a class="TabMenuItem <%if(results.order==1){%>Selected<%}%>" href="/PopularGenreListPcV.jsp?OD=1"><%=_TEX.T("PopularTagList.TabMenu.Hot")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper GridList">
			<section id="IllustThumbList" class="IllustThumbList">
			<%for(int nCnt=0; nCnt<results.contents.size(); nCnt++) {
				GenreRank genre = results.contents.get(nCnt);%>
			<a class="GenreItem" href="SearchIllustByTagPcV.jsp?GD=<%=genre.genreId%>">
				<span class="GenreImage" style="background-image: url('<%=Common.GetUrl(genre.genreImage)%>');" ></span>
				<span class="GenreInfo">
					<h2 class="GenreNameOrg"><%=Util.toStringHtml(genre.genreName)%></h2>
					<span class="GenreDesc"><%=Util.toStringHtml(genre.genreDesc)%></span>
					<span class="GenreData">
						<span class="DataItem"><i class="far fa-image"></i> <%=genre.rank%></span>
					</span>
				</span>
			</a>
			<%if(nCnt==1){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_1.jsp"%><%}%>
			<%if(nCnt==25){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_2.jsp"%><%}%>
			<%if(nCnt==47){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_3.jsp"%><%}%>
			<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/PopularGenreListPcV.jsp", String.format("&OD=%d", results.order), results.m_nPage, results.contentsNum, results.SELECT_MAX)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>

<%@ page import="java.util.stream.Collectors" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

SearchIllustByTagC results = new SearchIllustByTagC();
results.getParam(request);
results.selectMaxGallery = 48;
boolean bRtn = results.getResults(checkLogin);
String strEncodedKeyword = URLEncoder.encode(results.keyword, "UTF-8");
String strTitle = String.format(_TEX.T("SearchIllustByTag.Title"), results.keyword) + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("SearchIllustByTag.Title.Desc"), results.keyword, results.contentsNum);
String strUrl = "https://poipiku.com/SearchIllustByTagPcV.jsp?GD="+results.genreId;
String strFileUrl = results.m_strRepFileName;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdGridPcHeader.jsp"%>
		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<meta name="twitter:site" content="@pipajp" />
		<meta property="og:url" content="<%=strUrl%>" />
		<meta property="og:title" content="<%=Util.toDescString(strTitle)%>" />
		<meta property="og:description" content="<%=Util.toDescString(strDesc)%>" />
		<link rel="canonical" href="<%=strUrl%>" />
		<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=Util.toDescString(strTitle)%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuGenre').addClass('Selected');
		});
		</script>

		<%if(!results.genre.genreImageBg.isEmpty()) {%>
		<style>
			.SearchGenreFrame {background-image:url('<%=Common.GetUrl(results.genre.genreImageBg)%>');}
		</style>
		<%}%>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<header class="SearchGenreFrame">
			<div class="SearchGenre">
				<div class="SearchEdit">
					<a class="SearchEditCmd PoiPassInline" href="/EditGenreInfoPcV.jsp?ID=<%=checkLogin.m_nUserId%>&GD=<%=results.genre.genreId%>"><i class="fas fa-pencil-alt"></i> <%=_TEX.T("SearchIllustByGenre.Edit")%></a>
				</div>
				<div class="SearchGenreMeta">
					<div class="SearchGenreTitle">
						<span class="GenreImage" style="background-image: url('<%=Common.GetUrl(results.genre.genreImage)%>');" ></span>
						<div class="GenreName">
							<h2 class="GenreNameOrg">#<%=Util.toStringHtml(results.genre.genreName)%></h2>
							<div class="GenreNameTranslate" translate="no">
								<i class="fas fa-language"></i>
								<%if(results.nameTranslationList!=null){%>
								<%=results.nameTranslationList.stream().map(e->String.format("<span>%s</span>", Util.toStringHtml(e))).collect(Collectors.joining(""))%>
								<%}%>
							</div>
						</div>
					</div>
					<div class="SearchGenreDesc"><%=Util.toStringHtml(results.genre.genreDesc)%></div>
				</div>
				<%if (!results.genre.genreDetail.isEmpty()){ %>
				<div id="GenreDetail" class="SearchGenreDetail"><%=Common.AutoLinkHtml(Util.toStringHtml(results.genre.genreDetail), CCnv.SP_MODE_WVIEW)%></div>
				<%}%>
				<div class="SearchGenreCmd">
					<%if(!checkLogin.m_bLogin) {%>
					<a class="CmdBtn BtnBase Rev TitleCmdFollow" href="/"><i class="fas fa-tag"></i> <%=_TEX.T("IllustV.Tag.Follow")%></a>
					<%} else if(!results.following) {%>
					<a class="CmdBtn BtnBase Rev TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(results.keyword)%>')"><i class="far fa-star"></i> <%=_TEX.T("IllustV.Tag.Follow")%></a>
					<%} else {%>
					<a class="CmdBtn BtnBase Rev TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(results.keyword)%>')"><i class="far fa-star"></i> <%=_TEX.T("IllustV.Tag.UnFollow")%></a>
					<%}%>
				</div>
			</div>
		</header>

		<article class="Wrapper GridList">
			<section id="IllustThumbList" class="IllustThumbList">
				<%
					for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
							CContent cContent = results.contentList.get(nCnt);
				%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
					<%if(nCnt==3){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_1.jsp"%><%}%>
					<%if(nCnt==19){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_2.jsp"%><%}%>
					<%if(nCnt==35){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_3.jsp"%><%}%>
				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/SearchIllustByTagPcV.jsp", String.format("&GD=%d", results.genreId) , results.page, results.contentsNum, results.selectMaxGallery)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>

<%@ page import="java.util.stream.Collectors" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

SearchIllustByTagC results = new SearchIllustByTagC();
results.getParam(request);
results.selectMaxGallery = 48;
boolean bRtn = results.getResults(checkLogin);

final String tagName = (results.transTagName != null && !results.transTagName.isEmpty()) ? results.transTagName : results.keyword;
final String strTitle = String.format(_TEX.T("SearchIllustByTag.Title"), tagName);
final String strDesc = String.format(_TEX.T("SearchIllustByTag.Title.Desc"), tagName, results.contentsNum);
final String strUrl = "https://unrealizm.com/SearchIllustByTagPcV.jsp?GD="+results.genreId;

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
					<a class="SearchEditCmd PoiPassInline" href="/EditGenreInfoPcV.jsp?ID=<%=checkLogin.m_nUserId%>&GD=<%=results.genre.genreId%>">
						<span class="AnyoneOK"><%=_TEX.T("SearchIllustByGenre.Edit.AnyoneOK")%></span><span style="font-size: 12px"><i class="far fa-edit"></i><%=_TEX.T("SearchIllustByGenre.Edit")%></span>
					</a>
				</div>
				<div class="SearchGenreMeta">
					<div class="SearchGenreTitle">
						<span class="GenreImage" style="background-image: url('<%=Common.GetUrl(results.genre.genreImage)%>');" ></span>
						<div class="GenreName">
							<h2 class="GenreNameOrg">#<%=Util.toStringHtml(results.genre.genreName)%></h2>
							<a class="GenreNameTranslate" translate="no" href="/EditGenreInfoPcV.jsp?ID=<%=checkLogin.m_nUserId%>&GD=<%=results.genre.genreId%>">
								<i class="fas fa-language"></i>
								<%if(results.nameTranslationList!=null){%>
								<%=results.nameTranslationList.stream().map(e->String.format("<span>%s</span>", Util.toStringHtml(e))).collect(Collectors.joining(""))%>
								<%}%>
							</a>
						</div>
					</div>
					<div class="SearchGenreDesc"><%=Util.toStringHtml(results.genre.genreDesc)%></div>
				</div>
				<%if (!results.genre.genreDetail.isEmpty()){ %>
				<div id="GenreDetail" class="SearchGenreDetail"><%=Common.AutoLinkHtml(Util.toStringHtml(results.genre.genreDetail), CCnv.SP_MODE_WVIEW)%></div>
				<%}%>
				<div class="SearchGenreCmd">
					<%if(!checkLogin.m_bLogin) {%>
					<a class="CmdBtn BtnBase TitleCmdFollow" href="/"><i class="fas fa-tag"></i> <%=_TEX.T("IllustV.Tag.Follow")%></a>
					<%} else if(!results.following) {%>
					<a class="CmdBtn BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(results.keyword)%>')"><i class="far fa-star"></i> <%=_TEX.T("IllustV.Tag.Follow")%></a>
					<%} else {%>
					<a class="CmdBtn BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(results.keyword)%>')"><i class="far fa-star"></i> <%=_TEX.T("IllustV.Tag.UnFollow")%></a>
					<%}%>
				</div>
			</div>
		</header>

		<article class="Wrapper GridList">
			<section id="IllustThumbList" class="IllustItemList2Column">
				<%for(CContent cContent: results.contentList) {%>
					<%=CCnv.Content2Html2Column(cContent, checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/SearchIllustByTagPcV.jsp", String.format("&GD=%d", results.genreId) , results.page, results.contentsNum, results.selectMaxGallery)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>

<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
boolean isApp = false;

CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

SearchTagByKeywordC results = new SearchTagByKeywordC();
results.getParam(request);

if (results.m_strKeyword.indexOf("@") == 0) {
	response.sendRedirect("https://ai.poipiku.com/SearchUserByKeyword" + (isApp?"App":"Pc") + "V.jsp?KWD=" + URLEncoder.encode(results.m_strKeyword.replaceFirst("@", ""), StandardCharsets.UTF_8));
	return;
}

results.selectMaxGallery = 45;
results.getResults(checkLogin);
g_strSearchWord = results.m_strKeyword;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdSearchUserPcHeader.jsp"%>
		<meta name="description" content="<%=Util.toStringHtml(String.format(_TEX.T("SearchTagByKeyword.Title.Desc"), results.m_strKeyword))%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("SearchTagByKeyword.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuNew').addClass('Selected');
		});
		</script>

		<script>
			$(function(){
				$('#HeaderSearchWrapper').on('submit', SearchByKeyword('Tags', <%=checkLogin.m_nUserId%>, <%=Common.SEARCH_LOG_SUGGEST_MAX[checkLogin.m_nPassportId]%>));
				$('#HeaderSearchBtn').on('click', SearchByKeyword('Tags', <%=checkLogin.m_nUserId%>, <%=Common.SEARCH_LOG_SUGGEST_MAX[checkLogin.m_nPassportId]%>));
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
				<li><a class="TabMenuItem" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
				<li><a class="TabMenuItem Selected" href="/SearchTagByKeywordPcV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/SearchUserByKeywordPcV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.User")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper ItemList">
			<header class="SearchResultTitle">
				<h2 class="Keyword">#<%=Util.toStringHtml(results.m_strKeyword)%></h2>
			</header>
			<section id="IllustThumbList" class="IllustItemList">
				<%
				String backgroundImageUrl;
				String thumbnailFileName;
				CTag tag;
				String strKeyWord;
				String transTxt;
				boolean isFollowTag;
				int genreId;
				for(int nCnt = 0; nCnt< results.tagList.size(); nCnt++) {
					tag = results.tagList.get(nCnt);
					strKeyWord = tag.m_strTagTxt;
					isFollowTag = tag.isFollow;
					thumbnailFileName = results.sampleContentFile.get(nCnt);
					genreId = tag.m_nGenreId;
					transTxt = tag.m_strTagTransTxt;
				%>
				<%@include file="inner/TTagThumb.jsp"%>

				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/SearchTagByKeywordPcV.jsp", "&KWD="+results.encodedKeyword, results.m_nPage, results.contentsNum, results.selectMaxGallery)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
boolean isApp = false;

CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

SearchTagByKeywordC results = new SearchTagByKeywordC();
results.getParam(request);
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
				$('#HeaderSearchWrapper').attr("action","/SearchTagByKeywordPcV.jsp");
				$('#HeaderSearchBtn').on('click', SearchTagByKeyword);
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
				<li><a class="TabMenuItem" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(results.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
				<li><a class="TabMenuItem Selected" href="/SearchTagByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(results.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/SearchUserByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(results.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.User")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper ItemList">
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
				<%=CPageBar.CreatePageBarSp("/SearchTagByKeywordPcV.jsp", "&KWD="+URLEncoder.encode(results.m_strKeyword, "UTF-8"), results.m_nPage, results.contentsNum, results.selectMaxGallery)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
if (Util.isBot(request)) return;

CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/SearchIllustByKeywordGridPcV.jsp").forward(request,response);
	return;
}

ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
SearchIllustByKeywordC cResults = new SearchIllustByKeywordC();
cResults.getParam(request);
if (isApp) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}


if (cResults.keyword.indexOf("#") == 0) {
	response.sendRedirect("https://unrealizm.com/SearchTagByKeywordPcV.jsp?KWD=" + URLEncoder.encode(cResults.keyword.replaceFirst("#", ""), StandardCharsets.UTF_8));
	return;
} else if (cResults.keyword.indexOf("@") == 0) {
	response.sendRedirect("https://unrealizm.com/SearchUserByKeywordPcV.jsp?KWD=" + URLEncoder.encode(cResults.keyword.replaceFirst("@", ""), StandardCharsets.UTF_8));
	return;
}

cResults.selectMaxGallery = 10;
boolean bRtn = cResults.getResults(checkLogin);
g_strSearchWord = cResults.keyword;
String strTitle = cResults.keyword + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("SearchIllustByTag.Title.Desc"), cResults.keyword, cResults.m_nContentsNum);
String strUrl = "https://unrealizm.com/SearchIllustByKeywordPcV.jsp?KWD="+cResults.encodedKeyword;
String strFileUrl = cResults.m_strRepFileName;

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
<head>
	<%if(!isApp){%>
	<%@ include file="/inner/THeaderCommonNoGenieePc.jsp"%>
	<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
	<%}else{%>
	<%@ include file="/inner/THeaderCommonNoGenieePc.jsp"%>
	<%}%>

	<%@ include file="/inner/TSendEmoji.jsp"%>
	<%@ include file="/inner/TReplyEmoji.jsp"%>
	<%@ include file="/inner/TRetweetContent.jsp"%>
	<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>

	<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
	<meta name="twitter:site" content="@pipajp" />
	<meta property="og:url" content="<%=strUrl%>" />
	<meta property="og:title" content="<%=Util.toDescString(strTitle)%>" />
	<meta property="og:description" content="<%=Util.toDescString(strDesc)%>" />
	<link rel="canonical" href="<%=strUrl%>" />
	<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />
	<title><%=Util.toDescString(strTitle)%></title>

	<script src="/js/masonry.pkgd.min.js"></script>
	<script src="/js/imagesloaded.pkgd.min.js"></script>

	<script type="text/javascript">
		<%if(!isApp){%>
		$(function(){
			$('#MenuNew').addClass('Selected');
		});
		<%}%>

		let lastContentId = <%=cResults.contentList.size()>0 ? cResults.contentList.get(cResults.contentList.size()-1).m_nContentId : -1%>;
		let page = 0;

		const loadingSpinner = {
			appendTo: "#IllustItemList",
			className: "loadingSpinner",
		}
		const observer = createIntersectionObserver(addContents);

		function addContents() {
			console.log("addContents");
			appendLoadingSpinner(loadingSpinner.appendTo, loadingSpinner.className);
			return $.ajax({
				"type": "post",
				"data": {
					"PG": page,
					"KWD": "<%=cResults.keyword%>",
					"MD": <%=CCnv.MODE_SP%>,
					"VD": <%=CCnv.VIEW_DETAIL%>,
					"SD": lastContentId,
				},
				"dataType": "json",
				"url": "/f/SearchIllustByKeywordF.jsp",
			}).then((data) => {
				page++;
				if (data.end_id > 0) {
					lastContentId = data.end_id;
					const contents = document.getElementById('IllustItemList');
					$(contents).append(data.html);
					observer.observe(contents.lastElementChild);

					let $newElems  = $('.IllustItem[style*="opacity: 0"]');
					<%if (!Common.isDevEnv()){ %>
					$('#IllustItemList').imagesLoaded(function(){
					<%}%>
					$newElems.animate({ opacity: 1 });
					$('#IllustItemList').masonry('appended', $newElems, true);
						<%if (!Common.isDevEnv()){ %>
					});
					<%}%>
				}
				removeLoadingSpinners(loadingSpinner.className);
			}, (error) => {
				DispMsg('Connection error');
			});
		}

		function initContents() {
			const contents = document.getElementById('IllustItemList');
			observer.observe(contents.lastElementChild);
		}

		$(function(){
			$('#HeaderSearchWrapper').on('submit', SearchByKeyword('Contents', <%=checkLogin.m_nUserId%>, <%=Common.SEARCH_LOG_SUGGEST_MAX[checkLogin.m_nPassportId]%>));
			$('#HeaderSearchBtn').on('click', SearchByKeyword('Contents', <%=checkLogin.m_nUserId%>, <%=Common.SEARCH_LOG_SUGGEST_MAX[checkLogin.m_nPassportId]%>));
			$('body, .Wrapper').each(function(index, element){
				$(element).on("drag dragstart",function(e){return false;});
			});
			initContents();
		});
	</script>

	<%if (!isApp) {%>
	<style>body {padding-top: 51px !important;}</style>
	<%} else {%>
	<style>body {padding-top: 0 !important;}</style>
	<%}%>

	<script>
		var _columnWidth = 180;
		<%if (!isApp && !bSmartPhone) {%>
		_columnWidth = 236;
		<%}%>

		$(function () {
			<%if (!Common.isDevEnv()){ %>
			$('#IllustItemList').imagesLoaded(function(){
			<%}%>
				let $newElems = $('.IllustItem, .loadingSpinner');
				$newElems.animate({ opacity: 1 });
				$('#IllustItemList').masonry({
					itemSelector: '.IllustItem',
					columnWidth: _columnWidth,
					isFitWidth: true,
					gutterWidth: 0,
				});
			<%if (!Common.isDevEnv()){ %>
			});
			<%}%>
		});
	</script>

</head>

<body>
<%if (!isApp) {%>
<%@ include file="/inner/TMenuPc.jsp"%>
<nav class="TabMenuWrapper">
	<ul class="TabMenu">
		<li><a class="TabMenuItem Selected" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=cResults.encodedKeyword%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
		<li><a class="TabMenuItem" href="/SearchTagByKeywordPcV.jsp?KWD=<%=cResults.encodedKeyword%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
		<li><a class="TabMenuItem" href="/SearchUserByKeywordPcV.jsp?KWD=<%=cResults.encodedKeyword%>"><%=_TEX.T("Search.Cat.User")%></a></li>
	</ul>
</nav>
<%} else {%>
<%@ include file="/inner/TMenuApp.jsp"%>
<%}%>

<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

<article class="Wrapper ThumbList">

	<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
	<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin: 12px 0 0 0;">
		<%@ include file="/inner/ad/TAdHomeSp300x100_top.jsp"%>
	</span>
	<%}%>

	<header class="SearchResultTitle">
		<h2 class="Keyword"><i class="fas fa-search"></i> <%=Util.toStringHtml(cResults.keyword)%></h2>
	</header>

	<section
			id="IllustItemList"
			class="IllustItemList2Column"
			style="position: relative; top: <%=checkLogin.m_nPassportId==Common.PASSPORT_OFF?72:48%>px;"
	>
		<% for (int cnt = 0; cnt<cResults.contentList.size(); cnt++) { %>
		<%=CCnv.Content2Html2Column(cResults.contentList.get(cnt), checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
		<% if (checkLogin.m_nPassportId==Common.PASSPORT_OFF && (cnt == 3 || cnt == 9) && bSmartPhone){ %>
		<div class="IllustItem" style="width: 360px; height: 250px; background: none; border: none;">
		<%=Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter)%>
		</div>
		<%}%>
		<%}%>
	</section>
</article>
<%@ include file="/inner/TShowDetail.jsp"%>
</body>
<%@include file="/inner/PolyfillIntersectionObserver.jsp"%>
</html>

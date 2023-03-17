<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
if (Util.isBot(request)) return;

CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
SearchIllustByKeywordC results = new SearchIllustByKeywordC();
results.getParam(request);
if (isApp) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}


if (results.keyword.indexOf("#") == 0) {
	response.sendRedirect("https://unrealizm.com/SearchTagByKeywordPcV.jsp?KWD=" + URLEncoder.encode(results.keyword.replaceFirst("#", ""), StandardCharsets.UTF_8));
	return;
} else if (results.keyword.indexOf("@") == 0) {
	response.sendRedirect("https://unrealizm.com/SearchUserByKeywordPcV.jsp?KWD=" + URLEncoder.encode(results.keyword.replaceFirst("@", ""), StandardCharsets.UTF_8));
	return;
}

results.selectMaxGallery = 10;
boolean bRtn = results.getResults(checkLogin);
g_strSearchWord = results.keyword;
String strTitle = results.keyword + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("SearchIllustByTag.Title.Desc"), results.keyword, results.m_nContentsNum);
String strUrl = "https://unrealizm.com/SearchIllustByKeywordPcV.jsp?KWD="+results.encodedKeyword;
String strFileUrl = results.m_strRepFileName;

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

	<script src="/js/imagesloaded.pkgd.min.js"></script>

	<script type="text/javascript">
		<%if(!isApp){%>
		$(function(){
			$('#MenuNew').addClass('Selected');
		});
		<%}%>

		let lastContentId = <%=results.contentList.size()>0 ? results.contentList.get(results.contentList.size()-1).m_nContentId : -1%>;
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
					"KWD": "<%=results.keyword%>",
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
//					$('#IllustItemList').masonry('appended', $newElems, true);
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
//				$('#IllustItemList').masonry({
//					itemSelector: '.IllustItem',
//					columnWidth: _columnWidth,
//					isFitWidth: true,
//					gutterWidth: 0,
//				});
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
		<li><a class="TabMenuItem Selected" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
		<li><a class="TabMenuItem" href="/SearchTagByKeywordPcV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
		<li><a class="TabMenuItem" href="/SearchUserByKeywordPcV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.User")%></a></li>
	</ul>
</nav>
<%} else {%>
<%@ include file="/inner/TMenuApp.jsp"%>
<%}%>

<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

<article class="Wrapper ThumbList" style="padding-top: 30px">

	<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd && false) {%>
	<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin: 12px 0 0 0;">
		<%@ include file="/inner/ad/TAdHomeSp300x100_top.jsp"%>
	</span>
	<%}%>

	<header class="SearchResultTitle">
		<h2 class="Keyword"><i class="fas fa-search"></i> <%=Util.toStringHtml(results.keyword)%></h2>
	</header>

	<section id="IllustItemList" class="IllustItemList2Column">
		<%for(CContent cContent: results.contentList) {%>
			<%=CCnv.Content2Html2Column(cContent, checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
		<%}%>
	</section>
</article>
<%@ include file="/inner/TShowDetail.jsp"%>
</body>
<%@include file="/inner/PolyfillIntersectionObserver.jsp"%>
</html>

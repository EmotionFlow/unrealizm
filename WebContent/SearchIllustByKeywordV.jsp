<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
if (Util.isBot(request)) return;

CheckLogin checkLogin = new CheckLogin(request, response);
SearchIllustByKeywordC results = new SearchIllustByKeywordC();
results.getParam(request);
if (g_isApp) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}


if (results.keyword.indexOf("#") == 0) {
	response.sendRedirect("https://unrealizm.com/SearchTagByKeywordV.jsp?KWD=" + URLEncoder.encode(results.keyword.replaceFirst("#", ""), StandardCharsets.UTF_8));
	return;
} else if (results.keyword.indexOf("@") == 0) {
	response.sendRedirect("https://unrealizm.com/SearchUserByKeywordV.jsp?KWD=" + URLEncoder.encode(results.keyword.replaceFirst("@", ""), StandardCharsets.UTF_8));
	return;
}

results.selectMaxGallery = 10;
boolean bRtn = results.getResults(checkLogin);
g_strSearchWord = results.keyword;
String strTitle = results.keyword + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("SearchIllustByTag.Title.Desc"), results.keyword, results.m_nContentsNum);
String strUrl = "https://unrealizm.com/SearchIllustByKeywordV.jsp?KWD="+results.encodedKeyword;
String strFileUrl = results.m_strRepFileName;

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
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
			<%if(!g_isApp){%>
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

		<script>
			var _columnWidth = 180;

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
		<%@ include file="/inner/TMenuPc.jsp"%>

		<%if (!g_isApp) {%>
		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem Selected" href="/SearchIllustByKeywordV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
				<li><a class="TabMenuItem" href="/SearchTagByKeywordV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/SearchUserByKeywordV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.User")%></a></li>
			</ul>
		</nav>
		<%}%>

		<article class="Wrapper" style="padding-top: 28px">
			<header class="SearchResultTitle">
				<h2 class="Keyword"><span class="material-symbols-sharp">search</span><%=Util.toStringHtml(results.keyword)%></h2>
			</header>

			<section id="IllustItemList" class="IllustItemList2Column">
				<%for(CContent content: results.contentList) {%>
					<%=CCnv.Content2Html2Column(content, checkLogin, _TEX)%>
				<%}%>
			</section>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
	<%@include file="/inner/PolyfillIntersectionObserver.jsp"%>
</html>

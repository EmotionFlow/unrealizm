<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

SearchTagByKeywordC results = new SearchTagByKeywordC();
results.getParam(request);

if (results.m_strKeyword.indexOf("@") == 0) {
	response.sendRedirect("https://unrealizm.com/SearchUserByKeywordV.jsp?KWD=" + URLEncoder.encode(results.m_strKeyword.replaceFirst("@", ""), StandardCharsets.UTF_8));
	return;
}

boolean bRtn = results.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%if(!g_isApp){%>
		<script type="text/javascript">
			$(function(){
				$('#MenuNew').addClass('Selected');
				$('#HeaderSearchWrapper').on('submit', SearchByKeyword('Tags', <%=checkLogin.m_nUserId%>, <%=Common.SEARCH_LOG_SUGGEST_MAX[checkLogin.m_nPassportId]%>));
				$('#HeaderSearchBtn').on('click', SearchByKeyword('Tags', <%=checkLogin.m_nUserId%>, <%=Common.SEARCH_LOG_SUGGEST_MAX[checkLogin.m_nPassportId]%>));
			});
		</script>
		<%}%>
		<meta name="description" content="<%=Util.toStringHtml(String.format(_TEX.T("SearchTagByKeyword.Title.Desc"), results.m_strKeyword))%>" />
		<title><%=Util.toStringHtml(results.m_strKeyword)%></title>
		<script>
			var g_nPage = 1;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"PG" : g_nPage, "KWD" :  "<%=results.m_strKeyword%>"},
					"url": "/f/SearchTagByKeywordF.jsp",
					"success": function(data) {
						if($.trim(data).length>0) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustThumbList").append(data);
							g_bAdding = false;
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
						} else {
							$(window).unbind("scroll.addContents");
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			$(function(){
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
			});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<%if(!g_isApp){%>
		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/SearchIllustByKeywordV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
				<li><a class="TabMenuItem Selected" href="/SearchTagByKeywordV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/SearchUserByKeywordV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.User")%></a></li>
			</ul>
		</nav>
		<%}%>

		<article class="Wrapper" style="padding-top: 28px">
			<header class="SearchResultTitle">
				<h2 class="Keyword">#<%=Util.toStringHtml(results.m_strKeyword)%></h2>
			</header>
			<section id="IllustThumbList" class="IllustItemList2Column">
				<%for(int nCnt = 0; nCnt<results.tagList.size(); nCnt++) {
					CTag cTag = results.tagList.get(nCnt);%>
					<%=CCnv.toHtmlTag(cTag, results.sampleContentFile.get(nCnt), checkLogin.m_nUserId)%>
				<%}%>
			</section>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>

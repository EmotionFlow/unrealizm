<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
if(Util.isBot(request)) {
	return;
}

final String referer = Util.toString(request.getHeader("Referer"));
if (!g_isApp && !referer.contains("unrealizm.com")) {
	Log.d("不正アクセス(referer不一致):" + referer);
//	return;
}

CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailV.jsp").forward(request,response);
	return;
}

SearchUserByKeywordC results = new SearchUserByKeywordC();
results.getParam(request);

if (results.m_strKeyword.indexOf("#") == 0) {
	response.sendRedirect("https://unrealizm.com/SearchTagByKeywordV.jsp?KWD=" + URLEncoder.encode(results.m_strKeyword.replaceFirst("#", ""), StandardCharsets.UTF_8));
	return;
}

String strKeywordHan = Util.toSingle(results.m_strKeyword);
if(strKeywordHan.matches("^[0-9]+$")) {
	String strUrl = (g_isApp ? "/IllustListAppV.jsp?ID=%s" : "/%s/").formatted(strKeywordHan);
	response.sendRedirect(Common.GetUnrealizmUrl(strUrl));
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
			});
		</script>

		<script>
			$(function(){
				$('#HeaderSearchWrapper').on('submit', SearchByKeyword('Users', <%=checkLogin.m_nUserId%>, <%=Common.SEARCH_LOG_SUGGEST_MAX[checkLogin.m_nPassportId]%>));
				$('#HeaderSearchBtn').on('click', SearchByKeyword('Users', <%=checkLogin.m_nUserId%>, <%=Common.SEARCH_LOG_SUGGEST_MAX[checkLogin.m_nPassportId]%>));
			});
		</script>
		<%}%>

		<meta name="description" content="<%=Util.toStringHtml(String.format(_TEX.T("SearchUserByKeyword.Title.Desc"), results.m_strKeyword))%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("SearchUserByKeyword.Title")%></title>
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
					"data": {"PG" : g_nPage, "KWD" :  decodeURIComponent("<%=URLEncoder.encode(results.m_strKeyword, "UTF-8")%>")},
					"url": "/f/SearchUserByKeywordF.jsp",
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
				<li><a class="TabMenuItem" href="/SearchTagByKeywordV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
				<li><a class="TabMenuItem Selected" href="/SearchUserByKeywordV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.User")%></a></li>
			</ul>
		</nav>
		<%}%>

		<article class="Wrapper" style="padding-top: 28px">
			<header class="SearchResultTitle">
				<h2 class="Keyword">@<%=Util.toStringHtml(results.m_strKeyword)%></h2>
			</header>
			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt = 0; nCnt<results.selectByNicknameUsers.size(); nCnt++) {
					CUser cUser = results.selectByNicknameUsers.get(nCnt);%>
					<%=CCnv.toHtmlUserMini(cUser)%>
				<%}%>
			</section>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>

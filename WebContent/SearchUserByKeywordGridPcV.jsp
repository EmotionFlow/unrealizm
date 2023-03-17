<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
if(Util.isBot(request)) {
	return;
}

final String referer = Util.toString(request.getHeader("Referer"));
if (!referer.contains("unrealizm.com")) {
	Log.d("不正アクセス(referer不一致):" + referer);
	return;
}

CheckLogin checkLogin = new CheckLogin(request, response);

SearchUserByKeywordC results = new SearchUserByKeywordC();
results.getParam(request);

if (results.m_strKeyword.indexOf("#") == 0) {
	response.sendRedirect("https://unrealizm.com/SearchTagByKeywordPcV.jsp?KWD=" + URLEncoder.encode(results.m_strKeyword.replaceFirst("#", ""), StandardCharsets.UTF_8));
	return;
}

results.SELECT_MAX_GALLERY = 45;

boolean bRtn = results.getResults(checkLogin);
g_strSearchWord = results.m_strKeyword;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdSearchUserPcHeader.jsp"%>
		<meta name="description" content="<%=Util.toStringHtml(String.format(_TEX.T("SearchUserByKeyword.Title.Desc"), results.m_strKeyword))%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("SearchUserByKeyword.Title")%></title>

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

		<style>
			body {padding-top: 51px !important;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
				<li><a class="TabMenuItem" href="/SearchTagByKeywordPcV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
				<li><a class="TabMenuItem Selected" href="/SearchUserByKeywordGridPcV.jsp?KWD=<%=results.encodedKeyword%>"><%=_TEX.T("Search.Cat.User")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper GridList">
			<header class="SearchResultTitle">
				<h2 class="Keyword">@<%=Util.toStringHtml(results.m_strKeyword)%></h2>
			</header>
			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt = 0; nCnt<results.selectByNicknameUsers.size(); nCnt++) {
					CUser cUser = results.selectByNicknameUsers.get(nCnt);%>
					<%=CCnv.toHtmlUserMini(cUser, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_WVIEW)%>
					<%if(Util.isSmartPhone(request)) {%>
						<%if(nCnt==13) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp"%><%}%>
						<%if(nCnt==29) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp"%><%}%>
					<%} else {%>
						<%if(nCnt==3){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_1.jsp"%><%}%>
						<%if(nCnt==19){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_2.jsp"%><%}%>
						<%if(nCnt==35){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_3.jsp"%><%}%>
					<%}%>
				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/SearchUserByKeywordGridPcV.jsp", "&KWD="+URLEncoder.encode(results.m_strKeyword, "UTF-8"), results.m_nPage, results.m_nContentsNum, results.SELECT_MAX_GALLERY)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
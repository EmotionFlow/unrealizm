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

SearchUserByKeywordC cResults = new SearchUserByKeywordC();
cResults.getParam(request);

if (cResults.m_strKeyword.indexOf("#") == 0) {
	response.sendRedirect("https://unrealizm.com/SearchTagByKeywordPcV.jsp?KWD=" + cResults.encodedKeyword);
	return;
}

if (cResults.m_strKeyword.indexOf("@") == 0) {
	cResults.m_strKeyword = cResults.m_strKeyword.substring(1);
}

String strKeywordHan = Util.toSingle(cResults.m_strKeyword);
if(strKeywordHan.matches("^[0-9]+$")) {
	String strUrl = "/%s/".formatted(strKeywordHan);
	response.sendRedirect(Common.GetUnrealizmUrl(strUrl));
	return;
}

cResults.SELECT_MAX_GALLERY = 20;
if (Util.isSmartPhone(request)){
	cResults.SELECT_MAX_GALLERY = 18;
}
boolean bRtn = cResults.getResults(checkLogin);
g_strSearchWord = cResults.m_strKeyword;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdSearchUserPcHeader.jsp"%>
		<meta name="description" content="<%=Util.toStringHtml(String.format(_TEX.T("SearchUserByKeyword.Title.Desc"), cResults.m_strKeyword))%>" />
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
				<li><a class="TabMenuItem" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=cResults.encodedKeyword%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
				<li><a class="TabMenuItem" href="/SearchTagByKeywordPcV.jsp?KWD=<%=cResults.encodedKeyword%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
				<li><a class="TabMenuItem Selected" href="/SearchUserByKeywordPcV.jsp?KWD=<%=cResults.encodedKeyword%>"><%=_TEX.T("Search.Cat.User")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper GridList">
			<header class="SearchResultTitle">
				<h2 class="Keyword">@<%=Util.toStringHtml(cResults.m_strKeyword)%></h2>
			</header>
			<section id="IllustThumbList" class="IllustThumbList">
				<%
					Iterator<CUser> itrNn = cResults.selectByNicknameUsers.iterator();
					Iterator<CUser> itrProf = cResults.selectByProfileUsers.iterator();
					List<CUser> row = new ArrayList<>(3);
					int nCnt = 0;
					boolean isNn = true;
					CUser cUser;
				%>
				<%while (itrNn.hasNext() || itrProf.hasNext()) {
					row.clear();
					for (int i=0; i<3; i++) {
						if (isNn) {
							if (itrNn.hasNext()){
								row.add(itrNn.next());
							} else {
								if (itrProf.hasNext()) row.add(itrProf.next());
							}
						} else {
							if (itrProf.hasNext()){
								row.add(itrProf.next());
							} else {
								if (itrNn.hasNext()) row.add(itrNn.next());
							}
						}
					}
					isNn = !isNn;
				%>
				<%for (int i=0; i<row.size(); i++, nCnt++) {%>
					<%if (Util.isSmartPhone(request)) {%>
					<%=CCnv.toHtmlUserMini(row.get(i), CCnv.MODE_SP, _TEX, CCnv.SP_MODE_WVIEW)%>
					<%}else{%>
					<%=CCnv.toHtmlUser(row.get(i), CCnv.MODE_PC, _TEX, CCnv.SP_MODE_WVIEW)%>
					<%}%>
				<%}%>
					<%if(Util.isSmartPhone(request)) {%>
						<%if(nCnt==9) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp"%><%}%>
						<%if(nCnt==18) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp"%><%}%>
						<%if(nCnt==27) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp"%><%}%>
					<%} else {%>
						<%if(nCnt==3){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_1.jsp"%><%}%>
						<%if(nCnt==19){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_2.jsp"%><%}%>
						<%if(nCnt==35){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_3.jsp"%><%}%>
					<%}%>
				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/SearchUserByKeywordPcV.jsp", "&KWD="+cResults.encodedKeyword, cResults.m_nPage, 90, cResults.SELECT_MAX_GALLERY)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
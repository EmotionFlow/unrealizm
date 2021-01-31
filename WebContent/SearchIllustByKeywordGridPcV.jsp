<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

SearchIllustByKeywordC cResults = new SearchIllustByKeywordC();
cResults.getParam(request);
String strKeywordHan = Util.toSingle(cResults.m_strKeyword);
if(strKeywordHan.matches("^[0-9]+$")) {
	String strUrl = "/";
	response.sendRedirect("/" + strKeywordHan + "/");
	return;
}
cResults.SELECT_MAX_GALLERY = 48;
boolean bRtn = cResults.getResults(checkLogin);
g_strSearchWord = cResults.m_strKeyword;
String strEncodedKeyword = URLEncoder.encode(cResults.m_strKeyword, "UTF-8");
String strTitle = cResults.m_strKeyword + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("SearchIllustByTag.Title.Desc"), cResults.m_strKeyword, cResults.m_nContentsNum);
String strUrl = "https://poipiku.com/SearchIllustByTagPcV.jsp?KWD="+strEncodedKeyword;
String strFileUrl = cResults.m_strRepFileName;
%>
<!DOCTYPE html>
<html>
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
		<title><%=Util.toDescString(strTitle)%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuNew').addClass('Selected');
		});
		</script>

		<script>
			$(function(){
				$('#HeaderSearchWrapper').attr("action","/SearchIllustByKeywordPcV.jsp");
				$('#HeaderSearchBtn').on('click', SearchIllustByKeyword);
			});
		</script>

		<style>
			body {padding-top: 79px !important;}

			<%if(Util.isSmartPhone(request)) {%>
			#HeaderTitleWrapper {display: none;}
			#HeaderSearchWrapper {display: block;}
			<%}%>
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem Selected" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
				<li><a class="TabMenuItem" href="/SearchTagByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/SearchUserByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.User")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper GridList">
			<header class="SearchResultTitle">
				<h2 class="Keyword"><i class="fas fa-search"></i> <%=Util.toStringHtml(cResults.m_strKeyword)%></h2>
				<%if(!checkLogin.m_bLogin) {%>
				<!--
				<a class="BtnBase TitleCmdFollow" href="/"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				-->
				<%} else if(!cResults.m_bFollowing) {%>
				<!--
				<a class="BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_SEARCH%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				-->
				<%} else {%>
				<a class="BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_SEARCH%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%}%>
			</header>


			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
					<%if(nCnt==3){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_1.jsp"%><%}%>
					<%if(nCnt==19){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_2.jsp"%><%}%>
					<%if(nCnt==35){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_3.jsp"%><%}%>
				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/SearchIllustByKeywordPcV.jsp", "&KWD="+strEncodedKeyword, cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>

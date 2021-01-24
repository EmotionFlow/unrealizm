<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

SearchTagByKeywordC cResults = new SearchTagByKeywordC();
cResults.getParam(request);
cResults.SELECT_MAX_GALLERY = 45;
String strKeywordHan = Util.toSingle(cResults.m_strKeyword);
if(strKeywordHan.matches("^[0-9]+$")) {
	String strUrl = "/";
	response.sendRedirect("/" + strKeywordHan + "/");
	return;
}
boolean bRtn = cResults.getResults(checkLogin);
g_strSearchWord = cResults.m_strKeyword;
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdSearchUserPcHeader.jsp"%>
		<meta name="description" content="<%=Util.toStringHtml(String.format(_TEX.T("SearchTagByKeyword.Title.Desc"), cResults.m_strKeyword))%>" />
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
				<li><a class="TabMenuItem" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
				<li><a class="TabMenuItem Selected" href="/SearchTagByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/SearchUserByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.User")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper ItemList">
			<section id="IllustThumbList" class="IllustItemList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CTag cTag = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toHtml(cTag, CCnv.MODE_PC, _TEX)%>
					<%if(Util.isSmartPhone(request)) {%>
						<%if(nCnt==14) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp"%><%}%>
						<%if(nCnt==29) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp"%><%}%>
					<%} else {%>
						<%if(nCnt==14) {%><%@ include file="/inner/ad/TAdSearchUserPc728x90_mid_1.jsp"%><%}%>
						<%if(nCnt==29) {%><%@ include file="/inner/ad/TAdSearchUserPc728x90_mid_2.jsp"%><%}%>
					<%}%>
				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/SearchTagByKeywordPcV.jsp", "&KWD="+URLEncoder.encode(cResults.m_strKeyword, "UTF-8"), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

SearchIllustByKeywordC cResults = new SearchIllustByKeywordC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
g_strSearchWord = cResults.m_strKeyword;
String strEncodedKeyword = URLEncoder.encode(cResults.m_strKeyword, "UTF-8");
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=Common.ToStringHtml(String.format(_TEX.T("SearchIllustByKeyword.Title.Desc"), cResults.m_strKeyword, cResults.m_nContentsNum))%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=Common.ToStringHtml(String.format(_TEX.T("SearchIllustByKeyword.Title"), cResults.m_strKeyword))%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>

		<script>
			$(function(){
				$('#HeaderSearchWrapper').attr("action","/SearchIllustByKeywordPcV.jsp");
				$('#HeaderSearchBtn').on('click', SearchIllustByKeyword);
			});
		</script>

		<style>
		#HeaderTitleWrapper {display: none;}
		#HeaderSearchWrapper {display: block;}
		</style>
	</head>

	<body>
		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem Selected" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Illust")%></a>
				<a class="TabMenuItem" href="/SearchTagByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Tag")%></a>
				<a class="TabMenuItem" href="/SearchUserByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.User")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper ThumbList">

			<div id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_KEYWORD_ILLUST, CCnv.MODE_PC, strEncodedKeyword, _TEX)%>
					<%if((nCnt+1)%15==0) {%>
					<%@ include file="/inner/TAdMidWide.jspf"%>
					<%}%>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/SearchIllustByKeywordPcV.jsp", "&KWD="+strEncodedKeyword, cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>
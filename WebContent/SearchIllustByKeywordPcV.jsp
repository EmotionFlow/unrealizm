
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/SearchIllustByKeywordC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

SearchIllustByKeywordCParam cParam = new SearchIllustByKeywordCParam();
cParam.GetParam(request);
cParam.m_nAccessUserId = cCheckLogin.m_nUserId;

SearchIllustByKeywordC cResults = new SearchIllustByKeywordC();
cResults.SELECT_MAX_GALLERY = 60;
boolean bRtn = cResults.GetResults(cParam);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=_TEX.T("SearchIllustByKeyword.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("SearchIllustByKeyword.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
			$('#HeaderSearchBox').val('<%=Common.ToStringHtml(cParam.m_strKeyword)%>');
		});
		</script>

		<style>
		#HeaderTitleWrapper {display: none;}
		#HeaderSearchWrapper {display: block;}
		</style>
	</head>

	<body>
		<div class="TabMenu">
			<a class="TabMenuItem Selected" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cParam.m_strKeyword, "UTF-8")%>">illustration</a>
			<a class="TabMenuItem" href="/SearchTagByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cParam.m_strKeyword, "UTF-8")%>">tag</a>
			<a class="TabMenuItem" href="/SearchUserByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cParam.m_strKeyword, "UTF-8")%>">user</a>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
			<%@ include file="/inner/TAdTop.jspf"%>

			<div id="IllustThumbList" class="IllustThumbList">
				<%for(CContent cContent : cResults.m_vContentList) {%>
					<a class="IllustThumb" href="/<%=cContent.m_nUserId%>/<%=cContent.m_nContentId%>.html">
						<span class="Category C<%=cContent.m_nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))%></span>
						<img class="IllustThumbImg" src="<%=Common.GetUrl(cContent.m_strFileName)%>_360.jpg">
					</a>
				<%}%>
			</div>

			<%@ include file="/inner/TAdBottom.jspf"%>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/SearchIllustByKeywordPcV.jsp", "&KWD="+URLEncoder.encode(cParam.m_strKeyword, "UTF-8"), cParam.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>
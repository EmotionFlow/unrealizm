
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

			<div id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, CCnv.MODE_PC, _TEX)%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAdMid.jspf"%>
					<%}%>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/SearchIllustByKeywordPcV.jsp", "&KWD="+URLEncoder.encode(cParam.m_strKeyword, "UTF-8"), cParam.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>
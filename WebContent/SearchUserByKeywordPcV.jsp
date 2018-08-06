<%@page import="com.emotionflow.poipic.util.CPageBar"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ include file="/SearchUserByKeywordC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

SearchUserByKeywordCParam cParam = new SearchUserByKeywordCParam();
cParam.GetParam(request);
cParam.m_nAccessUserId = cCheckLogin.m_nUserId;

SearchUserByKeywordC cResults = new SearchUserByKeywordC();
cResults.SELECT_MAX_GALLERY = 60;
boolean bRtn = cResults.GetResults(cParam);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("SearchUserByKeyword.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("SearchUserByKeyword.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuSearch').addClass('Selected');
			$('#HeaderSearchBox').val('<%=Common.ToStringHtml(cParam.m_strKeyword)%>');
		});
		</script>

		<style>
		#HeaderLink {display: none;}
		#HeaderSearchWrapper {display: block;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<div class="Wrapper">
			<div class="TabMenu">
				<a class="TabMenuItem" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cParam.m_strKeyword, "UTF-8")%>">illustration</a>
				<a class="TabMenuItem" href="/SearchTagByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cParam.m_strKeyword, "UTF-8")%>">tag</a>
				<a class="TabMenuItem Selected" href="/SearchUserByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cParam.m_strKeyword, "UTF-8")%>">user</a>
			</div>

			<div id="IllustThumbList" class="IllustItemList">
				<%for(CUser cContent : cResults.m_vContentList) {%>
				<a class="UserThumb" href="/IllustListPcV.jsp?ID=<%=cContent.m_nUserId%>">
					<span class="UserThumbImg"><img src="<%=Common.GetUrl(cContent.m_strFileName)%>"></span>
					<span class="UserThumbName"><%=cContent.m_strNickName%></span>
				</a>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/SearchUserByKeywordPcV.jsp", "&KWD="+URLEncoder.encode(cParam.m_strKeyword, "UTF-8"), cParam.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
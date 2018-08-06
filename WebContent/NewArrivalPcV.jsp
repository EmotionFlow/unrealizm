<%@page import="com.emotionflow.poipic.util.CPageBar"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ include file="/NewArrivalC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/");
	return;
}

NewArrivalCParam cParam = new NewArrivalCParam();
cParam.GetParam(request);
cParam.m_nAccessUserId = cCheckLogin.m_nUserId;

NewArrivalC cResults = new NewArrivalC();
cResults.SELECT_MAX_GALLERY = 60;
boolean bRtn = cResults.GetResults(cParam);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("NewArrivalPc.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("NewArrivalPc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuSearch').addClass('Selected');
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
				<a class="TabMenuItem Selected" href="/NewArrivalPcV.jsp">recent</a>
				<a class="TabMenuItem" href="/PopularIllustListPcV.jsp">popular</a>
				<a class="TabMenuItem" href="/PopularTagListPcV.jsp">tag</a>
			</div>

			<div id="IllustThumbList" class="IllustThumbList">
				<%for(CContent cContent : cResults.m_vContentList) {%>
					<a class="IllustThumb" href="/<%=cContent.m_nUserId%>/<%=cContent.m_nContentId%>.html">
						<img class="IllustThumbImg" src="<%=Common.GetUrl(cContent.m_strFileName)%>_360.jpg">
					</a>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/NewArrivalPcV.jsp", "", cParam.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/NewArrivalC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

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
			$('#MenuHome').addClass('Selected');
		});
		</script>
	</head>

	<body>
		<div class="TabMenu">
			<a class="TabMenuItem" href="/"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
			<a class="TabMenuItem Selected" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
			<a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
			<a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
			<div id="IllustThumbList" class="IllustThumbList">
				<%for(CContent cContent : cResults.m_vContentList) {%>
					<a class="IllustThumb" href="/<%=cContent.m_nUserId%>/<%=cContent.m_nContentId%>.html">
						<span class="Category C<%=cContent.m_nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))%></span>
						<img class="IllustThumbImg" src="<%=Common.GetUrl(cContent.m_strFileName)%>_360.jpg">
					</a>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/NewArrivalPcV.jsp", "", cParam.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>
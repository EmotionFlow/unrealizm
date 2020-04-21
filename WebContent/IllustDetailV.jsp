<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

IllustDetailC cResults = new IllustDetailC();
cResults.getParam(request);
if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("https://poipiku.com/NotFoundV.jsp");
	return;
}
if(Util.isBot(request.getHeader("user-agent"))) {
	response.sendRedirect("https://poipiku.com/NotFoundV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html lang="ja" style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=yes">
		<title><%=_TEX.T("THeader.Title")%></title>

		<script>
		$(function(){
			$('body, .IllustDetail').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){return false;});
			});
		});
		</script>
		<style>
			body {height: 100%;background: #333333; padding: 0 !important;}
			.IllustItemImage {max-width: 100%; height: auto;}
		</style>
	</head>

	<body>
		<table class="IllustDetail">
		<tr>
		<td>
		<%if(!cResults.m_cContent.m_strFileName.isEmpty()) {%>
		<span class="IllustItemLink" style="display: block;">
			<img class="IllustItemImage" src="<%=Common.GetUrl(cResults.m_cContent.m_strFileName)%>" />
		</span>
		<div class="IllustItemTProhibit">
			<%if(cResults.m_cContent.m_cUser.m_nUserId==cCheckLogin.m_nUserId) {
				String file_name = Util.changeExtension(
						(new File(cResults.m_cContent.m_strFileName)).getName(),
						ImageUtil.getExt(getServletContext().getRealPath(cResults.m_cContent.m_strFileName)));
			%>
			<a href="/DownloadImageFile?TD=<%=cResults.m_nContentId%>&AD=<%=cResults.m_nAppendId%>"><i class="fas fa-download"></i> <%=_TEX.T("IllustView.Download")%></a>
			<%} else {%>
			<%=_TEX.T("IllustView.ProhibitMsg.Long")%>
			<%}%>
		</div>
		<%} else {%>
		Not Found.
		<%}%>
		</td>
		</tr>
		</table>
	</body>
</html>
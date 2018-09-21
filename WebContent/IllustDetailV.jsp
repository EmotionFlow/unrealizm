<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

IllustDetailC cResults = new IllustDetailC();
cResults.getParam(request);
if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html lang="ja" style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=yes">
		<title><%=_TEX.T("THeader.Title")%></title>

		<script>
		$(function(){
			$('body, .Wrapper').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){return false;});
			});
		});
		</script>
	</head>

	<body style="height: 100%;background: #ffffff; padding: 0;">
		<table style="width: 100%; height: 100%; text-align: center;">
		<tr>
		<td>
		<%if(!cResults.m_cContent.m_strFileName.isEmpty()) {%>
		<span class="IllustItemLink" style="display: block;">
			<img class="IllustItemImage" src="<%=Common.GetUrl(cResults.m_cContent.m_strFileName)%>" />
		</span>
		<div class="IllustItemTProhibit"><%=_TEX.T("IllustView.ProhibitMsg.Long")%></div>
		<%} else {%>
		Not Found.
		<%}%>
		</td>
		</tr>
		</table>
	</body>
</html>
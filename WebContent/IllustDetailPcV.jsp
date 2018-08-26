<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.net.URLEncoder"%>
<%@ include file="/IllustDetailC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

IllustDetailCParam cParam = new IllustDetailCParam();
cParam.GetParam(request);
cParam.m_nAccessUserId = cCheckLogin.m_nUserId;

IllustDetailC cResults = new IllustDetailC();
if(!cResults.GetResults(cParam)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html lang="ja" style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript">
			$(function(){
				$('#MenuHome').addClass('Selected');
			});
		</script>
	</head>

	<body style="height: 100%;background: #ffffff; padding: 0;">
		<table style="width: 100%; height: 100%; text-align: center;">
		<tr>
		<td>
		<%if(!cResults.m_cContent.m_strFileName.isEmpty()) {%>
		<a class="IllustItemLink" style="display: block;" href="javascript:(window.open('','_self').opener=window).close();">
			<img class="IllustItemImage" src="<%=Common.GetUrl(cResults.m_cContent.m_strFileName)%>" />
		</a>
		<%} else {%>
		Not Found.
		<%}%>
		</td>
		</tr>
		</table>
	</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

IllustDetailC cResults = new IllustDetailC();
cResults.getParam(request);
if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html lang="ja" style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<title><%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>

		<%if(Util.isSmartPhone(request)) {%>
		<script type="text/javascript">
		$(function(){
			$('body, .Wrapper').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){return false;});
			});
			DispMsg('<%=_TEX.T("IllustDetailPc.InitMsgSp")%>');
		});
		</script>
		<style>
		.IllustItemImage {max-width: 360px;}
		</style>
		<%} else {%>
		<script type="text/javascript">
		$(function(){
			$('body, .Wrapper').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){return false;});
			});
			DispMsg('<%=_TEX.T("IllustDetailPc.InitMsg")%>');
		});
		</script>
		<%}%>
	</head>

	<body style="height: 100%;background: #ffffff; padding: 0;">
		<div id="DispMsg" style="top: 0;"></div>
		<table style="width: 100%; height: 100%; text-align: center;">
		<tr>
		<td>
		<%if(!cResults.m_cContent.m_strFileName.isEmpty()) {%>
		<a class="IllustItemLink" style="display: block;" href="javascript:(window.open('','_self').opener=window).close();">
			<img class="IllustItemImage" src="<%=Common.GetUrl(cResults.m_cContent.m_strFileName)%>" />
		</a>
		<div class="IllustItemTProhibit"><%=_TEX.T("IllustView.ProhibitMsg.Long")%></div>
		<%} else {%>
		Not Found.
		<%}%>
		</td>
		</tr>
		</table>
	</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

IllustDetailC cResults = new IllustDetailC();
cResults.getParam(request);
if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("https://poipiku.com/NotFoundPcV.jsp");
	return;
}
if(Util.isBot(request.getHeader("user-agent"))) {
	response.sendRedirect("https://poipiku.com/NotFoundPcV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html lang="ja" style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuSearch').addClass('Selected');
		});
		</script>

		<%if(Util.isSmartPhone(request)) {%>
		<script type="text/javascript">
		$(function(){
			$('body, .IllustDetail').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){return false;});
			});
			DispMsg('<%=_TEX.T("IllustDetailPc.InitMsgSp")%>');
		});
		</script>
		<%} else {%>
		<script type="text/javascript">
		$(function(){
			$('body, .IllustDetail').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){return false;});
			});
			DispMsg('<%=_TEX.T("IllustDetailPc.InitMsg")%>');
		});
		</script>
		<%}%>
		<style>
		body {height: 100%;background: #333333;}
		.AnalogicoInfo {display: none;}
		.IllustItemLink {padding: 4px;}
		.IllustItemImage {max-width: 100%; height: auto;}
		</style>
	</head>

	<body>
		<div id="DispMsg" style="top: 51px;"></div>

		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper" style="overflow: scroll; width: 100%; height: 100%;">
			<table class="IllustDetail">
			<tr>
			<td>
			<%if(!cResults.m_cContent.m_strFileName.isEmpty()) {%>
			<a class="IllustItemLink" style="display: block;" href="javascript:(window.open('','_self').opener=window).close();">
				<img class="IllustItemImage" src="<%=Common.GetUrl(cResults.m_cContent.m_strFileName)%>" />
			</a>
			<div class="IllustItemTProhibit">
				<%if(cResults.m_cContent.m_cUser.m_nUserId==cCheckLogin.m_nUserId) {
					String file_name = null;
					try {
						file_name = Util.changeExtension(
								(new File(cResults.m_cContent.m_strFileName)).getName(),
								ImageUtil.getExt(getServletContext().getRealPath(cResults.m_cContent.m_strFileName))
						);
					}catch (IllegalArgumentException ioe) {
						Log.d("IllegalArgumentException(not found)", getServletContext().getRealPath(cResults.m_cContent.m_strFileName));
						file_name = "";
					}
				%>
				<a href="/DownloadImageFile?TD=<%=cResults.m_nContentId%>&AD=<%=cResults.m_nAppendId%>" download="<%=file_name%>"><i class="fas fa-download"></i> <%=_TEX.T("IllustView.Download")%></a>
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
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
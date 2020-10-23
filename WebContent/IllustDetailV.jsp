<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(Util.isBot(request)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

if(!cCheckLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
}

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
			.IllustItemText {color: #eee; text-align: left; font-size: 1.2em; width: 90%; margin: auto; line-height: 1.8; font-family: yumincho,游明朝,游明朝体,yu mincho,ヒラギノ明朝 pron,hiragino mincho pron,hiraminpron-w3,hiraminpron-w6,ヒラギノ明朝 pro,hiragino mincho pro,hiraminpro-w3,hiraminpro-w6,hg明朝e,hgp明朝e,hgs明朝e,hgminchoe,hgpminchoe,hgsminchoe,hg明朝b,hgp明朝b,hgs明朝b,hgminchob,hgpminchob,hgsminchob,平成明朝,平成明朝 std,平成明朝 pro,heisei mincho,heisei mincho std,heisei mincho pro,ipa明朝,ipamincho,Georgia,georgia ref,times new roman,SerifJP,serif;  }
		</style>
	</head>

	<body>
		<table class="IllustDetail">
		<tr>
		<td>
		<%if(!cResults.m_cContent.m_strFileName.isEmpty()) {%>
		<div class="IllustItemLink" style="display: block;">
			<img class="IllustItemImage" src="<%=Common.GetUrl(cResults.m_cContent.m_strFileName)%>" />
		</div>
		<div class="IllustItemTProhibit">
			<%if(cResults.m_cContent.m_cUser.m_nUserId==cCheckLogin.m_nUserId) {%>
			<a href="/DownloadImageFile?TD=<%=cResults.m_nContentId%>&AD=<%=cResults.m_nAppendId%>"><i class="fas fa-download"></i> <%=_TEX.T("IllustView.Download")%></a>
			<%} else {%>
			<%=_TEX.T("IllustView.ProhibitMsg.Long")%>
			<%}%>
		</div>
		<%} else if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {%>
		<div class="IllustItemLink">
			<div class="IllustItemText">
				<%=Util.toStringHtml(cResults.m_cContent.m_strTextBody)%>
			</div>
		</div>
		<%} else {%>
		Not Found.
		<%}%>
		</td>
		</tr>
		</table>
	</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(Util.isBot(request)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

IllustDetailC cResults = new IllustDetailC();
cResults.getParam(request);
if(!cResults.getResults(checkLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
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
			$('#MenuNew').addClass('Selected');
		});
		</script>

		<script type="text/javascript">
		$(function(){
			$('body, .IllustDetail').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){return false;});
			});
		});
		</script>
		<style>
		body {height: 100%; background: #333333;}
		.AnalogicoInfo {display: none;}
		.IllustItemLink {padding: 4px;}
		.IllustItemImage {max-width: 100%; height: auto;}
		.IllustItemText {color: #eee; text-align: left; font-size: 1.3em; width: 80%; margin: auto; line-height: 1.8; font-family: yumincho,游明朝,游明朝体,yu mincho,ヒラギノ明朝 pron,hiragino mincho pron,hiraminpron-w3,hiraminpron-w6,ヒラギノ明朝 pro,hiragino mincho pro,hiraminpro-w3,hiraminpro-w6,hg明朝e,hgp明朝e,hgs明朝e,hgminchoe,hgpminchoe,hgsminchoe,hg明朝b,hgp明朝b,hgs明朝b,hgminchob,hgpminchob,hgsminchob,平成明朝,平成明朝 std,平成明朝 pro,heisei mincho,heisei mincho std,heisei mincho pro,ipa明朝,ipamincho,Georgia,georgia ref,times new roman,SerifJP,serif;  }
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
			<div class="IllustItemLink">
				<img class="IllustItemImage" src="<%=Common.GetUrl(cResults.m_cContent.m_strFileName)%>" />
			</div>
			<div class="IllustItemTProhibit">
				<%if(cResults.m_cContent.m_cUser.m_nUserId==checkLogin.m_nUserId) {
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
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
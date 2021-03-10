<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(Util.isBot(request)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

IllustDetailC cResults = new IllustDetailC();
cResults.getParam(request);
if(!cResults.getResults(checkLogin)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}
boolean bDownload = cResults.m_cContent.m_cUser.m_nUserId==checkLogin.m_nUserId || cResults.m_nDownload==CUser.DOWNLOAD_ON;
%>
<!DOCTYPE html>
<html lang="ja" style="height: 100%;">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="Pragma" content="no-cache"/>
		<meta http-equiv="Cache-Control" content="no-cache"/>
		<meta http-equiv="Expires" content="0"/>
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<meta name="robots" content="noindex" />
		<meta name=“pinterest” content=“nopin” />
		<link rel="icon" href="/favicon_2.ico" />
		<link href="https://fonts.googleapis.com/earlyaccess/roundedmplus1c.css" rel="stylesheet" />
		<link href="/css/TBase-36.css" type="text/css" rel="stylesheet" />
		<link href="/css/TMaking-128.css" type="text/css" rel="stylesheet" />
		<link href="/css/TBasePc-64.css" type="text/css" rel="stylesheet" />
		<link href="/font/typicons.min.css" type="text/css" rel="stylesheet" />
		<link href="/webfonts/all.min.css" type="text/css" rel="stylesheet" />
		<link rel="apple-touch-icon" sizes="114x114" href="/img/apple-touch-icon-114x114_2.png" />
		<link rel="apple-touch-icon" sizes="72x72" href="/img/apple-touch-icon-72x72_2.png" />
		<link rel="apple-touch-icon" sizes="57x57" href="/img/apple-touch-icon_2.png" />
		<script type="text/javascript" src="/js/jquery-1.12.4.min.js"></script>
		<script type="text/javascript" src="/js/common-47.js"></script>
		<script type="text/javascript" src="/js/commonPc-03.js"></script>
		<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
		<%@ include file="/inner/TGoogleAnalytics.jsp"%>
		<meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=yes">
		<title><%=_TEX.T("THeader.Title")%></title>

		<%if(bDownload) {%>
		<style>
			body {
				user-select:  all;
				-webkit-user-select: all;
				-moz-user-select: all;
				-ms-user-select: element;
				-webkit-touch-callout: default;
			}
		</style>
		<%} else {%>
		<script>
		$(function(){
			$('body, .IllustDetail').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){return false;});
			});
		});
		</script>
		<%}%>

		<style>
			body {height: 100%;background: #333333; padding: 0 !important;}
			.IllustDetail {display: flex; align-content: center; justify-content: center; flex-flow: column;}
			.IllustItemImage {max-width: 100%; height: auto;}
			.IllustItemText {color: #eee; text-align: left; font-size: 1.2em; width: 90%; margin: auto; line-height: 1.8; font-family: yumincho,游明朝,游明朝体,yu mincho,ヒラギノ明朝 pron,hiragino mincho pron,hiraminpron-w3,hiraminpron-w6,ヒラギノ明朝 pro,hiragino mincho pro,hiraminpro-w3,hiraminpro-w6,hg明朝e,hgp明朝e,hgs明朝e,hgminchoe,hgpminchoe,hgsminchoe,hg明朝b,hgp明朝b,hgs明朝b,hgminchob,hgpminchob,hgsminchob,平成明朝,平成明朝 std,平成明朝 pro,heisei mincho,heisei mincho std,heisei mincho pro,ipa明朝,ipamincho,Georgia,georgia ref,times new roman,SerifJP,serif;  }
		</style>
	</head>

	<body>
		<div class="IllustDetail">
			<%if(!cResults.m_cContent.m_strFileName.isEmpty()) {%>
			<%if(bDownload) {%>
			<div class="IllustItemTProhibit">
				<a href="/DownloadImageFile?TD=<%=cResults.m_nContentId%>&AD=<%=cResults.m_nAppendId%>"><i class="fas fa-download"></i> <%=_TEX.T("IllustView.Download")%></a>
			</div>
			<%}%>
			<div class="IllustItemLink" style="display: block;">
				<img class="IllustItemImage" src="<%=Common.GetUrl(cResults.m_cContent.m_strFileName)%>" />
			</div>
			<%if(bDownload) {%>
			<div class="IllustItemTProhibit">
				<a href="/DownloadImageFile?TD=<%=cResults.m_nContentId%>&AD=<%=cResults.m_nAppendId%>"><i class="fas fa-download"></i> <%=_TEX.T("IllustView.Download")%></a>
			</div>
			<%}%>
			<div class="IllustItemTProhibit">
				<%=_TEX.T("IllustView.ProhibitMsg.Long")%>
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
		</div>
	</body>
</html>

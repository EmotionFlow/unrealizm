<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(Util.isBot(request)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailV.jsp").forward(request,response);
	return;
}

IllustDetailC results = new IllustDetailC();
results.getParam(request);
if(!results.getResults(checkLogin)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

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
		<meta name="pinterest" content="nopin" />
		<link rel="icon" href="/favicon.ico" />
		<link rel="preconnect" href="https://fonts.googleapis.com">
		<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
		<link href="https://fonts.googleapis.com/css?family=Noto+Serif+JP" rel="stylesheet">
		<link href="https://fonts.googleapis.com/earlyaccess/roundedmplus1c.css" rel="stylesheet" />
		<link href="/css/TBase-45.css" type="text/css" rel="stylesheet" />
		<link href="/css/TMaking-222.css" type="text/css" rel="stylesheet" />
		<link href="/css/TBasePc-84.css" type="text/css" rel="stylesheet" />
		<link href="/font/typicons.min.css" type="text/css" rel="stylesheet" />
		<link href="/webfonts/all.min.css" type="text/css" rel="stylesheet" />
		<link rel="apple-touch-icon" sizes="114x114" href="/img/apple-touch-icon-114x114.png" />
		<link rel="apple-touch-icon" sizes="72x72" href="/img/apple-touch-icon-72x72.png" />
		<link rel="apple-touch-icon" sizes="57x57" href="/img/apple-touch-icon.png" />
		<script type="text/javascript" src="/js/jquery-1.12.4.min.js"></script>
		<script type="text/javascript" src="/js/common-127.js"></script>
		<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
		<%@ include file="/inner/TGoogleAnalytics.jsp"%>
		<meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=yes">
		<title><%=_TEX.T("THeader.Title")%></title>

		<%if(results.isDownloadable) {%>
		<style>
			body {
				user-select:  all;
				-webkit-user-select: all;
				-moz-user-select: all;
				-ms-user-select: all;
				-webkit-touch-callout: default;
			}
		</style>
		<%} else {%>
		<script>
		$(function(){
			$('body, .IllustDetail').each(function(index, element){
				$(element).on("drag dragstart",function(e){return false;});
			});
		});
		</script>
		<%}%>

		<%if(results.content.m_nEditorId==Common.EDITOR_TEXT){%>
		<script>
			$(function () {
				<%if(results.content.novelDirection==0){%>
				if (window.innerWidth< $(".NovelSection").width()){
					$(".IllustItemLink").css("width", String(window.innerWidth - 10) +"px");
				}
				<%}else{%>
				$(".IllustItemTextDetail").css("width", (window.innerWidth - 10) + "px");
				$(".IllustItemTextDetail").scrollLeft(100000);
				const h = $("body").height();
				if (h < $(".IllustItemTextDetail.Vertical").height()){
					$(".IllustItemLink").css("height", String(h - 10) +"px");
					$(".IllustItemLink").css("padding", 0);
					$(".IllustItemTextDetail.Vertical").css("height", String(h - 10) +"px");
				}
				<%}%>
			})
		</script>
		<%}%>

		<style>
			body {
								height: 100%;
				<%if(results.content.m_nEditorId==Common.EDITOR_TEXT ){%>
								background: #ffffff;
				<%}else{%>
								background: #333333;
				<%}%>
								padding: 0 !important;
			}

						.IllustItemLink {
				<%if(results.content.m_nEditorId==Common.EDITOR_TEXT && results.content.novelDirection==0){%>
								margin: 0 auto;
								width: 25em;
				<%}else{%>
								padding: 4px;
				<%}%>
						}

						.IllustItemImage {max-width: 100%; height: auto;}

						.IllustItemTextDetail {
				color: #333333;
								display: block;
								float: left;
								box-sizing: border-box;
								text-align: left;
								font-size: 1.3em;
								line-height: 1.8;
								margin: 0 4px;
						}

						.IllustItemTextDetail.Vertical{
								writing-mode: vertical-rl;
								overflow-x: scroll;
								height: 500px;
								width: 100%;
						}
		</style>
	</head>

	<body>
		<div class="IllustDetail">
			<%if(!results.content.m_strFileName.isEmpty()) {%>
			<%if(results.isDownloadable) {%>
			<div class="IllustItemTProhibit">
				<a href="/DownloadImageFile?TD=<%=results.contentId%>&AD=<%=results.appendId%>"><i class="fas fa-download"></i> <%=_TEX.T("IllustView.Download")%></a>
				<%if (results.isOwner) {%>
				<br><span>
				<%if (results.downloadCode ==CUser.DOWNLOAD_OFF) {%>
				(<%=_TEX.T("IllustView.DownloadInfo.Disallow")%>)
				<%}else{%>
				(<%=_TEX.T("IllustView.DownloadInfo.Allow")%>)
				<%}%>
				</span>
				<%}%>
			</div>
			<%}%>
			<div class="IllustItemLink" style="display: block;">
				<img class="IllustItemImage" src="<%=Common.GetOrgImgUrl(results.content.m_strFileName)%>" />
			</div>
			<%if(results.isDownloadable) {%>
			<div class="IllustItemTProhibit">
				<a href="/DownloadImageFile?TD=<%=results.contentId%>&AD=<%=results.appendId%>"><i class="fas fa-download"></i> <%=_TEX.T("IllustView.Download")%></a>
				<%if (results.isOwner) {%>
				<br><span>
				<%if (results.downloadCode ==CUser.DOWNLOAD_OFF) {%>
				(<%=_TEX.T("IllustView.DownloadInfo.Disallow")%>)
				<%}else{%>
				(<%=_TEX.T("IllustView.DownloadInfo.Allow")%>)
				<%}%>
				</span>
				<%}%>
			</div>
			<%}%>
			<div class="IllustItemTProhibit">
				<%=_TEX.T("IllustView.ProhibitMsg.Long")%>
			</div>
			<%} else if(results.content.m_nEditorId==Common.EDITOR_TEXT) {%>
			<div class="IllustItemLink">
				<div class="IllustItemTextDetail <%=results.content.novelDirection==1 ? "Vertical" : ""%>">
					<%=Util.replaceForGenEiFont(results.content.novelHtml)%>
				</div>
			</div>
			<%} else {%>
			Not Found.
			<%}%>
		</div>
	</body>
</html>

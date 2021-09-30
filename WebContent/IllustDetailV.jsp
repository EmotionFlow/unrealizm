<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if (!Util.isIOS(request) && !Util.isSmartPhone(request)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

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
		<link rel="icon" href="/favicon_2.ico" />
		<link rel="preconnect" href="https://fonts.googleapis.com">
		<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
		<link href="https://fonts.googleapis.com/css?family=Noto+Serif+JP" rel="stylesheet">
		<link href="https://fonts.googleapis.com/earlyaccess/roundedmplus1c.css" rel="stylesheet" />
		<link href="/css/TBase-39.css" type="text/css" rel="stylesheet" />
		<link href="/css/TMaking-150.css" type="text/css" rel="stylesheet" />
		<link href="/css/TBasePc-71.css" type="text/css" rel="stylesheet" />
		<link href="/font/typicons.min.css" type="text/css" rel="stylesheet" />
		<link href="/webfonts/all.min.css" type="text/css" rel="stylesheet" />
		<link rel="apple-touch-icon" sizes="114x114" href="/img/apple-touch-icon-114x114_2.png" />
		<link rel="apple-touch-icon" sizes="72x72" href="/img/apple-touch-icon-72x72_2.png" />
		<link rel="apple-touch-icon" sizes="57x57" href="/img/apple-touch-icon_2.png" />
		<script type="text/javascript" src="/js/jquery-1.12.4.min.js"></script>
		<script type="text/javascript" src="/js/common-59.js"></script>
		<script type="text/javascript" src="/js/commonPc-03.js"></script>
		<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
		<%@ include file="/inner/TGoogleAnalytics.jsp"%>
		<meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=yes">
		<title><%=_TEX.T("THeader.Title")%></title>

		<%if(cResults.isDownloadable) {%>
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
				$(element).on("contextmenu drag dragstart copy",function(e){return false;});
			});
		});
		</script>
		<%}%>

		<%if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT){%>
		<script>
			$(function () {
				<%if(cResults.m_cContent.novelDirection==0){%>
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
				<%if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT ){%>
                background: #ffffff;
				<%}else{%>
                background: #333333;
				<%}%>
                padding: 0 !important;
			}

            .IllustItemLink {
				<%if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT && cResults.m_cContent.novelDirection==0){%>
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
			<%if(!cResults.m_cContent.m_strFileName.isEmpty()) {%>
			<%if(cResults.isDownloadable) {%>
			<div class="IllustItemTProhibit">
				<a href="/DownloadImageFile?TD=<%=cResults.m_nContentId%>&AD=<%=cResults.m_nAppendId%>"><i class="fas fa-download"></i> <%=_TEX.T("IllustView.Download")%></a>
				<%if (cResults.isOwner) {%>
				<br><span>
				<%if (cResults.m_nDownload==CUser.DOWNLOAD_OFF) {%>
				(<%=_TEX.T("IllustView.DownloadInfo.Disallow")%>)
				<%}else{%>
				(<%=_TEX.T("IllustView.DownloadInfo.Allow")%>)
				<%}%>
				</span>
				<%}%>
			</div>
			<%}%>
			<div class="IllustItemLink" style="display: block;">
				<img class="IllustItemImage" src="<%=Common.GetOrgImgUrl(cResults.m_cContent.m_strFileName)%>" />
			</div>
			<%if(cResults.isDownloadable) {%>
			<div class="IllustItemTProhibit">
				<a href="/DownloadImageFile?TD=<%=cResults.m_nContentId%>&AD=<%=cResults.m_nAppendId%>"><i class="fas fa-download"></i> <%=_TEX.T("IllustView.Download")%></a>
				<%if (cResults.isOwner) {%>
				<br><span>
				<%if (cResults.m_nDownload==CUser.DOWNLOAD_OFF) {%>
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
			<%} else if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {%>
			<div class="IllustItemLink">
				<div class="IllustItemTextDetail <%=cResults.m_cContent.novelDirection==1 ? "Vertical" : ""%>">
					<%=Util.replaceForGenEiFont(cResults.m_cContent.novelHtml)%>
				</div>
			</div>
			<%} else {%>
			Not Found.
			<%}%>
		</div>
	</body>
</html>

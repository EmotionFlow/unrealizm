<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

String referer = Util.toString(request.getHeader("Referer"));
if (!referer.contains("poipiku")) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

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


String file_name = "";
if(cResults.isDownloadable) {
	try {
		file_name = (new File(cResults.m_cContent.m_strFileName)).getName();
		file_name = Util.changeExtension(
				file_name,
				ImageUtil.getExt(getServletContext().getRealPath(cResults.m_cContent.m_strFileName))
		);
	}catch (IllegalArgumentException ioe) {
		Log.d("Download ERROR(not found)", getServletContext().getRealPath(cResults.m_cContent.m_strFileName));
	}
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

		<%if(cResults.m_cContent.m_cUser.m_nUserId==checkLogin.m_nUserId || cResults.m_nDownload==CUser.DOWNLOAD_ON) {%>
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
		<script type="text/javascript">
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
			const h = $(".Wrapper").height();
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
		}
		.AnalogicoInfo {display: none;}

		.IllustItemLink {
			<%if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT && cResults.m_cContent.novelDirection==0){%>
			margin: 0 auto;
			width: 38em;
			<%}else{%>
            padding: 4px;
			<%}%>
		}
		.IllustItemImage {max-width: 100%; height: auto;}

		.IllustItemTextDetail {
			display: block;
			float: left;
			box-sizing: border-box;
			color: #333;
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
		<div id="DispMsg" style="top: 51px;"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper" style="overflow: scroll; width: 100%; height: 100%;">
			<table class="IllustDetail">
			<tr>
			<td>
			<%if(!cResults.m_cContent.m_strFileName.isEmpty()) {%>
			<%if(cResults.isDownloadable) {%>
			<div class="IllustItemTProhibit">
				<a href="/DownloadImageFile?TD=<%=cResults.contentId%>&AD=<%=cResults.appendId%>" download="<%=file_name%>"><i class="fas fa-download"></i> <%=_TEX.T("IllustView.Download")%></a>
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
			<div class="IllustItemLink">
				<img class="IllustItemImage" src="<%=Common.GetOrgImgUrl(cResults.m_cContent.m_strFileName)%>" />
			</div>
			<%if(cResults.isDownloadable) {%>
			<div class="IllustItemTProhibit">
				<a href="/DownloadImageFile?TD=<%=cResults.contentId%>&AD=<%=cResults.appendId%>" download="<%=file_name%>"><i class="fas fa-download"></i> <%=_TEX.T("IllustView.Download")%></a>
				<%if (cResults.isOwner) {%>
				<br><span>
				<%if (cResults.m_nDownload==CUser.DOWNLOAD_OFF) {%>
				(<%=_TEX.T("IllustView.DownloadInfo.Disallow")%>)
				<%}else{%>
				(<%=_TEX.T("IllustView.DownloadInfo.Allow")%>)
				<%}%>
				</span>
				<%}%>
				<%if (checkLogin.m_nPassportId == 0) {%>
				<br><span><a style="text-decoration: underline;" href="https://poipiku.com/MyEditSettingPcV.jsp?MENUID=POIPASS"><%=_TEX.T("IllustDetailPc.PoipassBenefit")%></a></span>
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
			</td>
			</tr>
			</table>
		</article>

		<%if(!(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT && cResults.m_cContent.novelDirection==1)){%>
		<%@ include file="/inner/TFooter.jsp"%>
		<%}%>
	</body>
</html>

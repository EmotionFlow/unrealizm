<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/how_to/TopGridPcV.jsp").forward(request,response);
	return;
}
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("HowTo.Title")%></title>
		<style>
			.AnalogicoInfo {display: none;}
			.IllustItem .IllustItemCommand .IllustItemCommandSub .IllustItemCommandDelete {display: none;}
		</style>

		<style>
			.HowToFarme {display: block; position: relative;}
			.HowToImage {width: 100%;}
			.HowToLinkList {display: flex; flex-flow: column; justify-content: center; width: 100%; position: absolute; z-index: 1; top: 94px;}
			.HowToLinkList .HowToLink {display: block; width: 100%; height: 62px; margin: 0 0 8.5px 0;}
			.CmdUp {display: block; position: absolute; width: 100%; height: 57px; left: 0; z-index: 1; bottom: 17px;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%String searchType = "Contents";%>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="HowToFarme">
				<img id="HowToImage" class="HowToImage" src="/how_to/tsukaikata_sumaho_01.png" />
				<div class="HowToLinkList">
					<a class="HowToLink" href="javascript:void(0);" onclick="$('#HowToImage').attr('src','/how_to/tsukaikata_sumaho_01.png');"></a>
					<a class="HowToLink" href="javascript:void(0);" onclick="$('#HowToImage').attr('src','/how_to/tsukaikata_sumaho_02.png');"></a>
					<a class="HowToLink" href="javascript:void(0);" onclick="$('#HowToImage').attr('src','/how_to/tsukaikata_sumaho_03.png');"></a>
					<a class="HowToLink" href="javascript:void(0);" onclick="$('#HowToImage').attr('src','/how_to/tsukaikata_sumaho_04.png');"></a>
					<a class="HowToLink" href="javascript:void(0);" onclick="$('#HowToImage').attr('src','/how_to/tsukaikata_sumaho_05.png');"></a>
					<a class="HowToLink" href="javascript:void(0);" onclick="$('#HowToImage').attr('src','/how_to/tsukaikata_sumaho_06.png');"></a>
				</div>

				<a class="CmdUp" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:0});"></a>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
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
			.Wrapper {width: 857px;}
			.HowToFarme {width: 100%; max-width: 100%;}
			.HowToImage {width: 100%;}
			.HowToLinkList {display: flex; flex-flow: row wrap; justify-content: center; width: 100%; padding: 0 47px; box-sizing: border-box; position: absolute; z-index: 1; top: 200px;}
			.HowToLinkList .HowToLink {display: block; width: 50%; height: 62px; margin: 0 0 15px 0;}
			.HowToMangaList {display: block; width: 100%; position: absolute; z-index: 1; top: 650px;}
			.HowToMangaList .HowToManga {display: block; width: 100%; height: 515px;}
			.CmdUp {display: none;}
		</style>

		<script>
		function OnclickMenu(n) {
			var FILE = [
					"/how_to/tsukaikata_01.png",
					"/how_to/tsukaikata_02.png",
					"/how_to/tsukaikata_03.png",
					"/how_to/tsukaikata_04.png",
					"/how_to/tsukaikata_05.png",
					"/how_to/tsukaikata_06.png"
			];
			$('#HowToImage').attr('src', FILE[n]);
			if(n==0){$('#HowToMangaList').show();}else{$('#HowToMangaList').hide();}
		}
		</script>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="HowToFarme">
				<img id="HowToImage" class="HowToImage" src="/how_to/tsukaikata_01.png" />
				<div class="HowToLinkList">
					<a class="HowToLink" href="javascript:void(0);" onclick="OnclickMenu(0);"></a>
					<a class="HowToLink" href="javascript:void(0);" onclick="OnclickMenu(1)"></a>
					<a class="HowToLink" href="javascript:void(0);" onclick="OnclickMenu(2)"></a>
					<a class="HowToLink" href="javascript:void(0);" onclick="OnclickMenu(3)"></a>
					<a class="HowToLink" href="javascript:void(0);" onclick="OnclickMenu(4)"></a>
					<a class="HowToLink" href="javascript:void(0);" onclick="OnclickMenu(5)"></a>
				</div>

				<div id="HowToMangaList" class="HowToMangaList">
					<a class="HowToManga" href="https://unrealizm.com/2/857776.html"></a>
				</div>

				<a class="CmdUp" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:0});"></a>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>
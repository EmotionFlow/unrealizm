<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title>腐女子は見た | <%=_TEX.T("THeader.Title")%></title>

		<style>
			.Wrapper {width: 960px;}
			.SettingBody {display: block; width: 100%; position: relative;}
			.MainImage {display: block; width: 100%;}
			.LinkButton {display: block; position: absolute; width: 100%;}
			.LinkButton.Link1 {height: 208px; top:1200px;}

.LinkButton.Link2 {
		width: 340px;
		height: 69px;
		top: 429px;
		left: 310px;
}
.LinkButton.Link3 {
		width: 340px;
		height: 69px;
		top: 1159px;
		left: 310px;
}
.LinkMovie {
		display: block;
		position: absolute;
		width: 560px;
		height: 315px;
		top: 810px;
		left: 200px;
}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingBody">
				<img class="MainImage" src="./poipiku_blskip_pc_UI.png" />
				<a class="LinkButton Link2" href="http://bit.ly/3aGTV7d" target="_blank"></a>
				<iframe class="LinkMovie" width="560" height="315" src="https://www.youtube.com/embed/v7d6hUxqMIs" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
				<a class="LinkButton Link3" href="http://bit.ly/3aFDIit" target="_blank"></a>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>
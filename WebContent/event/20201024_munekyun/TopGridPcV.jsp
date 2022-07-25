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
		<title>自分的祭りマンガ2020 | <%=_TEX.T("THeader.Title")%></title>

		<style>
			.SettingBody {display: block; width: 100%; position: relative;}
			.MainImage {display: block; width: 100%;}
			.LinkButton {display: block; position: absolute; width: 100%;}
			.LinkButton.Link1 {height: 208px; top:1200px;}
.LinkButton.Link2 {
		height: 83px;
		top: 1096px;
}
.LinkButton.Link3 {
		width: 76px;
		height: 25px;
		top: 2006px;
		left: 200px;
		border-bottom: solid 3px #000;
}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%String searchType = "Contents";%>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingBody">
				<img class="MainImage" src="./poipiku_kyun_pc.png" />
				<!--
				<a class="LinkButton Link2" href="https://www.wacom.com/ja-jp/products/pen-tablets/wacom-intuos" target="_blank"></a>
				<a class="LinkButton Link3" href="https://twitter.com/pipajp" target="_blank"></a>
				-->
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>
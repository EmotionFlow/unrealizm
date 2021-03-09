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
		<title>自分的祭りマンガ2020 | <%=_TEX.T("THeader.Title")%></title>

		<style>
			.SettingBody {display: block; width: 100%; position: relative;}
			.MainImage {display: block; width: 100%;}
			.LinkButton {display: block; position: absolute; width: 100%;}
			.LinkButton.Link1 {height: 208px; top:1200px;}
.LinkButton.Link2 {
		width: 302px;
		height: 208px;
		top: 391px;
		left: 27px;
}
.LinkButton.Link3 {
		width: 85px;
		height: 20px;
		top: 827px;
		left: 372px;
		border-bottom: solid 2px #fff;
}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingBody">
				<img class="MainImage" src="./poipiku_2020best1_pc.png" />
				<a class="LinkButton Link2" href="https://www.wacom.com/ja-jp/products/pen-tablets/wacom-intuos" target="_blank"></a>
				<a class="LinkButton Link3" href="https://twitter.com/pipajp" target="_blank"></a>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>
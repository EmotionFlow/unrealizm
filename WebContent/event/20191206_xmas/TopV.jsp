<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>ポイピククリスマス | <%=_TEX.T("THeader.Title")%></title>

		<style>
			.SettingBody {display: block; width: 100%; position: relative;}
			.MainImage {display: block; width: 100%;}
			.LinkButton {display: block; position: absolute; width: 100%;}
			.LinkButton.Link1 {height: 80px; top:629px;}
			.LinkButton.Link2 {height: 63px; top:832px;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>

		<article class="Wrapper">
			<div class="SettingBody">
				<img class="MainImage" src="./wacom_sumaho-2.png" />
				<a class="LinkButton Link1" href="https://www.wacom.com/ja-jp/products/pen-tablets/wacom-intuos" target="_blank"></a>
				<a class="LinkButton Link2" href="https://www.wacom.com/ja-jp/products/pen-tablets/wacom-intuos" target="_blank"></a>
			</div>
		</article>
	</body>
</html>
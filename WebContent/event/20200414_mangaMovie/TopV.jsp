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
		<title>ポイピクバレンタイン | <%=_TEX.T("THeader.Title")%></title>

		<style>
			.SettingBody {display: block; width: 100%; position: relative;}
			.MainImage {display: block; width: 100%;}
			.LinkButton {display: block; position: absolute; width: 100%;}
			.LinkButton.Link1 {height: 80px; top:629px;}
			.LinkButton.Link2 {height: 193px; top:707px;}
			.LinkButton.Link3 {width: 61px; height: 21px; top: 1537px; left: 115px; border-bottom: solid 2px #ad4247;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>

		<article class="Wrapper">
			<div class="SettingBody">
				<img class="MainImage" src="./poipiku_lp_mdc_sp.png" />
				<a class="LinkButton Link2" href="https://www.wacom.com/ja-jp/products/pen-displays/wacom-one" target="_blank"></a>
			</div>
		</article>
	</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>自分的祭りマンガ2020 | <%=_TEX.T("THeader.Title")%></title>

		<style>
			.SettingBody {display: block; width: 100%; position: relative;}
			.MainImage {display: block; width: 100%;}
			.LinkButton {display: block; position: absolute; width: 100%;}
			.LinkButton.Link1 {height: 80px; top:629px;}
.LinkButton.Link2 {
		width: 180px;
		height: 124px;
		top: 234px;
		left: 17px;
}
.LinkButton.Link3 {
		width: 52px;
		height: 12px;
		top: 496px;
		left: 223px;
		border-bottom: solid 1px #fff;
}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>

		<article class="Wrapper">
			<div class="SettingBody">
				<img class="MainImage" src="./poipiku_2020best1_sp.png" />
				<a class="LinkButton Link2" href="https://www.wacom.com/ja-jp/products/pen-tablets/wacom-intuos" target="_blank"></a>
				<a class="LinkButton Link3" href="https://twitter.com/pipajp" target="_blank"></a>
			</div>
		</article>
	</body>
</html>
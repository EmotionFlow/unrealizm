<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/event/2021_02_18_blskip/TopGridPcV.jsp").forward(request,response);
	return;
}
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
			.LinkButton.Link1 {height: 80px; top:629px;}
.LinkButton.Link2 {
		width: 150px;
		height: 32px;
		top: 190px;
		left: 105px;
}
.LinkButton.Link3 {
		width: 150px;
		height: 32px;
		top: 524px;
		left: 105px;
}
.LinkMovie {
		display: block;
		position: absolute;
		width: 250px;
		height: 140px;
		top: 360px;
		left: 55px;
}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingBody">
				<img class="MainImage" src="./poipiku_blskip_sp.png" />
				<a class="LinkButton Link2" href="https://www.youtube.com/channel/UCaOwSJ-UiNV-7IxOxNFAt4w" target="_blank"></a>
				<iframe class="LinkMovie" width="250" height="140" src="https://www.youtube.com/embed/v7d6hUxqMIs" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
				<a class="LinkButton Link3" href="https://www.youtube.com/channel/UCaOwSJ-UiNV-7IxOxNFAt4w" target="_blank"></a>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>
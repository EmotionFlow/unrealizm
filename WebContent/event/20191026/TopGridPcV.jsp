<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - 使い回しハロウィン</title>

		<style>
			.Wrapper {width: 990px;}
			.SettingBody {display: block; width: 100%; position: relative;}
			.Mainmage {display: block; width: 100%;}
			.LinkList {display: flex; flex-flow: row nowrap; justify-content: space-between; box-sizing: border-box; width: 100%; padding: 0 187px 0 197px; position: absolute; top: 749px; z-index: 1;}
			.LinkItem {display: block; width: 179px; height: 179px;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingBody">
				<img class="Mainmage" src="/event/20191026/tukaimawashi_halloween_sumaho.png" />
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>
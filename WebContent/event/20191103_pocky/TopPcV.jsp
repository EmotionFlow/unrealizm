<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/event/20191103_pocky/TopGridPcV.jsp").forward(request,response);
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - ポッキープリッツの日</title>

		<style>
			.SettingBody {display: block; width: 100%; position: relative;}
			.MainImage {display: block; width: 100%;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingBody">
				<img class="MainImage" src="./pocky_sumaho.png" />
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

%>
<!DOCTYPE html>
<html style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript" src="/js/jquery.simplyscroll.min.js"></script>
		<style>
		body {padding: 0;}
		.Wrapper {width: 1024px; color: #000; background: #3498db; height: auto; margin: 0; padding: 77px 0;}
		.AnalogicoDesc {width: 100%; padding: 0 0 0 0; box-sizing: border-box; text-align: center; font-size: 14px; line-height: 37px; color: #000; font-weight: normal;}
		.AnalogicoStart {text-align: center; margin: 20px 0 0 0; padding: 0 0 0 0;}
		.IllustThumb .IllustThumbImg {width: 100%; height: 100%;}
		.AnalogicoInfo {display: none;}
		.Logo {height: 30px;}
		.BtnBase {padding: 2px 25px; border-radius: 30px;}
		.AnalogicoDesc.Title {font-size: 16px;}
		</style>
	</head>

	<body>
		<article class="Wrapper">
			<div class="AnalogicoStart">
				<div style="margin: 0 0 5px 0; font-size: 16px;"><%=_TEX.T("Catchphrase")%></div>
				<a class="BtnBase Rev" style="background-color: #ffffff;" href="https://unrealizm.com/">
					<img class="Logo" src="//img.unrealizm.com/img/logo_tr_48.png" alt="<%=_TEX.T("THeader.Title")%>">
				</a>
			</div>
		</article>
	</body>
</html>
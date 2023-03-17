<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

%>
<!DOCTYPE html>
<html style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript" src="/js/jquery.simplyscroll.min.js"></script>
		<style>
		body {padding: 0;}
		.Wrapper {width: 350px; color: #000; background: #3498db; height: auto; margin: 0; padding: 4px 3px; display: flex;align-items: center; box-sizing: border-box;}
		.AnalogicoDesc {flex: 1 1; padding: 0 0 0 0; margin: 0 0 0 5px; box-sizing: border-box; text-align: left; font-size: 14px; line-height: 16px; color: #000; font-weight: normal;}
		.AnalogicoStart {text-align: center; margin: 0 0 0 0; padding: 0 0 0 0;}
		.IllustThumb .IllustThumbImg {width: 100%; height: 100%;}
		.AnalogicoInfo {display: none;}
		.Logo {height: 23px;}
		.BtnBase {padding: 2px 5px; border-radius: 4px;}
		.AnalogicoDesc.Title {font-size: 13px;}
		</style>
	</head>

	<body>
		<article class="Wrapper">
			<div class="AnalogicoStart">
				<a class="BtnBase" href="https://unrealizm.com/">
					<img class="Logo" src="//img.unrealizm.com/img/logo_tr_48.png" alt="<%=_TEX.T("THeader.Title")%>">
				</a>
			</div>
			<div class="AnalogicoDesc Title">
				<div><%=_TEX.T("Catchphrase")%></div>
				<div>「unrealizm」正式オープン！</div>
			</div>
		</article>
	</body>
</html>
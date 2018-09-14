<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

%>
<!DOCTYPE html>
<html style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript" src="/js/jquery.simplyscroll.min.js"></script>
		<style>
		body {padding: 0;}
		.Wrapper {width: 350px; color: #fff; background: #5bd; height: auto; margin: 0; padding: 4px 3px; display: flex;align-items: center; box-sizing: border-box;}
		.AnalogicoDesc {flex: 1 1; padding: 0 0 0 0; margin: 0 0 0 6px; box-sizing: border-box; text-align: left; font-size: 14px; line-height: 16px; color: #fff; font-weight: normal;}
		.AnalogicoStart {text-align: center; margin: 0 0 0 0; padding: 0 0 0 0;}
		.IllustThumb .IllustThumbImg {width: 100%; height: 100%;}
		.AnalogicoInfo {display: none;}
		.Logo {height: 23px;}
		.BtnBase {padding: 2px 3px; border-radius: 6px;}
		.AnalogicoDesc.Title {font-size: 13px;}
		</style>
	</head>

	<body>
		<div class="Wrapper">
			<div class="AnalogicoStart">
				<a class="BtnBase Rev" href="https://poipiku.com/">
					<img class="Logo" src="/img/pc_top_title.jpg" alt="ポイピク">
				</a>
			</div>
			<h1 class="AnalogicoDesc Title">
				ポイポイしたら誰かがきっと励ましてくれる<br />
				イラストポイポイSNS プレオープン！
			</h1>
		</div>
	</body>
</html>
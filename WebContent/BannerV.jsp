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
		.Wrapper {width: 300px; color: #fff; background: #5bd; height: auto; margin: 0; padding: 23px 0;}
		.AnalogicoDesc {width: 100%; padding: 0 0 0 0; box-sizing: border-box; text-align: center; font-size: 14px; line-height: 30px; color: #fff; font-weight: normal;}
		.AnalogicoStart {text-align: center; margin: 20px 0 0 0; padding: 0 0 0 0;}
		.IllustThumb .IllustThumbImg {width: 100%; height: 100%;}
		.AnalogicoInfo {display: none;}
		.Logo {height: 30px;}
		.BtnBase {padding: 2px 25px; border-radius: 30px;}
		.AnalogicoDesc.Title {font-size: 14px;}
		</style>
	</head>

	<body>
		<div class="Wrapper">
			<h1 class="AnalogicoDesc Title">
				描くのに飽きたらポイポイ<br />
				日々の鍛錬をポイポイ<br />
				闇に葬る前にとりあえずポイポイ<br />
				ポイポイしたら誰かがきっと励ましてくれる
			</h1>
			<div class="AnalogicoStart">
				<div style="margin: 0 0 5px 0;">イラストポイポイSNS</div>
				<a class="BtnBase Rev" href="https://poipiku.com/">
					<img class="Logo" src="/img/pc_top_title.jpg" alt="ポイピク">
				</a>
			</div>
		</div>
	</body>
</html>
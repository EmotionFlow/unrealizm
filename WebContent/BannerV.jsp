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
		.Wrapper {width: 300px; height: 250px; color: #6d6965; background: #3498db; margin: 0; padding: 14px 0;}
		.AnalogicoDesc {width: 100%; padding: 0 0 0 0; box-sizing: border-box; text-align: center; font-size: 14px; line-height: 25px; color: #6d6965; font-weight: normal;}
		.AnalogicoDesc.Foot {margin: 15px 0 0 0; font-weight: bold;}
		.AnalogicoStart {text-align: center; margin: 10px 0 0 0; padding: 0 0 0 0;font-size: 18px;}
		.IllustThumb .IllustThumbImg {width: 100%; height: 100%;}
		.AnalogicoInfo {display: none;}
		.Logo {height: 30px;}
		.BtnBase {padding: 2px 25px; border-radius: 30px;}
		.AnalogicoDesc.Title {font-size: 14px;}
		</style>
	</head>

	<body>
		<article class="Wrapper">
			<div class="AnalogicoStart">
				<div style="margin: 0 0 5px 0;">
					放置絵ポイポイ<br />
					練習ポイポイ<br />
					らくがきポイポイ<br />
					進捗ポイポイ<br />
					<br />
					<a class="BtnBase" href="https://unrealizm.com/">
						<img class="Logo" src="//img.unrealizm.com/img/unrealizm_logo_64x64.png" alt="<%=_TEX.T("THeader.Title")%>">
					</a>
				</div>
			</div>
			<div class="AnalogicoDesc Foot" style="margin-top: 10px;">
				<div style="font-size: 18px;">
					正式オープン！
				</div>
			</div>
		</article>
	</body>
</html>
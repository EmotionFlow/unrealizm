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
		.Wrapper {width: 350px; color: #fff; background: #3498db; height: auto; margin: 0; padding: 4px 3px; display: flex;align-items: center; box-sizing: border-box;}
		.AnalogicoDesc {flex: 1 1; padding: 0 0 0 0; margin: 0 0 0 5px; box-sizing: border-box; text-align: left; font-size: 14px; line-height: 16px; color: #fff; font-weight: normal;}
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
				<a class="BtnBase" href="https://ai.poipiku.com/">
					<img class="Logo" src="//img.ai.poipiku.com/img/pc_top_title-03.png" alt="<%=_TEX.T("THeader.Title")%>">
				</a>
			</div>
			<div class="AnalogicoDesc Title">
				<div>放置絵ポイポイ 練習ポイポイ 進捗ポイポイ</div>
				<div>「ポイピク」正式オープン！</div>
			</div>
		</article>
	</body>
</html>
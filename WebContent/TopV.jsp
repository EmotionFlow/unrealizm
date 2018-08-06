<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ include file="/TopC.jsp"%>
<%
if(Common.isSmartPhone(request)) {
		//response.sendRedirect("/sTopV.jsp");
		//return;
}

CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(cCheckLogin.m_bLogin) {
	response.sendRedirect("/MyHomePcV.jsp");
	return;
}

TopCParam cParam = new TopCParam();
cParam.GetParam(request);

TopC cResults = new TopC();
cResults.SELECT_MAX_GALLERY = 20;
boolean bRtn = cResults.GetResults(cParam);
%>
<!DOCTYPE html>
<html style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript" src="/js/jquery.simplyscroll.min.js"></script>
		<style>
		body {color: #fff; background: url('/img/pc_top_bg.jpg') 50% 50% no-repeat fixed; background-size: cover; height: auto;}
		.AnalogicoDesc {width: 90%; margin: 80px auto 0 auto; padding: 0; text-align: center; font-size: 16px; text-shadow: 0 0 8px #000; color: #fff; font-weight: normal;}
		.AnalogicoDesc.Title {font-family: "游明朝", YuMincho, "ヒラギノ明朝 ProN W3", "Hiragino Mincho ProN", "HG明朝E", "ＭＳ Ｐ明朝", "ＭＳ 明朝", serif;}
		.AnalogicoStart {text-align: center; margin: 60px 0 0 0;}
		.simply-scroll-container {position: relative;}
		.simply-scroll-clip {position: relative; overflow: hidden;}
		.simply-scroll-list {display: block; float: left; width: 100%; list-style: none; overflow: hidden;margin: 0;padding: 0;}
		.simply-scroll-list li {display: block; float: left;}
		<%if(Common.isSmartPhone(request)) {%>
		.simply-scroll-list li a {display: block; float: left; width: 90px; height: 90px; margin: 0 3px 0 0;}
		<%} else {%>
		.simply-scroll-list li a {display: block; float: left; width: 120px; height: 120px; margin: 0 3px 0 0;}
		<%}%>
		.IllustThumb .IllustThumbImg {width: 100%; height: 100%;}
		.Footer {background: none;}
		.AnalogicoInfo {display: none;}
		</style>

		<script>
			$(function() {
				$('#loopSlide').simplyScroll({
					autoMode : 'loop',
					speed : 1,
					frameRate : 24,
					horizontal : true,
					pauseOnHover : true,
					pauseOnTouch : true
				});
				$('#MenuHome').addClass('Selected');
			});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<div style="width: 100%;">
			<h1 class="AnalogicoDesc Title">
				analogico (アナロジコ)へようこそ<br />
				<br />
				analogicoはアナログイラストを<br />愛する人のSNSです。<br />
				<br />
				<a class="AnalogicoDesc" href="/PopularIllustListPcV.jsp" style="text-decoration: underline;">
					<span class="fa fa-search"></span>analogicoをのぞいてみる
				</a>
			</h1>
			<div style="margin: 50px 0 0 0;">
				<ul id="loopSlide">
					<%for(CContent cContent : cResults.m_vContentList) {%>
					<li>
						<a class="IllustThumb" href="/<%=cContent.m_nUserId%>/<%=cContent.m_nContentId%>.html">
							<img class="IllustThumbImg" src="<%=Common.GetUrl(cContent.m_strFileName)%>_360.jpg">
						</a>
					</li>
					<%}%>
				</ul>
			</div>
			<div class="AnalogicoStart">
				<a class="BtnBase" href="/LoginFormTwitterPc.jsp">
					<span class="typcn typcn-social-twitter"></span> Twitterで新規登録/ログイン
				</a>
				<p><a class="AnalogicoDesc" href="/RulePcS.jsp" style="font-size: 14px; text-decoration: underline;">利用規約</a></p>
				<p><a class="AnalogicoDesc" href="/PrivacyPolicyPcS.jsp" style="font-size: 14px; text-decoration: underline;">プライバシーポリシー</a></p>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
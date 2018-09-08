<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(cCheckLogin.m_bLogin) {
	response.sendRedirect("/MyHomePcV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript" src="/js/jquery.simplyscroll.min.js"></script>
		<style>
		.Wrapper {width: 100%; color: #fff; background: #5bd; height: auto;}
		.AnalogicoDesc {width: 100%; padding: 40px 0 0 0; box-sizing: border-box; text-align: center; font-size: 14px; line-height: 28px; color: #fff; font-weight: normal;}
		.AnalogicoStart {text-align: center; margin: 60px 0 0 0; padding: 0 0 30px 0;}
		.IllustThumb .IllustThumbImg {width: 100%; height: 100%;}
		.AnalogicoInfo {display: none;}
		<%if(Common.isSmartPhone(request)) {%>
		<%} else {%>
		.AnalogicoDesc.Title {font-size: 16px;}
		<%}%>
		</style>
	</head>

	<body>
		<div class="TabMenu">
			<a class="TabMenuItem Selected" href="/"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
			<a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
			<a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
			<a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
			<h1 class="AnalogicoDesc Title">
				描くのに飽きたらポイポイ<br />
				下描き放置もポイポイ<br />
				完成したらもちろんポイポイ<br />
				日々の鍛錬をポイポイ<br />
				闇に葬る前にとりあえずポイポイ<br />
				なんでもポイピクにポイポイ<br />
				ポイポイしたら誰かがきっと励ましてくれる<br />
				<br />
				ポイピクはイラストをポイポイして<br />
				励まし合うイラストSNSです。
			</h1>
			<div class="AnalogicoStart">
				<a class="BtnBase Rev" href="/LoginFormTwitterPc.jsp">
					<span class="typcn typcn-social-twitter"></span> Twitterで新規登録/ログイン
				</a>
				<p><a class="AnalogicoDesc" href="/RulePcS.jsp" style="font-size: 14px; text-decoration: underline;">利用規約</a></p>
				<p><a class="AnalogicoDesc" href="/PrivacyPolicyPcS.jsp" style="font-size: 14px; text-decoration: underline;">プライバシーポリシー</a></p>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>
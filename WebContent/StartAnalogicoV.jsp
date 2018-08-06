<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

// login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

String strRequestUri = (String)request.getAttribute("javax.servlet.forward.request_uri");
String strRequestQuery = (String)request.getAttribute("javax.servlet.forward.query_string");

String strMessage = "";
session.removeAttribute("LoginUri");
if(strRequestUri != null) {
	if(strRequestQuery != null) {
		strRequestUri += "?" + strRequestQuery;
	}
	session.setAttribute("LoginUri", strRequestUri);
}

%>
<!DOCTYPE html>
<html style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>Start</title>
	</head>

	<style>
		.AnalogicoDesc {display: block; width: 90%; margin: 0 auto; padding: 10px 0; text-align: center; text-shadow: 0 0 8px #000; color: #fff; font-weight: normal;}
		.AnalogicoDesc.Title {margin: 50px auto; font-family: "游明朝", YuMincho, "ヒラギノ明朝 ProN W3", "Hiragino Mincho ProN", "HG明朝E", "ＭＳ Ｐ明朝", "ＭＳ 明朝", serif;}
		.AnalogicoLink {display: block; margin: 10px 0; text-align: center; text-shadow: 0 0 8px #000; color: #fff; font-weight: normal;}
		.AnalogicoLogin {margin: 10px 0;}
		.AnalogicoCode {margin: 10px 0;}
		.AnalogicoTerm {margin: 50px 0 0 0;}
	</style>

	<body style="color: #fff; background: url('/img/pc_top_bg.jpg') 50% 50% no-repeat fixed; background-size: cover;">
		<div id="DispMsg"></div>
		<div class="Wrapper">
			<div id="InfoMsg" style="float: left; width: 100%; padding: 60px 0 0 0; text-align: center;">
				<div class="AnalogicoDesc Title">
					analogico (アナロジコ)へようこそ<br />
					<br />
					analogicoはアナログイラストを<br />愛する人のためのSNSです。<br />
					<br />
					<a class="AnalogicoDesc" href="/PopularIllustListV.jsp" style="text-decoration: underline;">
						<span class="fa fa-search"></span>analogicoをのぞいてみる
					</a>
				</div>
				<div class="AnalogicoLogin">
					<a class="BtnBase" href="/LoginFormTwitter.jsp">
						<span class="typcn typcn-social-twitter"></span> Twitterで新規登録/ログイン
					</a>
				</div>
				<div class="AnalogicoCode">
					<a class="AnalogicoLink" style="font-size: 12px; text-decoration: underline;" href="/LoginFormV.jsp">(旧バージョン用)機種変コードの入力</a>
				</div>
				<div class="AnalogicoTerm">
					<a class="AnalogicoLink" href="/RuleS.jsp" style="font-size: 14px; text-decoration: underline;">利用規約</a>
					<a class="AnalogicoLink" href="/PrivacyPolicyS.jsp" style="font-size: 14px; text-decoration: underline;">プライバシーポリシー</a>
					<p class="AnalogicoLink" style="font-size: 11px; text-align: center;">
						利用規約は[me]→[設定]からいつでも確認することができます。
					</p>
				</div>
			</div>
		</div><!--Wrapper-->
	</body>
</html>

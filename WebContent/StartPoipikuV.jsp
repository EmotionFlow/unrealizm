<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
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
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title>Start</title>
	</head>

	<style>
		.AnalogicoDesc {display: block; width: 90%; margin: 0 auto; padding: 10px 0; text-align: center; color: #fff; font-weight: normal;}
		.AnalogicoDesc.Title {}
		.AnalogicoLink {display: block; margin: 10px 0; text-align: center; color: #fff; font-weight: normal;font-size: 12px;text-decoration: underline;}
		.AnalogicoLogin {margin: 10px 0;}
		.AnalogicoCode {margin: 10px 0;}
		.AnalogicoTerm {margin: 30px 0 0 0;}
		.AnalogicoLang {display: block; width: 90%; margin: 0 auto; font-size: 12px;}
	</style>

	<body style="color: #fff; background: #5bd;">
		<div id="DispMsg"></div>
		<div class="Wrapper">

			<div id="InfoMsg" style="float: left; width: 100%; padding: 60px 0 0 0; text-align: center;">
				<div class="AnalogicoDesc Title">
					<%=_TEX.T("Poipiku.Info.Message")%>
				</div>
				<div class="AnalogicoLogin">
					<a class="BtnBase" href="/LoginFormTwitter.jsp">
						<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login")%>
					</a>
				</div>
				<div class="AnalogicoCode">
					<a class="AnalogicoLink" href="/LoginFormV.jsp">機種変コードの入力</a>
				</div>
				<div class="AnalogicoTerm">
					<a class="AnalogicoLink" href="/RuleS.jsp"><%=_TEX.T("Footer.Term")%></a>
					<a class="AnalogicoLink" href="/PrivacyPolicyS.jsp"><%=_TEX.T("Footer.PrivacyPolicy")%></a>
					<p class="AnalogicoLink" style="font-size: 11px;">
						<%=_TEX.T("Footer.Term.Info")%>
					</p>
				</div>
				<div class="AnalogicoLang">
					<a style="text-decoration: underline; color: #fff;" onclick="ChLang('en')" href="javascript:void(0);">English</a>
					&nbsp
					<a style="text-decoration: underline; color: #fff;" onclick="ChLang('ja')" href="javascript:void(0);">日本語</a>
				</div>
			</div>
		</div><!--Wrapper-->
	</body>
</html>

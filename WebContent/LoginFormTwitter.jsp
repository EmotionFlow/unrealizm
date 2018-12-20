<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="oauth.signpost.basic.DefaultOAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthConsumer"%>
<%@page import="oauth.signpost.OAuthProvider"%>
<%@page import="oauth.signpost.OAuthConsumer"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");
//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);

//Twitter
String authUrl="";
try{
	OAuthConsumer consumer = new DefaultOAuthConsumer(
			Common.TWITTER_CONSUMER_KEY, Common.TWITTER_CONSUMER_SECRET
			);
	OAuthProvider provider = new DefaultOAuthProvider(
			"https://api.twitter.com/oauth/request_token",
			"https://api.twitter.com/oauth/access_token",
			//"https://api.twitter.com/oauth/authorize");
			"https://api.twitter.com/oauth/authenticate");
	provider.setOAuth10a(true);
	session.setAttribute("consumer", consumer);
	session.setAttribute("provider", provider);
	String callbackUri = Common.TWITTER_CALLBAK_DOMAIN + "/RegistTwitterUser.jsp";
	authUrl = provider.retrieveRequestToken(consumer, callbackUri);
	//Log.d("LoginFormTwitterV.jsp authUrl:"+authUrl);
}catch(Exception e){
	e.printStackTrace();
}

if(!authUrl.isEmpty()) {
	response.sendRedirect(authUrl);
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("EditSettingV.Twitter")%></title>
	</head>

	<body>
		<div class="Wrapper" style="text-align: center;">
			<p>
				Twitter is not working.<br />
				Wait for a moment.
			</p>
		</div>
	</body>
</html>

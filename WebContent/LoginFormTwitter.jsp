<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="oauth.signpost.basic.DefaultOAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthConsumer"%>
<%@page import="oauth.signpost.OAuthProvider"%>
<%@page import="oauth.signpost.OAuthConsumer"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");
//login check
CheckLogin checkLogin = new CheckLogin(request, response);

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
	String callbackUri = Util.toString(request.getParameter("CBPATH"));
	boolean isApp = callbackUri.equals("app");

	if(callbackUri.isEmpty() || callbackUri.equals("/")){
		if(Util.isSmartPhone(request)){
			callbackUri = Common.TWITTER_CALLBAK_DOMAIN + "/MyHomePcV.jsp?ID="+checkLogin.m_nUserId;
		}else{
			callbackUri = Common.TWITTER_CALLBAK_DOMAIN + "/MyHomePcV.jsp?ID="+checkLogin.m_nUserId;
		}
	}else{
		callbackUri = Common.TWITTER_CALLBAK_DOMAIN + callbackUri;
	}
	//Log.d("USERAUTH callbackuri:" + callbackUri);
	session.setAttribute("callback_uri", callbackUri);

	String strTwCallBackUri = "";
	if(isApp){
		strTwCallBackUri = Common.TWITTER_CALLBAK_DOMAIN + "/RegistTwitterUserApp.jsp";
	}else{
		strTwCallBackUri = Common.TWITTER_CALLBAK_DOMAIN + "/RegistTwitterUserPc.jsp";
	}
	//Log.d("USERAUTH twCallBackUri:" + strTwCallBackUri);
	authUrl = provider.retrieveRequestToken(consumer, strTwCallBackUri);

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
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("EditSettingV.Twitter")%></title>
	</head>

	<body>
		<article class="Wrapper" style="text-align: center;">
			<p>
				Twitter側の認証処理にに障害が発生しているようです。<br />
				しばらくお待ちいただくか、<a style="text-decoration: underline;" href="/LoginFormEmailPcV.jsp">メールアドレスとパスワードによるログイン</a>をお試しください。
			</p>
			<p>
				Twitter is not working.<br />
				Wait for a moment.
			</p>
		</article>
	</body>
</html>

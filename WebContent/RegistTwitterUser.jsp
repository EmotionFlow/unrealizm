<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="org.apache.commons.lang3.RandomStringUtils"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="javax.naming.*"%>
<%@page import="javax.sql.*"%>
<%@page import="oauth.signpost.http.*"%>
<%@page import="oauth.signpost.*"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");
CheckLogin checkLogin = new CheckLogin(request, response);

int nResult = UserAuthUtil.registUserFromTwitter(request, response, session, _TEX);
String nextUrl = "/MyHomeAppV.jsp";
java.lang.Object callbackUrl = session.getAttribute("callback_uri");
if(callbackUrl!=null) {
	nextUrl = callbackUrl.toString();
}

Log.d(String.format("USERAUTH RetistTwitterUser APP1 : user_id:%d, twitter_result:%d, url:%s", checkLogin.m_nUserId, nResult, nextUrl));

if(nResult>0) {
	response.sendRedirect(nextUrl);
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("EditSettingV.Twitter")%></title>
		<meta http-equiv="refresh" content="3;URL=/MyHomeAppV.jsp?ID=<%=checkLogin.m_nUserId%>" />
		<script>
		$(function(){
			sendObjectMessage("restart");
		});
		</script>
	</head>

	<body>
		<article class="Wrapper" style="text-align: center;">
			<p><%=_TEX.T("EditSettingV.Twitter")%></p>
			<a href="/MyHomeAppV.jsp">
			<%if(nResult>0) {%>
			<%=_TEX.T("RegistUserV.UpdateComplete")%>
			<%} else {%>
			<%=_TEX.T("RegistUserV.UpdateError")%>
			<%}%>
			</a>
		</article><!--Wrapper-->
	</body>
</html>

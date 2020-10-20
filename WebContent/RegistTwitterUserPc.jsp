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
CheckLogin cCheckLogin = new CheckLogin(request, response);

int nResult = UserAuthUtil.registUserFromTwitter(request, response, session, _TEX);
String nextUrl = "/MyHomePcV.jsp";
java.lang.Object callbackUrl = session.getAttribute("callback_uri");
if(callbackUrl!=null) {
	nextUrl = callbackUrl.toString();
}

Log.d(String.format("USERAUTH RetistTwitterUser WEB : user_id:%d, twitter_result:%d, url:%s", cCheckLogin.m_nUserId, nResult, nextUrl));

if(nResult>0) {
	response.sendRedirect(nextUrl);
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("EditSettingV.Twitter")%></title>
		<meta http-equiv="refresh" content="3;URL=/MyHomePcV.jsp?ID=<%=cCheckLogin.m_nUserId%>" />
		<style>
		.AnalogicoInfo {display: none;}
		</style>
		<script>
		$(function(){
			location.href = "/MyHomePcV.jsp?ID=<%=cCheckLogin.m_nUserId%>";
		});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper" style="text-align: center; margin: 150px auto;">
			<p><%=_TEX.T("EditSettingV.Twitter")%></p>
			<a href="/MyHomePcV.jsp">
			<%if(nResult>0) {%>
			<%=_TEX.T("RegistUserV.UpdateComplete")%>
			<%} else {%>
			<%=_TEX.T("RegistUserV.UpdateError")%>
			<%}%>
			</a>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>

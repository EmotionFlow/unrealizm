<%@page
language="java"
contentType="text/html; charset=UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="oauth.signpost.OAuthConsumer"%>
<%@page import="oauth.signpost.OAuthProvider"%>
<%@page import="oauth.signpost.http.HttpParameters"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");
CheckLogin checkLogin = new CheckLogin(request, response);

boolean bResult = false;

//login check
if(!checkLogin.m_bLogin || checkLogin.m_nUserId < 1){
	getServletContext().getRequestDispatcher("/StartUnrealizmV.jsp").forward(request,response);
	return;
}

RegistTwitterTokenC c = new RegistTwitterTokenC();
bResult = c.getResult(checkLogin, request, session, _TEX);

response.sendRedirect("/MyEditSettingV.jsp#TwitterSetting");
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("EditSettingV.Twitter")%></title>
		<meta http-equiv="refresh" content="3;URL=/MyEditSettingV.jsp#TwitterSetting" />
	</head>

	<body>
		<article class="Wrapper" style="text-align: center;">
			<p><%=_TEX.T("EditSettingV.Twitter")%></p>
			<a href="/MyEditSettingV.jsp#TwitterSetting">
			<%if(bResult) {%>
			<%=_TEX.T("RegistUserV.UpdateComplete")%>
			<%} else {%>
			<%=_TEX.T("RegistUserV.UpdateError")%>
			<%}%>
			</a>
		</article><!--Wrapper-->
	</body>
</html>

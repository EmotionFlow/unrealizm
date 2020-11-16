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
int userId = UserAuthUtil.registUserFromTwitter(request, response, session, _TEX);
CacheUsers0000.User user = CacheUsers0000.getInstance().getUser(userId);


Log.d(String.format("USERAUTH RetistTwitterUser APP2 : user_id:%d, twitter_result:%d, url:%s", cCheckLogin.m_nUserId, nResult, "myurlscheme://restart"));
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("EditSettingV.Twitter")%></title>
		<meta http-equiv="refresh" content="3;URL=myurlscheme://restart" />
		<script>
		$(function(){
			sendObjectMessage("auth_data?<%=Common.POIPIKU_LK_POST%>=<%=user.hashPass%>&<%=Common.LANG_ID_POST%>=<%=(user.langId==0)?"en":"ja"%>");
			//sendObjectMessage("restart");
		});
		</script>
	</head>

	<body>
		<article class="Wrapper" style="text-align: center;">
			<p><%=_TEX.T("EditSettingV.Twitter")%></p>
			<a href="myurlscheme://restart">
			<%if(nResult>0) {%>
			<%=_TEX.T("RegistUserV.UpdateComplete")%>
			<%} else {%>
			<%=_TEX.T("RegistUserV.UpdateError")%>
			<%}%>
			</a>
		</article><!--Wrapper-->
	</body>
</html>

<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");
CheckLogin checkLogin = new CheckLogin(request, response);

RegistTwitterUserC c = new RegistTwitterUserC(request, response, session, _TEX);
boolean result = c.getResults();
if (!result) return;

int loginResult = RegistTwitterUserC.ERROR_UNKOWN;
// TODO 複数レコード見つかった -> 選択を促す。
// １レコードだが、選択解除されている　-> 選択を促す。
// 1レコードで、選択解除されていない -> ログイン
// 0レコード -> 新規登録
if (c.results.size() == 0) {
	Log.d("register new user");
} else if (c.results.size() == 1 && !c.results.get(0).oauth.delFlg) {
	final RegistTwitterUserC.Result r = c.results.get(0);
	loginResult = RegistTwitterUserC.login(r.poipikuUserId, r.hashPassword, r.oauth, response);
} else {
	Log.d("deleted or found multiple users");
}

String nextUrl = "/MyHomeAppV.jsp";
java.lang.Object callbackUrl = session.getAttribute("callback_uri");
if(callbackUrl!=null) {
	nextUrl = callbackUrl.toString();
}

Log.d(String.format("USERAUTH RetistTwitterUser APP1 : user_id:%d, twitter_result:%d, url:%s", checkLogin.m_nUserId, loginResult, nextUrl));

if(loginResult == RegistTwitterUserC.ERROR_NONE) {
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
			<%if(loginResult == RegistTwitterUserC.ERROR_NONE) {%>
			<%=_TEX.T("RegistUserV.UpdateComplete")%>
			<%} else {%>
			<%=_TEX.T("RegistUserV.UpdateError")%>
			<%}%>
			</a>
		</article><!--Wrapper-->
	</body>
</html>

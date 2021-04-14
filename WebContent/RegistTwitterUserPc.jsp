<%@ page import="java.util.stream.Collectors" %>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
	final String SESSION_ATTRIBUTE = "RegistTwitterUserResult";
%>
<%
	boolean isApp = false;
	request.setCharacterEncoding("UTF-8");
	CheckLogin checkLogin = new CheckLogin(request, response);

	RegistTwitterUserC controller = new RegistTwitterUserC();
	Object sessionAttribute = session.getAttribute(SESSION_ATTRIBUTE);

	boolean result;
	if (sessionAttribute == null) {
		result = controller.getResults(request, session);
	} else {
		controller.results = (List<RegistTwitterUserC.Result>)sessionAttribute;
		int poipikuUserId = Util.toInt(request.getParameter("ID"));
		if (poipikuUserId == -1) {
			controller.results.clear();
			result = true;
		} else {
			result = Oauth.activatePoipikuUser(
					controller.results.get(0).oauth.twitterUserId, poipikuUserId);
			if (result) {
				controller.results = controller.results.stream()
						.filter(s -> s.user.m_nUserId == poipikuUserId)
						.collect(Collectors.toList());
				controller.results.get(0).oauth.delFlg = false;
			}
		}
	}
	if (!result) {
		if (sessionAttribute != null) {
			session.removeAttribute(SESSION_ATTRIBUTE);
		}
		return;
	}

	int loginResult = RegistTwitterUserC.ERROR_UNKOWN;

	// TODO 複数レコード見つかった -> 選択を促す。LoginFormTwitter
	// １レコードだが、連携解除されている　-> 選択を促す。
	// 1レコードで、連携解除されていない -> ログイン
	// 0レコード -> 新規登録

	if (controller.results.size() == 0) {
		Log.d("register new user");
		loginResult = RegistTwitterUserC.ERROR_NONE;
		if (sessionAttribute != null) {
			session.removeAttribute(SESSION_ATTRIBUTE);
		}
	} else if (controller.results.size() == 1 && !controller.results.get(0).oauth.delFlg) {
		final RegistTwitterUserC.Result r = controller.results.get(0);
		loginResult = RegistTwitterUserC.login(r.user.m_nUserId, r.hashPassword, r.oauth, response);
		String nextUrl = "/MyHomeAppV.jsp";
		java.lang.Object callbackUrl = session.getAttribute("callback_uri");
		if(callbackUrl!=null) {
			nextUrl = callbackUrl.toString();
		}
		Log.d(String.format("USERAUTH RetistTwitterUser APP1 : user_id:%d, twitter_result:%d, url:%s", checkLogin.m_nUserId, loginResult, nextUrl));
		if (sessionAttribute != null) {
			session.removeAttribute(SESSION_ATTRIBUTE);
		}
		if(loginResult == r.user.m_nUserId) {
			response.sendRedirect(nextUrl);
			return;
		}
	} else {
		Log.d("disconnected or found many users");
		session.setAttribute(SESSION_ATTRIBUTE, controller.results);
		loginResult = RegistTwitterUserC.ERROR_NONE;
	}


%>
<!DOCTYPE html>
<html>
<head>
	<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("EditSettingV.Twitter")%></title>
	<%if(loginResult != RegistTwitterUserC.ERROR_NONE){%>
	<meta http-equiv="refresh" content="3;URL=/MyHomeAppV.jsp?ID=<%=checkLogin.m_nUserId%>" />
	<%}else{%>
	<%if(isApp){%>
	<%@ include file="/inner/THeaderCommon.jsp"%>
	<%}else{%>
	<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
	<%}%>
	<%}%>
</head>

<body>
<article class="Wrapper ItemList">
	<%if(loginResult != RegistTwitterUserC.ERROR_NONE){%>
	<p><%=_TEX.T("EditSettingV.Twitter")%></p>
	<a href="/MyHomeAppV.jsp">
		<%=_TEX.T("RegistUserV.UpdateError")%>
	</a>
	<%}else{%>
	<section id="IllustThumbList" class="IllustItemList">
		<%
		for (RegistTwitterUserC.Result r : controller.results) {
			CUser user = r.user;
		%>
		<a class="UserThumb" href="/RegistTwitterUserPc.jsp?ID=<%=user.m_nUserId%>">
			<span class="UserThumbImg"
				  style="background-image:url('//img-cdn.poipiku.com<%=user.m_strFileName%>')">
			</span>
			<span class="UserThumbName"><%=user.m_strNickName%> (<%=user.m_nUserId%>)</span>
		</a>
		<%}%>
		<a class="UserThumb" href="/RegistTwitterUserPc.jsp?ID=-1">
			<span class="UserThumbImg"
				  style="background-image:url('//img-cdn.poipiku.com/img/default_user.jpg')">
			</span>
			<span class="UserThumbName">新しいアカウントを作る</span>
		</a>
	</section>
	<%}%>
</article><!--Wrapper-->
</body>
</html>

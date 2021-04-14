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

	final int NEW_USER = -1;
	int selectedUserId = -99;
	boolean result;
	if (sessionAttribute == null) {
		result = controller.getResults(request, session);
		if (controller.results.size() == 1) {
			selectedUserId = NEW_USER;
		} else {
			if (controller.results.size() == 2) {
				RegistTwitterUserC.Result r = controller.results.get(0);
				if (!r.oauth.delFlg) {
					selectedUserId = r.user.m_nUserId;
				}
			}
		}
	} else {
		controller.results = (List<RegistTwitterUserC.Result>)sessionAttribute;
		selectedUserId = Util.toInt(request.getParameter("ID"));
		final int finalSelectedUserId1 = selectedUserId;
		List<RegistTwitterUserC.Result> list = controller.results.stream()
				.filter(s -> s.user.m_nUserId == finalSelectedUserId1)
				.collect(Collectors.toList());
		if (list.size() > 0 && selectedUserId > 0) {
			result = Oauth.connectPoipikuUser(
					list.get(0).oauth.twitterUserId, selectedUserId);
		} else {
			result = true;
		}
	}
	if (!result) {
		if (sessionAttribute != null) {
			session.removeAttribute(SESSION_ATTRIBUTE);
		}
		return;
	}

	int loginResult;

	if (selectedUserId == NEW_USER || selectedUserId > 0) {
		final int finalSelectedUserId = selectedUserId;
		final RegistTwitterUserC.Result r = controller.results.stream()
				.filter(s -> (s.user.m_nUserId == finalSelectedUserId))
				.collect(Collectors.toList()).get(0);

		String nextUrl = "/MyHomePcV.jsp";
		if (selectedUserId == NEW_USER) {
			if (controller.results.size()>2) { // 不正アクセス。
				return;
			}
			loginResult = RegistTwitterUserC.register(request, controller.results.get(0).oauth, _TEX, response);
		} else {
			loginResult = RegistTwitterUserC.login(r.user.m_nUserId, r.hashPassword, r.oauth, response);
			java.lang.Object callbackUrl = session.getAttribute("callback_uri");
			if(callbackUrl!=null) {
				nextUrl = callbackUrl.toString();
			}
			Log.d(String.format("USERAUTH RetistTwitterUser APP1 : user_id:%d, twitter_result:%d, url:%s", checkLogin.m_nUserId, loginResult, nextUrl));
		}
		if (sessionAttribute != null) {
			session.removeAttribute(SESSION_ATTRIBUTE);
		}
		if(loginResult > 0) {
			response.sendRedirect(nextUrl);
			return;
		}
	} else {
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
	<p><%=_TEX.T("RegistTwitterUser.DoSelect")%></p>
	<section id="IllustThumbList" class="IllustItemList">
		<%
		for (RegistTwitterUserC.Result r : controller.results) {
			if (r.user.m_nUserId == -1) continue;
			final CUser user = r.user;
		%>
		<a class="UserThumb" href="/RegistTwitterUserPc.jsp?ID=<%=user.m_nUserId%>">
			<span class="UserThumbImg"
				  style="background-image:url('//img-cdn.poipiku.com<%=user.m_strFileName%>')">
			</span>
			<span class="UserThumbName"><%=user.m_strNickName%> (<%=user.m_nUserId%>)</span>
		</a>
		<%}%>
		<%if (controller.results.size()<=2) {%>
		<a class="UserThumb" href="/RegistTwitterUserPc.jsp?ID=-1">
			<span class="UserThumbImg"
				  style="background-image:url('//img-cdn.poipiku.com/img/default_user.jpg')">
			</span>
			<span class="UserThumbName"><%=_TEX.T("RegistTwitterUser.CreateNew")%></span>
		</a>
		<%}%>
	</section>
	<%}%>
</article><!--Wrapper-->
</body>
</html>

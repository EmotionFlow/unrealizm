<%@page import="java.util.stream.Collectors" %>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
	final String SESSION_ATTRIBUTE = "RegistTwitterUserResult";
	enum Status {Undef, Error, SelectUser, LoginSucceed, RegisterSucceed};
%>
<%
request.setCharacterEncoding("UTF-8");
CheckLogin checkLogin = new CheckLogin(request, response);

RegistTwitterUserC controller = new RegistTwitterUserC();
Object controllerResults = session.getAttribute(SESSION_ATTRIBUTE);

final int NEW_USER = -2;
int selectedUserId = -99;
boolean result;

if (controllerResults == null) { // 初回アクセス
	result = controller.getResults(request, session);
	session.removeAttribute("consumer");
	session.removeAttribute("provider");
	if (!result) {
		response.sendRedirect("/");
		return;
	}
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
} else { // 一覧から選択した時のアクセス
	controller.results = (List<RegistTwitterUserC.Result>) controllerResults;
	selectedUserId = Util.toInt(request.getParameter("ID"));
	if (selectedUserId == NEW_USER || selectedUserId > 0) {
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
	} else {
		result = false;
	}
}
if (!result) {
	if (controllerResults != null) {
		session.removeAttribute(SESSION_ATTRIBUTE);
	}
	return;
}

String nextUrl = "/MyHomePcV.jsp";
Status status = Status.Undef;

if (selectedUserId == NEW_USER || selectedUserId > 0) {
	if (selectedUserId == NEW_USER) { // 新規登録
		if (!(controller.results.size() == 1 || controller.results.size() == 2)) { // 不正アクセス。
			session.removeAttribute(SESSION_ATTRIBUTE);
			return;
		}
		int registerResult = RegistTwitterUserC.register(request, controller.results.get(0).oauth, _TEX, response);
		selectedUserId = registerResult;
		status = registerResult > 0 ? Status.RegisterSucceed : Status.Error;

		final int initFollowUserId = Util.findUserIdFromUrl(session.getAttribute("callback_uri").toString());
		if (initFollowUserId > 0) {
			FollowUser followUser = new FollowUser();
			followUser.userId = selectedUserId;
			followUser.followUserId = initFollowUserId;
			followUser.insert();
		}

	} else { // ログイン
		final int finalSelectedUserId = selectedUserId;
		final List<RegistTwitterUserC.Result> list = controller.results.stream()
				.filter(s -> s.user.m_nUserId == finalSelectedUserId)
				.collect(Collectors.toList());
		RegistTwitterUserC.Result r;
		if (list.size() > 0) {
			r = list.get(0);
			int loginResult = RegistTwitterUserC.login(r.user.m_nUserId, r.hashPassword, r.oauth, response);
			Object callbackUrl = session.getAttribute("callback_uri");
			if(callbackUrl!=null) {
				nextUrl = callbackUrl.toString();
				session.removeAttribute("callback_uri");
			}
			Log.d(String.format("USERAUTH RetistTwitterUser BROWSER1 : user_id:%d, twitter_result:%d, url:%s", selectedUserId, loginResult, nextUrl));
			status = loginResult > 0 ? Status.LoginSucceed : Status.Error;
		} else {
			status = Status.Error;
		}
	}
	if (controllerResults != null) {
		session.removeAttribute(SESSION_ATTRIBUTE);
	}
} else {
	session.setAttribute(SESSION_ATTRIBUTE, controller.results);
	status = Status.SelectUser;
}
%>
<%
if(!isApp && (status == Status.LoginSucceed || status == Status.RegisterSucceed)) {
	response.sendRedirect(nextUrl);
	return;
} else {
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
<head>
	<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("EditSettingV.Twitter")%></title>

	<%if (status == Status.LoginSucceed || status == Status.RegisterSucceed) { // ここにくるのはisApp==trueのみ%>

		<%@ include file="/inner/THeaderCommon.jsp"%>
		<meta http-equiv="refresh" content="3;URL=/MyHomeAppV.jsp?ID=<%=selectedUserId%>" />
		<script>
			$( () => {
				<%
				CacheUsers0000.User user = CacheUsers0000.getInstance().getUser(selectedUserId);
				%>
				sendObjectMessage("auth_data?<%=Common.POIPIKU_LK_POST%>=<%=user.hashPass%>&<%=Common.LANG_ID_POST%>=<%=(user.langId==0)?"en":"ja"%>");
			});
		</script>

	<%} else if (status == Status.SelectUser) {%>

		<%if(isApp){%>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%}else{%>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%}%>

	<%} else {%>

		<%if(isApp){%>
		<meta http-equiv="refresh" content="3;URL=/MyHomeAppV.jsp?ID=<%=checkLogin.m_nUserId%>" />
		<script>
			$( () => {sendObjectMessage("restart");});
		</script>
		<%}else{%>
		<meta http-equiv="refresh" content="3;URL=/MyHomePcV.jsp" />
		<%}%>

	<%}%>
</head>

<body>
<article class="Wrapper ItemList">

	<%if (status == Status.LoginSucceed || status == Status.RegisterSucceed) { // ここにくるのはisApp==trueのみ%>

		<p><%=_TEX.T("EditSettingV.Twitter")%></p>
		<a href="myurlscheme://restart">
			<%=_TEX.T("RegistUserV.UpdateComplete")%>
		</a>

	<%} else if (status == Status.SelectUser) {%>

		<p style="margin-left: 10px"><%=_TEX.T("RegistTwitterUser.DoSelect")%></p>
		<section id="IllustThumbList" class="IllustItemList">
			<%
				for (RegistTwitterUserC.Result r : controller.results) {
					if (r.user.m_nUserId == NEW_USER) continue;
					final CUser user = r.user;
			%>
			<a class="UserThumb" href="/RegistTwitterUser<%=isApp?"App":"Pc"%>.jsp?ID=<%=user.m_nUserId%>">
				<span class="UserThumbImg"
					  style="background-image:url('//img.poipiku.com<%=user.m_strFileName%>')">
				</span>
				<span class="UserThumbName"><%=user.m_strNickName%> (ID:<%=user.m_nUserId%>)</span>
			</a>
			<%}%>
			<%if (controller.results.size()<=2) {%>
			<a class="UserThumb" href="/RegistTwitterUser<%=isApp?"App":"Pc"%>.jsp?ID=<%=NEW_USER%>">
				<span class="UserThumbImg"
					  style="background-image:url('//img.poipiku.com/img/default_user.jpg')">
				</span>
				<span class="UserThumbName"><%=_TEX.T("RegistTwitterUser.CreateNew")%></span>
			</a>
			<%}%>
		</section>

	<%} else {%>

		<p><%=_TEX.T("EditSettingV.Twitter")%></p>
		<%if(isApp){%>
		<a href="myurlscheme://restart"><%=_TEX.T("RegistUserV.UpdateError")%></a>
		<%}else{%>
		<a href="/MyHomePcV.jsp"><%=_TEX.T("RegistUserV.UpdateError")%></a>
		<%}%>

	<%}%>
</article><!--Wrapper-->
</body>
</html>
<%
} //if(!isApp && isLoginSucceed) {} else{
%>
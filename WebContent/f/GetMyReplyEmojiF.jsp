<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
StringBuilder sb = new StringBuilder();

if (Util.isBot(request)) return;

boolean result = false;

if (!checkLogin.m_bLogin) {
	sb.append("<span>>ログインしてください</span>");
} else {
	var cResults = new GetMyReplyEmojiC();
	cResults.getParam(request);

	if (cResults.getResults(checkLogin)) {
		sb.append(CEmoji.parse(cResults.myReplyEmoji));
		result = true;
	}
}

%>
{"result":<%=result ? Common.API_OK : Common.API_NG%>, "html": "<%=CEnc.E(sb.toString())%>"}

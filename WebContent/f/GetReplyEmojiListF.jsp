<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
StringBuilder sb = new StringBuilder();

if (Util.isBot(request)) return;

if (!checkLogin.m_bLogin) {
	sb.append("<span class=\"IllustItemReplyListTitle\">ログインしてください</span>");
} else {
	var cResults = new GetReplyEmojiListC();
	cResults.getParam(request);

	List<String> replies = cResults.getResults(checkLogin);

	if (replies != null && !replies.isEmpty()) {
		for(String emoji : replies) {
			sb.append(
				String.format("<span class=\"ResEmoji\">%s</span>", CEmoji.parse(emoji))
			);
		}
	}
}

%>
{"result":<%=Common.API_OK%>, "html": "<%=CEnc.E(sb.toString())%>"}

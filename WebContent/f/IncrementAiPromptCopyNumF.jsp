<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	if (Util.isBot(request)) return;

	final String referer = Util.toString(request.getHeader("Referer"));
	if (!referer.contains("unrealizm.com")) {
		Log.d("ShowIllustDetailFへの不正アクセス(referer不一致):" + referer);
		return;
	}

	CheckLogin checkLogin = new CheckLogin(request, response);
	IncrementAiPromptCopyNumC results = new IncrementAiPromptCopyNumC();
	results.getParam(request);
	boolean result = results.getResults(checkLogin);
%>{"result":<%=result?Common.API_OK:Common.API_NG%>}
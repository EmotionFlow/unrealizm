<%@ page import="java.util.stream.Collectors" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
String referer = Util.toString(request.getHeader("Referer"));
if (!referer.contains("unrealizm")) {
    Log.d("おそらく不正アクセス Referer不一致 " + referer);
    return;
}

CheckLogin checkLogin = new CheckLogin(request, response);
if (!checkLogin.m_bLogin) return;
GetSearchLogC cResults = new GetSearchLogC();
cResults.getParam(request);
int nResult = cResults.getResults(checkLogin);
%>
{
"result": <%=nResult%>,
"keywords": [
    <%=cResults.keywords.stream().map(k -> "\"" + k + "\"").collect(Collectors.joining(","))%>
]
}

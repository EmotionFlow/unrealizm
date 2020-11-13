<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

UpdateActivityListC cResults = new UpdateActivityListC();
cResults.getParam(request);
String url = cResults.getResults(cCheckLogin);
if(url!=null && !url.isEmpty()) {
	response.sendRedirect(url);
}
return;
%>
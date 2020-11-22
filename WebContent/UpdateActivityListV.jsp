<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateActivityListC cResults = new UpdateActivityListC();
cResults.getParam(request);
String url = cResults.getResults(checkLogin);
if(url!=null && !url.isEmpty()) {
	response.sendRedirect(url);
}
return;
%>
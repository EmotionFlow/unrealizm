<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
SendTranslationSuggestionC cResults = new SendTranslationSuggestionC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(checkLogin);
%>{"result" : <%=bRtn?Common.API_OK:Common.API_NG%>}
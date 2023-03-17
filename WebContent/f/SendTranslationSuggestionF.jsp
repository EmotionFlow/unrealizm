<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
SendTranslationSuggestionC results = new SendTranslationSuggestionC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin);
%>{"result" : <%=bRtn?Common.API_OK:Common.API_NG%>}
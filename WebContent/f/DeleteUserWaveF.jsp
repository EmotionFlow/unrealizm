<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

DeleteUserWaveC results = new DeleteUserWaveC();
results.getParam(request);

boolean result =  results.getResults(checkLogin);
%>{"result": <%=result?Common.API_OK:Common.API_NG%>}
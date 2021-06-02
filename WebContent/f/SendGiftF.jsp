<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

SendGiftC c = new SendGiftC();
c.getParam(request);
boolean result = c.getResults(checkLogin, true, _TEX);
%>{ "result" : <%=(result)?1:0%>, "error_code" : <%=c.m_nErrCode%>}

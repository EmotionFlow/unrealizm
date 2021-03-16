<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

boolean result = false;
int errorCode = 0;
AcceptRequestCParam param = new AcceptRequestCParam();
param.GetParam(request);

AcceptRequestC acceptRequest = new AcceptRequestC();
result = acceptRequest.getResults(checkLogin, param);
errorCode = acceptRequest.errorCode;

%>{
"result" : <%=result?1:0%>,
"error_code" : <%=errorCode%>
}

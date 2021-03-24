<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

boolean result = false;
AcceptRequestCParam param = new AcceptRequestCParam();
param.GetParam(request);

AcceptRequestC acceptRequest = new AcceptRequestC();
result = acceptRequest.getResults(checkLogin, param);

%>{
"result" : <%=result?Common.API_OK:Common.API_NG%>,
"error_code" : <%=acceptRequest.errorKind.getCode()%>
}

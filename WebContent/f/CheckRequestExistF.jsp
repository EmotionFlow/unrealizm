<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

Request r = new Request();
boolean result = r.selectByContentId(Util.toInt(request.getParameter("CID")));
if (result) {
	result = r.id > 0;
}

%>{
"result" : <%=result?1:0%>,
"error_code" : <%=r.errorKind.getCode()%>
}

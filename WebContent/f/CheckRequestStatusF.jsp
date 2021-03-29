<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

Request r = new Request();
boolean result = r.selectByContentId(Util.toInt(request.getParameter("CID")));

%>{
"result" : <%=result?1:0%>,
"exist" : <%=r.id>0?1:0%>,
"status_code" : <%=r.status.getCode()%>,
"error_code" : <%=r.errorKind.getCode()%>
}

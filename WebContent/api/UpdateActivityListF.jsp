<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
UpdateActivityListC cResults = new UpdateActivityListC();
cResults.getParam(request);
boolean rtn = cResults.getResults(checkLogin);
%>
{"result": <%=rtn?Common.API_OK:Common.API_NG%>, "to_url": "<%=cResults.toUrl%>", "error_code": <%=cResults.errorKind.getCode()%>}

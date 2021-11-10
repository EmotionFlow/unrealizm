<%@ page import="java.time.LocalDate" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

boolean bRtn;
int errorCode;

CancelPassportCParam cParam = new CancelPassportCParam();
cParam.GetParam(request);

CancelPassportC cResults = new CancelPassportC();
bRtn = cResults.getResults(checkLogin, cParam);
errorCode = cResults.m_nErrCode;

%>{"result" : <%=(bRtn)?1:0%>, "error_code" : <%=errorCode%>}

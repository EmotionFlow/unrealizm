<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

boolean bRtn;
int errorCode;

CancelPassportCParam cParam = new CancelPassportCParam();
cParam.GetParam(request);

CancelPassportC results = new CancelPassportC();
bRtn = results.getResults(checkLogin, cParam);
errorCode = results.m_nErrCode;

%>{"result" : <%=(bRtn)?1:0%>, "error_code" : <%=errorCode%>}

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

CancelPassportCParam cParam = new CancelPassportCParam();
cParam.GetParam(request);

CancelPassportC cResults = new CancelPassportC();
boolean bRtn = cResults.getResults(checkLogin, cParam);
%>{
"result" : <%=(bRtn)?1:0%>,
"error_code" : <%=cResults.m_nErrCode%>
}

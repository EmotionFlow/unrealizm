<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

BuyPassportCParam cParam = new BuyPassportCParam();
cParam.GetParam(request);

BuyPassportC cResults = new BuyPassportC();
boolean bRtn = cResults.getResults(checkLogin, cParam);
%>{
"result" : <%=(bRtn)?1:0%>,
"error_code" : <%=cResults.errorCode%>
}

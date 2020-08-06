<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);

int m_nUserId = Common.ToInt(request.getParameter("ID"));

if(!cCheckLogin.m_bLogin || (cCheckLogin.m_nUserId != m_nUserId)) {
	return;
}

RequestExchangeCheerPointCParam cParam = new RequestExchangeCheerPointCParam();
cParam.GetParam(request);
RequestExchangeCheerPointC c = new RequestExchangeCheerPointC();
boolean bResult = c.GetResults(cParam);

%>{"result":<%=bResult%>}
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);

int m_nUserId = Util.toInt(request.getParameter("ID"));

if(!checkLogin.m_bLogin || (checkLogin.m_nUserId != m_nUserId)) {
	Log.d(String.format("%b, %d, %d", checkLogin.m_bLogin, checkLogin.m_nUserId, m_nUserId));
	Log.d("login error");
	return;
}

RequestExchangeCheerPointCParam cParam = new RequestExchangeCheerPointCParam();
cParam.GetParam(request);
RequestExchangeCheerPointC c = new RequestExchangeCheerPointC();
boolean bResult = c.GetResults(cParam);
%>{"result":<%=bResult?0:1%>}

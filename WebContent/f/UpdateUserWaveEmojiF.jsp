<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateUserWaveEmojiC results = new UpdateUserWaveEmojiC();
results.getParam(request);

boolean rtn = false;
if(checkLogin.m_bLogin) {
	rtn = results.getResults(checkLogin);
}
%>{"result":<%=rtn?Common.API_OK:Common.API_NG%>}

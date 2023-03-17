<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
SendEmojiC results = new SendEmojiC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin, _TEX);
%>{"result_num" : <%=(bRtn)?1:0%>, "result" : "<%=CEnc.E(CEmoji.parse(results.m_strEmoji))%>", "error_code" : <%=results.m_nErrCode%>}
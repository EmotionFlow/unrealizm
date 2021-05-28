<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
Log.d("%s, %s", request.getRemoteAddr(), request.getHeader("REFERER"));
%>
<%if(false){%>
{"result":<%=UserAuthUtil.registUser(request, response, _TEX)%>}
<%}%>
{"result":-1}

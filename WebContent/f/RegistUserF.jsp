<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
{"result":<%=UserAuthUtil.registUser(request, response, _TEX)%>}
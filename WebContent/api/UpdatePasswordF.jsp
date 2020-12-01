<%@page import="jp.pipa.poipiku.cache.CacheUsers0000.User"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
int userId = UserAuthUtil.updatePassword(request, response);
User user = CacheUsers0000.getInstance().getUser(userId);
String poipikuLk = "";
if(user!=null) {
	poipikuLk = user.hashPass;
}
%>
{
"result":<%=userId%>,
"poipiku_lk":<%=poipikuLk%>
}
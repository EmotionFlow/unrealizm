<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jp.pipa.poipiku.cache.CacheUsers0000"%>
<%
	String resp = "OK";
	String TOKEN = "kkvjaw8per32qt3j28ycb4";
	String token = request.getParameter("TOKEN");
	if (token != null && token.equals(TOKEN)) {
		try {
			int userId = Integer.parseInt(request.getParameter("ID"));
			CacheUsers0000.getInstance().clearUser(userId);
		} catch(Exception ex) {
			resp = "NG";
		}
	} else {
		resp = "NG";
	}
%>
<%=resp%>

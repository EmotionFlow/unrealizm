<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jp.pipa.poipiku.util.DatabaseUtil" %>
<%@ page import="java.sql.Connectionnnnnnn" %>
<%
	final String s = "Hello world!";
	Connection connection = DatabaseUtil.dataSource.getConnection();
%>
<!DOCTYPE html>
<html>
<head></head>
<body>
<%=s%>
</body>
</html>

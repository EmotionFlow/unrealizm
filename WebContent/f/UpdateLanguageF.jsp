<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

final int langId;
String strLocale = Util.toString(request.getParameter("LD"));
if (!strLocale.isEmpty()) {
	langId = SupportedLocales.findId(strLocale);
} else {
	return;
}

Connection connection = null;
PreparedStatement statement = null;
String strSql = "";

try {
	connection = DatabaseUtil.dataSource.getConnection();
	strSql = "UPDATE users_0000 SET lang_id=? WHERE user_id=?";
	statement = connection.prepareStatement(strSql);
	statement.setInt(1, langId);
	statement.setInt(2, checkLogin.m_nUserId);
	statement.executeUpdate();
	statement.close();statement =null;
	CacheUsers0000.getInstance().clearUser(checkLogin.m_strHashPass);
} catch(Exception e) {
	e.printStackTrace();
} finally {
	try{if(statement != null) statement.close();statement =null;} catch(Exception ignored) {;}
	try{if(connection != null) connection.close();connection =null;} catch(Exception ignored) {;}
}
%>{"result":<%=langId%>}
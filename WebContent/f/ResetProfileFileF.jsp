<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);

int m_nUserId = Util.toInt(request.getParameter("ID"));
int m_nModeId = Util.toInt(request.getParameter("MD"));

if(!checkLogin.m_bLogin || (checkLogin.m_nUserId != m_nUserId)) {
	return;
}

DataSource dsPostgres = null;
Connection cConn = null;
PreparedStatement cState = null;
ResultSet cResSet = null;
String strSql = "";

try {
	Class.forName("org.postgresql.Driver");
	dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
	cConn = dsPostgres.getConnection();

	strSql = "SELECT * FROM users_0000 WHERE user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cResSet = cState.executeQuery();
	String strDeleteFile = "";
	strSql = "";
	if(cResSet.next()) {
		switch(m_nModeId) {
		case 1:
	strDeleteFile = Util.toString(cResSet.getString("file_name"));
	strSql = "UPDATE users_0000 SET file_name='' WHERE user_id=?";
	break;
		case 2:
	strSql = "UPDATE users_0000 SET header_file_name='' WHERE user_id=?";
	strDeleteFile = Util.toString(cResSet.getString("header_file_name"));
	break;
		case 3:
	strSql = "UPDATE users_0000 SET bg_file_name='' WHERE user_id=?";
	strDeleteFile = Util.toString(cResSet.getString("bg_file_name"));
	break;
		default:
	break;
		}
	}
	cResSet.close();cResSet=null;
	cState.close();cState=null;

	if(strSql.length()>0 && strDeleteFile.length()>0) {
		ImageUtil.deleteFiles(getServletContext().getRealPath(strDeleteFile));
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, m_nUserId);
		cState.executeUpdate();
		cState.close();cState=null;
	}
	CacheUsers0000.getInstance().clearUser(checkLogin.m_strHashPass);
} catch(Exception e) {
	e.printStackTrace();
} finally {
	try{if(cState != null) cState.close();cState=null;} catch(Exception e) {;}
	try{if(cConn != null) cConn.close();cConn=null;} catch(Exception e) {;}
	try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
}
%>{"result":1}
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

int m_nUserId = Common.ToInt(request.getParameter("ID"));
int m_nModeId = Common.ToInt(request.getParameter("MD"));

if(!cCheckLogin.m_bLogin || (cCheckLogin.m_nUserId != m_nUserId)) {
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
			strDeleteFile = Common.ToString(cResSet.getString("file_name"));
			strSql = "UPDATE users_0000 SET file_name='' WHERE user_id=?";
			break;
		case 2:
			strSql = "UPDATE users_0000 SET header_file_name='' WHERE user_id=?";
			strDeleteFile = Common.ToString(cResSet.getString("header_file_name"));
			break;
		case 3:
			strSql = "UPDATE users_0000 SET bg_file_name='' WHERE user_id=?";
			strDeleteFile = Common.ToString(cResSet.getString("bg_file_name"));
			break;
		default:
			break;
		}
	}
	cResSet.close();cResSet=null;
	cState.close();cState=null;

	if(strSql.length()>0 && strDeleteFile.length()>0) {
		Log.d(strDeleteFile);
		CImage.DeleteFiles(getServletContext().getRealPath(strDeleteFile));
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, m_nUserId);
		cState.executeUpdate();
		cState.close();cState=null;
	}
} catch(Exception e) {
	e.printStackTrace();
} finally {
	try{if(cState != null) cState.close();cState=null;} catch(Exception e) {;}
	try{if(cConn != null) cConn.close();cConn=null;} catch(Exception e) {;}
	try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
}
%>{"result":1}
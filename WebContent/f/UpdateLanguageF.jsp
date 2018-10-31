<%@page import="jp.pipa.poipiku.*"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.naming.*"%>
<%@page import="javax.sql.*"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

int m_nLangId = Common.ToIntN(request.getParameter("LD"), 0, 1);

if(!cCheckLogin.m_bLogin) {
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

	strSql = "UPDATE users_0000 SET lang_id=? WHERE user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nLangId);
	cState.setInt(2, cCheckLogin.m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;
} catch(Exception e) {
	e.printStackTrace();
} finally {
	try{if(cState != null) cState.close();cState=null;} catch(Exception e) {;}
	try{if(cConn != null) cConn.close();cConn=null;} catch(Exception e) {;}
	try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
}
%>{"result":<%=m_nLangId%>}
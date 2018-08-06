<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.net.URLEncoder"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

int m_nUserId = Common.ToInt(request.getParameter("ID"));
String strNickName = Common.TrimAll(Common.ToStringHtml(Common.EscapeInjection(Common.ToString(request.getParameter("NN")))));

if(!cCheckLogin.m_bLogin || (cCheckLogin.m_nUserId != m_nUserId)) {
	return;
}

if(strNickName.length()<5) {
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

	strSql = "UPDATE users_0000 SET nickname=? WHERE user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setString(1, strNickName);
	cState.setInt(2, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;
} catch(Exception e) {
	e.printStackTrace();
} finally {
	try{if(cState != null) cState.close();cState=null;} catch(Exception e) {;}
	try{if(cConn != null) cConn.close();cConn=null;} catch(Exception e) {;}
	try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
}
%>{"result":1}
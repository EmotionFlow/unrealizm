<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="java.security.MessageDigest"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

int m_nUserId = Common.ToInt(request.getParameter("ID"));
String strProfile = Common.SubStrNum(Common.TrimAll(Common.ToString(request.getParameter("DES"))), 1000);

if(!cCheckLogin.m_bLogin || (cCheckLogin.m_nUserId != m_nUserId)) {
	return;
}

DataSource dsPostgres = null;
Connection cConn = null;
PreparedStatement cState = null;
ResultSet cResSet = null;
String strSql = "";
int nRtn = 0;

try {
	dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
	cConn = dsPostgres.getConnection();

	strSql = "UPDATE users_0000 SET profile=? WHERE user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setString(1, strProfile);
	cState.setInt(2, m_nUserId);
	cState.executeUpdate();
	cState.close(); cState=null;
	nRtn = 1;
} catch(Exception e) {
	System.out.println(strSql);
	e.printStackTrace();
} finally {
	try{if(cState != null) cState.close();cState=null;} catch(Exception e) {;}
	try{if(cConn != null) cConn.close();cConn=null;} catch(Exception e) {;}
	try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
}
%>{"result":<%=nRtn%>}
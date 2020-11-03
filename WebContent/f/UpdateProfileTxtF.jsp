<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);

int m_nUserId = Util.toInt(request.getParameter("ID"));
String strProfile = Common.SubStrNum(Common.TrimAll(Util.toString(request.getParameter("DES"))), 1000);

if(!checkLogin.m_bLogin || (checkLogin.m_nUserId != m_nUserId)) {
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
	CacheUsers0000.getInstance().clearUser(checkLogin.m_strHashPass);
	nRtn = 1;
} catch(Exception e) {
	Log.d(strSql);
	e.printStackTrace();
} finally {
	try{if(cState != null) cState.close();cState=null;} catch(Exception e) {;}
	try{if(cConn != null) cConn.close();cConn=null;} catch(Exception e) {;}
	try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
}
%>{"result":<%=nRtn%>}
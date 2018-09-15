<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

int m_nUserId = Common.ToInt(request.getParameter("ID"));

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

	strSql = "DELETE FROM tbloauth WHERE flduserid=? AND fldproviderid=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, cCheckLogin.m_nUserId);
	cState.setInt(2, Common.TWITTER_PROVIDER_ID);
	cResSet = cState.executeQuery();
	cState.executeUpdate(strSql);
	cState.close();cState=null;

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
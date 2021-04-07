<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);

int m_nUserId = Util.toInt(request.getParameter("ID"));

if(!checkLogin.m_bLogin || (checkLogin.m_nUserId != m_nUserId)) {
	return;
}

DataSource dsPostgres = null;
Connection cConn = null;
PreparedStatement cState = null;
String strSql = "";
int nRtn = 0;

try {
	dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
	cConn = dsPostgres.getConnection();
	strSql = "UPDATE tbloauth SET del_flg=True WHERE flduserid=? AND fldproviderid=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, checkLogin.m_nUserId);
	cState.setInt(2, Common.TWITTER_PROVIDER_ID);
	cState.execute();
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
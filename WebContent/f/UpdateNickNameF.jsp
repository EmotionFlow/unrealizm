<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);

int m_nUserId = Util.toInt(request.getParameter("ID"));
String strNickName = Common.TrimAll(Util.toStringHtml(Common.EscapeInjection(Util.toString(request.getParameter("NN")))));

if(!checkLogin.m_bLogin || (checkLogin.m_nUserId != m_nUserId)) return;

if(strNickName.length()<UserAuthUtil.LENGTH_NICKNAME_MIN || strNickName.length()>UserAuthUtil.LENGTH_NICKNAME_MAX) {
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
	CacheUsers0000.getInstance().clearUser(checkLogin.m_strHashPass);
} catch(Exception e) {
	e.printStackTrace();
} finally {
	try{if(cState != null) cState.close();cState=null;} catch(Exception e) {;}
	try{if(cConn != null) cConn.close();cConn=null;} catch(Exception e) {;}
	try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
}
%>{"result":1}
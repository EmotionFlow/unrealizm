<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

//パラメータの取得
request.setCharacterEncoding("UTF-8");
String strPassword	= Common.EscapeInjection(Common.ToString(request.getParameter("PW")));
String strHashPass = "";

DataSource dsPostgres = null;
Connection cConn = null;
PreparedStatement cState = null;
ResultSet cResSet = null;
try {
	dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
	cConn = dsPostgres.getConnection();

	String strSql = "SELECT * FROM users_0000 WHERE password=?";
	cState = cConn.prepareStatement(strSql);
	cState.setString(1, strPassword);
	cResSet = cState.executeQuery();
	if(cResSet.next()) {
		strHashPass 	= cResSet.getString("hash_password");
	}
	cResSet.close();cResSet=null;
	cState.close();cState=null;
} catch(Exception e) {
	e.printStackTrace();
} finally {
	try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
	try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
	try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
}


String strRequestUri = (String)session.getAttribute("LoginUri");
String strRedirectUrl = strRequestUri;
if(strRequestUri==null) {
	strRequestUri = "/LoginFormV.jsp";
	strRedirectUrl = "/";
}

if(strHashPass.length()>0) {
	Cookie cLK = new Cookie("POIPIKU_LK", strHashPass);

	cLK.setMaxAge(Integer.MAX_VALUE);
	cLK.setPath("/");

	response.addCookie(cLK);
}
%>{"result":<%=strHashPass.length()%>}
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);

int userId = Util.toInt(request.getParameter("ID"));
int twitterAccountPublicMode = Util.toInt(request.getParameter("MD"));

int nRtn = 0;
if(checkLogin.m_bLogin && (checkLogin.m_nUserId == userId)) {
	Connection cConn = null;
	PreparedStatement cState = null;
	String strSql = "";

	try {
		cConn =  DatabaseUtil.dataSource.getConnection();
		strSql = "UPDATE users_0000 SET twitter_account_public_mode = ? WHERE user_id=?";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, twitterAccountPublicMode);
		cState.setInt(2, userId);
		cState.executeUpdate();
		cState.close(); cState=null;
		nRtn = 1;
	} catch(Exception e) {
		Log.d(strSql);
		e.printStackTrace();
	} finally {
		try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
		try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
	}
}
%>{"result":<%=nRtn%>}
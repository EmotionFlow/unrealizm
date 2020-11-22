<%@page import="com.sun.org.apache.regexp.internal.recompile"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!class RegistNotificationTokenC {
	public int m_nUserId = -1;
	public String m_strDeviceTokenString = "";
	public int m_nTokenType = 0;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId				= Util.toInt(cRequest.getParameter("UID"));
			m_strDeviceTokenString	= Util.toString(cRequest.getParameter("TKN"));
			m_nTokenType			= Util.toInt(cRequest.getParameter("TYP"));	// 1: iOS, 2: Android
			if(m_strDeviceTokenString.length()>1024) m_strDeviceTokenString=m_strDeviceTokenString.substring(0, 1024);
		} catch(Exception e) {
			m_nTokenType = -1;
		}
	}

	public int GetResults(CheckLogin checkLogin) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		if(m_strDeviceTokenString.isEmpty()) return nRtn;

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// 同じTokenがあれば削除
			strSql ="DELETE FROM notification_tokens_0000 WHERE notification_token=? AND token_type=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, m_strDeviceTokenString);
			cState.setInt(2, m_nTokenType);
			cState.executeUpdate();
			cState.close();cState=null;

			// Tokenを登録
			strSql ="INSERT INTO notification_tokens_0000(user_id, notification_token, token_type) VALUES (?, ?, ?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.setString(2, m_strDeviceTokenString);
			cState.setInt(3, m_nTokenType);
			cState.executeUpdate();
			cState.close();cState=null;

			nRtn = checkLogin.m_nUserId;
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

RegistNotificationTokenC cResults = new RegistNotificationTokenC();
cResults.GetParam(request);

int nRtn = -1;
if( checkLogin.m_bLogin && cResults.m_nUserId == checkLogin.m_nUserId ) {
	nRtn = cResults.GetResults(checkLogin);
}
%>{"result":<%=nRtn%>}
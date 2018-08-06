<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%><%@ page import="javax.sql.*"%><%@ page import="javax.naming.*"%>
<%@ page import="java.net.*"%>
<%@ page import="javax.mail.*"%>
<%@ page import="javax.mail.internet.*"%>
<%@ page import="java.security.MessageDigest"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%!
class GetAccountCodeCParam {
	public int m_nUserId = -1;
	public String m_strPassWord = "";
	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId	= Common.ToInt(cRequest.getParameter("ID"));
		}
		catch(Exception e) {
			m_nUserId = -1;
		}
	}
}

class GetAccountCodeC {
	String m_strHashPass="";

	public boolean GetResults(GetAccountCodeCParam cParam) {
		boolean bResult = false;
		String strSql = "";
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;

		try{
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// create password
			for(boolean bLoop=true; bLoop;) {
				cParam.m_strPassWord = "";
				for(int nCnt=0; nCnt<16; nCnt++) {
					cParam.m_strPassWord += String.valueOf((int)(Math.random()*10));
				}

				strSql = "SELECT * FROM users_0000 WHERE password=?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, cParam.m_strPassWord);
				cResSet = cState.executeQuery();
				if(!cResSet.next()) {
					bLoop=false;
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			// update password
			strSql = "UPDATE users_0000 SET password=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, cParam.m_strPassWord);
			cState.setInt(2, cParam.m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;

			bResult = true;
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}

		return bResult;
	}
}
%><%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

GetAccountCodeCParam cParam = new GetAccountCodeCParam();
cParam.GetParam(request);

if(cCheckLogin.m_bLogin && cCheckLogin.m_nUserId==cParam.m_nUserId) {
	GetAccountCodeC cResults = new GetAccountCodeC();
	cResults.GetResults(cParam);
}
%>{"account_code":"<%=cParam.m_strPassWord%>"}
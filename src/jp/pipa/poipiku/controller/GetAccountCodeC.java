package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;


import jp.pipa.poipiku.CacheUsers0000;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class GetAccountCodeC {
	public int m_nUserId = -1;
	public String m_strPassWord = "";

	public void GetParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId	= Util.toInt(request.getParameter("ID"));
		}
		catch(Exception e) {
			m_nUserId = -1;
		}
	}

	String m_strHashPass="";

	public boolean GetResults(CheckLogin checkLogin) {
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
				m_strPassWord = "";
				for(int nCnt=0; nCnt<16; nCnt++) {
					m_strPassWord += String.valueOf((int)(Math.random()*10));
				}

				strSql = "SELECT * FROM users_0000 WHERE password=?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, m_strPassWord);
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
			cState.setString(1, m_strPassWord);
			cState.setInt(2, m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
			CacheUsers0000.getInstance().clearUser(checkLogin.m_strHashPass);
			bResult = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}

		return bResult;
	}

}

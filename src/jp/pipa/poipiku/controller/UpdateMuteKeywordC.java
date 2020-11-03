package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;


import jp.pipa.poipiku.CacheUsers0000;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class UpdateMuteKeywordC {
	// params
	public int m_nUserId = -1;
	public String m_strDescription = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId			= Util.toInt(request.getParameter("UID"));
			m_strDescription	= Common.TrimAll(Util.toString(request.getParameter("DES")));

			m_strDescription = m_strDescription.replace("　", " ").replace("\r\n", " ").replace("\r", " ").replace("\n", " ");
			if(m_strDescription.length()>100) {m_strDescription=m_strDescription.substring(0, 100);}
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public boolean getResults(CheckLogin checkLogin) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// update mute keyword
			String strKeywords[] = m_strDescription.split("[\\s.]");
			String strMuteKeyword = String.join(" OR ", strKeywords);

			strSql = "UPDATE users_0000 SET mute_keyword_list=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strMuteKeyword);
			cState.setInt(2, checkLogin.m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
			CacheUsers0000.getInstance().clearUser(checkLogin.m_strHashPass);
			bRtn = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try {if(cState != null) cState.close();} catch(Exception e) {;}
			try {if(cConn != null) cConn.close();} catch(Exception e) {;}
		}
		return bRtn;
	}
}

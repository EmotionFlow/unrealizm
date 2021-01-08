package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import jp.pipa.poipiku.CUser;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class UpdateNgDownloadC {
	// params
	public int m_nUserId = -1;
	public int m_nMode = CUser.AD_MODE_HIDE;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId = Util.toInt(request.getParameter("UID"));
			m_nMode = Util.toInt(request.getParameter("MID"));
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public int getResults(CheckLogin checkLogin) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "UPDATE users_0000 SET ng_download=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nMode);
			cState.setInt(2, checkLogin.m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
			CacheUsers0000.getInstance().clearUser(checkLogin.m_strHashPass);
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try {if(cState != null) cState.close();} catch(Exception e) {;}
			try {if(cConn != null) cConn.close();} catch(Exception e) {;}
		}
		return m_nMode;
	}

}

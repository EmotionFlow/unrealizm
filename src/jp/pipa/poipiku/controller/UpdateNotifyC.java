package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;

public class UpdateNotifyC {
	public int m_nUserId = -1;

	public void GetParam(HttpServletRequest request) {
		try {
			//cRequest.setCharacterEncoding("UTF-8");
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public boolean GetResults(CheckLogin checkLogin) {
		String strSql = "";
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;

		try {
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Update Last Check Time
			strSql = "UPDATE users_0000 SET last_check_date=CURRENT_TIMESTAMP, last_notify_date=CURRENT_TIMESTAMP WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CUser;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class UpdateSendEmailModeC {
	public int m_nUserId = -1;
	public int m_nMode = CUser.SEND_EMAIL_ON;

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
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			sql = "UPDATE users_0000 SET send_email_mode=? WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, m_nMode);
			statement.setInt(2, checkLogin.m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try {if(statement != null) statement.close();} catch(Exception e) {;}
			try {if(connection != null) connection.close();} catch(Exception e) {;}
		}
		return m_nMode;
	}

}

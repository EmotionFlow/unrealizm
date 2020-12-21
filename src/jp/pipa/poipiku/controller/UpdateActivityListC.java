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
import jp.pipa.poipiku.util.Util;

public class UpdateActivityListC {
	int user_id = -1;
	int content_id = -1;
	int info_type = Common.NOTIFICATION_TYPE_REACTION;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			info_type = Util.toInt(request.getParameter("TY"));
			user_id = Util.toInt(request.getParameter("ID"));
			content_id = Util.toInt(request.getParameter("TD"));
		} catch(Exception e) {
			user_id = -1;
		}
	}

	public int getResults(CheckLogin checkLogin) {
		if(!checkLogin.m_bLogin || (checkLogin.m_nUserId!=user_id)) return Common.API_NG;

		int rtn = Common.API_NG;
		String sql = "";
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// Get info_list
			sql = "UPDATE info_lists "
					+ "SET had_read=true, badge_num=0 "
					+ "WHERE user_id=? "
					+ "AND content_id=? "
					+ "AND info_type=? ";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, user_id);
			statement.setInt(2, content_id);
			statement.setInt(3, info_type);
			statement.executeUpdate();
			statement.close();statement=null;
			rtn = Common.API_OK;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			rtn = Common.API_NG;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return rtn;
	}
}

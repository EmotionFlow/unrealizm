package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class ActivityListC {
	public int m_nUserId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public ArrayList<ActivityInfo> m_vContentList = new ArrayList<>();
	public boolean GetResults(CheckLogin cCheckLogin) {
		String strSql = "";
		boolean bRtn = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// Get info_list
			strSql = "SELECT * FROM info_lists WHERE user_id=? ORDER BY had_read, info_date DESC LIMIT 50";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				ActivityInfo activityInfo = new ActivityInfo(resultSet);
				m_vContentList.add(activityInfo);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Update Last Check Time(UpdateNotify相当)
			strSql = "UPDATE users_0000 SET last_check_date=CURRENT_TIMESTAMP, last_notify_date=CURRENT_TIMESTAMP WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bRtn;
	}

	public class ActivityInfo {
		public int user_id = -1;
		public int content_id = -1;
		public int content_type = Common.CONTENT_TYPE_IMAGE;
		public int info_type = Common.NOTIFICATION_TYPE_REACTION;
		public String info_thumb = "";
		public String info_desc = "";
		public Timestamp info_date;
		public int badge_num = 0;
		public boolean had_read = false;

		ActivityInfo() {}
		ActivityInfo(ResultSet resultSet) throws SQLException {
			user_id = resultSet.getInt("user_id");
			content_id = resultSet.getInt("content_id");
			content_type = resultSet.getInt("content_type");
			info_type = resultSet.getInt("info_type");
			info_thumb = resultSet.getString("info_thumb");
			info_desc = resultSet.getString("info_desc");
			info_date = resultSet.getTimestamp("info_date");
			badge_num = resultSet.getInt("badge_num");
			had_read = resultSet.getBoolean("had_read");
		}
	}
}

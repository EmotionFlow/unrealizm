package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class ActivityAnalyzeC {
	int userId = -1;
	int mode = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("ID"));
			mode = Util.toIntN(request.getParameter("MD"), 0, 2);
		} catch(Exception e) {
			userId = -1;
		}
	}

	public static final int ERROR = -1;
	public static final int OK = 0;

	public ArrayList<ActivityInfo> activityInfos = new ArrayList<>();
	public ArrayList<ActivityInfo> activityLists = new ArrayList<>();
	public int emojiNumTotal = 0;
	public int getResults(CheckLogin checkLogin) {
		if(!checkLogin.m_bLogin || checkLogin.m_nUserId!=userId) return ERROR;

		String strSql = "";
		int returnVal = ERROR;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// create mode query
			String condTerm = "AND upload_date>CURRENT_TIMESTAMP-interval'7 days' ";
			int selectMax = 10;
			switch(mode) {
			case 2:	// total
				if(checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
					condTerm = "";
					selectMax = 100;
				}
				break;
			case 1:	// 30days
				if(checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
					condTerm = "AND upload_date>CURRENT_TIMESTAMP-interval'30 days' ";
					selectMax = 100;
				}
				break;
			case 0:	// 7day
			default:
				break;
			}

			// Get emoji_num_total
			strSql = "SELECT COUNT(description) "
					+ "FROM comments_0000 "
					+ "WHERE to_user_id=? "
					+ condTerm;
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				emojiNumTotal = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// Get info_list
			strSql = "SELECT description, COUNT(description) as emoji_num "
					+ "FROM comments_0000 "
					+ "WHERE to_user_id=? "
					+ condTerm
					+ "GROUP BY description "
					+ "ORDER BY emoji_num DESC LIMIT ?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			statement.setInt(2, selectMax);
			resultSet = statement.executeQuery();
			for (int i=0; resultSet.next(); i++) {
				ActivityInfo activityInfo = new ActivityInfo(resultSet);
				if(i<10) activityInfos.add(activityInfo);
				activityLists.add(activityInfo);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			returnVal = OK;	// 以下エラーが有ってもOK.表示は行う
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return returnVal;
	}

	public class ActivityInfo {
		public String description = "";
		public int emoji_num = -1;

		ActivityInfo() {}
		ActivityInfo(ResultSet resultSet) throws SQLException {
			description = resultSet.getString("description");
			emoji_num = resultSet.getInt("emoji_num");
		}
	}
}

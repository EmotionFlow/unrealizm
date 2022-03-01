package jp.pipa.poipiku.controller;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public final class ActivityListC {
	public static final SimpleDateFormat TIMESTAMP_FORMAT = new SimpleDateFormat("M/d HH:mm");
	public int userId = -1;
	public int infoType;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			infoType = Util.toInt(cRequest.getParameter("TY"));
		} catch(Exception e) {
			userId = -1;
		}
	}

	public ArrayList<InfoList> activities = new ArrayList<>();
	public boolean getResults(final CheckLogin checkLogin) {
		String strSql = "";
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			// Get info_list
			strSql = "SELECT * FROM info_lists WHERE user_id=? AND " +
					(infoType==Common.NOTIFICATION_TYPE_REACTION ? "(info_type=1 OR info_type=4)" : "(info_type=3 OR info_type=5)") +
					" ORDER BY had_read, info_date DESC LIMIT 50";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				InfoList activityInfo = new InfoList(resultSet);
				activities.add(activityInfo);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Update Last Check Time(UpdateNotify相当)
			strSql = "UPDATE users_0000 SET last_check_date=CURRENT_TIMESTAMP, last_notify_date=CURRENT_TIMESTAMP WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
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
}

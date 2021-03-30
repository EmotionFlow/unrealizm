package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;

public class NotificationBuffer extends Model {
	public int notificationId = -1;
	public String notificationToken = "";
	public int notificationType = -1;
	public int badgeNum = -1;
	public String title = "";
	public String subTitle = "";
	public String body = "";
	public String agentUuid = "";
	public Timestamp registDate;
	public int tokenType = -1;

	public boolean insert() {
		return insert(null);
	}

	public boolean insert(Connection _connection) {
		Connection connection = null;
		PreparedStatement statement = null;
		final String strSql = "INSERT INTO notification_buffers_0000(" +
				" notification_token, notification_type, badge_num," +
				" title, sub_title, body, token_type)" +
				" VALUES(?, ?, ?, ?, ?, ?, ?)";
		try {
			if (_connection == null) {
				connection = DatabaseUtil.dataSource.getConnection();
			} else {
				connection = _connection;
			}
			statement = connection.prepareStatement(strSql);
			statement.setString(1, notificationToken);
			statement.setInt(2, notificationType);
			statement.setInt(3, badgeNum);
			statement.setString(4, title);
			statement.setString(5, subTitle);
			statement.setString(6, body);
			statement.setInt(7, tokenType);
			statement.executeUpdate();
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(_connection==null && connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return true;
	}
}

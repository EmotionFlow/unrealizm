package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.notify.RequestStartedNotifier;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class NotifyRequestStartedToFollowee extends Batch {
	public static void main(String[] args) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		try {
			connection = dataSource.getConnection();
			sql = "SELECT user_id FROM request_creators WHERE status=2 AND notified=0 LIMIT 50";
			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();
			List<Integer> creatorUserIds = new ArrayList<>();
			while (resultSet.next()) {
				creatorUserIds.add(resultSet.getInt("user_id"));
			}
			resultSet.close();
			statement.close();
			connection.close();

			RequestStartedNotifier notifier = new RequestStartedNotifier();
			for (int creatorUserId : creatorUserIds) {
				if (CheckLogin.isStaff(creatorUserId)) {
					continue;
				}
				Log.d(String.format("creatorUserId: %d", creatorUserId));
				boolean notifyResult = notifier.notifyRequestStarted(creatorUserId);
				if (!notifyResult) {
					break;
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			Log.d(sql);
		} finally {
			if(resultSet!=null){try{resultSet.close();}catch(SQLException ignored){}};
			if(statement!=null){try{statement.close();}catch(SQLException ignored){}};
			if(connection!=null){try{connection.close();}catch(SQLException ignored){}};
		}
	}
}

package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.RegisteredNotifier;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class NotifyTwitterFollowerRegistered extends Batch {
	public static void main(String[] args) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		try {
			int userIdFrom, userIdTo;
			connection = dataSource.getConnection();
			sql = "SELECT num1 FROM counters WHERE id=1";
			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();
			resultSet.next();
			userIdFrom = resultSet.getInt(1) + 1;

			sql = "SELECT MAX(user_id) FROM users_0000";
			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();
			resultSet.next();
			userIdTo = resultSet.getInt(1);

			userIdFrom = userIdTo;

			Log.d(String.format("%d - %d", userIdFrom, userIdTo));

			RegisteredNotifier registeredNotifier = new RegisteredNotifier();
			boolean result = registeredNotifier.notifyToMyTwitterFollower(dataSource, userIdFrom, userIdTo);

//			if (result) {
//				sql = "UPDATE counters SET num1=? WHERE id=1";
//				statement = connection.prepareStatement(sql);
//				statement.setInt(1, userIdTo);
//			}
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

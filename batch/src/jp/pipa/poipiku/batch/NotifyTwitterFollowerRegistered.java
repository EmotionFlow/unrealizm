package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.notify.RegisteredNotifier;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;

public class NotifyTwitterFollowerRegistered extends Batch {
	// 配信時間帯
	private static final int[] DELIVERY_TIME = {1, 23};
	private static final int MAX_USER = 75;

	public static void main(String[] args) {
		// 配信時間帯外だったら何もしない
		LocalDateTime now = LocalDateTime.now();
		if (!(DELIVERY_TIME[0] < now.getHour() && now.getHour() < DELIVERY_TIME[1])) {
			Log.d("配信時間外");
			return;
		}

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
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			sql = "SELECT MAX(user_id) FROM users_0000";
			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();
			resultSet.next();
			userIdTo = resultSet.getInt(1);
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			userIdTo = Math.min(userIdFrom + MAX_USER, userIdTo);

			Log.d(String.format("%d - %d", userIdFrom, userIdTo));

			RegisteredNotifier registeredNotifier = new RegisteredNotifier();
			registeredNotifier.notifyToMyTwitterFollower(dataSource, userIdFrom, userIdTo);

			sql = "UPDATE counters SET num1=? WHERE id=1";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userIdTo);
			statement.executeUpdate();

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

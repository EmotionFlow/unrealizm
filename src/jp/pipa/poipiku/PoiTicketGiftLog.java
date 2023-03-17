package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;


public final class PoiTicketGiftLog extends Model {
	public int fromUserId = -1;
	public int toUserId = -1;
	public int orderId = -1;

	public PoiTicketGiftLog() { }

	public boolean insert() {
		if (fromUserId<0 || toUserId<0 || orderId<0) {
			Log.d("fromUserId<0 || toUserId<0 || orderId<0");
			errorKind = ErrorKind.OtherError;
			return false;
		}

		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			sql = "INSERT INTO poi_ticket_gift_logs(from_user_id, to_user_id, order_id) VALUES (?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, fromUserId);
			statement.setInt(2, toUserId);
			statement.setInt(3, orderId);
			statement.executeUpdate();

			errorKind = ErrorKind.None;

		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
			try{if(connection!=null){connection.rollback();}}catch(SQLException ignore){}
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.setAutoCommit(true);connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return true;
	}
}

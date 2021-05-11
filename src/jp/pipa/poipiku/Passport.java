package jp.pipa.poipiku;

import java.sql.*;
import java.time.LocalDateTime;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.CardSettlementEpsilon;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;


public final class Passport {
	public int userId = -1;
	public int courseId = -1;
	public Timestamp expiredAt = null;

//	public enum PaymentBy {
//		Undef,
//		Subscription,
//		Ticket
//	}
//	PaymentBy paymentByThisMonth = PaymentBy.Undef;

	public enum Status implements CodeEnum<Status> {
		Undef(-1),      // 未定義
		NotYet(0),      // 実績なし
		Active(1),      // 有効
		Cancelling(2),  // 解約予約中
		InActive(3);    // 無効
		private final int code;
		private Status(int code) {
			this.code = code;
		}

		static public Status byCode(int _code) {
			return CodeEnum.getEnum(Status.class, _code);
		}

		@Override
		public int getCode() {
			return code;
		}
	}
	Status status = Status.Undef;

	public Passport(CheckLogin checkLogin) {
		if(checkLogin == null || !checkLogin.m_bLogin) return;

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			sql = "SELECT * FROM passports WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();

			if (resultSet.next()) {
				courseId = resultSet.getInt("course_id");
				expiredAt = resultSet.getTimestamp("expired_at");
				status = Status.byCode(resultSet.getInt("status"));
			} else {
				status = Status.NotYet;
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
	}

	public boolean insert() {
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			sql = "INSERT INTO passports(user_id, status, course_id, expired_at) VALUES (?, ?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt(2, status.getCode());
			statement.setInt(3, courseId);
			statement.setTimestamp(4, expiredAt);
			statement.executeUpdate();

		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return true;
	}

	public boolean updateExpired(Timestamp _expiredAt) {
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "UPDATE passports SET expired_at=?, updated_at=current_timestamp WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setTimestamp(1, _expiredAt);
			statement.setInt(2, userId);
			statement.executeUpdate();
			expiredAt = _expiredAt;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return true;
	}

	public boolean updateStatus(Status _status) {
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "UPDATE passports SET status=?, updated_at=current_timestamp WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, _status.getCode());
			statement.setInt(2, userId);
			statement.executeUpdate();
			status = _status;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return true;
	}

}

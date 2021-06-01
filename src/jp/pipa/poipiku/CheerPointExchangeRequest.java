package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.*;

public final class CheerPointExchangeRequest extends Model {
	public boolean isExists = false;
	public enum Status implements CodeEnum<Status> {
		Undef(-99),
		Waiting(0),     // 支払い待ち
		Done(1),        // 完了
		Error(-1),      // エラー
		Canceled(-2);   // 取り消し

		static public Status byCode(int _code) {
			return CodeEnum.getEnum(Status.class, _code);
		}

		@Override
		public int getCode() {
			return code;
		}

		private final int code;

		private Status(int code) {
			this.code = code;
		}
	}

	public String requestId = "";
	public int userId = -1;
	public int exchangePoint;
	public int commissionFee;
	public int paymentFee;
	public String fCode = "";
	public String fName = "";
	public String fSubcode = "";
	public String fSubname = "";
	public int acType = -1;
	public String acCode = "";
	public String acName = "";
	public Status status = Status.Undef;
	public String messageFromStaff = "";
	public Timestamp createdAt = null;
	public Timestamp updatedAt = null;

	public CheerPointExchangeRequest() {
	}

	public CheerPointExchangeRequest(int _userId) {
		if (_userId < 0) {
			return;
		}
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			strSql = "SELECT * FROM cheer_point_exchange_requests WHERE user_id=? ORDER BY updated_at DESC LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, _userId);
			resultSet = statement.executeQuery();

			if (resultSet.next()) {
				set(resultSet);
				isExists = true;
				errorKind = ErrorKind.None;
			}

			resultSet.close();
			statement.close();
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
	}

	private void set(ResultSet resultSet) throws SQLException {
		requestId = resultSet.getString("request_id");
		userId = resultSet.getInt("user_id");
		exchangePoint = resultSet.getInt("exchange_point");
		commissionFee = resultSet.getInt("commission_fee");
		paymentFee = resultSet.getInt("payment_fee");
		fCode = resultSet.getString("f_code");
		fName = resultSet.getString("f_name");
		fSubcode = resultSet.getString("f_subcode");
		fSubname = resultSet.getString("f_subname");
		acType = resultSet.getInt("ac_type");
		acCode = resultSet.getString("ac_code");
		acName = resultSet.getString("ac_name");
		status = Status.byCode(resultSet.getInt("status"));
		messageFromStaff = resultSet.getString("message_from_staff");
		createdAt = resultSet.getTimestamp("created_at");
		updatedAt = resultSet.getTimestamp("updated_at");
	}
}

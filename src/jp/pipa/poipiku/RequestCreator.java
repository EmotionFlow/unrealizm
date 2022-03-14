package jp.pipa.poipiku;

import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.*;


public final class RequestCreator extends Model{
	private boolean exists = false;
	public int userId = -1;

	public enum Status {
		Undef(0),     // 未設定or設定中
		Disabled(1),  // 設定済みだがOFF
		Enabled(2),	// 設定済みでON
		NotFound(-1); // 見つからなかった
		private final int code;
		private Status(int code) {
			this.code = code;
		}
		public int getCode() {
			return code;
		}
	}
	private void setStatus(final int code){
		switch (code){
			case 0:
				status = Status.Undef;
				break;
			case 1:
				status = Status.Disabled;
				break;
			case 2:
				status = Status.Enabled;
				break;
			default:
				status = Status.Undef;
		}
	}
	public Status status = Status.Undef;

	static public final int ALLOW_MEDIA_DEFAULT = 1;
	private Integer allowMedia = ALLOW_MEDIA_DEFAULT;

	static public final int ALLOW_SENSITIVE_DEFAULT = 0;
	private Integer allowSensitive = ALLOW_SENSITIVE_DEFAULT;

	static public final int ALLOW_CLIENT_SIGNED = 0;
	static public final int ALLOW_CLIENT_ANONYMOUS = 1;  // 匿名リクエストOK
	private Integer allowClient = ALLOW_CLIENT_SIGNED;

	static public final int RETURN_PERIOD_MIN = 3;
	static public final int RETURN_PERIOD_MAX = 180;
	static public final int RETURN_PERIOD_DEFAULT = 7;
	public Integer returnPeriod = RETURN_PERIOD_DEFAULT;

	static public final int DELIVERY_PERIOD_MIN = 7;
	static public final int DELIVERY_PERIOD_MAX = 200;
	static public final int DELIVERY_PERIOD_DEFAULT = 60;
	public Integer deliveryPeriod = DELIVERY_PERIOD_DEFAULT;

	public boolean allowFreeRequest = true;
	public boolean allowPaidRequest = false;

	static public final int AMOUNT_LEFT_TO_ME_MIN = 3000;
	static public final int AMOUNT_LEFT_TO_ME_MAX = 10000;
	static public final int AMOUNT_LEFT_TO_ME_DEFAULT = 5000;
	public Integer amountLeftToMe = AMOUNT_LEFT_TO_ME_DEFAULT;

	static public final int AMOUNT_MINIMUM_MIN = 3000;
	static public final int AMOUNT_MINIMUM_MAX = 10000;
	static public final int AMOUNT_MINIMUM_DEFAULT = 3000;
	public Integer amountMinimum = AMOUNT_MINIMUM_DEFAULT;

	static public final int COMMERCIAL_TRANSACTION_LAW_MAX = 1500;
	public String commercialTransactionLaw = "";

	static public final int PROFILE_MAX = 5000;
	public String profile = "";

	static public final int NOTIFIED_ERROR = -1;
	static public final int NOTIFIED_NOT_YET = 0;
	static public final int NOTIFIED_STARTED = 1;
	public int notified = NOTIFIED_NOT_YET;

	public RequestCreator() { }
	public RequestCreator(final int _userId) {
		userId = _userId;
		init();
	}
	public RequestCreator(final CheckLogin checkLogin){
		if(checkLogin == null || !checkLogin.m_bLogin) return;
		userId = checkLogin.m_nUserId;
		init();
	}
	private void init(){
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			strSql = "SELECT * FROM request_creators WHERE user_id=? LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();

			if(resultSet.next()){
				setStatus(resultSet.getInt("status"));
				allowSensitive = resultSet.getInt("allow_sensitive");
				allowMedia = resultSet.getInt("allow_media");
				allowClient = resultSet.getInt("allow_client");
				allowFreeRequest = resultSet.getBoolean("allow_free_request");
				allowPaidRequest = resultSet.getBoolean("allow_paid_request");
				returnPeriod = resultSet.getInt("return_period");
				deliveryPeriod = resultSet.getInt("delivery_period");
				amountLeftToMe = resultSet.getInt("amount_left_to_me");
				amountMinimum = resultSet.getInt("amount_minimum");
				commercialTransactionLaw = resultSet.getString("commercial_transaction_law");
				profile = resultSet.getString("profile");
				notified = resultSet.getInt("notified");
				exists = true;
			}else{
				status = Status.NotFound;
			}

			resultSet.close();
			statement.close();
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}

	}

	public boolean allowIllust() {
		return allowMedia % 2 == 1;
	}

	public boolean allowNovel() {
		return (allowMedia / 10) % 2 == 1;
	}

	public boolean allowSensitive() {
		return allowSensitive == 1;
	}

	public boolean allowAnonymous() {
		return allowClient == ALLOW_CLIENT_ANONYMOUS;
	}
	
	public int tryInsert() {
		if (userId < 0) return -1;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		
		int result = 0;

		String strSql = "";

		try {
			cConn = DatabaseUtil.dataSource.getConnection();

			strSql = "INSERT INTO request_creators" +
					"(user_id, status, allow_media, allow_sensitive, allow_client, allow_free_request, allow_paid_request, return_period, delivery_period, amount_left_to_me, amount_minimum, commercial_transaction_law, profile)" +
					" VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT (user_id) DO NOTHING RETURNING user_id";
			cState = cConn.prepareStatement(strSql);
			int idx = 1;
			cState.setInt(idx++, userId);
			cState.setInt(idx++, status.getCode());
			cState.setInt(idx++, allowMedia);
			cState.setInt(idx++, allowSensitive);
			cState.setInt(idx++, allowClient);
			cState.setBoolean(idx++, allowFreeRequest);
			cState.setBoolean(idx++, allowPaidRequest);
			cState.setInt(idx++, returnPeriod);
			cState.setInt(idx++, deliveryPeriod);
			cState.setInt(idx++, amountLeftToMe);
			cState.setInt(idx++, amountMinimum);
			cState.setString(idx++, commercialTransactionLaw);
			cState.setString(idx++, profile);

			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				result = cResSet.getInt("user_id");
			}
			cState.close();
			errorKind = ErrorKind.None;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return result;
	}
	
	private boolean update(String column, Integer intValue, String strValue, Boolean boolValue){
		if (userId < 0) return false;
		if (!exists) tryInsert();

		Connection cConn = null;
		PreparedStatement cState = null;
		String strSql = "";
		try {
			cConn = DatabaseUtil.dataSource.getConnection();

			strSql = "UPDATE request_creators SET " + column + "=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			if (intValue != null) {
				cState.setInt(1, intValue);
			} else if (strValue != null) {
				cState.setString(1, strValue);
			} else if (boolValue != null) {
				cState.setBoolean(1, boolValue);
			}
			cState.setInt(2, userId);
			cState.executeUpdate();
			cState.close();
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
			return false;
		} finally {
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		errorKind = ErrorKind.None;
		return true;
	}

	private boolean update(final String column, final Integer intValue) {
		return update(column, intValue, null, null);
	}

	private boolean update(final String column, final String strValue) {
		return update(column, null, strValue, null);
	}

	private boolean update(final String column, final Boolean boolValue) {
		return update(column, null, null, boolValue);
	}

	public void delete() {
		if (userId < 0) return;
		Connection connection = null;
		PreparedStatement statement = null;
		String strSql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();

			strSql = "DELETE FROM request_creators WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			statement.executeUpdate();
			statement.close();
			errorKind = ErrorKind.None;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
	}
	
	public boolean updateStatus(final Status _status) {
		if (!update("status", _status.getCode())){
			return false;
		} else {
			if (_status == Status.Disabled) {
				update("notified", NOTIFIED_NOT_YET);
			}

			Connection connection = null;
			PreparedStatement statement = null;
			String strSql = "";
			try {
				connection = DatabaseUtil.dataSource.getConnection();

				strSql = "UPDATE users_0000 SET request_creator_status=? WHERE user_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, _status.getCode());
				statement.setInt(2, userId);
				statement.executeUpdate();
				statement.close();
				errorKind = ErrorKind.None;
			} catch(Exception e) {
				Log.d(strSql);
				e.printStackTrace();
				errorKind = ErrorKind.DbError;
				return false;
			} finally {
				try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
				try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
			}
			CacheUsers0000.getInstance().clearUser(userId);
			status = _status;
		}
		return true;
	}
	public boolean updateAllowMedia(final boolean illustOk, final boolean novelOk) {
		int n = 0;
		if (illustOk) { n += 1; }
		if (novelOk) { n += 10; }
		return update("allow_media", n);
	}
	public boolean updateAllowSensitive(boolean isOk) {
		return update("allow_sensitive", isOk ? 1 : 0);
	}
	public boolean updateAllowAnonymous(boolean isOk) {
		return update("allow_client", isOk ? ALLOW_CLIENT_ANONYMOUS : ALLOW_CLIENT_SIGNED);
	}
	public boolean updateAllowFreeRequest(boolean isOk) {
		return update("allow_free_request", isOk);
	}
	public boolean updateAllowPaidRequest(boolean isOk) {
		return update("allow_paid_request", isOk);
	}
	public boolean updateReturnPeriod(final int day) {
		if (RETURN_PERIOD_MIN <= day && day <= RETURN_PERIOD_MAX) {
			return update("return_period", day);
		}
		return false;
	}
	public boolean updateDeliveryPeriod(final int day) {
		if (DELIVERY_PERIOD_MIN <= day && day <= DELIVERY_PERIOD_MAX) {
			return update("delivery_period", day);
		}
		return false;
	}
	public boolean updateAmountLeftToMe(final int amount) {
		if (AMOUNT_LEFT_TO_ME_MIN <= amount && amount <= AMOUNT_LEFT_TO_ME_MAX) {
			return update("amount_left_to_me", amount);
		}
		return false;
	}
	public boolean updateAmountMinimum(final int amount) {
		if (AMOUNT_MINIMUM_MIN <= amount && amount <= AMOUNT_MINIMUM_MAX) {
			return update("amount_minimum", amount);
		}
		return false;
	}
	public boolean updateCommercialTransactionLaw(final String text) {
		if (text.length() <= COMMERCIAL_TRANSACTION_LAW_MAX) {
			return update("commercial_transaction_law", text);
		}
		return false;
	}
	public boolean updateProfile(final String text) {
		if (text.length() <= PROFILE_MAX) {
			return update("profile", text);
		}
		return false;
	}
	public boolean updateNotifiedStarted() {
		return update("notified", NOTIFIED_STARTED);
	}
}

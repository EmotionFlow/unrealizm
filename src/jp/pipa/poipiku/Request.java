package jp.pipa.poipiku;

import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.*;


public class Request extends Model{
	public int id = -1;
	public int clientUserId = -1;
	public int creatorUserId = -1;
	public Status status = Status.Undefined;
	public int mediaId = -1;
	public String requestText = "";
	public int requestCategory = -1;
	public int amount = -1;
	public Timestamp returnLimit = null;
	public Timestamp deliveryLimit = null;
	public int orderId = -1;
	public int contentId = -1;

	public enum Status implements CodeEnum<Status> {
		Undefined(0),       // 未定義
		WaitingAppoval(1),  // 承認待ち
		InProgress(2),	  // 作業中
		Done(3),            // 完了
		Canceled(-1),       // キャンセル
		SettlementError(-2),// 決済エラー
		OtherError(-99);    // その他エラー

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

	public Request() { }
	public Request(ResultSet resultSet) throws SQLException {
		set(resultSet);
	}
	public Request(int reauestId){
		selectByRequestId(reauestId);
	}
	private void set(ResultSet resultSet) throws SQLException {
		id = resultSet.getInt("id");
		status = Status.byCode(resultSet.getInt("status"));
		clientUserId = resultSet.getInt("client_user_id");
		creatorUserId = resultSet.getInt("creator_user_id");
		mediaId = resultSet.getInt("media_id");
		requestText = resultSet.getString("request_text");
		requestCategory = resultSet.getInt("request_category");
		amount = resultSet.getInt("amount");
		returnLimit = resultSet.getTimestamp("return_limit");
		deliveryLimit = resultSet.getTimestamp("delivery_limit");
		orderId = resultSet.getInt("order_id");
		contentId = resultSet.getInt("content_id");
	}

	private void selectByRequestId(final int requestId){
		if (requestId < 0) {
			return;
		}
		DataSource dataSource;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			strSql = "SELECT * FROM requests WHERE id=? LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, requestId);
			resultSet = statement.executeQuery();

			if(resultSet.next()){
				set(resultSet);
			}

			resultSet.close();
			statement.close();
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
	}

	public boolean isClient(int userId) {
		return (clientUserId > 0 && clientUserId == userId);
	}

	public boolean selectByContentId(final int _contentId) {
		if (_contentId < 0) {
			errorKind = ErrorKind.OtherError;
			return false;
		}

		DataSource dataSource;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			strSql = "SELECT * FROM requests WHERE content_id=? LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, _contentId);
			resultSet = statement.executeQuery();

			if(resultSet.next()){
				set(resultSet);
			}

			errorKind = ErrorKind.None;
			return true;

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
	}
	
	public boolean insert() {
		if (id > 0 ||
			clientUserId < 0 ||
			creatorUserId < 0 ||
			mediaId < 0 ||
			requestText.isEmpty() ||
			requestCategory < 0 ||
			amount < RequestCreator.AMOUNT_MINIMUM_MIN
		) {
			errorKind = ErrorKind.OtherError;
			return false;
		}

		DataSource dataSource;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		int result = 0;
		String sql = "";

		try {
			RequestCreator requestCreator = new RequestCreator(creatorUserId);
			if (requestCreator.status == RequestCreator.Status.Enabled) {
				Class.forName("org.postgresql.Driver");
				dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
				connection = dataSource.getConnection();
				sql = "INSERT INTO public.requests(" +
						" status, client_user_id, creator_user_id, media_id, request_text," +
						" request_category, amount, return_limit, delivery_limit)" +
						" VALUES (?, ?, ?, ?, ?, ?, ?, current_timestamp + interval '%d day', current_timestamp + interval '%d day')" +
						" RETURNING id";
				sql = String.format(sql, requestCreator.returnPeriod, requestCreator.deliveryPeriod);
				statement = connection.prepareStatement(sql);
				int idx = 1;
				statement.setInt(idx++, Status.Undefined.getCode());
				statement.setInt(idx++, clientUserId);
				statement.setInt(idx++, creatorUserId);
				statement.setInt(idx++, mediaId);
				statement.setString(idx++, requestText);
				statement.setInt(idx++, requestCategory);
				statement.setInt(idx++, amount);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					this.id = resultSet.getInt(1);
					errorKind = ErrorKind.None;
					return true;
				} else {
					errorKind = ErrorKind.OtherError;
					return false;
				}
			} else {
				Log.d("creator is disabled");
				errorKind = ErrorKind.OtherError;
				return false;
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
	}

	public boolean updateStatus(Status newStatus) {
		boolean result;
		DataSource dataSource;
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();
			sql = "UPDATE requests SET status=?, updated_at=CURRENT_TIMESTAMP WHERE id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, newStatus.getCode());
			statement.setInt(2, id);
			statement.executeUpdate();
			status = newStatus;
			errorKind = ErrorKind.None;
			result = true;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
			result = false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return result;
	}

	public boolean send(final int _orderId) {
		if (status != Status.Undefined) {
			errorKind = ErrorKind.StatementError;
			return false;
		}
		boolean result = false;
		DataSource dataSource;
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();
			sql = "UPDATE requests SET order_id=?, updated_at=CURRENT_TIMESTAMP WHERE id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, _orderId);
			statement.setInt(2, id);
			statement.executeUpdate();
			orderId = _orderId;
			errorKind = ErrorKind.None;
			result = true;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
			result = false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		updateStatus(Request.Status.WaitingAppoval);
		return result;
	}

	public boolean accept() {
		if (status != Status.WaitingAppoval) {
			updateStatus(Status.OtherError);
			errorKind = ErrorKind.StatementError;
			return false;
		}
		if (updateStatus(Status.InProgress)) {
			errorKind = ErrorKind.None;
			return true;
		} else {
			errorKind = ErrorKind.OtherError;
			return false;
		}
	}

	public boolean deliver(int _contentId) {
		if (status != Status.InProgress || _contentId < 0) {
			updateStatus(Status.OtherError);
			Log.d(String.format("ステータスまたはcontentIdが異常 %d, %d", status.getCode(), _contentId));
			errorKind = ErrorKind.StatementError;
			return false;
		}

		boolean result;
		DataSource dataSource;
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();
			sql = "UPDATE requests SET content_id=?, updated_at=CURRENT_TIMESTAMP WHERE id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, _contentId);
			statement.setInt(2, id);
			statement.executeUpdate();
			this.contentId = _contentId;
			errorKind = ErrorKind.None;
			result = true;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
			result = false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}

		return result && updateStatus(Status.Done);
	}

	public boolean cancel() {
		if (status != Status.InProgress && status != Status.WaitingAppoval) {
			updateStatus(Status.OtherError);
			errorKind = ErrorKind.StatementError;
			return false;
		}
		return updateStatus(Status.Canceled);
	}
}

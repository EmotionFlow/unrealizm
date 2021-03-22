package jp.pipa.poipiku;

import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.*;


public class Request {
	public int id = -1;
	public int clientUserId = -1;
	public int creatorUserId = -1;

	public enum Status implements DbCodeEnum<Status> {
		Undef(0),           // 未定義
		WaitingAppoval(1),  // 承認待ち
		InProgress(2),	  // 作業中
		Done(3),            // 完了
		Canceled(-1),       // キャンセル
		SettlementError(-2),// 決済エラー
		OtherError(-99);    // その他エラー

		private final int code;
		private Status(int code) {
			this.code = code;
		}

		@Override
		public int getCode() {
			return code;
		}

		static public Status byCode(int _code) {
			return DbCodeEnum.getEnum(Status.class, _code);
		}
	}
	public Status status = Status.WaitingAppoval;

	public int mediaId = -1;
	public String requestText = "";
	public int requestCategory = -1;
	public int amount = -1;
	public Timestamp returnLimit = null;
	public Timestamp deliveryLimit = null;
	public int orderId = -1;
	public int contentId = -1;

	public Request() { }
	public Request(ResultSet resultSet) throws SQLException {
		set(resultSet);
	}
	public Request(int _id){
		id = _id;
		init();
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
	private void init(){
		if (id < 0) {
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
			statement.setInt(1, id);
			resultSet = statement.executeQuery();

			if(resultSet.next()){
				set(resultSet);
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

	public boolean isClient(int userId) {
		return (clientUserId > 0 && clientUserId == userId);
	}

	public int selectByContentId() {
		if (contentId < 0) {
			return -99;
		}

		int result = -1;
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
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();

			if(resultSet.next()){
				set(resultSet);
			}

			resultSet.close();
			statement.close();
			result = 0;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			result = -1;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return result;
	}
	
	public int insert() {
		if (id > 0 ||
			clientUserId < 0 ||
			creatorUserId < 0 ||
			mediaId < 0 ||
			requestText.isEmpty() ||
			requestCategory < 0 ||
			amount < RequestCreator.AMOUNT_MINIMUM_MIN
		) {
			return -1;
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
				statement.setInt(idx++, Status.WaitingAppoval.getCode());
				statement.setInt(idx++, clientUserId);
				statement.setInt(idx++, creatorUserId);
				statement.setInt(idx++, mediaId);
				statement.setString(idx++, requestText);
				statement.setInt(idx++, requestCategory);
				statement.setInt(idx++, amount);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					this.id = resultSet.getInt(1);
					result = 0;
				} else {
					result = -99;
				}
			} else {
				Log.d("creator is disabled");
				result = -1;
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return result;
	}

	private boolean updateStatus(Status newStatus) {
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
			result = true;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			result = false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return result;
	}

	public int accept() {
		if (status != Status.WaitingAppoval) {
			updateStatus(Status.OtherError);
			return -99;
		}
		if (updateStatus(Status.InProgress)) {
			return 0;
		} else {
			return -99;
		}
	}

	public int deliver(int _contentId) {
		if (status != Status.InProgress || _contentId < 0) {
			updateStatus(Status.OtherError);
			Log.d(String.format("ステータスまたはcontentIdが異常 %d, %d", status.getCode(), _contentId));
			return -99;
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
			result = true;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			result = false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}

		if (result && updateStatus(Status.Done)) {
			return 0;
		} else {
			Log.d("ステータス更新失敗");
			return -99;
		}
	}

	public int cancel() {
		if (status != Status.InProgress && status != Status.WaitingAppoval) {
			updateStatus(Status.OtherError);
			return -99;
		}
		if (updateStatus(Status.Canceled)) {
			return 0;
		} else {
			return -99;
		}
	}

	public int settlementError() {
		if (status != Status.WaitingAppoval) {
			updateStatus(Status.OtherError);
			return -99;
		}
		if (updateStatus(Status.SettlementError)) {
			return 0;
		} else {
			return -99;
		}
	}
}

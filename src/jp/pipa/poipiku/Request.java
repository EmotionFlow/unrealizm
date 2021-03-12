package jp.pipa.poipiku;

import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;


public class Request {
	public int id = -1;
	public int clientUserId = -1;
	public int creatorUserId = -1;

	public enum Status {
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
		public int getCode() {
			return code;
		}
	}
	public Status status = Status.WaitingAppoval;
	private void setStatus(int code){
		status = Status.Undef;
		for (Status s: Status.values()) {
			if (s.getCode() == code){
				status = s;
				break;
			}
		}
	}

	public int mediaId = -1;
	public String requestText = "";
	public int requestCategory = -1;
	public int amount = -1;
	public Timestamp returnLimit = null;
	public Timestamp deliveryLimit = null;
	public int orderId = -1;

	public Request() { }
	public Request(int _id){
		id = _id;
		init();
	}
	private void init(){
		if (id < 0) {
			return;
		}
		DataSource dataSource;
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			strSql = "SELECT * FROM requests WHERE id=? LIMIT 1";
			preparedStatement = connection.prepareStatement(strSql);
			preparedStatement.setInt(1, id);
			resultSet = preparedStatement.executeQuery();

			if(resultSet.next()){
				setStatus(resultSet.getInt("status"));
				clientUserId = resultSet.getInt("client_user_id");
				creatorUserId = resultSet.getInt("creator_user_id");
				mediaId = resultSet.getInt("media_id");
				requestText = resultSet.getString("request_text");
				requestCategory = resultSet.getInt("request_category");
				amount = resultSet.getInt("amount");
				returnLimit = resultSet.getTimestamp("return_limit");
				deliveryLimit = resultSet.getTimestamp("delivery_limit");
				orderId = resultSet.getInt("order_id");
			}

			resultSet.close();
			preparedStatement.close();
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(preparedStatement!=null){preparedStatement.close();preparedStatement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}

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
		PreparedStatement preparedStatement = null;
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
						" VALUES (?, ?, ?, ?, ?, ?, ?, current_timestamp + interval '%d day', current_timestamp + interval '%d day')";
				sql = String.format(sql, requestCreator.returnPeriod, requestCreator.deliveryPeriod);
				preparedStatement = connection.prepareStatement(sql);
				int idx = 1;
				preparedStatement.setInt(idx++, Status.WaitingAppoval.getCode());
				preparedStatement.setInt(idx++, clientUserId);
				preparedStatement.setInt(idx++, creatorUserId);
				preparedStatement.setInt(idx++, mediaId);
				preparedStatement.setString(idx++, requestText);
				preparedStatement.setInt(idx++, requestCategory);
				preparedStatement.setInt(idx++, amount);
				preparedStatement.executeUpdate();
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(preparedStatement!=null){preparedStatement.close();preparedStatement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return result;
	}
}

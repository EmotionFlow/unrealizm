package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public class CreditCard {
	public int id = -1;
	public int userId = -1;
	public int agentId = -1;
	public String cardExpire = "";
	public String securityCode = "";
	public String agentUserId = "";
	public String lastAgentOrderId = "";
	public boolean isInvalid = false;
	
	public CreditCard(int _userId, int _agentId){
		userId = _userId;
		agentId = _agentId;
	}

	public boolean select() {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		final String sql =
				"SELECT id, user_id, agent_id, card_expire, security_code, agent_user_id, last_agent_order_id, invalid_flg" +
				" FROM creditcards" +
				" WHERE user_id=? AND agent_id=? AND del_flg=false";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			int idx = 1;
			statement.setInt(idx++, userId);
			statement.setInt(idx++, agentId);
			resultSet = statement.executeQuery();

			idx = 1;
			if (resultSet.next()) {
				id = resultSet.getInt(idx++);
				userId = resultSet.getInt(idx++);
				agentId = resultSet.getInt(idx++);
				cardExpire = resultSet.getString(idx++);
				securityCode = resultSet.getString(idx++);
				agentUserId = resultSet.getString(idx++);
				lastAgentOrderId = resultSet.getString(idx++);
				isInvalid = resultSet.getBoolean(idx++);
			} else {
				id = -1;
				Log.d("record not found");
				return false;
			}
			if (resultSet.next()) {
				Log.d("too many found records");
				return false;
			}
		} catch (SQLException sqlException) {
			sqlException.printStackTrace();
			id = -1;
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return true;
	}

	public boolean insert() {
		if (id > 0) return false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		final String sql = "INSERT INTO creditcards" +
				" (user_id, agent_id, card_expire, security_code, agent_user_id, last_agent_order_id)" +
				" VALUES (?, ?, ?, ?, ?, ?) RETURNING id";

//		String HASH_SALT = "yoi29MeetMeat";
//		final String hashValue = Util.getHashPass(cardNumPart + HASH_SALT);

		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			int idx = 1;
			statement.setInt(idx++, userId);
			statement.setInt(idx++, agentId);
			statement.setString(idx++, cardExpire);
			statement.setString(idx++, securityCode);
			statement.setString(idx++, agentUserId);
			statement.setString(idx++, lastAgentOrderId);
			//statement.setString(idx++, hashValue);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				id = resultSet.getInt(1);
			} else {
				id = -1;
				Log.d("cannot get new credit_cards.id");
				return false;
			}
		} catch (SQLException sqlException) {
			sqlException.printStackTrace();
			id = -1;
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return true;
	}

	public boolean disable() {
		Connection connection = null;
		PreparedStatement statement = null;
		final String sql = "UPDATE creditcards SET del_flg=true, updated_at=now() WHERE id=?";

		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, id);
			statement.executeUpdate();
		} catch (SQLException sqlException) {
			sqlException.printStackTrace();
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return true;
	}

	public boolean ivalidate() {
		Connection connection = null;
		PreparedStatement statement = null;
		final String sql = "UPDATE creditcards SET invalid_flg=true, updated_at=now() WHERE id=?";

		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, id);
			statement.executeUpdate();
		} catch (SQLException sqlException) {
			sqlException.printStackTrace();
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return true;
	}




}

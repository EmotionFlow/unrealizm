package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.*;
import java.time.LocalDateTime;


public class CreditCard {
	public boolean isExist = false;
	public int id = -1;
	public int userId = -1;
	public int agentId = -1;
	private String strCardExpire = "";
	private LocalDateTime dtCardExpire = null;
	public String securityCode = "";
	public String agentUserId = "";
	public String lastAgentOrderId = "";
	public boolean isInvalid = false;
	public Timestamp updatedAt = null;
	
	public CreditCard(int _userId, int _agentId){
		userId = _userId;
		agentId = _agentId;
	}

	public void setExpire(String MMYY){
		strCardExpire = MMYY;
		int mm = Integer.parseInt(MMYY.split("/")[0]);
		int yy = Integer.parseInt(MMYY.split("/")[1]);
		dtCardExpire = LocalDateTime.of(2000+yy, mm, 1, 0, 0, 0)
				.plusMonths(1).minusDays(1);
	}

	public String getExpireStr() {
		return strCardExpire;
	}

	public LocalDateTime getExpireDateTime() {
		return dtCardExpire;
	}

	public boolean passingFromLastUpdated(int nDay){
		return updatedAt.getTime() + (long) nDay * 24 * 3600 * 1000 < System.currentTimeMillis();
	}

	public boolean isExpired(int nMarginMonth){
		return dtCardExpire.plusMonths(-nMarginMonth).compareTo(LocalDateTime.now()) < 0;
	}

	public boolean selectByUserIdAgentId() {
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
				isExist = true;
				id = resultSet.getInt(idx++);
				userId = resultSet.getInt(idx++);
				agentId = resultSet.getInt(idx++);
				setExpire(resultSet.getString(idx++));
				securityCode = resultSet.getString(idx++);
				agentUserId = resultSet.getString(idx++);
				lastAgentOrderId = resultSet.getString(idx++);
				isInvalid = resultSet.getBoolean(idx++);
			} else {
				isExist = false;
				id = -1;
				return true;
			}
			if (resultSet.next()) {
				Log.d("too many found records");
				return false;
			}
		} catch (SQLException sqlException) {
			sqlException.printStackTrace();
			isExist = false;
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
			statement.setString(idx++, strCardExpire);
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

	public boolean delete() {
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

	public boolean invalidate() {
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

	public boolean updateLastAgentOrderId(String _lastAgentOrderId) {
		Connection connection = null;
		PreparedStatement statement = null;
		final String sql = "UPDATE creditcards SET last_agent_order_id=?, updated_at=now() WHERE id=?";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setString(1, _lastAgentOrderId);
			statement.setInt(2, id);
			statement.executeUpdate();
			lastAgentOrderId = _lastAgentOrderId;
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

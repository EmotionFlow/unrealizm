package jp.pipa.poipiku;

import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public class CreditCard {
	public Integer id;
	public Integer userId;

	private Connection _connection;

	public CreditCard(Connection conn, final int userId){
		this.userId = userId;
		_connection = conn;
	}

	public void insert(final int agentId, final String expire,
	                      final String securityCode, final String agentUserId,
	                      final String orderNumber, final String cardNumPart) throws SQLException {
		PreparedStatement preparedStatement = null;
		ResultSet resultSet = null;

		final String sql = "INSERT INTO creditcards" +
				" (user_id, agent_id, card_expire, security_code, agent_user_id, last_agent_order_id, hash)" +
				" VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING id";

		String HASH_SALT = "yoi29MeetMeat";
		final String hashValue = Util.getHashPass(cardNumPart + HASH_SALT);

		try {
			preparedStatement = _connection.prepareStatement(sql);
			int idx = 1;
			preparedStatement.setInt(idx++, userId);
			preparedStatement.setInt(idx++, agentId);
			preparedStatement.setString(idx++, expire);
			preparedStatement.setString(idx++, securityCode);
			preparedStatement.setString(idx++, agentUserId);
			preparedStatement.setString(idx++, orderNumber);
			preparedStatement.setString(idx++, hashValue);
			resultSet = preparedStatement.executeQuery();
			if (resultSet.next()) {
				id = resultSet.getInt(1);
			} else {
				id = null;
				Log.d("cannot get new credit_cards.id");
			}
		} catch (SQLException sqlException) {
			id = null;
			throw sqlException;
		} finally {
			if (resultSet != null) resultSet.close();
			if (preparedStatement != null) preparedStatement.close();
		}
	}

	public void selectId(final int agentId) throws SQLException {
		PreparedStatement preparedStatement = null;
		ResultSet resultSet = null;
		final String sql = "SELECT id FROM creditcards WHERE user_id=? AND agent_id=?";
		try {
			preparedStatement = _connection.prepareStatement(sql);
			int idx = 1;
			preparedStatement.setInt(idx++, userId);
			preparedStatement.setInt(idx++, agentId);
			resultSet = preparedStatement.executeQuery();
			if (resultSet.next()) {
				id = resultSet.getInt(1);
			} else {
				id = null;
			}
		} catch (SQLException sqlException) {
			id = null;
			throw sqlException;
		} finally {
			if (resultSet != null) resultSet.close();
			if (preparedStatement != null) preparedStatement.close();
		}
	}

	public void updateLastAgentOrderId(final String lastAgentOrderId) throws SQLException {
		PreparedStatement preparedStatement = null;
		final String sql = "UPDATE creditcards" +
				" SET updated_at=now(), last_agent_order_id=?" +
				" WHERE id=?";
		try {
			preparedStatement = _connection.prepareStatement(sql);
			int idx = 1;
			preparedStatement.setString(idx++, lastAgentOrderId);
			preparedStatement.setInt(idx++, id);
			preparedStatement.executeUpdate();
		} finally {
			if (preparedStatement != null) preparedStatement.close();
		}
	}
}

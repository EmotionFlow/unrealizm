package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public class SpotUpdateContentsUpdatedAt extends Batch {
	public static void main(String[] args) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		int minContentId = -1;

		try {
			connection = dataSource.getConnection();

			sql = "select min(content_id) from contents_0000 where updated_at is not null";

			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				minContentId = resultSet.getInt(1);
				if (minContentId == 0) {
					return;
				}
			} else {
				return;
			}
			resultSet.close();
			statement.close();

			sql = "update contents_0000 set updated_at=null WHERE content_id BETWEEN ? and ? and updated_at is not NULL";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, minContentId);
			statement.setInt(1, minContentId + 10000);
			statement.executeUpdate();

		} catch (SQLException e) {
			e.printStackTrace();
			Log.d(sql);
		} finally {
			if (resultSet != null) {
				try {
					resultSet.close();
				} catch (SQLException ignored) {
				}
			}
			if (statement != null) {
				try {
					statement.close();
				} catch (SQLException ignored) {
				}
			}
			if (connection != null) {
				try {
					connection.close();
				} catch (SQLException ignored) {
				}
			}
		}
	}
}

package jp.pipa.poipiku.batch.spot;

import jp.pipa.poipiku.batch.Batch;
import jp.pipa.poipiku.util.ImageUtil;
import jp.pipa.poipiku.util.Log;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

class HeaderFileRecord {
	public int userId;
	public String fileName;
	HeaderFileRecord(int _userId, String _fileName) {
		userId = _userId;
		fileName = _fileName;
	}
}

public class SpotConvertProfileHeader extends Batch {
	public static void main(String[] args) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		List<HeaderFileRecord> headerFilePathList = new ArrayList<>();

		try {
			connection = dataSource.getConnection();
			int userIdFrom = 0;
			sql = "select num1 from counters where id=-1";
			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();
			resultSet.next();
			userIdFrom = resultSet.getInt(1);
			resultSet.close();statement.close();

			sql = "select user_id, header_file_name from users_0000 where header_file_name<>'' and user_id>? order by user_id";
			statement = connection.prepareStatement(sql);
			statement.setInt(1,userIdFrom);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				headerFilePathList.add(
						new HeaderFileRecord(
								resultSet.getInt(1),
								resultSet.getString(2)
						)
				);
			}
 			resultSet.close();
			statement.close();
			connection.close();

			Log.d("headerFilePathList.size: " + headerFilePathList.size());

			final String PREFIX = "/var/www/html/ai_poipiku";
			final String THUMB_ADDED = "_640.jpg";
			int cnt = 1;
			for (HeaderFileRecord record : headerFilePathList) {
				Path fullPath = Paths.get(PREFIX + record.fileName);
				if (!Files.exists(fullPath)) {
					Log.d("file not found: " + fullPath);
					continue;
				}
				Path thumbPath = Paths.get(PREFIX + record.fileName + THUMB_ADDED);
				if (!Files.exists(thumbPath)) {
					ImageUtil.createThumbProfileHeader(fullPath.toString());
					Log.d("created thumbnail of profile header: " + fullPath);

					if (cnt % 10 == 0){
						connection = dataSource.getConnection();
						sql = "update counters set num1=? WHERE id=-1";
						statement = connection.prepareStatement(sql);
						statement.setInt(1, record.userId);
						statement.executeUpdate();
						statement.close();
						connection.close();
					}
					Thread.sleep(2000);
					cnt++;
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			Log.d(sql);
		} catch (IOException | InterruptedException e) {
			e.printStackTrace();
		} finally {
			if (resultSet != null) {
				try {
					resultSet.close();
				} catch (SQLException ignored) {
				}
			}
			;
			if (statement != null) {
				try {
					statement.close();
				} catch (SQLException ignored) {
				}
			}
			;
			if (connection != null) {
				try {
					connection.close();
				} catch (SQLException ignored) {
				}
			}
			;
		}
	}
}

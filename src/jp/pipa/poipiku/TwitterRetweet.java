package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public final class TwitterRetweet extends Model {
	static public boolean find(int userId, int contentId){
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		final String sql = "SELECT 1 FROM twitter_retweets WHERE user_id=? AND content_id=?";
		final boolean isFound;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt(2, contentId);
			resultSet = statement.executeQuery();
			isFound = resultSet.next();
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return isFound;
	}
	static public boolean insert(int userId, long twitter_user_id, int contentId){
		Connection connection = null;
		PreparedStatement statement = null;
		final String sql = "INSERT INTO twitter_retweets(user_id, twitter_user_id, content_id) VALUES (?,?,?)";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setLong(2, twitter_user_id);
			statement.setInt(3, contentId);
			statement.executeUpdate();
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return true;
	}
 }

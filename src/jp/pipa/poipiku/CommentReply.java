package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public final class CommentReply extends Model {
	public int id = -1;
	public int contentId = -1;
	public int comment_id = -1;
	public int toUserId = -1;
	public int description = -1;

	public CommentReply(){};

	public CommentReply(final ResultSet resultSet) throws SQLException {
		set(resultSet);
	}

	private void set(final ResultSet resultSet) throws SQLException {
		id = resultSet.getInt("id");
		comment_id = resultSet.getInt("comment_id");
		contentId = resultSet.getInt("content_id");
		toUserId = resultSet.getInt("to_user_id");
		description = resultSet.getInt("description");
	}

	public boolean select(int userId, int contentId) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		final String sql = "SELECT * FROM pins WHERE user_id=? AND content_id=?";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt(2, contentId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				set(resultSet);
			}
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
		return true;
	}

	static public boolean insert(int comment_id, int contentId, int toUserId, String description){
		if (comment_id < 0 || contentId < 0 || toUserId < 0 || description==null || description.isEmpty()) {
			return false;
		}

		Connection connection = null;
		PreparedStatement statement = null;
		final String sql = "INSERT INTO comment_replies(comment_id, content_id, to_user_id, description) VALUES (?,?,?,?)";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, comment_id);
			statement.setInt(2, contentId);
			statement.setInt(3, toUserId);
			statement.setString(4, description);
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

	static public boolean deleteByUserId(int userId){
		if (userId < 0) return false;
		Connection connection = null;
		PreparedStatement statement = null;
		final String sql = "DELETE FROM comment_replies WHERE content_id=(SELECT content_id FROM contents_0000 WHERE user_id=?)";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
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

	static public boolean deleteByContentId(int contentId){
		if (contentId < 0) return false;
		Connection connection = null;
		PreparedStatement statement = null;
		final String sql = "DELETE FROM comment_replies WHERE content_id=?";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, contentId);
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

	static public List<CommentReply> selectByContentId(int contentId) {
		if (contentId < 0) return null;
		List<CommentReply> replies = new ArrayList<>();
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		final String sql = "SELECT * FROM comment_replies WHERE content_id=? ORDER BY id DESC";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CommentReply reply = new CommentReply(resultSet);
				replies.add(reply);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return replies;
	}
 }

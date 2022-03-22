package jp.pipa.poipiku.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import jp.pipa.poipiku.*;

public class GridUtil {
	public static int SELECT_MAX_EMOJI = 59;

	public static void getEachComment(Connection connection, List<CContent> contents) throws SQLException {
		String sql = "SELECT description FROM comments_desc_cache WHERE content_id=?";
		PreparedStatement statement = connection.prepareStatement(sql);
		for(CContent content : contents) {
			if(content.m_cUser.m_nReaction!=CUser.REACTION_SHOW) continue;
			statement.setInt(1, content.m_nContentId);
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				content.m_strCommentsListsCache = Util.toString(resultSet.getString("description"));
			}
			resultSet.close();resultSet=null;
		}
		statement.close();statement=null;
	}

	public static ArrayList<CContent> getEachBookmark(Connection connection, ArrayList<CContent> contents, CheckLogin checkLogin) throws SQLException {
		if(!checkLogin.m_bLogin) return contents;
		// Each Bookmark
		String sql = "SELECT * FROM bookmarks_0000 WHERE user_id=? AND content_id=?";
		PreparedStatement statement = connection.prepareStatement(sql);
		for(CContent content : contents) {
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setInt(2, content.m_nContentId);
			ResultSet resultSet = statement.executeQuery();
			if(resultSet.next()) {
				content.m_nBookmarkState = CContent.BOOKMARK_BOOKMARKING;
			}
			resultSet.close();resultSet=null;
		}
		statement.close();statement=null;

		return contents;
	}

	public static void updateCommentsLists(Connection connection, int contentId, int toUserId) throws SQLException {
		// comments_0000から絵文字取得
		StringBuilder sbDescription = new StringBuilder();
		String sql = "SELECT comment_id, description FROM comments_0000 WHERE content_id=? AND to_user_id=? ORDER BY comment_id DESC LIMIT ?";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, contentId);
		statement.setInt(2, toUserId);
		statement.setInt(3, SELECT_MAX_EMOJI);
		ResultSet resultSet = statement.executeQuery();
		int lastCommentId = -1;
		while (resultSet.next()) {
			if (lastCommentId < 0) lastCommentId = resultSet.getInt(1);
			sbDescription.insert(0, Util.toString(resultSet.getString(2)));
		}
		resultSet.close();resultSet=null;
		statement.close();statement=null;

		// 参照用に結合してcomments_desc_cache格納
		sql = "INSERT INTO comments_desc_cache(content_id, description, last_comment_id) VALUES (?, ?, ?) "
				+ "ON CONFLICT (content_id) DO "
				+ "UPDATE SET description=?, last_comment_id=?";
		statement = connection.prepareStatement(sql);
		statement.setInt(1, contentId);
		statement.setString(2, sbDescription.toString());
		statement.setInt(3, lastCommentId);
		statement.setString(4, sbDescription.toString());
		statement.setInt(5, lastCommentId);
		statement.executeUpdate();
		statement.close();statement=null;
	}

	public static void getComment(Connection connection, CContent content) throws SQLException {
		String strSql = "SELECT description, last_comment_id FROM comments_desc_cache WHERE content_id=?";
		PreparedStatement statement = connection.prepareStatement(strSql);
		statement.setInt(1, content.m_nContentId);
		ResultSet resultSet = statement.executeQuery();
		if (resultSet.next()) {
			content.m_strCommentsListsCache = Util.toString(resultSet.getString("description"));
			content.m_nCommentsListsCacheLastId = resultSet.getInt("last_comment_id");
		}
		resultSet.close();resultSet=null;
		statement.close();statement=null;
	}
}

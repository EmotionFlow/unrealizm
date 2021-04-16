package jp.pipa.poipiku.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import jp.pipa.poipiku.*;

public class GridUtil {
	public static int SELECT_MAX_EMOJI = 59;

	public static ArrayList<CContent> getEachComment(Connection connection, ArrayList<CContent> contents) throws SQLException {
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
		return contents;
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

	public static String updateCommentsLists(Connection connection, int contentId) throws SQLException {
		// comments_0000から絵文字取得
		StringBuilder sbDescription = new StringBuilder();
		String sql = "SELECT description FROM comments_0000 WHERE content_id=? ORDER BY comment_id DESC LIMIT ?";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, contentId);
		statement.setInt(2, SELECT_MAX_EMOJI);
		ResultSet resultSet = statement.executeQuery();
		while (resultSet.next()) {
			sbDescription.insert(0, Util.toString(resultSet.getString(1)));
		}
		resultSet.close();resultSet=null;
		statement.close();statement=null;

		// 参照用に結合してcomments_desc_cache格納
		sql = "INSERT INTO comments_desc_cache(content_id, description) VALUES (?, ?) "
				+ "ON CONFLICT (content_id) DO "
				+ "UPDATE SET description=?";
		statement = connection.prepareStatement(sql);
		statement.setInt(1, contentId);
		statement.setString(2, sbDescription.toString());
		statement.setString(3, sbDescription.toString());
		statement.executeUpdate();
		statement.close();statement=null;

		return sbDescription.toString();
	}

	public static String getComment(Connection connection, CContent content) throws SQLException {
		String strSql = "SELECT description FROM comments_desc_cache WHERE content_id=?";
		PreparedStatement statement = connection.prepareStatement(strSql);
		statement.setInt(1, content.m_nContentId);
		ResultSet resultSet = statement.executeQuery();
		if (resultSet.next()) {
			content.m_strCommentsListsCache = Util.toString(resultSet.getString("description"));
		}
		resultSet.close();resultSet=null;
		statement.close();statement=null;

		return content.m_strCommentsListsCache;
	}

}

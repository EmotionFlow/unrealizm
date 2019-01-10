package jp.pipa.poipiku.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import jp.pipa.poipiku.*;

public class GridUtil {
	public static int SELECT_MAX_EMOJI = 60;

	public static void getEachImage(Connection connection, ArrayList<CContent> contents) throws SQLException {
		// Each append image
		/*
		String sql = "SELECT * FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id ASC LIMIT 1000";
		PreparedStatement statement = connection.prepareStatement(sql);
		for(CContent content : contents) {
			if(content.m_nFileNum<=1) continue;
			statement.setInt(1, content.m_nContentId);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				content.m_vContentAppend.add(new CContentAppend(resultSet));
			}
			resultSet.close();resultSet=null;
		}
		statement.close();statement=null;
		*/
	}

	public static void getEachComment(Connection connection, ArrayList<CContent> contents) throws SQLException {
		// Each Comment
		String sql = "SELECT * FROM comments_0000 WHERE content_id=? ORDER BY comment_id DESC LIMIT ?";
		PreparedStatement statement = connection.prepareStatement(sql);
		for(CContent content : contents) {
			if(content.m_cUser.m_nReaction!=CUser.REACTION_SHOW) continue;
			statement.setInt(1, content.m_nContentId);
			statement.setInt(2, SELECT_MAX_EMOJI);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CComment comment = new CComment(resultSet);
				content.m_vComment.add(0, comment);
			}
			resultSet.close();resultSet=null;
		}
		statement.close();statement=null;
	}

	public static void getEachBookmark(Connection connection, ArrayList<CContent> contents, CheckLogin checkLogin) throws SQLException {
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
	}

}

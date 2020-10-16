package jp.pipa.poipiku.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Collections;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CTag;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;

public class RelatedContents {
	static public ArrayList<CContent> getUserContentList(int userId, int listNum, CheckLogin checkLogin){
		ArrayList<CContent> contents = new ArrayList<CContent>();
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		if(listNum<1) return contents;
		try {
			dataSource = (DataSource) new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// user contents
			strSql = "SELECT contents_0000.*, nickname, users_0000.file_name as user_file_name "
					+ "FROM contents_0000 "
					+ "INNER JOIN users_0000 ON users_0000.user_id=contents_0000.user_id "
					+ "WHERE contents_0000.user_id=? AND open_id<>2 AND safe_filter<=?";
			if(checkLogin.m_bLogin) {
				strSql += "AND contents_0000.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) "
						+ "AND contents_0000.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ";
			}
			strSql += "ORDER BY content_id DESC LIMIT ?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, userId);
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if(checkLogin.m_bLogin) {
				statement.setInt(idx++, checkLogin.m_nUserId);
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			statement.setInt(idx++, listNum);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				content.m_cUser.m_strNickName	= Common.ToString(resultSet.getString("nickname"));
				content.m_cUser.m_strFileName	= Common.ToString(resultSet.getString("user_file_name"));
				if(content.m_cUser.m_strFileName.isEmpty()) content.m_cUser.m_strFileName="/img/default_user.jpg";
				contents.add(content);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return contents;
	}

	static public String getTitleTag(int contentId) {
		String tag = "";
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			dataSource = (DataSource) new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// genre tag
			strSql = "SELECT tag_txt FROM tags_0000 WHERE content_id=? AND tag_type=1 ORDER BY tag_id LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				tag = Util.toString(resultSet.getString(1)).trim();
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return tag;
	}

	static public ArrayList<CTag> getAllTag(int contentId) {
		ArrayList<CTag> tags = new ArrayList<CTag>();
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			dataSource = (DataSource) new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// genre tag
			strSql = "SELECT tag_txt FROM tags_0000 WHERE content_id=? AND tag_type=1 ORDER BY tag_id";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CTag tag = new CTag(resultSet);
				tags.add(tag);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return tags;
	}

	static public ArrayList<CContent> getGenreContentList(int contentId, int listNum, CheckLogin checkLogin){
		ArrayList<CContent> contents = new ArrayList<CContent>();
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		if(listNum<1) return contents;
		try {
			dataSource = (DataSource) new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// genre tag
			String tag = getTitleTag(contentId);
			if(tag.isEmpty()) return contents;

			// genre contents
			strSql = "SELECT contents_0000.*, nickname, users_0000.file_name as user_file_name "
					+ "FROM contents_0000 "
					+ "INNER JOIN users_0000 ON users_0000.user_id=contents_0000.user_id "
					+ "WHERE open_id<>2 AND content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=? AND tag_type=1) AND safe_filter<=? ";
			if(checkLogin.m_bLogin) {
				strSql += "AND contents_0000.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) "
						+ "AND contents_0000.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ";
			}
			strSql += "LIMIT ?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setString(idx++, tag);
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if(checkLogin.m_bLogin) {
				statement.setInt(idx++, checkLogin.m_nUserId);
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			statement.setInt(idx++, listNum);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				content.m_cUser.m_strNickName	= Common.ToString(resultSet.getString("nickname"));
				content.m_cUser.m_strFileName	= Common.ToString(resultSet.getString("user_file_name"));
				if(content.m_cUser.m_strFileName.isEmpty()) content.m_cUser.m_strFileName="/img/default_user.jpg";
				contents.add(content);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			Collections.shuffle(contents);
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return contents;
	}
}

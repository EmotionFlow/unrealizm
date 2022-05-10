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
import jp.pipa.poipiku.cache.CacheUsers0000;

public final class RelatedContents {
	static final String SELECT_USER_CONTENTS = "SELECT contents_0000.*, nickname, users_0000.file_name as user_file_name, ct.trans_text description_translated "
			+ "FROM contents_0000 "
			+ "LEFT JOIN content_translations ct ON type_id=0 AND lang_id=? AND contents_0000.content_id = ct.content_id "
			+ "INNER JOIN users_0000 ON users_0000.user_id=contents_0000.user_id "
			+ "WHERE contents_0000.user_id=? AND open_id<>2 AND safe_filter<=?";
	static final String SELECT_USER_CONTENTS_BLOCK_COND =
			" AND contents_0000.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?)" +
			" AND contents_0000.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?)";
	static final String SELECT_USER_CONTENTS_ORDER_BY = " ORDER BY content_id DESC LIMIT ?";

	static public ArrayList<CContent> getUserContentList(int userId, int listNum, CheckLogin checkLogin, Connection connection){
		ArrayList<CContent> contents = new ArrayList<>();
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		if(userId<1 || listNum<1 || checkLogin==null || connection==null) return contents;
		try {
			CacheUsers0000 users = CacheUsers0000.getInstance();

			// user contents
			if (!checkLogin.m_bLogin) {
				strSql = SELECT_USER_CONTENTS + SELECT_USER_CONTENTS_ORDER_BY;
			} else {
				strSql = SELECT_USER_CONTENTS +
						SELECT_USER_CONTENTS_BLOCK_COND +
						SELECT_USER_CONTENTS_ORDER_BY;
			}

			statement = connection.prepareStatement(strSql);
			statement.setInt(idx++, checkLogin.m_nLangId);
			statement.setInt(idx++, userId);
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if(checkLogin.m_bLogin) {
				statement.setInt(idx++, checkLogin.m_nUserId);
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			statement.setInt(idx, listNum);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_cUser.m_strNickName	= Util.toString(user.nickName);
				content.m_cUser.m_strFileName	= Util.toString(user.fileName);
				if(content.m_cUser.m_strFileName.isEmpty()) content.m_cUser.m_strFileName="/img/default_user.jpg";
				content.m_strDescriptionTranslated = resultSet.getString("description_translated");
				contents.add(content);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
		}
		return contents;
	}

	static private final String SQL_SELECT_TAG_TXT = "SELECT tag_txt FROM tags_0000 WHERE content_id=? AND tag_type=1 ORDER BY tag_id LIMIT 1";
	static public String getTitleTag(final int contentId) {
		String tag = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			// genre tag
			statement = connection.prepareStatement(SQL_SELECT_TAG_TXT);
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				tag = Util.toString(resultSet.getString(1)).trim();
			}
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}

		if(tag==null) tag="";
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

	static private final String SQL_SELECT_GENRE_CONTENTS = "WITH tagged_contents AS (" +
			"    SELECT c.*" +
			"    FROM tags_0000 t1" +
			"    INNER JOIN contents_0000 c ON c.content_id=t1.content_id" +
			"    WHERE t1.genre_id IN (SELECT genre_id FROM tags_0000 t2 WHERE t2.content_id = ? ORDER BY random() LIMIT 1)" +
			"    LIMIT 100)" +
			" SELECT tagged_contents.*" +
			" FROM tagged_contents" +
			"    INNER JOIN users_0000 ON users_0000.user_id = tagged_contents.user_id" +
			" WHERE open_id <> 2" +
			"  AND safe_filter <= ?";

	static public ArrayList<CContent> getGenreContentList(int contentId, int listNum, final CheckLogin checkLogin, Connection connection){
		ArrayList<CContent> contents = new ArrayList<>();
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		if(contentId<1 || listNum<1 || checkLogin==null || connection==null) return contents;
		try {
			// genre tag
			String tag = getTitleTag(contentId);
			if(tag.isEmpty()) return contents;

			CacheUsers0000 users = CacheUsers0000.getInstance();

			// genre contents
			strSql = SQL_SELECT_GENRE_CONTENTS;
			if(checkLogin.m_bLogin) {
				strSql += "AND tagged_contents.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) "
						+ "AND tagged_contents.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ";
			}
			strSql += "LIMIT ?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(idx++, contentId);
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if(checkLogin.m_bLogin) {
				statement.setInt(idx++, checkLogin.m_nUserId);
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			statement.setInt(idx, listNum);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_cUser.m_strNickName	= Util.toString(user.nickName);
				content.m_cUser.m_strFileName	= Util.toString(user.fileName);
				if(content.m_cUser.m_strFileName.isEmpty()) content.m_cUser.m_strFileName="/img/default_user.jpg";
				contents.add(content);
			}
			Collections.shuffle(contents);
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
		}
		return contents;
	}
}

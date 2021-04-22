package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public final class SearchIllustByTagC {
	public String m_strKeyword = "";
	public int m_nPage = 0;
	public int m_nGenreId = -1;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_strKeyword	= Common.TrimAll(cRequest.getParameter("KWD"));
			m_nGenreId		= Util.toInt(cRequest.getParameter("GD"));
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		} catch(Exception e) {
			m_strKeyword = "";
			m_nPage = 0;
		}
	}

	public ArrayList<CContent> contentList = new ArrayList<CContent>();
	public int SELECT_MAX_GALLERY =15;
	public int contentsNum = 0;
	public boolean following = false;
	public String m_strRepFileName = "";
	public Genre genre = new Genre();

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean bResult = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		if(m_strKeyword.isEmpty() && m_nGenreId<1) return false;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			connection = DatabaseUtil.dataSource.getConnection();

			// Check Following
			strSql = "SELECT * FROM follow_tags_0000 WHERE user_id=? AND tag_txt=?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setString(idx++, m_strKeyword);
			resultSet = statement.executeQuery();
			following = (resultSet.next());
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// BLOCK USER
			String strCondBlockUser = "";
			if(SqlUtil.hasBlockUser(connection, checkLogin.m_nUserId)) {
				strCondBlockUser = "AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) ";
			}

			// BLOCKED USER
			String strCondBlocedkUser = "";
			if(SqlUtil.hasBlockedUser(connection, checkLogin.m_nUserId)) {
				strCondBlocedkUser = "AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ";
			}

			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCondMute = "";
			if(checkLogin.m_bLogin && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
				strMuteKeyword = SqlUtil.getMuteKeyWord(connection, checkLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "AND content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ";
				}
			}

			if(m_nGenreId<1) {
				// genre id
				strSql = "SELECT genre_id FROM genres WHERE genre_name=?";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setString(idx++, m_strKeyword);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_nGenreId = resultSet.getInt("genre_id");
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			String strSqlFromWhere;
			strSqlFromWhere = "FROM contents_0000 c "
					+ "INNER JOIN tags_0000 t ON c.content_id=t.content_id "
					+ "WHERE open_id<>2 "
					+ "AND t.genre_id=? AND tag_type=1 "
					+ "AND safe_filter<=? "
					+ strCondBlockUser
					+ strCondBlocedkUser
					+ strCondMute;

			// NEW ARRIVAL
			if(!bContentOnly) {
				strSql = "SELECT COUNT(*) " + strSqlFromWhere;
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, m_nGenreId);
				statement.setInt(idx++, checkLogin.m_nSafeFilter);
				if(!strCondBlockUser.isEmpty()) {
					statement.setInt(idx++, checkLogin.m_nUserId);
				}
				if(!strCondBlocedkUser.isEmpty()) {
					statement.setInt(idx++, checkLogin.m_nUserId);
				}
				if(!strCondMute.isEmpty()) {
					statement.setString(idx++, strMuteKeyword);
				}
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					contentsNum = resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
				genre = Util.getGenre(m_nGenreId);
			}

			// contents
			strSql = "SELECT c.* " + strSqlFromWhere
					+ "ORDER BY c.content_id DESC OFFSET ? LIMIT ?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, m_nGenreId);
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if(!strCondBlockUser.isEmpty()) {
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			if(!strCondBlocedkUser.isEmpty()) {
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			if(!strCondMute.isEmpty()) {
				statement.setString(idx++, strMuteKeyword);
			}
			statement.setInt(idx++, SELECT_MAX_GALLERY*m_nPage);
			statement.setInt(idx++, SELECT_MAX_GALLERY);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent cContent = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
				cContent.m_cUser.m_strNickName	= Util.toString(user.nickName);
				cContent.m_cUser.m_strFileName	= Util.toString(user.fileName);
				if(!bContentOnly && m_strRepFileName.isEmpty() && cContent.m_nPublishId==Common.PUBLISH_ID_ALL) {
					m_strRepFileName = cContent.m_strFileName;
				}
				contentList.add(cContent);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bResult = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bResult;
	}
}

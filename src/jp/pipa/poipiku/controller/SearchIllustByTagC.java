package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public final class SearchIllustByTagC {
	public String keyword = "";
	public int genreId = -1;
	public int page = 0;
	public int mode = CCnv.MODE_PC;
	public int startId = -1;
	public int viewMode = CCnv.VIEW_LIST;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			keyword = Common.TrimAll(request.getParameter("KWD"));
			genreId = Util.toInt(request.getParameter("GD"));
			page = Math.max(Util.toInt(request.getParameter("PG")), 0);
			mode = Util.toInt(request.getParameter("MD"));
			startId = Util.toInt(request.getParameter("SD"));
			viewMode = Util.toInt(request.getParameter("VD"));
		} catch(Exception e) {
			keyword = "";
			page = 0;
		}
	}

	public ArrayList<CContent> contentList = new ArrayList<>();
	public int selectMaxGallery =15;
	public int contentsNum = 0;
	public boolean following = false;
	public String m_strRepFileName = "";
	public Genre genre = new Genre();
	public int lastContentId = -1;

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

		Log.d(String.format("kw: %s, sid:%d",keyword, startId));

		if(keyword.isEmpty() && genreId <1) return false;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			connection = DatabaseUtil.dataSource.getConnection();

			// Check Following
			strSql = "SELECT 1 FROM follow_tags_0000 WHERE user_id=? AND tag_txt=?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setString(idx++, keyword);
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
					strCondMute = "AND c.content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ";
				}
			}

			if(genreId <1) {
				// genre id
				strSql = "SELECT genre_id FROM genres WHERE genre_name=?";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setString(idx++, keyword);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					genreId = resultSet.getInt("genre_id");
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			final String strCondStart = (startId >0)?"AND c.content_id<? ":"";

			final String strSqlFromWhere;
			strSqlFromWhere = "FROM contents_0000 c "
					+ "INNER JOIN tags_0000 t ON c.content_id=t.content_id "
					+ "WHERE open_id<>2 "
					+ "AND t.genre_id=? AND tag_type=1 "
					+ "AND safe_filter<=? "
					+ strCondStart
					+ strCondBlockUser
					+ strCondBlocedkUser
					+ strCondMute;

			// NEW ARRIVAL
			if(!bContentOnly) {
				strSql = "SELECT COUNT(*) " + strSqlFromWhere;
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, genreId);
				statement.setInt(idx++, checkLogin.m_nSafeFilter);
				if (!strCondStart.isEmpty()) statement.setInt(idx++, startId);
				if (!strCondBlockUser.isEmpty()) statement.setInt(idx++, checkLogin.m_nUserId);
				if (!strCondBlocedkUser.isEmpty()) statement.setInt(idx++, checkLogin.m_nUserId);
				if (!strCondMute.isEmpty()) statement.setString(idx++, strMuteKeyword);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					contentsNum = resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
				genre = Util.getGenre(genreId);
			}

			// contents
			strSql = "SELECT c.* " + strSqlFromWhere
					+ "ORDER BY c.content_id DESC OFFSET ? LIMIT ?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, genreId);
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if (!strCondStart.isEmpty()) statement.setInt(idx++, startId);
			if (!strCondBlockUser.isEmpty()) statement.setInt(idx++, checkLogin.m_nUserId);
			if (!strCondBlocedkUser.isEmpty()) statement.setInt(idx++, checkLogin.m_nUserId);
			if (!strCondMute.isEmpty()) statement.setString(idx++, strMuteKeyword);
			statement.setInt(idx++, startId > 0 ? 0 :page * selectMaxGallery);
			statement.setInt(idx++, selectMaxGallery);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_cUser.m_strNickName = Util.toString(user.nickName);
				content.m_cUser.m_strFileName = Util.toString(user.fileName);
				if (!bContentOnly && m_strRepFileName.isEmpty() && content.m_nPublishId == Common.PUBLISH_ID_ALL) {
					m_strRepFileName = content.m_strFileName;
				}
				lastContentId = content.m_nContentId;
				contentList.add(content);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bResult = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return bResult;
	}
}

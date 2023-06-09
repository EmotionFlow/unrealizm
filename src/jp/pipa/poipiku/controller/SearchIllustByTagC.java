package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

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
	public List<String> nameTranslationList = null;
	public String transTagName = null; // 閲覧言語に一致したタグ名

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

		if(keyword.isEmpty() && genreId < 1) return false;

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
				strCondBlockUser = "AND c.user_id NOT IN(SELECT block_user_id FROM blocks_0000 b WHERE b.user_id=?) ";
			}

			// BLOCKED USER
			String strCondBlocedkUser = "";
			if(SqlUtil.hasBlockedUser(connection, checkLogin.m_nUserId)) {
				strCondBlocedkUser = "AND c.user_id NOT IN(SELECT user_id FROM blocks_0000 b2 WHERE b2.block_user_id=?) ";
			}

			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCondMute = "";
			if(checkLogin.m_bLogin && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
				strMuteKeyword = SqlUtil.getMuteKeyWord(connection, checkLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "AND c.content_id NOT IN(SELECT content_id FROM contents_0000 c2 WHERE c2.description &@~ ?) ";
				}
			}

			if (genreId < 1) {
				// select genre id
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

			if (genreId < 1) {
				return false;
			}

			final String strCondStart = (startId >0)?"AND c.content_id<? ":"";

			String strSqlFromWhere;
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
			}

			if (page <= 0 || startId < 0) {
				genre = Genre.select(genreId);
			}

			// contents
			strSql = "WITH a AS ( " +
					" SELECT c.*" + (checkLogin.m_bLogin ? ",f.follow_user_id " : "") +
					" FROM contents_0000 c " +
					" INNER JOIN tags_0000 t ON c.content_id = t.content_id " +
					(checkLogin.m_bLogin ?
							" LEFT JOIN follows_0000 f ON c.user_id=f.follow_user_id AND f.user_id=? " : "") +
					" WHERE open_id <> 2 " +
					" AND t.genre_id = ? AND tag_type = 1 " +
					" AND safe_filter <= ? " +
					strCondStart +
					" )";

			boolean withBlk = false;
			if (!strCondBlockUser.isEmpty() || !strCondBlocedkUser.isEmpty()) {
				strSql += " ,b AS (" +
						" SELECT block_user_id AS user_id FROM blocks_0000 WHERE user_id = ?" +
						" UNION DISTINCT" +
						" SELECT user_id FROM blocks_0000 WHERE block_user_id = ?" +
						")";
				withBlk = true;
			}

			/*
			 * description翻訳を組み込んだ状態でmute keyword ONにするとpgroongaがpostgresを道連れにして
			 * クラッシュする。よって一時的にミュートキーワードをOFFにする。
			 */
			boolean withKw = false;
//			if (!strCondMute.isEmpty()) {
//				strSql += " ,kw AS (" +
//						" SELECT content_id FROM contents_0000 WHERE description &@~ ?" +
//						")";
//				withKw = true;
//			}

			strSql += "SELECT *, ct.trans_text description_translated FROM a" +
					" LEFT JOIN content_translations ct ON type_id=0 AND lang_id=? AND a.content_id = ct.content_id" +
					(withBlk ? " LEFT JOIN b ON a.user_id = b.user_id" : "") +
					(withKw  ? " LEFT JOIN kw ON a.content_id = kw.content_id" : "") +
					(withBlk || withKw ? " WHERE" : "") +
					(withBlk ? " b.user_id IS NULL" : "") +
					(withBlk && withKw ? " AND" : "") +
					(withKw  ? " kw.content_id IS NULL" : "") +
					" ORDER BY a.content_id DESC OFFSET ? LIMIT ?";

			statement = connection.prepareStatement(strSql);
			idx = 1;
			if (checkLogin.m_bLogin) statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setInt(idx++, genreId);
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if (!strCondStart.isEmpty()) statement.setInt(idx++, startId);
			if (withBlk) {
				statement.setInt(idx++, checkLogin.m_nUserId);
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			if (withKw) statement.setString(idx++, strMuteKeyword);
			statement.setInt(idx++, checkLogin.m_nLangId);
			statement.setInt(idx++, startId > 0 ? 0 :page * selectMaxGallery);
			statement.setInt(idx++, selectMaxGallery);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_cUser.m_strNickName	= Util.toString(user.nickName);
				content.m_cUser.m_nReaction	= user.reaction;
				content.m_cUser.m_nFollowing = CUser.FOLLOW_HIDE;
				content.m_cUser.m_strFileName = Util.toString(user.fileName);
				if (checkLogin.m_bLogin) {
					content.m_cUser.m_nFollowing = (content.m_nUserId == checkLogin.m_nUserId)?CUser.FOLLOW_HIDE:(resultSet.getInt("follow_user_id")>0)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				} else {
					content.m_cUser.m_nFollowing = CUser.FOLLOW_NONE;
				}
				content.m_strDescriptionTranslated = resultSet.getString("description_translated");
				lastContentId = content.m_nContentId;
				contentList.add(content);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bResult = true;

			// Each Comment
			GridUtil.getEachComment(connection, contentList);

			// Bookmark
			GridUtil.getEachBookmark(connection, contentList, checkLogin);

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}

		// translations
		List<GenreTranslation> transList = GenreTranslation.select(genreId, Genre.ColumnType.Name);
		for (GenreTranslation g : transList) {
			if (g.langId == checkLogin.m_nLangId) {
				transTagName = g.transTxt;
				break;
			}
		}

		nameTranslationList = transList
				.stream()
				.map(e->e.transTxt)
				.collect(Collectors.toList());

		GenreTranslation translation = null;
		translation = GenreTranslation.select(genreId, checkLogin.m_nLangId, Genre.ColumnType.Description);
		if (translation != null) {
			genre.genreDesc = translation.transTxt;
		}
		translation = GenreTranslation.select(genreId, checkLogin.m_nLangId, Genre.ColumnType.Detail);
		if (translation != null) {
			genre.genreDetail = translation.transTxt;
		}

		return bResult;
	}
}

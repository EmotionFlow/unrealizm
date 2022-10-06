package jp.pipa.poipiku.controller;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public final class SearchIllustByKeywordC {
	public int page = 0;
	public String keyword = "";
	public int mode = CCnv.MODE_PC;
	public int viewMode = CCnv.VIEW_LIST;
	public String encodedKeyword = "";
	public String ipAddress = "";
	public int startId = -1;
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			page = Math.max(Util.toInt(request.getParameter("PG")), 0);
			keyword = Common.TrimAll(request.getParameter("KWD"));
			mode = Util.toInt(request.getParameter("MD"));
			viewMode = Util.toInt(request.getParameter("VD"));
			startId = Util.toInt(request.getParameter("SD"));
			encodedKeyword = URLEncoder.encode(keyword, StandardCharsets.UTF_8);
			ipAddress = request.getRemoteAddr();
		}
		catch(Exception ex) {ex.printStackTrace();}
	}

	public int selectMaxGallery = 15;
	public ArrayList<CContent> contentList = new ArrayList<>();
	public int lastContentId = -1;
	public ArrayList<CTag> tagList = new ArrayList<>();
	public int m_nContentsNum = 0;
	public String m_strRepFileName = "";

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		if (keyword.isEmpty()) return false;

		StringBuilder keywords = new StringBuilder(keyword);

		KeywordSearchLog searchLog = new KeywordSearchLog();

		String strCondStart = (startId >0)?" AND c.content_id<? ":"";

		String muteKeywords = "";

		String strCondBlockUser = "";
		String strCondBlockedUser = "";
		try (Connection connection = DatabaseUtil.replicaDataSource.getConnection()) {
			if (SqlUtil.hasBlockUser(connection, checkLogin.m_nUserId)) {
				strCondBlockUser = " AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) ";
			}
			if (SqlUtil.hasBlockedUser(connection, checkLogin.m_nUserId)) {
				strCondBlockedUser = " AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ";
			}
			if(checkLogin.m_bLogin && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
				muteKeywords = SqlUtil.getMuteKeyWord(connection, checkLogin.m_nUserId);
				if (!muteKeywords.isEmpty()) {
					keywords.append(" -(").append(muteKeywords).append(")");
					searchLog.muteWords = muteKeywords;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		boolean bResult = false;

		final String sqlSelectContents = """
				SELECT c.*, b.content_id bookmarking, f.follow_user_id following FROM contents_0000 c
				LEFT JOIN (SELECT content_id FROM bookmarks_0000 WHERE user_id=?) b ON c.content_id=b.content_id
    			LEFT JOIN (SELECT follow_user_id FROM follows_0000 WHERE user_id=?) f ON c.user_id=f.follow_user_id
                WHERE
			    """
				+ " (description &@~ ? OR tag_list &@~ ?) AND open_id<>2 AND safe_filter<=? AND publish_id IN (0, 5, 6)"
				+ strCondStart
				+ strCondBlockUser
				+ strCondBlockedUser
				+ " ORDER BY c.always_null, c.content_id DESC OFFSET ? LIMIT ?";

		try (Connection connection = DatabaseUtil.replicaDataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sqlSelectContents);
			){

			CacheUsers0000 users  = CacheUsers0000.getInstance();

			int idx = 1;
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setString(idx++, keywords.toString());
			statement.setString(idx++, keywords.toString());
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if (startId > 0) {
				statement.setInt(idx++, startId);
			}
			if (!strCondBlockUser.isEmpty()) {
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			if (!strCondBlockedUser.isEmpty()) {
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			statement.setInt(idx++, startId > 0 ? 0 : page * selectMaxGallery);
			statement.setInt(idx++, selectMaxGallery);

			ResultSet resultSet = statement.executeQuery();

			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_nBookmarkState = resultSet.getInt("bookmarking")>0?CContent.BOOKMARK_BOOKMARKING:CContent.BOOKMARK_NONE;
				content.m_cUser.m_nFollowing   = resultSet.getInt("following")>0?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				content.m_cUser.m_nReaction	= user.reaction;
				content.m_cUser.m_strNickName	= Util.toString(user.nickName);
				content.m_cUser.m_strFileName	= Util.toString(user.fileName);
				if(!bContentOnly && m_strRepFileName.isEmpty() && content.m_nPublishId==Common.PUBLISH_ID_ALL) {
					m_strRepFileName = content.m_strFileName;
				}
				lastContentId = content.m_nContentId;
				contentList.add(content);
			}

			if (page < 4) {
				KeywordSearchLog.insert(checkLogin.m_nUserId, keyword, muteKeywords,
						page, KeywordSearchLog.SearchTarget.Contents, contentList.size(), ipAddress);
			}

			bResult = true;

		} catch(Exception e) {
			Log.d(sqlSelectContents);
			e.printStackTrace();
			bResult = false;
		}

//		final String sqlSelectTags = """
//				WITH g_matched AS (
//				    SELECT genre_id
//				    FROM genres
//				    WHERE genre_id>0 AND genre_name &@~ ?
//				    UNION
//				    DISTINCT
//				    SELECT genre_id
//				    FROM genre_translations
//				    WHERE genre_id>0 AND trans_text &@~ ?
//				), t_matched AS (
//				    SELECT t.genre_id, COUNT(*) tag_count
//				    FROM tags_0000 t
//				             INNER JOIN g_matched ON t.genre_id=g_matched.genre_id
//				    GROUP BY t.genre_id
//				    having COUNT(t.tag_txt) > 2
//				    ORDER BY COUNT(t.tag_txt) DESC LIMIT 10
//				)
//				SELECT t.genre_id, genre_name, trans_text, tag_count
//				FROM t_matched t
//				INNER JOIN genres g ON t.genre_id=g.genre_id
//				LEFT JOIN (SELECT genre_id, trans_text FROM genre_translations WHERE type_id=1 AND lang_id=?) gt ON t.genre_id=gt.genre_id
//				""";
//		try (Connection connection = DatabaseUtil.replicaDataSource.getConnection();
//		     PreparedStatement statement = connection.prepareStatement(sqlSelectTags);
//		){
//			int idx = 1;
//			statement.setString(idx++, m_strKeyword);
//			statement.setString(idx++, m_strKeyword);
//			statement.setInt(idx++, checkLogin.m_nLangId);
//
//			Log.d(statement.toString());
//
//			ResultSet resultSet = statement.executeQuery();
//			while (resultSet.next()) {
//				CTag tag = new CTag();
//				tag.m_nGenreId = resultSet.getInt("genre_id");
//				tag.m_strTagTxt = resultSet.getString("genre_name");
//				tag.m_strTagTransTxt = resultSet.getString("trans_text");
//				tagList.add(tag);
//			}
//		} catch(Exception e) {
//			Log.d(sqlSelectTags);
//			e.printStackTrace();
//			bResult = false;
//		}

		return bResult;
	}
}

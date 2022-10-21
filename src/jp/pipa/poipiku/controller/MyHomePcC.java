package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public final class MyHomePcC {
	public int n_nUserId = -1;
	public int n_nVersion = 0;
	public int m_nPage = 0;
	public boolean m_bNoContents = false;
	private int m_nLastSystemInfoId = -1;
	public int cookieLangId = -1;

	public void getParam(final HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			n_nVersion = Util.toInt(request.getParameter("VER"));
			m_nPage = Math.max(Util.toInt(request.getParameter("PG")), 0);
			if(m_nPage<=0) {
				String strUnrealizmInfoId = Util.getCookie(request, Common.AI_POIPIKU_INFO);
				if(strUnrealizmInfoId!=null && !strUnrealizmInfoId.isEmpty()) {
					m_nLastSystemInfoId = Integer.parseInt(strUnrealizmInfoId);
				}
			}
		} catch(Exception ignored) {
			;
		}
	}

	static public final int SELECT_MAX_GALLERY = 15;
	static public final int SELECT_MAX_EMOJI = GridUtil.SELECT_MAX_EMOJI;
	public ArrayList<CContent> m_vContentList = new ArrayList<>();
	public int m_nContentsNum = 0;
	public int m_nContentsNumTotal = 0;
	public int m_nEndId = -1;
	public CContent m_cSystemInfo = null;
	public int m_nSelectRecommendedListNum = 6;
	public List<CUser> m_vRecommendedUserList = null;
	public List<CUser> m_vRecommendedRequestCreatorList = null;
	public int followUserNum = -1;

	static private final String POIPIKU_INFO_SQL = """
				SELECT c.content_id, c.upload_date, c.description, ct.trans_text
				FROM pins p
				INNER JOIN contents_0000 c ON p.content_id = c.content_id
				LEFT JOIN (SELECT content_id, trans_text, lang_id FROM content_translations WHERE type_id = 0 AND lang_id = ?) ct ON p.content_id = ct.content_id
				WHERE p.user_id = 2
				AND p.disp_order = 1
				AND p.content_id <> ?
				""";

	public boolean getResults(final CheckLogin checkLogin) {
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx;

		try {
			CacheUsers0000 users = CacheUsers0000.getInstance();
			connection = DatabaseUtil.dataSource.getConnection();

			if(checkLogin.m_bLogin && cookieLangId >= 0 && checkLogin.m_nLangId != cookieLangId){
				Log.d(String.format("updateLangId %d to %d", checkLogin.m_nLangId, cookieLangId));
				strSql = "UPDATE users_0000 SET lang_id=? WHERE user_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, cookieLangId);
				statement.setInt(2, checkLogin.m_nUserId);
				statement.executeUpdate();
				statement.close();
				users.clearUser(checkLogin.m_nUserId);
				checkLogin.m_nLangId = cookieLangId;
			}

			// Unrealizm INFO
			if(m_nPage<=0) {
				statement = connection.prepareStatement(POIPIKU_INFO_SQL);
				statement.setInt(1, checkLogin.m_nLangId);
				statement.setInt(2, m_nLastSystemInfoId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_cSystemInfo = new CContent();
					m_cSystemInfo.m_nUserId		= 2;
					m_cSystemInfo.m_nContentId		= resultSet.getInt("content_id");
					m_cSystemInfo.m_timeUploadDate	= resultSet.getTimestamp("upload_date");
					m_cSystemInfo.m_strDescription	= Util.toString(resultSet.getString("description"));
					m_cSystemInfo.m_strDescriptionTranslated = Util.toString(resultSet.getString("trans_text"));
					if (!m_cSystemInfo.m_strDescriptionTranslated.isEmpty()) {
						m_cSystemInfo.m_strDescription = m_cSystemInfo.m_strDescriptionTranslated;
					}
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCondMute = "";
			if(checkLogin.m_bLogin && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
				strMuteKeyword = SqlUtil.getMuteKeyWord(connection, checkLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "SELECT content_id as mute_content_id FROM contents_0000 WHERE description &@~ ?";
				}
			}

			final String strSqlWith;
			if (strMuteKeyword.isEmpty()) {
				strSqlWith = "";
			} else {
				strSqlWith = "WITH mute_contents AS (" + strCondMute + ")";
			}

			StringBuilder sb = new StringBuilder();
			sb.append("FROM contents_0000 c")
			.append(" LEFT JOIN content_translations ct ON type_id=0 AND lang_id=? AND c.content_id = ct.content_id")
			.append(" LEFT JOIN requests ON requests.content_id=c.content_id");

			if(!strCondMute.isEmpty()){
				sb.append(" LEFT JOIN mute_contents ON mute_contents.mute_content_id=c.content_id");
			}

			sb.append(" WHERE open_id<>2 ")
			.append(" AND user_id IN (SELECT follow_user_id FROM follows_0000 WHERE user_id=? UNION SELECT ?) ")
			.append(" AND safe_filter<=? ");

			if(!strCondMute.isEmpty()){
				sb.append(" AND mute_content_id IS NULL");
			}

			final String strSqlFromWhere = new String(sb);

			// NEW ARRIVAL COUNT
			strSql = strSqlWith + "SELECT count(*) " + strSqlFromWhere;
			statement = connection.prepareStatement(strSql);
			idx = 1;
			if(!strCondMute.isEmpty()) {
				statement.setString(idx++, strMuteKeyword);
			}
			statement.setInt(idx++, checkLogin.m_nLangId);
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				m_nContentsNum = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// PC版右ペインならびに初期メッセージ表示判定用
			strSql = "SELECT COUNT(*) FROM contents_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				m_nContentsNumTotal = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if (!m_bNoContents) {
				// NEW ARRIVAL
				strSql = strSqlWith + "SELECT c.*, requests.id request_id, ct.trans_text description_translated " + strSqlFromWhere;
				strSql += " ORDER BY c.content_id DESC OFFSET ? LIMIT ?";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				if(!strMuteKeyword.isEmpty()) {
					statement.setString(idx++, strMuteKeyword);
				}
				statement.setInt(idx++, checkLogin.m_nLangId);
				statement.setInt(idx++, checkLogin.m_nUserId);
				statement.setInt(idx++, checkLogin.m_nUserId);
				statement.setInt(idx++, checkLogin.m_nSafeFilter);
				statement.setInt(idx++, m_nPage * SELECT_MAX_GALLERY);
				statement.setInt(idx++, SELECT_MAX_GALLERY); // LIMIT ?
				resultSet = statement.executeQuery();
				while (resultSet.next()) {
					CContent cContent = new CContent(resultSet);
					CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
					cContent.m_cUser.m_strNickName	= Util.toString(user.nickName);
					cContent.m_cUser.m_strFileName	= Util.toString(user.fileName);
					cContent.m_cUser.m_nReaction	= user.reaction;
					cContent.m_cUser.m_nFollowing	= CUser.FOLLOW_HIDE;
					cContent.m_nRequestId = resultSet.getInt("request_id");
					cContent.m_strDescriptionTranslated = resultSet.getString("description_translated");
					m_nEndId = cContent.m_nContentId;
					m_vContentList.add(cContent);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			if (!m_bNoContents) {
				if (!m_vContentList.isEmpty()) {
					// Each Comment
					GridUtil.getEachComment(connection, m_vContentList);

					// Bookmark
					GridUtil.getEachBookmark(connection, m_vContentList, checkLogin);
				}
				// Recommended Request Creators
				m_vRecommendedRequestCreatorList = RecommendedUsers.getRequestCreators(m_nSelectRecommendedListNum, checkLogin, connection);

				// Recommended Users
//				if (m_nContentsNum <= SELECT_MAX_GALLERY || m_nPage == 1) {
				if (false) {
					m_vRecommendedUserList = RecommendedUsers.getUnFollowedUsers(m_nSelectRecommendedListNum, checkLogin, connection);
				}
			}

			if (m_nPage < 1) {
				followUserNum = FollowUser.countFollower(checkLogin.m_nUserId);
			}

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();}}catch(Exception e){;}
			try{if(statement!=null){statement.close();}}catch(Exception e){;}
			try{if(connection!=null){connection.close();}}catch(Exception e){;}
		}
		return bRtn;
	}
}

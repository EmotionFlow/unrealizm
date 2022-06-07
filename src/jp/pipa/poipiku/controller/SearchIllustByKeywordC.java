package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public final class SearchIllustByKeywordC {
	public int m_nPage = 0;
	public String m_strKeyword = "";
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
			m_strKeyword = Common.TrimAll(cRequest.getParameter("KWD"));
		}
		catch(Exception ignored) {}
	}

	private static final String PG_HINT = "/*+ BitmapIndexScan(contents_0000_description_pgidx) */";

	public int selectMaxGallery = 15;
	public ArrayList<CContent> m_vContentList = new ArrayList<>();
	public int m_nContentsNum = 0;
	public boolean m_bFollowing = false;
	public String m_strRepFileName = "";

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		if (!checkLogin.m_bLogin) return false;
		if (m_strKeyword.isEmpty()) return false;

		String strSql = PG_HINT + "SELECT content_id FROM contents_0000 WHERE description &@~ ? LIMIT 1000";
		StringBuilder keywords = new StringBuilder(m_strKeyword);
		List<Integer> keywordMatchedIds = new LinkedList<>();

		KeywordSearchLog searchLog = new KeywordSearchLog();
		searchLog.userId = checkLogin.m_nUserId;
		searchLog.keywords = m_strKeyword;
		searchLog.searchTarget = KeywordSearchLog.SearchTarget.Contents;
		searchLog.page = m_nPage;

		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(strSql);
		) {
			if(checkLogin.m_bLogin && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
				String muteKeywords = SqlUtil.getMuteKeyWord(connection, checkLogin.m_nUserId);
				if (muteKeywords != null && !muteKeywords.isEmpty()) {
					keywords.append(" -(").append(muteKeywords).append(")");
					searchLog.muteWords = muteKeywords;
				}
			}
			statement.setString(1, keywords.toString());
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				keywordMatchedIds.add(resultSet.getInt(1));
			}
			resultSet.close();
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		}

		searchLog.resultNum = keywordMatchedIds.size();
		searchLog.insert();

		if (keywordMatchedIds.isEmpty()) return true;


		boolean bResult = false;
		int idx = 1;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		try {
			connection = DatabaseUtil.dataSource.getConnection();
			CacheUsers0000 users  = CacheUsers0000.getInstance();

			String strCondContentId = " AND content_id IN (" +
					keywordMatchedIds.stream().map(String::valueOf).collect(Collectors.joining(",")) +
					")";

			// BLOCK USER
			String strCondBlockUser = "";
			if(SqlUtil.hasBlockUser(connection, checkLogin.m_nUserId)) {
				strCondBlockUser = " AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) ";
			}

			// BLOCKED USER
			String strCondBlocedkUser = "";
			if(SqlUtil.hasBlockedUser(connection, checkLogin.m_nUserId)) {
				strCondBlocedkUser = " AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ";
			}

			final String strSqlFromWhere = "FROM contents_0000 "
					+ " WHERE open_id<>2 AND safe_filter<=? "
					+ strCondContentId
					+ strCondBlockUser
					+ strCondBlocedkUser;

			// NEW ARRIVAL
			if(!bContentOnly) {
				strSql = "SELECT count(*) " + strSqlFromWhere;
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, checkLogin.m_nSafeFilter);
				if(!strCondBlockUser.isEmpty()) {
					statement.setInt(idx++, checkLogin.m_nUserId);
				}
				if(!strCondBlocedkUser.isEmpty()) {
					statement.setInt(idx++, checkLogin.m_nUserId);
				}
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_nContentsNum = resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			strSql = "SELECT * " + strSqlFromWhere
					+ " ORDER BY content_id DESC OFFSET ? LIMIT ?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if(!strCondBlockUser.isEmpty()) {
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			if(!strCondBlocedkUser.isEmpty()) {
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			statement.setInt(idx++, m_nPage * selectMaxGallery);
			statement.setInt(idx++, selectMaxGallery);
			resultSet = statement.executeQuery();

			int cnt = 0;
			while (resultSet.next() && cnt < selectMaxGallery) {
				CContent cContent = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
				cContent.m_cUser.m_strNickName	= Util.toString(user.nickName);
				cContent.m_cUser.m_strFileName	= Util.toString(user.fileName);
				if(!bContentOnly && m_strRepFileName.isEmpty() && cContent.m_nPublishId==Common.PUBLISH_ID_ALL) {
					m_strRepFileName = cContent.m_strFileName;
				}
				m_vContentList.add(cContent);
				cnt++;
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bResult = true;

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			bResult = false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}

		return bResult;
	}
}

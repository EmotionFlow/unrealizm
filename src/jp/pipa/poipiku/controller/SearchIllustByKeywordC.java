package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

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
	private static final String sqlWith = "WITH kwd_contents AS (SELECT * FROM contents_0000 WHERE description &@~ ?)";

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

		boolean bResult = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		if(m_strKeyword.isEmpty()) return false;
		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			connection = DatabaseUtil.dataSource.getConnection();

			StringBuilder keyWords = new StringBuilder(m_strKeyword);
			if(checkLogin.m_bLogin && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
				String[] muteKeywords = SqlUtil.getMuteKeyWord(connection, checkLogin.m_nUserId).trim().split("\\s+");
				for (String kw : muteKeywords) {
					keyWords.append(" -").append(kw);
				}
			}

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

			final String strSqlFromWhere = "FROM kwd_contents "
					+ "WHERE open_id<>2 "
					+ "AND safe_filter<=? "
					+ strCondBlockUser
					+ strCondBlocedkUser;

			// NEW ARRIVAL
			if(!bContentOnly) {
				strSql = PG_HINT + sqlWith + " SELECT count(*) " + strSqlFromWhere;
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setString(idx++, keyWords.toString());
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

			strSql = PG_HINT + sqlWith + " SELECT * " + strSqlFromWhere
					+ "ORDER BY content_id DESC OFFSET ? LIMIT ?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setString(idx++, keyWords.toString());
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
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return bResult;
	}
}

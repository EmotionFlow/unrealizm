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
		catch(Exception e) {
			;
		}
	}

	// SELECTのLIMITが小さすぎると実行計画がバグってクエリが遅くなってしまうため、LIMITの下限を設けている。
	// 将来的にはpg_hint_planによる制御をしたい。
	private static final int SELECT_LIMIT_MIN = 1000;

	public int selectMaxGallery = 15;
	public ArrayList<CContent> m_vContentList = new ArrayList<>();
	public int m_nContentsNum = 0;
	public boolean m_bFollowing = false;
	public String m_strRepFileName = "";

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

		if(m_strKeyword.isEmpty()) return bResult;
		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			connection = DatabaseUtil.dataSource.getConnection();

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

			String strSqlFromWhere = "FROM contents_0000 "
					+ "WHERE open_id<>2 "
					+ "AND description &@~ ? "
					+ "AND safe_filter<=? "
					+ strCondBlockUser
					+ strCondBlocedkUser
					+ strCondMute;

			// NEW ARRIVAL
			if(!bContentOnly) {
				strSql = "SELECT count(*) " + strSqlFromWhere;
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setString(idx++, m_strKeyword);
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
					m_nContentsNum = resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			strSql = "SELECT * " + strSqlFromWhere
					+ "ORDER BY content_id DESC OFFSET ? LIMIT ?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setString(idx++, m_strKeyword);
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
			statement.setInt(idx++, m_nPage * selectMaxGallery);
			statement.setInt(idx++, Math.max(SELECT_LIMIT_MIN, selectMaxGallery));
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
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bResult;
	}
}

package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class SearchIllustByTagC {
	public String m_strKeyword = "";
	public int m_nPage = 0;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_strKeyword	= Common.TrimAll(cRequest.getParameter("KWD"));
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		} catch(Exception e) {
			m_strKeyword = "";
			m_nPage = 0;
		}
	}

	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public int SELECT_MAX_GALLERY =15;
	public int m_nContentsNum = 0;
	public boolean m_bFollowing = false;
	public String m_strRepFileName = "";

	public boolean getResults(CheckLogin cCheckLogin) {
		return getResults(cCheckLogin, false);
	}

	public boolean getResults(CheckLogin cCheckLogin, boolean bContentOnly) {
		boolean bResult = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		if(m_strKeyword.isEmpty()) return false;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// Check Following
			strSql = "SELECT * FROM follow_tags_0000 WHERE user_id=? AND tag_txt=? AND type_id=?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, cCheckLogin.m_nUserId);
			statement.setString(idx++, m_strKeyword);
			statement.setInt(idx++, Common.FOVO_KEYWORD_TYPE_TAG);
			resultSet = statement.executeQuery();
			m_bFollowing = (resultSet.next());
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCondMute = "";
			if(cCheckLogin.m_bLogin && cCheckLogin.m_nPremiumId>=CUser.PREMIUM_ON) {
				strMuteKeyword = SqlUtil.getMuteKeyWord(connection, cCheckLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "AND content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ";
				}
			}

			String strSqlFromWhere = "FROM contents_0000 "
					+ "WHERE open_id<>2 "
					+ "AND content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=? AND tag_type=1) "
					+ "AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) "
					+ "AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) "
					+ "AND safe_filter<=? "
					+ strCondMute;

			// NEW ARRIVAL
			if(!bContentOnly) {
				strSql = "SELECT COUNT(*) " + strSqlFromWhere;
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setString(idx++, m_strKeyword);
				statement.setInt(idx++, cCheckLogin.m_nUserId);
				statement.setInt(idx++, cCheckLogin.m_nUserId);
				statement.setInt(idx++, cCheckLogin.m_nSafeFilter);
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
			statement.setInt(idx++, cCheckLogin.m_nUserId);
			statement.setInt(idx++, cCheckLogin.m_nUserId);
			statement.setInt(idx++, cCheckLogin.m_nSafeFilter);
			if(!strCondMute.isEmpty()) {
				statement.setString(idx++, strMuteKeyword);
			}
			statement.setInt(idx++, SELECT_MAX_GALLERY*m_nPage);
			statement.setInt(idx++, SELECT_MAX_GALLERY);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent cContent = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
				cContent.m_cUser.m_strNickName	= Util.toString(user.m_strNickName);
				cContent.m_cUser.m_strFileName	= Util.toString(user.m_strFileName);
				if(!bContentOnly && m_strRepFileName.isEmpty() && cContent.m_nPublishId==Common.PUBLISH_ID_ALL) {
					m_strRepFileName = cContent.m_strFileName;
				}
				m_vContentList.add(cContent);
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

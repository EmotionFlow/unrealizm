package jp.pipa.poipiku.controller;

import java.sql.*;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class IllustViewC {
	public int m_nUserId = -1;
	public int m_nContentId = -1;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId		= Util.toInt(cRequest.getParameter("ID"));
			m_nContentId	= Util.toInt(cRequest.getParameter("TD"));
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}

	private Integer searchContentIdHistory(Connection cConn, PreparedStatement cState, ResultSet cResSet, int nContentId) throws SQLException {
		int SEARCH_MAX = 100;
		Integer cid = nContentId;
		String strSql = "SELECT new_id FROM content_id_histories WHERE old_id=?";
		cState = cConn.prepareStatement(strSql);

		for(int i=0; i<SEARCH_MAX; i++){
			cState.setInt(1, cid);
			cResSet = cState.executeQuery();
			if(cResSet.next()){
				cid = cResSet.getInt("new_id");
			}else{
				break;
			}
		}
		return cid;
	}


	public int SELECT_MAX_EMOJI = GridUtil.SELECT_MAX_EMOJI;
	public CUser m_cUser = new CUser();
	public CContent m_cContent = new CContent();
	public boolean m_bOwner = false;
	public boolean m_bFollow = false;
	public boolean m_bBlocking = false;
	public boolean m_bBlocked = false;
	public int m_nContentsNumTotal = 0;
	public Integer m_nNewContentId = null;
	public boolean m_bCheerNg = true;
	public boolean getResults(CheckLogin cCheckLogin) {
		boolean bRtn = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// owner
			if(m_nUserId == cCheckLogin.m_nUserId) {
				m_bOwner = true;
			}

			// content main
			String strOpenCnd = (!m_bOwner)?" AND open_id<>2":"";
			strSql = String.format("SELECT * FROM contents_0000 WHERE user_id=? AND content_id=? %s", strOpenCnd);
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, m_nUserId);
			statement.setInt(idx++, m_nContentId);
			resultSet = statement.executeQuery();
			boolean bContentExist = false;
			if(resultSet.next()) {
				m_cContent = new CContent(resultSet);
				bRtn = true;	// 以下エラーが有ってもOK.表示は行う
				bContentExist = true;
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			if(!bContentExist){
				m_nNewContentId = searchContentIdHistory(connection, statement, resultSet, m_nContentId);
				return false;
			}

			if(!bContentExist) return false;

			// author profile
			strSql = "SELECT * FROM users_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, m_nUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				m_cUser.m_nUserId			= resultSet.getInt("user_id");
				m_cUser.m_strNickName		= Util.toString(resultSet.getString("nickname"));
				m_cUser.m_strProfile		= Util.toString(resultSet.getString("profile"));
				m_cUser.m_strFileName		= Util.toString(resultSet.getString("file_name"));
				m_cUser.m_strHeaderFileName	= Util.toString(resultSet.getString("header_file_name"));
				m_cUser.m_strBgFileName		= Util.toString(resultSet.getString("bg_file_name"));
				m_cUser.m_nReaction			= resultSet.getInt("ng_reaction");
				if(m_cUser.m_strFileName.isEmpty()) m_cUser.m_strFileName="/img/default_user.jpg";
				m_cContent.m_cUser.m_strNickName	= m_cUser.m_strNickName;
				m_cContent.m_cUser.m_strFileName	= m_cUser.m_strFileName;
				m_cContent.m_cUser.m_nReaction		= m_cUser.m_nReaction;
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if(m_cUser.m_strHeaderFileName.isEmpty()) {
				strSql = "SELECT * FROM contents_0000 WHERE publish_id=0 AND safe_filter=0 AND user_id=? ORDER BY content_id DESC LIMIT 1";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, m_nUserId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					m_cUser.m_strHeaderFileName	= Util.toString(resultSet.getString("file_name"));
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}


			if(!m_bOwner) {
				// blocking
				strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, cCheckLogin.m_nUserId);
				statement.setInt(idx++, m_nUserId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					m_bBlocking = true;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;

				// blocked
				strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, m_nUserId);
				statement.setInt(idx++, cCheckLogin.m_nUserId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					m_bBlocked = true;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			// User contents total number
			strSql = String.format("SELECT COUNT(*) FROM contents_0000 WHERE user_id=? %s", strOpenCnd);
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, m_nUserId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				m_nContentsNumTotal = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if(m_bBlocking || m_bBlocked) {
				return false;
			}

			// follow
			int m_nFollow = CUser.FOLLOW_HIDE;
			if(m_nUserId != cCheckLogin.m_nUserId) {
				strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, cCheckLogin.m_nUserId);
				statement.setInt(idx++, m_nUserId);
				resultSet = statement.executeQuery();
				m_bFollow = resultSet.next();
				m_nFollow = (m_bFollow)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				if(m_bFollow) {
					cCheckLogin.m_nSafeFilter = Math.max(cCheckLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			} else {	// owner
				cCheckLogin.m_nSafeFilter = Math.max(cCheckLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
			}
			m_cContent.m_cUser.m_nFollowing = m_nFollow;

			// Each append image
			strSql = "SELECT * FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id ASC LIMIT 1000";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_cContent.m_nContentId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				m_cContent.m_vContentAppend.add(new CContentAppend(resultSet));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// Emoji
			if(m_cUser.m_nReaction==CUser.REACTION_SHOW) {
				m_cContent.m_strCommentsListsCache = GridUtil.getComment(connection, m_cContent);
			}

			// Bookmark
			if(cCheckLogin.m_bLogin) {
				strSql = "SELECT * FROM bookmarks_0000 WHERE user_id=? AND content_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, cCheckLogin.m_nUserId);
				statement.setInt(2, m_cContent.m_nContentId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_cContent.m_nBookmarkState = CContent.BOOKMARK_BOOKMARKING;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

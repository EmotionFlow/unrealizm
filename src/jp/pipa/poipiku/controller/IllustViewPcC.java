package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public final class IllustViewPcC {
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
		final int SEARCH_MAX = 100;
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


	public int SELECT_MAX_GALLERY = 9;
	public int SELECT_MAX_RELATED_GALLERY = 9;
	public int SELECT_MAX_RECOMMENDED_GALLERY = 9;
	public ArrayList<CContent> m_vContentList = new ArrayList<>();
	public ArrayList<CContent> m_vRelatedContentList = new ArrayList<>();
	public ArrayList<CContent> m_vRecommendedList = new ArrayList<>();
	public int SELECT_MAX_EMOJI = GridUtil.SELECT_MAX_EMOJI;
	public CUser m_cUser = new CUser();
	public CContent m_cContent = new CContent();
	public boolean m_bOwner = false;
	public boolean m_bRequestClient = false;
	public boolean m_bFollow = false;
	public boolean m_bBlocking = false;
	public boolean m_bBlocked = false;
	public int m_nContentsNumTotal = 0;
	public Integer m_nNewContentId = null;
	public boolean m_bCheerNg = true;

	public boolean getResults(CheckLogin checkLogin) {
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			// owner
			if(m_nUserId == checkLogin.m_nUserId) {
				m_bOwner = true;
			} else {
				Request poipikuRequest = new Request();
				poipikuRequest.selectByContentId(m_nContentId, connection);
				m_bRequestClient = (poipikuRequest.clientUserId == checkLogin.m_nUserId);
			}

			// content main
			final String strOpenCnd = (!m_bOwner && !m_bRequestClient)?" AND open_id<>2":"";

			strSql = "SELECT c.*, r.id request_id FROM contents_0000 c" +
					 " LEFT JOIN requests r ON r.content_id=c.content_id " +
					 " WHERE c.user_id=? AND c.content_id=? " + strOpenCnd;

			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, m_nUserId);
			statement.setInt(idx++, m_nContentId);
			resultSet = statement.executeQuery();
			boolean bContentExist = false;
			if(resultSet.next()) {
				m_cContent = new CContent(resultSet);
				final int requestId = resultSet.getInt("request_id");
				if(requestId>0) m_cContent.m_nRequestId=requestId;
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
				m_cUser.m_nPassportId	= resultSet.getInt("passport_id");
				m_cUser.m_nAdMode		= resultSet.getInt("ng_ad_mode");
				if(m_cUser.m_strFileName.isEmpty()) m_cUser.m_strFileName="/img/default_user.jpg";
				m_cContent.m_cUser.m_strNickName	= m_cUser.m_strNickName;
				m_cContent.m_cUser.m_strFileName	= m_cUser.m_strFileName;
				m_cContent.m_cUser.m_nReaction		= m_cUser.m_nReaction;
				m_cUser.setRequestEnabled(resultSet);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if(m_cUser.m_strHeaderFileName.isEmpty()) {
				strSql = "SELECT file_name FROM contents_0000 WHERE publish_id=0 AND safe_filter=0 AND user_id=? ORDER BY content_id DESC LIMIT 1";
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
				strSql = "SELECT user_id FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, checkLogin.m_nUserId);
				statement.setInt(idx++, m_nUserId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					m_bBlocking = true;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;

				// blocked
				strSql = "SELECT user_id FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, m_nUserId);
				statement.setInt(idx++, checkLogin.m_nUserId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					m_bBlocked = true;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			// User contents total number
			strSql = "SELECT COUNT(*) FROM contents_0000 WHERE user_id=? " + strOpenCnd;
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
			if(m_nUserId != checkLogin.m_nUserId) {
				strSql = "SELECT user_id FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, checkLogin.m_nUserId);
				statement.setInt(idx++, m_nUserId);
				resultSet = statement.executeQuery();
				m_bFollow = resultSet.next();
				m_nFollow = (m_bFollow)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				if(m_bFollow) {
					checkLogin.m_nSafeFilter = Math.max(checkLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			} else {	// owner
				checkLogin.m_nSafeFilter = Math.max(checkLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
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
			if(checkLogin.m_bLogin) {
				strSql = "SELECT user_id FROM bookmarks_0000 WHERE user_id=? AND content_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, checkLogin.m_nUserId);
				statement.setInt(2, m_cContent.m_nContentId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_cContent.m_nBookmarkState = CContent.BOOKMARK_BOOKMARKING;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			// Owner Contents
			if(SELECT_MAX_GALLERY>0) {
				m_vContentList = RelatedContents.getUserContentList(m_nUserId, SELECT_MAX_GALLERY, checkLogin);
			}

			// Related Contents
			if(SELECT_MAX_RELATED_GALLERY>0) {
				m_vRelatedContentList = RelatedContents.getGenreContentList(m_cContent.m_nContentId, SELECT_MAX_RELATED_GALLERY, checkLogin);
			}

			// Recommended Contents
			if(checkLogin.isStaff() && SELECT_MAX_RECOMMENDED_GALLERY>0) {
				long start = System.currentTimeMillis();
				m_vRecommendedList = RecommendedContents.getContents(m_cContent.m_nUserId, m_cContent.m_nContentId, SELECT_MAX_RECOMMENDED_GALLERY, checkLogin);
				Log.d(String.format("RecommendedContents: %d", System.currentTimeMillis() - start));
			}

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う
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

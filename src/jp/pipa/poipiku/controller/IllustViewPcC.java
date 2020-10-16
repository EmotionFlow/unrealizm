package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class IllustViewPcC {
	public int m_nUserId = -1;
	public int m_nContentId = -1;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId		= Common.ToInt(cRequest.getParameter("ID"));
			m_nContentId	= Common.ToInt(cRequest.getParameter("TD"));
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


	public int SELECT_MAX_GALLERY = 6;
	public int SELECT_MAX_RELATED_GALLERY = 30;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public ArrayList<CContent> m_vRelatedContentList = new ArrayList<CContent>();
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
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 1;

		try {
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// owner
			if(m_nUserId == cCheckLogin.m_nUserId) {
				m_bOwner = true;
			}

			// content main
			String strOpenCnd = (!m_bOwner)?" AND open_id<>2":"";
			strSql = String.format("SELECT * FROM contents_0000 WHERE user_id=? AND content_id=? %s", strOpenCnd);
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, m_nUserId);
			cState.setInt(idx++, m_nContentId);
			cResSet = cState.executeQuery();
			boolean bContentExist = false;
			if(cResSet.next()) {
				m_cContent = new CContent(cResSet);
				bRtn = true;	// 以下エラーが有ってもOK.表示は行う
				bContentExist = true;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(!bContentExist){
				m_nNewContentId = searchContentIdHistory(cConn, cState, cResSet, m_nContentId);
				return false;
			}

			if(!bContentExist) return false;

			// author profile
			strSql = "SELECT * FROM users_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cUser.m_nUserId			= cResSet.getInt("user_id");
				m_cUser.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
				m_cUser.m_strProfile		= Common.ToString(cResSet.getString("profile"));
				m_cUser.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
				m_cUser.m_strHeaderFileName	= Common.ToString(cResSet.getString("header_file_name"));
				m_cUser.m_strBgFileName		= Common.ToString(cResSet.getString("bg_file_name"));
				m_cUser.m_nReaction			= cResSet.getInt("ng_reaction");
				if(m_cUser.m_strFileName.isEmpty()) m_cUser.m_strFileName="/img/default_user.jpg";
				m_cContent.m_cUser.m_strNickName	= m_cUser.m_strNickName;
				m_cContent.m_cUser.m_strFileName	= m_cUser.m_strFileName;
				m_cContent.m_cUser.m_nReaction		= m_cUser.m_nReaction;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			if(m_cUser.m_strHeaderFileName.isEmpty()) {
				strSql = "SELECT * FROM contents_0000 WHERE publish_id=0 AND safe_filter=0 AND user_id=? ORDER BY content_id DESC LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				idx = 1;
				cState.setInt(idx++, m_nUserId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					m_cUser.m_strHeaderFileName	= Common.ToString(cResSet.getString("file_name"));
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}


			if(!m_bOwner) {
				// blocking
				strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				idx = 1;
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cState.setInt(idx++, m_nUserId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					m_bBlocking = true;
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				// blocked
				strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				idx = 1;
				cState.setInt(idx++, m_nUserId);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					m_bBlocked = true;
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			// User contents total number
			strSql = String.format("SELECT COUNT(*) FROM contents_0000 WHERE user_id=? %s", strOpenCnd);
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nContentsNumTotal = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			if(m_bBlocking || m_bBlocked) {
				return false;
			}

			// follow
			int m_nFollow = CUser.FOLLOW_HIDE;
			if(m_nUserId != cCheckLogin.m_nUserId) {
				strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				idx = 1;
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cState.setInt(idx++, m_nUserId);
				cResSet = cState.executeQuery();
				m_bFollow = cResSet.next();
				m_nFollow = (m_bFollow)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				if(m_bFollow) {
					cCheckLogin.m_nSafeFilter = Math.max(cCheckLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			} else {	// owner
				cCheckLogin.m_nSafeFilter = Math.max(cCheckLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
			}
			m_cContent.m_cUser.m_nFollowing = m_nFollow;

			// Each append image
			strSql = "SELECT * FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id ASC LIMIT 1000";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_cContent.m_nContentId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_cContent.m_vContentAppend.add(new CContentAppend(cResSet));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Each Emoji
			if(m_cUser.m_nReaction==CUser.REACTION_SHOW) {
				strSql = "SELECT * FROM comments_0000 WHERE content_id=? ORDER BY comment_id DESC LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_cContent.m_nContentId);
				cState.setInt(2, SELECT_MAX_EMOJI);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CComment cComment = new CComment(cResSet);
					m_cContent.m_vComment.add(0, cComment);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			// Bookmark
			if(cCheckLogin.m_bLogin) {
				strSql = "SELECT * FROM bookmarks_0000 WHERE user_id=? AND content_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cCheckLogin.m_nUserId);
				cState.setInt(2, m_cContent.m_nContentId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_cContent.m_nBookmarkState = CContent.BOOKMARK_BOOKMARKING;
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			// Owner Contents
			if(SELECT_MAX_GALLERY>0) {
				m_vContentList = RelatedContents.getUserContentList(m_nUserId, SELECT_MAX_GALLERY, cCheckLogin);
			}

			// Related Contents
			if(SELECT_MAX_RELATED_GALLERY>0) {
				m_vRelatedContentList = RelatedContents.getGenreContentList(m_cContent.m_nContentId, SELECT_MAX_RELATED_GALLERY, cCheckLogin);
			}


			bRtn = true;	// 以下エラーが有ってもOK.表示は行う
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

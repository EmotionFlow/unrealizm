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
			m_nUserId		= Common.ToInt(cRequest.getParameter("ID"));
			m_nContentId	= Common.ToInt(cRequest.getParameter("TD"));
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}


	public int SELECT_MAX_EMOJI = 60;
	public CUser m_cUser = new CUser();
	public CContent m_cContent = new CContent();
	public boolean m_bOwner = false;
	public boolean m_bFollow = false;
	public boolean m_bBlocking = false;
	public boolean m_bBlocked = false;
	public int m_nContentsNumTotal = 0;
	public boolean getResults(CheckLogin cCheckLogin) {
		String strSql = "";
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;

		try {
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// content main
			if(m_nContentId>0) {
				strSql = "SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nUserId);
				cState.setInt(2, m_nContentId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					m_cContent = new CContent(cResSet);
					bRtn = true;	// 以下エラーが有ってもOK.表示は行う
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			} else if(m_nUserId>0) {
				strSql = "SELECT * FROM contents_0000 WHERE user_id=? AND safe_filter<=? ORDER BY content_id DESC LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nUserId);
				cState.setInt(2, cCheckLogin.m_nSafeFilter);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					m_cContent = new CContent(cResSet);
					m_nContentId = m_cContent.m_nContentId;
					bRtn = true;	// 以下エラーが有ってもOK.表示は行う
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}
			if(m_cContent.m_nContentId<=0) return false;

			// owner
			if(cCheckLogin.m_nUserId == m_cContent.m_nUserId) {
				m_bOwner = true;
			}

			// author profile
			strSql = "SELECT * FROM users_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_cContent.m_nUserId);
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
				strSql = "SELECT * FROM contents_0000 WHERE open_id=0 AND safe_filter=0 AND user_id=? ORDER BY content_id DESC LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nUserId);
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
				cState.setInt(1, cCheckLogin.m_nUserId);
				cState.setInt(2, m_cContent.m_nUserId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					m_bBlocking = true;
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				// blocked
				strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_cContent.m_nUserId);
				cState.setInt(2, cCheckLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					m_bBlocked = true;
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			// User contents total number
			strSql = "SELECT COUNT(*) FROM contents_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
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
			if(m_cContent.m_nUserId != cCheckLogin.m_nUserId) {
				strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cCheckLogin.m_nUserId);
				cState.setInt(2, m_cContent.m_nUserId);
				cResSet = cState.executeQuery();
				m_bFollow = cResSet.next();
				m_nFollow = (m_bFollow)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				if(m_bFollow) {
					cCheckLogin.m_nSafeFilter = Math.max(cCheckLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			} else {
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

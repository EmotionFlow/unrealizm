package jp.pipa.poipiku.controller;

import java.sql.*;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class IllustViewC {
	public int m_nContentId = -1;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nContentId		= Common.ToInt(cRequest.getParameter("TD"));
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}


	public CUser m_cUser = new CUser();
	public CContent m_cContent = new CContent();
	public boolean m_bOwner = false;
	public boolean m_bFollow = false;
	public boolean m_bBlocking = false;
	public boolean m_bBlocked = false;
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
			strSql = "SELECT contents_0000.*, nickname, users_0000.file_name as user_file_name FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE contents_0000.content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cContent = new CContent(cResSet);
				m_cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				m_cContent.m_cUser.m_strFileName	= Common.ToString(cResSet.getString("user_file_name"));
				if(m_cContent.m_cUser.m_strFileName.isEmpty()) m_cContent.m_cUser.m_strFileName="/img/default_user.jpg";
				bRtn = true;	// 以下エラーが有ってもOK.表示は行う
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
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
				if(m_cUser.m_strFileName.isEmpty()) m_cUser.m_strFileName="/img/default_user.jpg";
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

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
				cResSet.close();cResSet=null;
				cState.close();cState=null;
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
			strSql = "SELECT * FROM comments_0000 WHERE content_id=? ORDER BY comment_id DESC LIMIT 240";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_cContent.m_nContentId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CComment cComment = new CComment(cResSet);
				m_cContent.m_vComment.add(0, cComment);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
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

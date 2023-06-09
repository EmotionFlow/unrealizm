package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class SearchIllustByTagGridC {
	public String m_strKeyword = "";
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_strKeyword	= Common.TrimAll(Util.toString(cRequest.getParameter("KWD")));
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		} catch(Exception e) {
			m_strKeyword = "";
			m_nPage = 0;
		}
	}

	public int SELECT_MAX_GALLERY = 24;
	public ArrayList<CContent> contentList = new ArrayList<CContent>();
	public int m_nContentsNum = 0;
	public boolean m_bFollowing = false;
	public String m_strRepFileName = "";

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 1;

		if(m_strKeyword.isEmpty()) return false;

		try {
			CacheUsers0000 users = CacheUsers0000.getInstance();
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// Check Following
			strSql = "SELECT * FROM follow_tags_0000 WHERE user_id=? AND tag_txt=?";
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, checkLogin.m_nUserId);
			cState.setString(idx++, m_strKeyword);
			cResSet = cState.executeQuery();
			m_bFollowing = (cResSet.next());
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			/*
			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCond = "";
			if(checkLogin.m_bLogin) {
				strSql = "SELECT mute_keyword_list FROM users_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, checkLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					strMuteKeyword = Util.toString(cResSet.getString(1)).trim();
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
				if(!strMuteKeyword.isEmpty()) {
					strCond = "AND description &@~ ?";
				}
			}
			*/


			// NEW ARRIVAL
			if(!bContentOnly) {
				strSql = "SELECT COUNT(*) FROM contents_0000 WHERE open_id<>2 AND content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=? AND tag_type=1) AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=?";
				cState = cConn.prepareStatement(strSql);
				idx = 1;
				cState.setString(idx++, m_strKeyword);
				cState.setInt(idx++, checkLogin.m_nUserId);
				cState.setInt(idx++, checkLogin.m_nUserId);
				cState.setInt(idx++, checkLogin.m_nSafeFilter);
				/*
				if(!strMuteKeyword.isEmpty()) {
					cState.setString(idx++, strMuteKeyword);
				}
				*/
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			strSql = "SELECT contents_0000.*, follows_0000.follow_user_id FROM (contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id) LEFT JOIN follows_0000 ON contents_0000.user_id=follows_0000.follow_user_id AND follows_0000.user_id=? WHERE open_id<>2 AND content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=? AND tag_type=1) AND contents_0000.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND contents_0000.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=? ORDER BY content_id DESC OFFSET ? LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, checkLogin.m_nUserId);
			cState.setString(idx++, m_strKeyword);
			cState.setInt(idx++, checkLogin.m_nUserId);
			cState.setInt(idx++, checkLogin.m_nUserId);
			cState.setInt(idx++, checkLogin.m_nSafeFilter);
			/*
			if(!strMuteKeyword.isEmpty()) {
				cState.setString(idx++, strMuteKeyword);
			}
			*/
			cState.setInt(idx++, SELECT_MAX_GALLERY*m_nPage);
			cState.setInt(idx++, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent content = new CContent(cResSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_cUser.m_strNickName	= Util.toString(user.nickName);
				content.m_cUser.m_strFileName	= Util.toString(user.fileName);
				content.m_cUser.m_nReaction	= user.reaction;
				if(content.m_cUser.m_strFileName.isEmpty()) content.m_cUser.m_strFileName="/img/default_user.jpg";
				content.m_cUser.m_nFollowing = (content.m_nUserId == checkLogin.m_nUserId)?CUser.FOLLOW_HIDE:(cResSet.getInt("follow_user_id")>0)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				contentList.add(content);
				if(!bContentOnly && m_strRepFileName.isEmpty() && content.m_nPublishId==Common.PUBLISH_ID_ALL) {
					m_strRepFileName = content.m_strFileName;
				}
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Each Comment
			GridUtil.getEachComment(cConn, contentList);
			// Bookmark
			contentList = GridUtil.getEachBookmark(cConn, contentList, checkLogin);
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

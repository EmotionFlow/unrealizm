package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class MyHomeTagC {
	public int n_nUserId = -1;
	public int n_nVersion = 0;
	public int m_nMode = CCnv.MODE_PC;
	public int m_nStartId = -1;
	public int m_nViewMode = CCnv.VIEW_LIST;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			n_nVersion = Common.ToInt(cRequest.getParameter("VER"));
			m_nMode = Common.ToInt(cRequest.getParameter("MD"));
			m_nStartId = Common.ToInt(cRequest.getParameter("SD"));
			n_nUserId = Common.ToInt(cRequest.getParameter("ID"));
			m_nViewMode = Common.ToInt(cRequest.getParameter("VD"));
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 10;
	public int SELECT_MAX_EMOJI = GridUtil.SELECT_MAX_EMOJI;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public int m_nContentsNum = 0;
	public int m_nContentsNumTotal = 0;
	public int m_nEndId = -1;

	public boolean getResults(CheckLogin cCheckLogin) {
		return getResults(cCheckLogin, false);
	}

	public boolean getResults(CheckLogin cCheckLogin, boolean bContentOnly) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 1;

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			String strMuteKeyword = "";
			String strCondMute = "";
			strSql = "SELECT mute_keyword_list FROM users_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cCheckLogin.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				strMuteKeyword = Common.ToString(cResSet.getString(1)).trim();
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(!strMuteKeyword.isEmpty()) {
				strCondMute = "AND description &@~ ?";
			}

			String m_strSearchKeyword = "";
			String strCondSearch = "";
			strSql = "SELECT ARRAY_TO_STRING(ARRAY(SELECT tag_txt FROM follow_tags_0000 WHERE user_id=? AND type_id=1 LIMIT 100), ' OR ')";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cCheckLogin.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_strSearchKeyword = Common.ToString(cResSet.getString(1)).trim();
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(!m_strSearchKeyword.isEmpty()) {
				strCondSearch = "OR description &@~ ?";
			}

			String strCondStart = (m_nStartId>0)?"AND content_id<?":"";

			// NEW ARRIVAL
			if(!bContentOnly) {
				/*
				strSql = String.format("SELECT count(*) FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE open_id<>2 AND contents_0000.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND contents_0000.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=? AND ((content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt IN(SELECT tag_txt FROM follow_tags_0000 WHERE user_id=? AND type_id=0) AND tag_type=1) %s) %s)", strCondMute, strCondSearch);
				cState = cConn.prepareStatement(strSql);
				idx = 1;
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cState.setInt(idx++, cCheckLogin.m_nSafeFilter);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					cState.setString(idx++, strMuteKeyword);
				}
				if(!m_strSearchKeyword.isEmpty()) {
					cState.setString(idx++, m_strSearchKeyword);
				}
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
				*/


				// Owner contents total number
				idx = 1;
				strSql = "SELECT COUNT(*) FROM contents_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNumTotal = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			strSql = String.format("SELECT contents_0000.*, nickname, ng_reaction, users_0000.file_name as user_file_name, follows_0000.follow_user_id FROM (contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id) LEFT JOIN follows_0000 ON contents_0000.user_id=follows_0000.follow_user_id AND follows_0000.user_id=? WHERE open_id<>2 AND contents_0000.upload_date>CURRENT_DATE-30 AND contents_0000.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND contents_0000.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=? AND ((content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt IN(SELECT tag_txt FROM follow_tags_0000 WHERE user_id=? AND type_id=0) AND tag_type=1) %s) %s) %s ORDER BY content_id DESC LIMIT ?", strCondMute, strCondSearch, strCondStart);
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			cState.setInt(idx++, cCheckLogin.m_nSafeFilter);
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			if(!strMuteKeyword.isEmpty()) {
				cState.setString(idx++, strMuteKeyword);
			}
			if(!m_strSearchKeyword.isEmpty()) {
				cState.setString(idx++, m_strSearchKeyword);
			}
			if(m_nStartId>0) {
				cState.setInt(idx++, m_nStartId);
			}
			cState.setInt(idx++, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				cContent.m_cUser.m_strFileName	= Common.ToString(cResSet.getString("user_file_name"));
				if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";
				cContent.m_cUser.m_nReaction = cResSet.getInt("ng_reaction");
				cContent.m_cUser.m_nFollowing = (cContent.m_nUserId == cCheckLogin.m_nUserId)?CUser.FOLLOW_HIDE:(cResSet.getInt("follow_user_id")>0)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				m_nEndId = cContent.m_nContentId;
				m_vContentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Each append image
			GridUtil.getEachImage(cConn, m_vContentList);

			// Each Comment
			GridUtil.getEachComment(cConn, m_vContentList);

			// Bookmark
			if(cCheckLogin.m_bLogin) {
				GridUtil.getEachBookmark(cConn, m_vContentList, cCheckLogin);
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

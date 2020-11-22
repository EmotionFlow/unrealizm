package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class IllustListGridC {
	public int m_nUserId = -1;
	public String m_strKeyword = "";
	public int m_nPage = 0;
	public String m_strAccessIp = "";
	public boolean m_bDispUnPublished = false;

	public void getParam(HttpServletRequest cRequest) {
		try {

			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId		= Util.toInt(cRequest.getParameter("ID"));
			m_strKeyword	= Common.TrimAll(Common.CrLfInjection(cRequest.getParameter("KWD")));
			m_nPage			= Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
			m_strAccessIp	= cRequest.getRemoteAddr();
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public CUser m_cUser = new CUser();
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public ArrayList<CTag> m_vCategoryList = new ArrayList<CTag>();
	public int SELECT_MAX_GALLERY = 24;
	public boolean m_bOwner = false;
	public boolean m_bFollow = false;
	public boolean m_bBlocking = false;
	public boolean m_bBlocked = false;
	public int m_nContentsNum = 0;
	public int m_nContentsNumTotal = 0;

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}
	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		String strSql = "";
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		int idx = 1;

		if(m_nUserId < 1) {
			return false;
		}

		if(checkLogin.m_nUserId == m_nUserId) {
			m_bOwner = true;
		}

		try {
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			if(!bContentOnly) {
				// author profile
				strSql = "SELECT * FROM users_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nUserId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					m_cUser.m_nUserId			= cResSet.getInt("user_id");
					m_cUser.m_strNickName		= Util.toString(cResSet.getString("nickname"));
					m_cUser.m_strProfile		= Util.toString(cResSet.getString("profile"));
					m_cUser.m_strFileName		= Util.toString(cResSet.getString("file_name"));
					m_cUser.m_strHeaderFileName	= Util.toString(cResSet.getString("header_file_name"));
					m_cUser.m_strBgFileName		= Util.toString(cResSet.getString("bg_file_name"));
					m_cUser.m_nMailComment		= cResSet.getInt("mail_comment");
					//if(m_cUser.m_strProfile.isEmpty())  m_cUser.m_strProfile = "";
					if(m_cUser.m_strFileName.isEmpty()) m_cUser.m_strFileName="/img/default_user.jpg";
					m_cUser.m_bDispFollower		= ((m_cUser.m_nMailComment>>>0 & 0x01) == 0x01);
					//m_cUser.m_bMailHeart		= ((m_cUser.m_nMailComment>>>1 & 0x01) == 0x01);
					//m_cUser.m_bMailBookmark	= ((m_cUser.m_nMailComment>>>2 & 0x01) == 0x01);
					//m_cUser.m_bMailFollow		= ((m_cUser.m_nMailComment>>>3 & 0x01) == 0x01);
					//m_cUser.m_bMailMessage	= ((m_cUser.m_nMailComment>>>4 & 0x01) == 0x01);
					//m_cUser.m_bMailTag		= ((m_cUser.m_nMailComment>>>5 & 0x01) == 0x01);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				if(m_cUser.m_strHeaderFileName.isEmpty()) {
					strSql = "SELECT * FROM contents_0000 WHERE publish_id=0 AND safe_filter=0 AND user_id=? ORDER BY content_id DESC LIMIT 1";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, m_nUserId);
					cResSet = cState.executeQuery();
					if(cResSet.next()) {
						m_cUser.m_strHeaderFileName	= Util.toString(cResSet.getString("file_name"));
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;
				}


				// flags
				if(m_bOwner) {
					strSql = "SELECT COUNT(user_id) as content_num FROM follows_0000 WHERE user_id=?";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, m_nUserId);
					cResSet = cState.executeQuery();
					if(cResSet.next()) {
						m_cUser.m_nFollowNum = cResSet.getInt("content_num");
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;

					strSql = "SELECT COUNT(follow_user_id) as content_num FROM follows_0000 WHERE follow_user_id=?";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, m_nUserId);
					cResSet = cState.executeQuery();
					if(cResSet.next()) {
						m_cUser.m_nFollowerNum = cResSet.getInt("content_num");
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;
					checkLogin.m_nSafeFilter = Math.max(checkLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
				} else {
					// follow
					strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, checkLogin.m_nUserId);
					cState.setInt(2, m_nUserId);
					cResSet = cState.executeQuery();
					if(cResSet.next()) {
						m_bFollow = true;
						checkLogin.m_nSafeFilter = Math.max(checkLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;

					// blocking
					strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, checkLogin.m_nUserId);
					cState.setInt(2, m_nUserId);
					cResSet = cState.executeQuery();
					if(cResSet.next()) {
						m_bBlocking = true;
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;

					// blocked
					strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, m_nUserId);
					cState.setInt(2, checkLogin.m_nUserId);
					cResSet = cState.executeQuery();
					if(cResSet.next()) {
						m_bBlocked = true;
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;
				}

				// User contents total number
				String strOpenCnd = (!m_bOwner || (m_bOwner&&!m_bDispUnPublished))?" AND open_id<>2":"";
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

				// category
				strSql = String.format("SELECT tag_txt FROM tags_0000 WHERE tag_type=3 AND content_id IN(SELECT content_id FROM contents_0000 WHERE user_id=? %s) GROUP BY tag_txt ORDER BY max(upload_date) DESC", strOpenCnd);
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nUserId);
				cResSet = cState.executeQuery();
				while(cResSet.next()) {
					m_vCategoryList.add(new CTag(cResSet));
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			if(m_bBlocking || m_bBlocked) return true;

			// condition
			String strCond = (m_strKeyword.isEmpty())?"":" AND content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=? AND tag_type=3)";

			// gallery
			String strOpenCnd = (!m_bOwner || (m_bOwner&&!m_bDispUnPublished))?" AND open_id<>2":"";
			strSql = String.format("SELECT COUNT(*) FROM contents_0000 WHERE user_id=? AND safe_filter<=? %s %s", strCond, strOpenCnd);
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, m_nUserId);
			cState.setInt(idx++, checkLogin.m_nSafeFilter);
			if(!m_strKeyword.isEmpty()) {
				cState.setString(idx++, m_strKeyword);
			}
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nContentsNum = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			idx = 1;
			strSql = String.format("SELECT contents_0000.*, nickname, ng_reaction, users_0000.file_name as user_file_name FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE contents_0000.user_id=? AND safe_filter<=? %s %s ORDER BY content_id DESC OFFSET ? LIMIT ?", strCond, strOpenCnd);
			cState = cConn.prepareStatement(strSql);
			cState.setInt(idx++, m_nUserId);
			cState.setInt(idx++, checkLogin.m_nSafeFilter);
			if(!m_strKeyword.isEmpty()) {
				cState.setString(idx++, m_strKeyword);
			}
			cState.setInt(idx++, m_nPage * SELECT_MAX_GALLERY);
			cState.setInt(idx++, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				cContent.m_cUser.m_strNickName	= Util.toString(cResSet.getString("nickname"));
				cContent.m_cUser.m_strFileName	= Util.toString(cResSet.getString("user_file_name"));
				if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";
				cContent.m_cUser.m_nReaction = cResSet.getInt("ng_reaction");
				cContent.m_cUser.m_nFollowing = (m_bOwner)?CUser.FOLLOW_HIDE:(m_bFollow)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				m_vContentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Each Comment
			m_vContentList = GridUtil.getEachComment(cConn, m_vContentList);

			// Bookmark
			m_vContentList = GridUtil.getEachBookmark(cConn, m_vContentList, checkLogin);
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

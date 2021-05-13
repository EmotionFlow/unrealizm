package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CContentAppend;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.CTweet;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public final class ShowAppendFileC {
	public static final int OK = 0;
	public static final int ERR_NOT_FOUND = -1;
	public static final int ERR_PASS = -2;
	public static final int ERR_LOGIN = -3;
	public static final int ERR_FOLLOWER = -4;
	public static final int ERR_T_FOLLOWER = -5;
	public static final int ERR_T_FOLLOW = -6;
	public static final int ERR_T_EACH = -7;
	public static final int ERR_T_LIST = -8;
	public static final int ERR_T_RATE_LIMIT_EXCEEDED = -429088;
	public static final int ERR_T_INVALID_OR_EXPIRED_TOKEN = -404089;
	public static final int ERR_HIDDEN = -9;
	public static final int ERR_UNKNOWN = -99;

	public int m_nUserId = -1;
	public int m_nContentId = -1;
	public String m_strPassword = "";
	public int m_nMode = 0;
	public int m_nTwFriendship = CTweet.FRIENDSHIP_UNDEF;

	public void getParam(HttpServletRequest request) {
		try {
			m_nUserId	= Util.toInt(request.getParameter("UID"));
			m_nContentId	= Util.toInt(request.getParameter("IID"));
			m_strPassword = request.getParameter("PAS");
			m_nMode = Util.toInt(request.getParameter("MD"));
			m_nTwFriendship = Util.toInt(request.getParameter("TWF"));
			request.setCharacterEncoding("UTF-8");
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}

	public CContent m_cContent = null;
	public int getResults(CheckLogin checkLogin) {
		int nRtn = OK;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			cConn = DatabaseUtil.dataSource.getConnection();

			strSql = "SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.setInt(2, m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cContent = new CContent(cResSet);
				m_cContent.m_strPassword = Util.toString(cResSet.getString("password"));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(m_cContent==null) return ERR_NOT_FOUND;

			boolean bRequestClient = false;
			strSql = "SELECT id FROM requests WHERE content_id=? AND client_user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cState.setInt(2, checkLogin.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				bRequestClient = true;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			boolean bOwner = m_cContent.m_nUserId==checkLogin.m_nUserId;

			if (!bRequestClient && m_cContent.m_nPublishId==Common.PUBLISH_ID_PASS && !m_cContent.m_strPassword.equals(m_strPassword)) return ERR_PASS;

			// login user
			if (m_cContent.m_nPublishId==Common.PUBLISH_ID_LOGIN && !checkLogin.m_bLogin) {
				return ERR_LOGIN;
			}

			// POIPIKU fav
			if (bRequestClient && m_cContent.m_nPublishId==Common.PUBLISH_ID_FOLLOWER) {
				boolean bFollow = (m_nUserId==checkLogin.m_nUserId);
				if(!bFollow) {
					strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, checkLogin.m_nUserId);
					cState.setInt(2, m_nUserId);
					cResSet = cState.executeQuery();
					if(cResSet.next()) {
						bFollow = true;
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;
				}
				if(!bFollow) return ERR_FOLLOWER;
			}

			// hidden
			if (!(bRequestClient || bOwner) && m_cContent.m_nPublishId==Common.PUBLISH_ID_HIDDEN){
				return ERR_HIDDEN;
			}

			// twitter follower, followee, each
			if (!(bRequestClient || bOwner) && (m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER || m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE || m_cContent.m_nPublishId==Common.PUBLISH_ID_T_EACH)) {
				if (!checkLogin.m_bLogin) {
					if (m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER) {
						return ERR_T_FOLLOWER;
					}
					if (m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE) {
						return ERR_T_FOLLOW;
					}
					if (m_cContent.m_nPublishId==Common.PUBLISH_ID_T_EACH) {
						return ERR_T_EACH;
					}
					return ERR_UNKNOWN;
				}
				CTweet cTweet = new CTweet();
				if(cTweet.GetResults(checkLogin.m_nUserId)){
					if (!cTweet.m_bIsTweetEnable) {
						if (m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER) {
							return ERR_T_FOLLOWER;
						}
						if (m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE) {
							return ERR_T_FOLLOW;
						}
						if (m_cContent.m_nPublishId==Common.PUBLISH_ID_T_EACH) {
							return ERR_T_EACH;
						}
						return ERR_UNKNOWN;
					}

					if(m_nTwFriendship==CTweet.FRIENDSHIP_UNDEF
						|| (m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER && (m_nTwFriendship==CTweet.FRIENDSHIP_NONE || m_nTwFriendship==CTweet.FRIENDSHIP_FOLLOWER))
						|| (m_cContent.m_nPublishId==Common.PUBLISH_ID_T_EACH     && (m_nTwFriendship==CTweet.FRIENDSHIP_NONE || m_nTwFriendship==CTweet.FRIENDSHIP_FOLLOWER))
						){
						m_nTwFriendship = cTweet.LookupFriendship(m_nUserId);
						if(m_nTwFriendship==CTweet.ERR_RATE_LIMIT_EXCEEDED){
							return ERR_T_RATE_LIMIT_EXCEEDED;
						}else if(m_nTwFriendship==CTweet.ERR_INVALID_OR_EXPIRED_TOKEN){
							return ERR_T_INVALID_OR_EXPIRED_TOKEN;
						}else if(m_nTwFriendship==CTweet.ERR_OTHER){
							return ERR_UNKNOWN;
						}
					}
					if(m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER && !(m_nTwFriendship==CTweet.FRIENDSHIP_FOLLOWEE || m_nTwFriendship==CTweet.FRIENDSHIP_EACH)){return ERR_T_FOLLOWER;}
					if(m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE && !(m_nTwFriendship==CTweet.FRIENDSHIP_FOLLOWER || m_nTwFriendship==CTweet.FRIENDSHIP_EACH)){return ERR_T_FOLLOW;}
					if(m_cContent.m_nPublishId==Common.PUBLISH_ID_T_EACH && !(m_nTwFriendship==CTweet.FRIENDSHIP_EACH)){return ERR_T_EACH;}
				}
			}

			// twitter openlist
			if (!(bRequestClient || bOwner) && m_cContent.m_nPublishId==Common.PUBLISH_ID_T_LIST){
				if (!checkLogin.m_bLogin) {
					return ERR_T_LIST;
				}
				CTweet cTweet = new CTweet();
				if(cTweet.GetResults(checkLogin.m_nUserId)){
					if(!cTweet.m_bIsTweetEnable){
						return ERR_T_LIST;
					}
					int nRet = cTweet.LookupListMember(m_cContent);
					if(nRet==CTweet.ERR_NOT_FOUND) return ERR_T_LIST;
					if(nRet==CTweet.ERR_INVALID_OR_EXPIRED_TOKEN) return ERR_T_INVALID_OR_EXPIRED_TOKEN;
					if(nRet==CTweet.ERR_RATE_LIMIT_EXCEEDED) return ERR_T_RATE_LIMIT_EXCEEDED;
					if(nRet<0) {
						return ERR_UNKNOWN;
					}
				} else {
					return ERR_UNKNOWN;
				}
			}

			// Each append image
			strSql = "SELECT * FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id ASC LIMIT 1000";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_cContent.m_vContentAppend.add(new CContentAppend(cResSet));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			nRtn = m_cContent.m_vContentAppend.size();
		} catch(Exception e) {
			e.printStackTrace();
			nRtn = ERR_UNKNOWN;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}

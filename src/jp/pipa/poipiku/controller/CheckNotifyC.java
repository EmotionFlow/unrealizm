package jp.pipa.poipiku.controller;

import java.sql.*;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

public final class CheckNotifyC {
	public int m_nUserId = -1;

	public void GetParam(HttpServletRequest request) {
//		try {
//			cRequest.setCharacterEncoding("UTF-8");
//		} catch(Exception e) {
//			m_nUserId = -1;
//		}
	}

	public int m_nCheckComment = 0;
//	public int m_nCheckFollow = 0;
//	public int m_nCheckHeart = 0;
	public int m_nCheckRequest = 0;
	public int m_nCheckGift = 0;

	public int m_nNotifyComment = 0;
//	public int m_nNotifyFollow = 0;
//	public int m_nNotifyHeart = 0;
	public int m_nNotifyRequest = 0;
	public int m_nNotifyGift = 0;

	public boolean GetResults() {
		String strSql = "";
		boolean bRtn = false;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;

		try {
			cConn = DatabaseUtil.dataSource.getConnection();

			// フォロー通知を表示するか
			/*
			boolean bDispFollower = false;
			strSql = "SELECT * FROM users_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				int nMailComment	= cResSet.getInt("mail_comment");
				bDispFollower		= ((nMailComment>>>0 & 0x01) == 0x01);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			*/

//			final Timestamp lastNotifyDate;

			final Timestamp lastCheckDate;
			strSql = "SELECT last_notify_date, last_check_date FROM users_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				// lastNotifyDate = cResSet.getTimestamp("last_notify_date");
				lastCheckDate = cResSet.getTimestamp("last_check_date");
			} else {
				// lastNotifyDate = null;
				lastCheckDate = null;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			strSql = "SELECT info_type, SUM(badge_num) FROM info_lists WHERE user_id=? AND had_read=false AND info_date>? GROUP BY info_type";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.setTimestamp(2, lastCheckDate);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				if (cResSet.getInt(1) == Common.NOTIFICATION_TYPE_REACTION) {
					m_nCheckComment = cResSet.getInt(2);
				} else if (cResSet.getInt(1) == Common.NOTIFICATION_TYPE_REQUEST) {
					m_nCheckRequest = cResSet.getInt(2);
				} else if (cResSet.getInt(1) == Common.NOTIFICATION_TYPE_GIFT) {
					m_nCheckGift = cResSet.getInt(2);
				}
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			// Check Follower
			/*
			if(bDispFollower) {
				strSql = "SELECT  COUNT(*) FROM follows_0000 WHERE follows_0000.follow_user_id=? AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_check_date FROM users_0000 WHERE user_id=?)";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nCheckFollow = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}
			*/

			// Check Heart
			/*
			strSql = "SELECT COUNT(*) FROM bookmarks_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE open_id<>2 AND user_id=?) AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_check_date FROM users_0000 WHERE user_id=?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nCheckHeart = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			*/


			// Notify Follower
			/*
			if(bDispFollower) {
				strSql = "SELECT  COUNT(*) FROM follows_0000 WHERE follows_0000.follow_user_id=? AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_notify_date FROM users_0000 WHERE user_id=?)";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nNotifyFollow = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}
			*/

			// Notify Heart
			/*
			strSql = "SELECT COUNT(*) FROM bookmarks_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE open_id<>2 AND user_id=?) AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_notify_date FROM users_0000 WHERE user_id=?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nNotifyHeart = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			*/

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Update Last Check Time
//			strSql = "UPDATE users_0000 SET last_notify_date=CURRENT_TIMESTAMP WHERE user_id=?";
//			cState = cConn.prepareStatement(strSql);
//			cState.setInt(1, m_nUserId);
//			cState.executeUpdate();
//			cState.close();cState=null;

			/*
			// Update Last Login Time
			strSql = "UPDATE users_0000 SET last_login_date=CURRENT_TIMESTAMP WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
			CacheUsers0000 user = CacheUsers0000.getInstance();
			user.clearUser(m_nUserId);
			*/

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

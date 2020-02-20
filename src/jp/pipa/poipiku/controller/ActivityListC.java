package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;
import java.util.Vector;
import java.util.Comparator;
import java.util.Collections;

import javax.naming.InitialContext;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class ActivityListC {
	public Vector<CComment> m_vComment = new Vector<CComment>();

	public boolean GetResults(ActivityListCParam cParam) {
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

			// フォロー通知を表示するか
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

			// Comment
			if(cParam.m_nMode<=0) {
				strSql = "SELECT comments_0000.*, T1.file_name, T1.nickname FROM comments_0000 LEFT JOIN users_0000 as T1 ON comments_0000.user_id=T1.user_id WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE open_id<>2 AND user_id=?) AND comments_0000.user_id!=? ORDER BY comment_id DESC LIMIT 100";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nUserId);
			} else {
				strSql = "SELECT comments_0000.*, T1.file_name, T1.nickname FROM comments_0000 LEFT JOIN users_0000 as T1 ON comments_0000.user_id=T1.user_id WHERE comments_0000.user_id=? ORDER BY comment_id DESC LIMIT 100";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
			}
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CComment cComment = new CComment(cResSet);
				cComment.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
				cComment.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
				cComment.m_nCommentType		= CComment.TYPE_COMMENT;
				if(cComment.m_strFileName.length()<=0) cComment.m_strFileName="/img/default_user.jpg";
				m_vComment.add(cComment);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Follow
			/*
			if(bDispFollower) {
				if(cParam.m_nMode<=0) {
					strSql = "SELECT follows_0000.*, nickname, file_name FROM follows_0000 INNER JOIN users_0000 ON follows_0000.user_id=users_0000.user_id WHERE follows_0000.follow_user_id=? ORDER BY follow_id DESC LIMIT 100";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, cParam.m_nUserId);
					cResSet = cState.executeQuery();
					while (cResSet.next()) {
						CComment cContent = new CComment();
						cContent.m_nUserId			= cResSet.getInt("user_id");
						cContent.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
						cContent.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
						cContent.m_timeUploadDate	= cResSet.getTimestamp("upload_date");
						cContent.m_nCommentType		= CComment.TYPE_FOLLOW;
						if(cContent.m_strFileName.isEmpty()) cContent.m_strFileName="/img/default_user.jpg";
						m_vComment.addElement(cContent);
					}
				} else {
					strSql = "SELECT follows_0000.*, nickname, file_name FROM follows_0000 INNER JOIN users_0000 ON follows_0000.follow_user_id=users_0000.user_id WHERE follows_0000.user_id=? ORDER BY follow_id DESC LIMIT 100";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, cParam.m_nUserId);
					cResSet = cState.executeQuery();
					while (cResSet.next()) {
						CComment cContent = new CComment();
						cContent.m_nUserId			= cResSet.getInt("follow_user_id");
						cContent.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
						cContent.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
						cContent.m_timeUploadDate	= cResSet.getTimestamp("upload_date");
						cContent.m_nCommentType		= CComment.TYPE_FOLLOW;
						if(cContent.m_strFileName.isEmpty()) cContent.m_strFileName="/img/default_user.jpg";
						m_vComment.addElement(cContent);
					}
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}
			*/

			// Heart
			/*
			if(cParam.m_nMode<=0) {
				strSql = "SELECT bookmarks_0000.*, users_0000.file_name, users_0000.nickname FROM bookmarks_0000 LEFT JOIN users_0000 ON bookmarks_0000.user_id=users_0000.user_id WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE open_id<>2 AND user_id=?) ORDER BY bookmark_id DESC LIMIT 200";
			} else {
				strSql = "SELECT T3.user_id, T1.content_id, T1.upload_date, T3.file_name, T3.nickname FROM (bookmarks_0000 as T1 LEFT JOIN contents_0000 as T2 ON T1.content_id=T2.content_id) LEFT JOIN users_0000 as T3 ON T2.user_id=T3.user_id WHERE open_id<>2 AND T1.user_id=? ORDER BY bookmark_id DESC LIMIT 200";
			}
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CComment cContent = new CComment();
				cContent.m_nContentId		= cResSet.getInt("content_id");
				cContent.m_nUserId			= cResSet.getInt("user_id");
				cContent.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
				cContent.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
				cContent.m_timeUploadDate	= cResSet.getTimestamp("upload_date");
				cContent.m_nCommentType		= CComment.TYPE_HEART;
				if(cContent.m_strFileName.isEmpty()) cContent.m_strFileName="/img/default_user.jpg";
				m_vComment.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			*/


			// Sort Time Line
			Collections.sort(m_vComment, new Comparator<CComment>(){
				public int compare(CComment obj1, CComment obj2){
					CComment cComment1 =(CComment)obj1;
					CComment cComment2 =(CComment)obj2;
					return cComment2.m_timeUploadDate.compareTo(cComment1.m_timeUploadDate);
				}
			});


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
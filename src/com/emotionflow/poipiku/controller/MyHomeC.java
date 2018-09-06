package com.emotionflow.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import com.emotionflow.poipiku.*;

public class MyHomeC {
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Common.ToInt(cRequest.getParameter("PG")), 0);
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX = 30;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	int m_nEndId = -1;
	public int m_nContentsNum = 0;

	public boolean getResults(CheckLogin cCheckLogin) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// NEW ARRIVAL
			strSql = "SELECT count(*) FROM (contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id) LEFT JOIN bookmarks_0000 ON contents_0000.content_id=bookmarks_0000.content_id AND bookmarks_0000.user_id=? WHERE (contents_0000.user_id IN (SELECT follow_user_id FROM follows_0000 WHERE user_id=?) OR contents_0000.user_id=?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cCheckLogin.m_nUserId);
			cState.setInt(2, cCheckLogin.m_nUserId);
			cState.setInt(3, cCheckLogin.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nContentsNum = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			strSql = "SELECT contents_0000.*, nickname, users_0000.file_name as user_file_name FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE contents_0000.user_id IN (SELECT follow_user_id FROM follows_0000 WHERE user_id=?) OR contents_0000.user_id=? ORDER BY content_id DESC OFFSET ? LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cCheckLogin.m_nUserId);
			cState.setInt(2, cCheckLogin.m_nUserId);
			cState.setInt(3, SELECT_MAX*m_nPage);
			cState.setInt(4, SELECT_MAX);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				cContent.m_cUser.m_strFileName	= Common.ToString(cResSet.getString("user_file_name"));
				if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";
				cContent.m_cUser.m_nFollowing = CUser.FOLLOW_HIDE;
				m_nEndId = cContent.m_nContentId;
				m_vContentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Eeach Emoji
			strSql = "SELECT * FROM comments_0000 WHERE content_id=? ORDER BY comment_id DESC LIMIT 240";
			cState = cConn.prepareStatement(strSql);
			for(CContent cContent : m_vContentList) {
				cState.setInt(1, cContent.m_nContentId);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CComment cComment = new CComment(cResSet);
					cContent.m_vComment.add(0, cComment);
				}
				cResSet.close();cResSet=null;
			}
			cState.close();cState=null;
			bResult = true;
		} catch(Exception e) {
			System.out.println(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bResult;
	}

}

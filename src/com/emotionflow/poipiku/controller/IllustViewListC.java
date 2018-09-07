package com.emotionflow.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import com.emotionflow.poipiku.*;

public class IllustViewListC {
	public int m_nUserId = -1;
	public int m_nContentId = -1;
	public int m_nPage = 0;
	public int m_nMode = 0;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId		= Common.ToInt(cRequest.getParameter("ID"));
			m_nContentId	= Common.ToInt(cRequest.getParameter("TD"));
			m_nPage 		= Common.ToInt(cRequest.getParameter("PG"));
			m_nMode 		= Common.ToInt(cRequest.getParameter("MD"));
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}


	public int SELECT_MAX = 10;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
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

			// follow
			int m_nFollow = CUser.FOLLOW_HIDE;
			if(m_nUserId != cCheckLogin.m_nUserId) {
				strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cCheckLogin.m_nUserId);
				cState.setInt(2, m_nUserId);
				cResSet = cState.executeQuery();
				m_nFollow = (cResSet.next())?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			// NEW ARRIVAL
			strSql = "SELECT contents_0000.*, nickname, users_0000.file_name as user_file_name FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE contents_0000.user_id=? AND contents_0000.content_id<? ORDER BY content_id DESC OFFSET ? LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.setInt(2, m_nContentId);
			cState.setInt(3, SELECT_MAX*m_nPage);
			cState.setInt(4, SELECT_MAX);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				cContent.m_cUser.m_strFileName	= Common.ToString(cResSet.getString("user_file_name"));
				if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";
				cContent.m_cUser.m_nFollowing = m_nFollow;
				m_vContentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Eeach Comment
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

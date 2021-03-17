package jp.pipa.poipiku.controller;

import java.sql.*;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class IllustDetailC {
	public int m_nUserId = -1;
	public int m_nContentId = -1;
	public int m_nAppendId = -1;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId		= Util.toInt(cRequest.getParameter("ID"));
			m_nContentId	= Util.toInt(cRequest.getParameter("TD"));
			m_nAppendId		= Util.toInt(cRequest.getParameter("AD"));
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}

	public CContent m_cContent = new CContent();
	public int m_nDownload = CUser.DOWNLOAD_OFF;
	public boolean isDownloadable = false;
	public boolean isRequestClient = false;
	public boolean getResults(CheckLogin checkLogin) {
		String strSql = "";
		boolean bRtn = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// author profile
			strSql = "SELECT * FROM users_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				m_nDownload = resultSet.getInt("ng_download");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			Request poipikuRequest = new Request();
			poipikuRequest.contentId = m_nContentId;
			poipikuRequest.selectByContentId();
			isRequestClient = poipikuRequest.isClient(checkLogin.m_nUserId);

			// content main
			String strOpenCnd = (m_nUserId!=checkLogin.m_nUserId && !isRequestClient) ? " AND open_id<>2" : "";
			strSql = String.format("SELECT * FROM contents_0000 WHERE user_id=? AND content_id=? %s", strOpenCnd);
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.setInt(2, m_nContentId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				m_cContent = new CContent(resultSet);
				bRtn = true;
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if(checkLogin.m_nUserId != m_cContent.m_nUserId && (
				m_cContent.m_nPublishId == Common.PUBLISH_ID_T_FOLLOWER ||
				m_cContent.m_nPublishId == Common.PUBLISH_ID_T_FOLLOWEE||
				m_cContent.m_nPublishId == Common.PUBLISH_ID_T_EACH ||
				m_cContent.m_nPublishId == Common.PUBLISH_ID_T_LIST )
			){
				CTweet tweet = new CTweet();
				tweet.GetResults(checkLogin.m_nUserId);
				if(m_cContent.m_nPublishId == Common.PUBLISH_ID_T_LIST){
					bRtn = (tweet.LookupListMember(m_cContent) == CTweet.OK);
				}else{
					final int friendshipResult = tweet.LookupFriendship(m_cContent.m_nUserId);
					switch (m_cContent.m_nPublishId){
						case Common.PUBLISH_ID_T_FOLLOWER:
							bRtn = (friendshipResult == CTweet.FRIENDSHIP_FOLLOWEE || friendshipResult == CTweet.FRIENDSHIP_EACH);
							break;
						case Common.PUBLISH_ID_T_FOLLOWEE:
							bRtn = (friendshipResult == CTweet.FRIENDSHIP_FOLLOWER || friendshipResult == CTweet.FRIENDSHIP_EACH);
							break;
						case Common.PUBLISH_ID_T_EACH:
							bRtn = (friendshipResult == CTweet.FRIENDSHIP_EACH);
							break;
						default:
							bRtn = false;
					}
				}
				if(!bRtn) return false;
			}

			if(m_nAppendId>0 && bRtn) {
				bRtn = false;
				strSql = "SELECT * FROM contents_appends_0000 WHERE content_id=? AND append_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nContentId);
				statement.setInt(2, m_nAppendId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					m_cContent.m_strFileName = resultSet.getString("file_name");
					bRtn = true;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			isDownloadable = m_cContent.m_nEditorId!=Common.EDITOR_TEXT &&
					(m_cContent.m_cUser.m_nUserId==checkLogin.m_nUserId || m_nDownload==CUser.DOWNLOAD_ON);

			// リクエストしたユーザは必ずダウンロードできる
			if(poipikuRequest.isClient(checkLogin.m_nUserId)){
				isDownloadable = true;
			}

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

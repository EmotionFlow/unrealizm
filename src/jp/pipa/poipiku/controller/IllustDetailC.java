package jp.pipa.poipiku.controller;

import java.sql.*;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public final class IllustDetailC {
	public int ownerUserId = -1;
	public int contentId = -1;
	public int appendId = -1;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			ownerUserId = Util.toInt(cRequest.getParameter("ID"));
			contentId = Util.toInt(cRequest.getParameter("TD"));
			appendId = Util.toInt(cRequest.getParameter("AD"));
		} catch(Exception e) {
			contentId = -1;
		}
	}

	private String paramToString() {
		return String.format("ID:%d, TD:%d ,AD:%d", ownerUserId, contentId, appendId);
	}

	public CContent m_cContent = new CContent();
	public boolean isOwner = false;
	public int m_nDownload = CUser.DOWNLOAD_OFF;
	public boolean isDownloadable = false;
	public boolean isRequestClient = false;
	public boolean getResults(CheckLogin checkLogin) {
		String strSql = "";
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			// author profile
			strSql = "SELECT ng_download FROM users_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, ownerUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				m_nDownload = resultSet.getInt("ng_download");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			Request poipikuRequest = new Request();
			poipikuRequest.selectByContentId(contentId, connection);
			isRequestClient = poipikuRequest.isClient(checkLogin.m_nUserId);

			// content main
			String strOpenCnd = (ownerUserId !=checkLogin.m_nUserId && !isRequestClient) ? " AND open_id<>2" : "";
			strSql = String.format("SELECT * FROM contents_0000 WHERE user_id=? AND content_id=? %s", strOpenCnd);
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, ownerUserId);
			statement.setInt(2, contentId);
			resultSet = statement.executeQuery();
			if(resultSet.next()){
				m_cContent = new CContent(resultSet);
				bRtn = true;
			} else {
				Log.d("record not found");
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
					final int friendshipResult = tweet.LookupFriendship(m_cContent.m_nUserId, m_cContent.m_nPublishId);
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
				if(!bRtn) {
					Log.d("Tw限定のチェックができなかった");
					return false;
				}
			}

			if(appendId >0 && bRtn) {
				bRtn = false;
				strSql = "SELECT file_name FROM contents_appends_0000 WHERE content_id=? AND append_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, contentId);
				statement.setInt(2, appendId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					m_cContent.m_strFileName = Util.toString(resultSet.getString("file_name"));
					bRtn = true;
				} else {
					Log.d("file_name was not found");
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			isOwner = m_cContent.m_cUser.m_nUserId==checkLogin.m_nUserId;

			isDownloadable = m_cContent.m_nEditorId!=Common.EDITOR_TEXT && (isOwner || m_nDownload==CUser.DOWNLOAD_ON);

			// リクエストしたユーザは必ずダウンロードできる
			if(poipikuRequest.isClient(checkLogin.m_nUserId)){
				isDownloadable = true;
			}

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return bRtn;
	}
}

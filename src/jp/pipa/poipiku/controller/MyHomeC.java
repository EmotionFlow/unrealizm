package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;


public class MyHomeC {
	public int userId = -1;
	public int version = 0;
	public int mode = CCnv.MODE_PC;
	public int startId = -1;
	public int viewMode = CCnv.VIEW_LIST;
	public int page = 1;
	private int lastSystemInfoId = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			version = Util.toInt(request.getParameter("VER"));
			mode = Util.toInt(request.getParameter("MD"));
			startId = Util.toInt(request.getParameter("SD"));
			userId = Util.toInt(request.getParameter("ID"));
			viewMode = Util.toInt(request.getParameter("VD"));
			page = Util.toInt(request.getParameter("PG"));
			if(startId <=0) {
				String strPoipikuInfoId = Util.getCookie(request, Common.POIPIKU_INFO);
				if(strPoipikuInfoId!=null && !strPoipikuInfoId.isEmpty()) {
					lastSystemInfoId = Integer.parseInt(strPoipikuInfoId);
				}
			}
		} catch(Exception ignored) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 10;
	public int SELECT_MAX_EMOJI = GridUtil.SELECT_MAX_EMOJI;
	public ArrayList<CContent> contentList = new ArrayList<>();
	public int contentsNum = 0;
	public int contentsNumTotal = 0;
	public int lastContentId = -1;
	public CContent systemInfo = null;
	public int recommendedMax = 6;
	public List<CUser> recommendedUserList = null;
	public List<CUser> recommendedRequestCreatorList = null;

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, true, true);
	}

	public boolean getResults(CheckLogin checkLogin, boolean needRecommendedUsers, boolean needRecommendedRequestCreator) {
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			connection = DatabaseUtil.dataSource.getConnection();

			// POIPIKU INFO
			if(startId <=0) {
				strSql = "SELECT content_id, upload_date, description FROM contents_0000 WHERE user_id=2 AND category_id=14 AND content_id>? ORDER BY content_id DESC LIMIT 1";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, lastSystemInfoId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					systemInfo = new CContent();
					systemInfo.m_nUserId		= 2;
					systemInfo.m_nContentId		= resultSet.getInt("content_id");
					systemInfo.m_timeUploadDate	= resultSet.getTimestamp("upload_date");
					systemInfo.m_strDescription	= Util.toString(resultSet.getString("description"));
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCondMute = "";
			if(checkLogin.m_bLogin && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
				strMuteKeyword = SqlUtil.getMuteKeyWord(connection, checkLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "AND content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ";
				}
			}
			String strCondStart = (startId >0)?"AND content_id<? ":"";

			StringBuilder sb = new StringBuilder();
			sb.append("SELECT * FROM contents_0000 ")
			.append("WHERE open_id<>2 ")
			.append("AND user_id IN (SELECT follow_user_id FROM follows_0000 WHERE user_id=? UNION SELECT ?) ");
			if(!strCondMute.isEmpty()) {
				sb.append(strCondMute);
			}
			if(!strCondStart.isEmpty()) {
				sb.append(strCondStart);
			}
			sb.append("AND safe_filter<=? ");
			sb.append("ORDER BY content_id DESC LIMIT ?");
			strSql = new String(sb);

			// NEW ARRIVAL
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setInt(idx++, checkLogin.m_nUserId);
			if(!strCondMute.isEmpty()) {
				statement.setString(idx++, strMuteKeyword);
			}
			if(!strCondStart.isEmpty()) {
				statement.setInt(idx++, startId);
			}
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			statement.setInt(idx++, SELECT_MAX_GALLERY);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent cContent = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
				cContent.m_cUser.m_strNickName	= Util.toString(user.nickName);
				cContent.m_cUser.m_strFileName	= Util.toString(user.fileName);
				cContent.m_cUser.m_nReaction	= user.reaction;
				cContent.m_cUser.m_nFollowing = CUser.FOLLOW_HIDE;
				lastContentId = cContent.m_nContentId;
				contentList.add(cContent);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Each Comment
			GridUtil.getEachComment(connection, contentList);

			// Bookmark
			GridUtil.getEachBookmark(connection, contentList, checkLogin);

			// Recommended Users
			if (needRecommendedUsers) {
				recommendedUserList = RecommendedUsers.getUnFollowedUsers(recommendedMax, checkLogin, connection);
			}

			// Recommended Request Creators
			if (needRecommendedRequestCreator) {
				recommendedRequestCreatorList = RecommendedUsers.getRequestCreators(recommendedMax, checkLogin, connection);
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

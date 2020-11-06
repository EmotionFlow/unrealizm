package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class MyHomeC {
	public int n_nUserId = -1;
	public int n_nVersion = 0;
	public int m_nMode = CCnv.MODE_PC;
	public int m_nStartId = -1;
	public int m_nViewMode = CCnv.VIEW_LIST;
	private int m_nLastSystemInfoId = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			n_nVersion = Util.toInt(request.getParameter("VER"));
			m_nMode = Util.toInt(request.getParameter("MD"));
			m_nStartId = Util.toInt(request.getParameter("SD"));
			n_nUserId = Util.toInt(request.getParameter("ID"));
			m_nViewMode = Util.toInt(request.getParameter("VD"));
			if(m_nStartId<=0) {
				String strPoipikuInfoId = Util.getCookie(request, Common.POIPIKU_INFO);
				if(strPoipikuInfoId!=null && !strPoipikuInfoId.isEmpty()) {
					m_nLastSystemInfoId = Integer.parseInt(strPoipikuInfoId);
				}
			}
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
	public CContent m_cSystemInfo = null;

	public boolean getResults(CheckLogin cCheckLogin) {
		boolean bRtn = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// POIPIKU INFO
			if(m_nStartId<=0) {
				strSql = "SELECT content_id, upload_date, description FROM contents_0000 WHERE user_id=2 AND category_id=14 AND content_id>? ORDER BY content_id DESC LIMIT 1";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, m_nLastSystemInfoId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_cSystemInfo = new CContent();
					m_cSystemInfo.m_nUserId		= 2;
					m_cSystemInfo.m_nContentId		= resultSet.getInt("content_id");
					m_cSystemInfo.m_timeUploadDate	= resultSet.getTimestamp("upload_date");
					m_cSystemInfo.m_strDescription	= Util.toString(resultSet.getString("description"));
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCondMute = "";
			if(cCheckLogin.m_bLogin && cCheckLogin.m_nPremiumId>=CUser.PREMIUM_ON) {
				strMuteKeyword = SqlUtil.getMuteKeyWord(connection, cCheckLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "AND content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ";
				}
			}
			String strCondStart = (m_nStartId>0)?"AND content_id<? ":"";

			StringBuilder sb = new StringBuilder();
			sb.append("SELECT * FROM contents_0000 ")
			.append("WHERE open_id<>2 ")
			.append("AND user_id IN ((SELECT follow_user_id FROM follows_0000 WHERE user_id=?) UNION ALL (SELECT ?)) ");
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
			statement.setInt(idx++, cCheckLogin.m_nUserId);
			statement.setInt(idx++, cCheckLogin.m_nUserId);
			if(!strCondMute.isEmpty()) {
				statement.setString(idx++, strMuteKeyword);
			}
			if(!strCondStart.isEmpty()) {
				statement.setInt(idx++, m_nStartId);
			}
			statement.setInt(idx++, cCheckLogin.m_nSafeFilter);
			statement.setInt(idx++, SELECT_MAX_GALLERY);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent cContent = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
				cContent.m_cUser.m_strNickName	= Util.toString(user.m_strNickName);
				cContent.m_cUser.m_strFileName	= Util.toString(user.m_strFileName);
				cContent.m_cUser.m_nReaction	= user.m_nReaction;
				cContent.m_cUser.m_nFollowing = CUser.FOLLOW_HIDE;
				m_nEndId = cContent.m_nContentId;
				m_vContentList.add(cContent);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Each Comment
			GridUtil.getEachComment(connection, m_vContentList);

			// Bookmark
			if(cCheckLogin.m_bLogin) {
				GridUtil.getEachBookmark(connection, m_vContentList, cCheckLogin);
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

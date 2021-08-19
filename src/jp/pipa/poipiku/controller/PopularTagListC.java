package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class PopularTagListC {
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception e) {
			;
		}
	}

	public int SELECT_MAX_GALLERY = 50;
	public int SELECT_MAX_SAMPLE_GALLERY = 10;
	public int SELECT_SAMPLE_GALLERY = 3;
	//public ArrayList<CTag> m_vContentList = new ArrayList<CTag>();
	public ArrayList<CTag> m_vContentListWeekly = new ArrayList<CTag>();
	//public ArrayList<ArrayList<CContent>> m_vContentSamplpeList = new ArrayList<ArrayList<CContent>>();
	public ArrayList<ArrayList<CContent>> m_vContentSamplpeListWeekly = new ArrayList<ArrayList<CContent>>();


	public boolean getResults(CheckLogin checkLogin) {
		boolean bResult = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			connection = DatabaseUtil.dataSource.getConnection();

			// TAG LIST
			/*
			CTag cPriprityTag = new CTag();
			cPriprityTag = new CTag();
			cPriprityTag.m_strTagTxt = "カラパレコスメ";
			m_vContentListWeekly.add(cPriprityTag);

			cPriprityTag = new CTag();
			cPriprityTag.m_strTagTxt = "お題ルーレット";
			m_vContentListWeekly.add(cPriprityTag);
			*/

			//strSql = "select tag_txt FROM vw_rank_tag_weekly WHERE tag_txt NOT IN('カラパレコスメ', 'お題ルーレット') order by rank desc offset ? limit ?";
			//strSql = "select tag_txt FROM vw_rank_tag_weekly order by rank desc offset ? limit ?";
			strSql = "select tag_txt FROM vw_rank_tag_daily order by rank desc offset ? limit ?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nPage*SELECT_MAX_GALLERY);
			statement.setInt(2, SELECT_MAX_GALLERY);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				m_vContentListWeekly.add(new CTag(resultSet));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// BLOCK USER
			String strCondBlockUser = "";
			if(SqlUtil.hasBlockUser(connection, checkLogin.m_nUserId)) {
				strCondBlockUser = "AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) ";
			}

			// BLOCKED USER
			String strCondBlocedkUser = "";
			if(SqlUtil.hasBlockedUser(connection, checkLogin.m_nUserId)) {
				strCondBlocedkUser = "AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ";
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

			// WEEKLY SAMPLE
			strSql = "/*+ BitmapScan(tags_0000 tags_0000_tag_txt_pgidx) */"
					+ "SELECT * FROM contents_0000 "
					+ "WHERE open_id<>2 "
					+ "AND content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=? AND tag_type=1) "
					+ "AND safe_filter<=? "
					+ strCondBlockUser
					+ strCondBlocedkUser
					+ strCondMute
					+ "ORDER BY content_id DESC LIMIT ? ";

			statement = connection.prepareStatement(strSql);
			for(int nCnt=0; nCnt<m_vContentListWeekly.size() && nCnt<SELECT_MAX_SAMPLE_GALLERY; nCnt++) {
				CTag cTag = m_vContentListWeekly.get(nCnt);
				ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
				idx = 1;
				statement.setString(idx++, cTag.m_strTagTxt);
				statement.setInt(idx++, checkLogin.m_nSafeFilter);
				if(!strCondBlockUser.isEmpty()) {
					statement.setInt(idx++, checkLogin.m_nUserId);
				}
				if(!strCondBlocedkUser.isEmpty()) {
					statement.setInt(idx++, checkLogin.m_nUserId);
				}
				if(!strCondMute.isEmpty()){
					statement.setString(idx++, strMuteKeyword);
				}
				statement.setInt(idx++, SELECT_SAMPLE_GALLERY);
				resultSet = statement.executeQuery();
				while (resultSet.next()) {
					CContent cContent = new CContent(resultSet);
					CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
					cContent.m_cUser.m_strNickName	= Util.toString(user.nickName);
					cContent.m_cUser.m_strFileName	= Util.toString(user.fileName);
					m_vContentList.add(cContent);
				}
				resultSet.close();resultSet=null;
				m_vContentSamplpeListWeekly.add(m_vContentList);
			}
			// DAILY SAMPLE
			/*
			for(CTag cTag : m_vContentList) {
				ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
				idx = 1;
				cState.setString(idx++, cTag.m_strTagTxt);
				cState.setInt(idx++, checkLogin.m_nUserId);
				cState.setInt(idx++, checkLogin.m_nUserId);
				cState.setInt(idx++, checkLogin.m_nSafeFilter);
				if(!strMuteKeyword.isEmpty()) {
					cState.setString(idx++, strMuteKeyword);
				}
				cState.setInt(idx++, SELECT_SAMPLE_GALLERY);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CContent cContent = new CContent(cResSet);
					m_vContentList.add(cContent);
				}
				cResSet.close();cResSet=null;
				m_vContentSamplpeList.add(m_vContentList);
			}
			cState.close();cState=null;
			*/

			bResult = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bResult;
	}
}

package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public final class PopularTagListC {
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception ignored) {
			;
		}
	}

	public int selectMaxGallery = 20;
	public int selectMaxSampleGallery = 10;
	public int selectSampleGallery = 3;
	//public ArrayList<CTag> m_vContentList = new ArrayList<CTag>();
	public ArrayList<CTag> m_vTagListWeekly = new ArrayList<>();
	//public ArrayList<ArrayList<CContent>> m_vContentSamplpeList = new ArrayList<ArrayList<CContent>>();
	public ArrayList<ArrayList<CContent>> m_vContentSamplpeListWeekly = new ArrayList<>();


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
			m_vTagListWeekly.add(cPriprityTag);

			cPriprityTag = new CTag();
			cPriprityTag.m_strTagTxt = "お題ルーレット";
			m_vTagListWeekly.add(cPriprityTag);
			*/

			//strSql = "select tag_txt FROM vw_rank_tag_weekly WHERE tag_txt NOT IN('カラパレコスメ', 'お題ルーレット') order by rank desc offset ? limit ?";
			//strSql = "select tag_txt FROM vw_rank_tag_weekly order by rank desc offset ? limit ?";
			strSql = """
				WITH a AS (
				    SELECT tag_txt, genre_id
				    FROM vw_rank_tag_daily
				    ORDER BY rank DESC
				    OFFSET ? LIMIT ?
				),
				b AS (
					SELECT tag_txt
					FROM follow_tags_0000
					WHERE user_id = ?
				),
				c AS (
					SELECT genre_id, trans_text
					FROM genre_translations
					WHERE type_id=0 AND lang_id=?
				)
				SELECT a.tag_txt AS tag_name, b.tag_txt AS following, trans_text, genre_image
				FROM a
					INNER JOIN genres g ON a.genre_id = g.genre_id
				    LEFT JOIN b ON a.tag_txt = b.tag_txt
				    LEFT JOIN c ON a.genre_id = c.genre_id
				""";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nPage* selectMaxGallery);
			statement.setInt(2, selectMaxGallery);
			statement.setInt(3, checkLogin.m_nUserId);
			statement.setInt(4, checkLogin.m_nLangId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CTag tag = new CTag();
				tag.m_strTagTxt = resultSet.getString(1);
				tag.isFollow = resultSet.getString(2) != null;
				tag.m_strTagTransTxt = resultSet.getString(3);
				tag.m_strImageUrl = resultSet.getString(4);
				m_vTagListWeekly.add(tag);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			Collections.shuffle(m_vTagListWeekly);

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
			// ミュートキーワードは一時無効にする。
//			if(checkLogin.m_bLogin && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
//				strMuteKeyword = SqlUtil.getMuteKeyWord(connection, checkLogin.m_nUserId);
//				if(!strMuteKeyword.isEmpty()) {
//					strCondMute = "SELECT content_id as mute_content_id FROM contents_0000 WHERE description &@~ ?";
//				}
//			}

			final String strSqlWith;
			if (strMuteKeyword.isEmpty()) {
				strSqlWith = "";
			} else {
				strSqlWith = "WITH mute_contents AS (" + strCondMute + ")";
			}

			// WEEKLY SAMPLE
			// "/*+ BitmapScan(tags_0000 tags_0000_tag_txt_pgidx) */"
			strSql = strSqlWith + " SELECT c.*, ct.trans_text FROM contents_0000 c"
					+ " LEFT JOIN content_translations ct ON type_id=0 AND lang_id=? AND c.content_id = ct.content_id";

			if(!strCondMute.isEmpty()){
				strSql += (" LEFT JOIN mute_contents ON mute_contents.mute_content_id=c.content_id");
			}


			strSql += " WHERE open_id<>2 AND publish_id=0 AND password_enabled=FALSE AND safe_filter=0 AND editor_id<>3"
					+ " AND c.content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt LIKE ? AND tag_type=1) "
					+ strCondBlockUser
					+ strCondBlocedkUser;

			if(!strCondMute.isEmpty()){
				strSql += " AND mute_content_id IS NULL";
			}

			strSql += " ORDER BY c.content_id DESC LIMIT ? ";

			statement = connection.prepareStatement(strSql);
			for(int nCnt = 0; nCnt< m_vTagListWeekly.size() && nCnt< selectMaxSampleGallery; nCnt++) {
				CTag cTag = m_vTagListWeekly.get(nCnt);
				ArrayList<CContent> m_vContentList = new ArrayList<>();
				idx = 1;
				statement.setInt(idx++, checkLogin.m_nLangId);
				if(!strCondMute.isEmpty()){
					statement.setString(idx++, strMuteKeyword);
				}
				statement.setString(idx++, cTag.m_strTagTxt);
				if(!strCondBlockUser.isEmpty()) {
					statement.setInt(idx++, checkLogin.m_nUserId);
				}
				if(!strCondBlocedkUser.isEmpty()) {
					statement.setInt(idx++, checkLogin.m_nUserId);
				}
				statement.setInt(idx++, selectSampleGallery);

				resultSet = statement.executeQuery();
				while (resultSet.next()) {
					CContent cContent = new CContent(resultSet);
					CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
					cContent.m_cUser.m_strNickName	= Util.toString(user.nickName);
					cContent.m_cUser.m_strFileName	= Util.toString(user.fileName);
					cContent.m_strDescriptionTranslated = resultSet.getString("trans_text");
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

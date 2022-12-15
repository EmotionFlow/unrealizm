package jp.pipa.poipiku.controller;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public final class SearchTagByKeywordC {
	public int m_nPage = 0;
	public String m_strKeyword = "";
	public String encodedKeyword = "";
	public String ipAddress = "";
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Util.toInt(request.getParameter("PG")), 0);
			m_strKeyword = Common.TrimAll(request.getParameter("KWD"));
			if (!m_strKeyword.isEmpty() && m_strKeyword.indexOf("#") == 0) {
				m_strKeyword = m_strKeyword.replaceFirst("#", "");
			}
			encodedKeyword = URLEncoder.encode(m_strKeyword, StandardCharsets.UTF_8);
			ipAddress = request.getRemoteAddr();
		}
		catch(Exception e) {
			;
		}
	}

	public int selectMaxGallery = 36;
	public ArrayList<CTag> tagList = new ArrayList<>();
	public ArrayList<String> sampleContentFile = new ArrayList<>();
	public int contentsNum = 0;


	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean bResult = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		if(m_strKeyword.isEmpty()) return bResult;
		try {
			connection = DatabaseUtil.replicaDataSource.getConnection();

			sql = """
				WITH g_matched AS (
				    SELECT genre_id
				    FROM genres
					WHERE genre_id>0 AND (genre_name &^ pgroonga.query_escape(?) OR genre_name_kana &^~ pgroonga.query_escape(?))
				    UNION
				    DISTINCT
				    SELECT genre_id
				    FROM genre_translations
				    WHERE genre_id>0 AND trans_text &^ pgroonga.query_escape(?)
				)
				SELECT t.genre_id, t.tag_txt, COUNT(t.tag_txt) count_contents, gt.trans_text, f.genre_id AS following
				FROM tags_0000 t
				    INNER JOIN g_matched ON t.genre_id=g_matched.genre_id
				    LEFT JOIN (SELECT genre_id FROM follow_tags_0000 WHERE user_id = ?) f ON t.genre_id = f.genre_id
				    LEFT JOIN (SELECT genre_id, trans_text FROM genre_translations WHERE type_id=1 AND lang_id=?) gt ON t.genre_id = gt.genre_id
				GROUP BY t.genre_id, t.tag_txt, gt.trans_text, f.genre_id
				ORDER BY COUNT(t.tag_txt) DESC OFFSET ? LIMIT ?;
				""";
			statement = connection.prepareStatement(sql);
			int idx = 1;
			statement.setString(idx++, m_strKeyword);
			statement.setString(idx++, m_strKeyword);
			statement.setString(idx++, m_strKeyword);
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setInt(idx++, checkLogin.m_nLangId);
			statement.setInt(idx++, m_nPage * selectMaxGallery);
			statement.setInt(idx++, selectMaxGallery);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CTag tag = new CTag();
				tag.m_nGenreId = resultSet.getInt(1);
				tag.m_strTagTxt = resultSet.getString(2);
				tag.m_strTagTransTxt = resultSet.getString(4);
				tag.isFollow = resultSet.getInt(5) > 0;
				tagList.add(tag);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if (m_nPage < 4) {
				KeywordSearchLog.insert(checkLogin.m_nUserId, m_strKeyword, "",
						m_nPage, KeywordSearchLog.SearchTarget.Tags, tagList.size(), ipAddress);
			}

			// sample contents filenames
			sql = "WITH a AS (" +
					"    SELECT content_id FROM tags_0000 WHERE genre_id = ? ORDER BY tag_id DESC LIMIT 100" +
					" )" +
					" SELECT file_name" +
					" FROM contents_0000 c" +
					"         INNER JOIN a ON a.content_id = c.content_id" +
					" WHERE open_id <> 2" +
					"  AND publish_id = 0" +
					"  AND safe_filter <= 0" +
					"  AND password_enabled = FALSE" +
					"  AND editor_id <> 3" +
					" ORDER BY c.content_id DESC" +
					" LIMIT 1;";
			statement = connection.prepareStatement(sql);
			for (CTag tag: tagList) {
				statement.setInt(1, tag.m_nGenreId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					sampleContentFile.add(resultSet.getString(1));
				} else {
					sampleContentFile.add("");
				}
			}

			bResult = true;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bResult;
	}

}

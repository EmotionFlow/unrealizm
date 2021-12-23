package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public final class SearchTagByKeywordC {
	public int m_nPage = 0;
	public String m_strKeyword = "";
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
			m_strKeyword = Common.TrimAll(cRequest.getParameter("KWD"));
		}
		catch(Exception e) {
			;
		}
	}


	public int selectMaxGallery = 36;
	public ArrayList<CTag> tagList = new ArrayList<>();
	public ArrayList<String> sampleContentFile = new ArrayList<>();
	public int contentsNum = 0;
	private static final String PG_HINT = "/*+ BitmapScan(tags_0000 tags_0000_tag_txt_pgidx) */";


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
			connection = DatabaseUtil.dataSource.getConnection();

			sql = PG_HINT + " SELECT t.tag_txt, genre_id, f.tag_txt AS following "
					+ "FROM tags_0000 t "
					+ "LEFT JOIN (SELECT tag_txt FROM follow_tags_0000 WHERE user_id = ?) f ON t.tag_txt = f.tag_txt "
					+ "WHERE genre_id>0 AND t.tag_txt &@~ ? GROUP BY genre_id, t.tag_txt, f.tag_txt "
					+ "ORDER BY COUNT(t.tag_txt) DESC OFFSET ? LIMIT ?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setString(2, m_strKeyword);
			statement.setInt(3, m_nPage * selectMaxGallery);
			statement.setInt(4, selectMaxGallery);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CTag tag = new CTag();
				tag.m_strTagTxt = resultSet.getString(1);
				tag.m_nGenreId = resultSet.getInt(2);
				tag.isFollow = resultSet.getString(3) != null;
				tagList.add(tag);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			
			// sample contents filenames
			sql = "WITH a AS (" +
					"    SELECT content_id FROM tags_0000 WHERE genre_id = ? ORDER BY tag_id DESC LIMIT 100" +
					" )" +
					" SELECT file_name" +
					" FROM contents_0000 c" +
					"         INNER JOIN a ON a.content_id = c.content_id" +
					" WHERE open_id <> 2" +
					"  AND publish_id = 0" +
					"  AND safe_filter<=?" +
					" ORDER BY c.content_id DESC" +
					" LIMIT 1;";
			statement = connection.prepareStatement(sql);
			for (CTag tag: tagList) {
				statement.setInt(1, tag.m_nGenreId);
				statement.setInt(2, checkLogin.m_nSafeFilter);
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

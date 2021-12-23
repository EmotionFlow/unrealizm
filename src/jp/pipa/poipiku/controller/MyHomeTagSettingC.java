package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public final class MyHomeTagSettingC {
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

	public int selectMaxGallery = 100;
	public ArrayList<CTag> tagList = new ArrayList<>();
	public ArrayList<String> sampleContentFile = new ArrayList<>();

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean bResult = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		int idx = 1;

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			sql = "select * FROM follow_tags_0000 WHERE user_id=? order by upload_date desc offset ? limit ?";
			statement = connection.prepareStatement(sql);
			idx = 1;
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setInt(idx++, m_nPage* selectMaxGallery);
			statement.setInt(idx++, selectMaxGallery);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CTag cTag = new CTag(resultSet);
				cTag.m_nTypeId = resultSet.getInt("type_id");
				cTag.m_strTagTxt = resultSet.getString("tag_txt");
				cTag.m_nGenreId = resultSet.getInt("genre_id");
				tagList.add(cTag);
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

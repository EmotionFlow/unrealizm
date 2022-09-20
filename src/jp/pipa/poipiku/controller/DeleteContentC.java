package jp.pipa.poipiku.controller;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class DeleteContentC {
	public int m_nContentId = -1;
	public int m_nUserId = -1;
	public int m_nDeleteTweet = 0;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId			= Util.toInt(cRequest.getParameter("UID"));
			m_nContentId		= Util.toInt(cRequest.getParameter("CID"));
			m_nDeleteTweet		= Util.toIntN(cRequest.getParameter("DELTW"), 0, 1);
		} catch(Exception e) {
			m_nContentId = -1;
			m_nUserId = -1;
		}
	}

	private ServletContext m_cServletContext = null;
	public boolean GetResults(ServletContext context) {
		m_cServletContext = context;

		CContent cContent = null;
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();
			// イラスト存在確認(不正アクセス対策)
			if(m_nUserId==1) {
				strSql = "SELECT * FROM contents_0000 WHERE content_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nContentId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					cContent = new CContent(resultSet);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			} else {
				strSql = "SELECT * FROM contents_0000 WHERE content_id=? AND user_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nContentId);
				statement.setInt(2, m_nUserId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					cContent = new CContent(resultSet);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;

				// エアスケブ納品物でないことを確認
				strSql = "SELECT * FROM requests WHERE content_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nContentId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					cContent = null;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}
			if(cContent==null) {
				return false;
			}
			connection.close();connection=null;
			//////

			//////
			connection = DatabaseUtil.dataSource.getConnection();
			// delete comment
			strSql ="DELETE FROM comments_0000 WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.executeUpdate();
			statement.close();statement=null;

			// delete comment cash
			strSql ="DELETE FROM comments_desc_cache WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;
			/////

			/////
			connection = DatabaseUtil.dataSource.getConnection();
			// delete info_lists
			strSql ="DELETE FROM info_lists WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.executeUpdate();
			statement.close();statement=null;

			// delete tags
			strSql ="DELETE FROM tags_0000 WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.executeUpdate();
			statement.close();statement=null;

			// delete bookmark
			strSql ="DELETE FROM bookmarks_0000 WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.executeUpdate();
			statement.close();statement=null;

			// delete pins
			strSql ="DELETE FROM pins WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.executeUpdate();
			statement.close();statement=null;

			connection.close();connection=null;
			//////

			// delete append files
			connection = DatabaseUtil.dataSource.getConnection();
			strSql ="SELECT * FROM contents_appends_0000 WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			resultSet = statement.executeQuery();
			List<CContentAppend> contentAppends = new ArrayList<>();
			while(resultSet.next()) {
				CContentAppend cContentAppend = new CContentAppend(resultSet);
				contentAppends.add(cContentAppend);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			connection.close();connection=null;
			for (CContentAppend c : contentAppends) {
				try{
					ImageUtil.deleteFiles(m_cServletContext.getRealPath(c.m_strFileName));
				} catch (Exception e) {
					Log.d("cannot delete content_append file : " + c.m_strFileName);
				}
			}

			///////
			connection = DatabaseUtil.dataSource.getConnection();
			// delete append data
			strSql ="DELETE FROM contents_appends_0000 WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.executeUpdate();
			statement.close();statement=null;

			// delete content_translations
			strSql ="DELETE FROM content_translations WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.executeUpdate();
			statement.close();statement=null;

			// delete content data
			strSql ="DELETE FROM contents_0000 WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.executeUpdate();
			statement.close();statement=null;

			///////

			// delete files
			try{
				ImageUtil.deleteFiles(m_cServletContext.getRealPath(cContent.m_strFileName));
			} catch (Exception e) {
				Log.d("cannot delete content file : " + cContent.m_strFileName);
			}

			// old_id
			List<Integer> oldIds = new ArrayList<>();
			strSql = "SELECT old_id FROM content_id_histories WHERE new_id=?";
			statement = connection.prepareStatement(strSql);
			int cid = m_nContentId;
			for (int i=0; i<100; i++) {
				statement.setInt(1, cid);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					cid = resultSet.getInt(1);
					oldIds.add(cid);
					resultSet.close();resultSet=null;
				} else {
					resultSet.close();resultSet=null;
					break;
				}
			}
			statement.close();

			// delete files
			for (int i=0; i<Common.CURRENT_CONTENTS_STORAGE_DIR_ARY.length; i++) {
				Path path = Paths.get(
						m_cServletContext.getRealPath(Common.CURRENT_CONTENTS_STORAGE_DIR_ARY[i]),
						"%09d".formatted(m_nUserId)
				);
				for (Integer oldId: oldIds) {
					String pat = "^%09d.*".formatted(oldId);
					Files.list(path)
							.filter(path1 -> path1.getFileName().toString().matches(pat))
							.forEach(e -> Util.deleteFile(e.toString()));
				}
			}

			if (!oldIds.isEmpty()) {
				strSql = "DELETE FROM content_id_histories WHERE old_id in (%s)"
						.formatted(oldIds.stream().map(Object::toString).collect(Collectors.joining(",")));
				statement = connection.prepareStatement(strSql);
				statement.executeUpdate();
				statement.close();

				strSql = "DELETE FROM content_id_histories WHERE new_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nContentId);
				statement.executeUpdate();
				statement.close();
			}

			// delete tweet
			if(m_nUserId==cContent.m_nUserId && m_nDeleteTweet==1 && !cContent.m_strTweetId.isEmpty()){
				CTweet cTweet = new CTweet();
				if(cTweet.GetResults(m_nUserId)) {
					if(cTweet.Delete(cContent.m_strTweetId)!=CTweet.OK){
						Log.d("cTweet.Delete() failed");
					}
				} else {
					Log.d("cTweet.GetResult() failed");
				}
			}

			bRtn = true;
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

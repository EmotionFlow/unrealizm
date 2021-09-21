package jp.pipa.poipiku.util;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.cache.CacheUsers0000;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;
import java.util.stream.Collectors;

public final class RecommendedContents {
	static private final int OLD_CONTENTS_LIMIT = 30;
	static private final List<Integer> oldPopularContents;
	static private final List<Integer> veryOldContents;

	static private final String SQL_SELECT_RECOMMENDED_BY_TAG = "WITH recommended_tags AS (" +
			"    SELECT t.genre_id" +
			"    FROM tags_0000 t" +
			"      LEFT JOIN contents_0000 c ON t.content_id = c.content_id" +
			"    WHERE user_id = ?" +
			"      AND t.genre_id > 0" +
			"    LIMIT 10" +
			")" +
			"SELECT content_id" +
			" FROM tags_0000 t" +
			" WHERE genre_id IN (SELECT * FROM recommended_tags)" +
			" ORDER BY RANDOM()" +
			" LIMIT 30";

	static private final String SQL_SELECT_OLD_POPULARS = "SELECT content_id" +
			" FROM rank_contents_total" +
			" WHERE add_date BETWEEN NOW() - INTERVAL '3 month' AND NOW() - INTERVAL '2 month'";

	static private final String SQL_SELECT_VERY_OLD_CONTENTS = "SELECT content_id" +
			" FROM contents_0000" +
			" WHERE upload_date" +
			"    BETWEEN NOW() - INTERVAL '300 days' AND NOW() - INTERVAL '299 days'" +
			" AND publish_id=0 AND open_id=0";

	static {
		oldPopularContents = new ArrayList<>();
		veryOldContents = new ArrayList<>();

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(SQL_SELECT_OLD_POPULARS);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				oldPopularContents.add(resultSet.getInt(1));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			statement = connection.prepareStatement(SQL_SELECT_VERY_OLD_CONTENTS);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				veryOldContents.add(resultSet.getInt(1));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
	}

	static public ArrayList<CContent> getContents(int showUserId, int showContentId, int listNum, final CheckLogin checkLogin, Connection connection){
		ArrayList<CContent> contents = new ArrayList<>();
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		if(listNum<1 || showUserId<1 || showContentId<1 || checkLogin==null || connection==null) return contents;
		try {
			CacheUsers0000 users = CacheUsers0000.getInstance();
			List<Integer> contentIds = new ArrayList<>();

			// タグによるおすすめ
			//// showUserIdが他に使っているタグ
			statement = connection.prepareStatement(SQL_SELECT_RECOMMENDED_BY_TAG);
			statement.setInt(1, showUserId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				contentIds.add(resultSet.getInt(1));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// 2〜3ヶ月前のPopular
			List<Integer> oldPopulars = new ArrayList<>(oldPopularContents);
			Collections.shuffle(oldPopulars);
			for (int i=0; i<OLD_CONTENTS_LIMIT && i<oldPopulars.size(); i++) {
				contentIds.add(oldPopulars.get(i));
			}

			// 300日前のランダム
			List<Integer> veryOlds = new ArrayList<>(veryOldContents);
			Collections.shuffle(veryOlds);
			for (int i=0; i<OLD_CONTENTS_LIMIT && i<veryOlds.size(); i++) {
				contentIds.add(veryOlds.get(i));
			}

			if (contentIds.isEmpty()) return contents;

			Collections.shuffle(contentIds);
			String selectContentIds = contentIds.stream()
					.distinct()
					.map(Object::toString)
					.collect(Collectors.joining(",", "(", ")"));

			strSql = "SELECT * FROM contents_0000 WHERE" +
					" content_id IN " + selectContentIds +
					" AND publish_id=0 AND open_id=0";

			if(checkLogin.m_bLogin) {
				strSql += " AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) "
						+ " AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ";
			}
			strSql += " LIMIT ?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			if(checkLogin.m_bLogin) {
				statement.setInt(idx++, checkLogin.m_nUserId);
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			statement.setInt(idx++, listNum);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_cUser.m_strNickName	= Util.toString(user.nickName);
				content.m_cUser.m_strFileName	= Util.toString(user.fileName);
				if(content.m_cUser.m_strFileName.isEmpty()) content.m_cUser.m_strFileName="/img/default_user.jpg";
				contents.add(content);
			}

		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
		}
		return contents;
	}
}

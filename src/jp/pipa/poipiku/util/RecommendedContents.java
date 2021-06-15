package jp.pipa.poipiku.util;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CTag;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.cache.CacheUsers0000;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

public final class RecommendedContents {
	static public ArrayList<CContent> getContents(int showUserId, int showContentId, int listNum, CheckLogin checkLogin, Connection connection){
		ArrayList<CContent> contents = new ArrayList<>();
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		if(listNum<1 || showUserId<1 || showContentId<1 || checkLogin==null || connection==null) return contents;
		try {
			CacheUsers0000 users = CacheUsers0000.getInstance();
			List<Integer> contentIds = new ArrayList<>();

//			long start;
//			start = System.currentTimeMillis();
			// タグによるおすすめ
			//// showUserIdが他に使っているタグ
			strSql = "WITH recommended_tags AS (" +
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
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, showUserId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				contentIds.add(resultSet.getInt(1));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
//			Log.d(String.format("RecommendedContents タグによるおすすめ: %d", System.currentTimeMillis() - start));

//			start = System.currentTimeMillis();
			// いま〜3ヶ月前のPopular
			strSql = "SELECT content_id" +
					" FROM rank_contents_total" +
					" WHERE add_date BETWEEN NOW() - INTERVAL '3 month' AND NOW() - INTERVAL '2 month'" +
					" ORDER BY RANDOM()" +
					" LIMIT 30;";
			statement = connection.prepareStatement(strSql);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				contentIds.add(resultSet.getInt(1));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
//			Log.d(String.format("RecommendedContents いま〜3ヶ月前のPopular: %d", System.currentTimeMillis() - start));


//			start = System.currentTimeMillis();
			// 300日前のランダム
			strSql = String.format("SELECT content_id" +
					" FROM contents_0000" +
					" WHERE upload_date" +
					"    BETWEEN NOW() - INTERVAL '%d days' AND NOW() - INTERVAL '%d days'" +
					" ORDER BY RANDOM()" +
					" LIMIT 30", 300, 300-1);
			statement = connection.prepareStatement(strSql);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				contentIds.add(resultSet.getInt(1));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
//			Log.d(String.format("RecommendedContents 300日以上前のランダム: %d", System.currentTimeMillis() - start));

			if (contentIds.isEmpty()) return contents;

//			start = System.currentTimeMillis();
			Collections.shuffle(contentIds);
			String selectContentIds = contentIds.stream()
					.distinct()
					.map(Object::toString)
					.collect(Collectors.joining(",", "(", ")"));

			strSql = "SELECT * FROM contents_0000 WHERE" +
					" content_id IN " + selectContentIds +
					" AND publish_id=0";

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
			resultSet.close();resultSet=null;
			statement.close();statement=null;
//			Log.d(String.format("RecommendedContents コンテンツ取得: %d", System.currentTimeMillis() - start));

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

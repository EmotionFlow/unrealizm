package jp.pipa.poipiku.util;

import jp.pipa.poipiku.CUser;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.cache.CacheUsers0000;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

public final class RecommendedUsers {
	static public ArrayList<CUser> getUnFollowedUsers(int listNum, CheckLogin checkLogin, Connection connection){
		ArrayList<CUser> unFollowedUsers = new ArrayList<>();
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		if(listNum<1 || checkLogin==null || connection==null) return unFollowedUsers;
		try {
			CacheUsers0000 cacheUsers = CacheUsers0000.getInstance();
			List<Integer> userIds = new ArrayList<>();

			// ツイッターでフォローしているが、ポイピクでフォローしていないユーザー
			strSql = "WITH poi AS (" +
					"    SELECT follow_user_id" +
					"    FROM follows_0000" +
					"    WHERE user_id = ?" +
					" )," +
					" tw AS (" +
					"    SELECT follow_user_id" +
					"    FROM twitter_friends" +
					"    WHERE user_id = ?" +
					"      AND follow_user_id IS NOT NULL" +
					" )" +
					" SELECT *" +
					" FROM tw" +
					"    LEFT JOIN poi ON tw.follow_user_id = poi.follow_user_id" +
					" WHERE poi.follow_user_id IS NULL";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setInt(2, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				userIds.add(resultSet.getInt(1));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// vw_hot_contents_hourの作者のうち、閉じていないコンテンツが多いクリエイター
			strSql = "SELECT user_id" +
					" FROM contents_0000" +
					" WHERE user_id IN (SELECT user_id FROM vw_hot_contents_hour)" +
					"  AND publish_id BETWEEN 0 AND 3" +
					" GROUP BY user_id" +
					" HAVING COUNT(*)>2" +
					" ORDER BY RANDOM()" +
					" LIMIT 20";
			statement = connection.prepareStatement(strSql);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				userIds.add(resultSet.getInt(1));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			List<Integer> selectUserIds = userIds.stream()
					.distinct()
					.collect(Collectors.toList());
			Collections.shuffle(selectUserIds);

			// 上記のうち、ブロックしてる・されている・フォロー済みユーザー
			List<Integer> skipUsers = new ArrayList<>();
			strSql = "select block_user_id as uid from blocks_0000 where user_id=?" +
					" union all" +
					" select user_id as uid from blocks_0000 where block_user_id=?" +
					" union all " +
					" select follow_user_id as uid from follows_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setInt(2, checkLogin.m_nUserId);
			statement.setInt(3, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				skipUsers.add(resultSet.getInt(1));
			}

			for (Integer uid : selectUserIds) {
				if (uid == checkLogin.m_nUserId || skipUsers.contains(uid)){
					continue;
				}
				CacheUsers0000.User cacheUser = cacheUsers.getUser(uid);
				if (cacheUser == null) continue;
				CUser u = new CUser(cacheUser);
				unFollowedUsers.add(u);
				if (unFollowedUsers.size()>=listNum) break;
			}
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
		}
		return unFollowedUsers;
	}

	static public ArrayList<CUser> getRequestCreators(int listNum, CheckLogin checkLogin, Connection connection){
		ArrayList<CUser> requestCreators = new ArrayList<>();
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		if(listNum<1 || checkLogin==null || connection==null) return requestCreators;
		try {
			CacheUsers0000 cacheUsers = CacheUsers0000.getInstance();
			List<Integer> userIds = new ArrayList<>();

			// フォロー済みで最近リクエスト受付をはじめたユーザー
			strSql = "SELECT rc.user_id" +
					" FROM request_creators rc" +
					"   INNER JOIN follows_0000 f ON rc.user_id = f.follow_user_id" +
					" WHERE f.user_id = ? AND rc.status=2" +
					" ORDER BY rc.id DESC" +
					" LIMIT 20";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				userIds.add(resultSet.getInt(1));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// 最近リクエスト受付をはじめたユーザー
			strSql = "SELECT user_id" +
					" FROM request_creators" +
					" WHERE status=2" +
					" ORDER BY id DESC" +
					" LIMIT 10";
			statement = connection.prepareStatement(strSql);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				userIds.add(resultSet.getInt(1));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			List<Integer> selectUserIds = userIds.stream()
					.distinct()
					.collect(Collectors.toList());
			Collections.shuffle(selectUserIds);

			// ブロックしていない・されていないユーザー
			List<Integer> skipUsers = new ArrayList<>();
			strSql = "select block_user_id as uid from blocks_0000 where user_id=?" +
					" union all" +
					" select user_id as uid from blocks_0000 where block_user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setInt(2, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				skipUsers.add(resultSet.getInt(1));
			}

			for (Integer uid : selectUserIds) {
				if (uid == checkLogin.m_nUserId || skipUsers.contains(uid)){
					continue;
				}
				CacheUsers0000.User cacheUser = cacheUsers.getUser(uid);
				if (cacheUser == null) continue;
				CUser u = new CUser(cacheUser);
				requestCreators.add(u);
				if (requestCreators.size()>=listNum) break;
			}
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
		}
		return requestCreators;
	}

}

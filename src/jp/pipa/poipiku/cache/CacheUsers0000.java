package jp.pipa.poipiku.cache;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.concurrent.ConcurrentHashMap;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import jp.pipa.poipiku.CUser;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class CacheUsers0000 {
	private static final ConcurrentHashMap<String, User> mapHashPass = new ConcurrentHashMap<String, User>();
	private static final ConcurrentHashMap<Integer,  User> mapUserId = new ConcurrentHashMap<Integer, User>();

	public static class InstanceHolder {
		private static final CacheUsers0000 instance = new CacheUsers0000();
	}

	private CacheUsers0000() {}

	public static CacheUsers0000 getInstance() {
		return InstanceHolder.instance;
	}

	public void init(){
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		try{
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();
			strSql = "SELECT * FROM users_0000 ORDER BY user_id DESC OFFSET ? LIMIT 10000";
			statement = connection.prepareStatement(strSql);
			for(int offset=0; offset<10; offset++) {
				statement.setInt(1, offset);
				resultSet = statement.executeQuery();
				while(resultSet.next()) {
					User user = new User(resultSet);
					mapHashPass.putIfAbsent(user.hashPass, user);
					mapUserId.putIfAbsent(user.userId, user);
				}
				resultSet.close();resultSet=null;
			}
			statement.close();statement=null;
			//Log.d("Load all user data");
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null)resultSet.close();resultSet=null;}catch(Exception e){;}
			try{if(statement!=null)statement.close();statement=null;}catch(Exception e){;}
			try{if(connection!=null)connection.close();connection=null;}catch(Exception e){;}
		}
		return;
	}

	public User getUser(String hashPassword) {
		if(hashPassword==null || hashPassword.isEmpty()) return null;

		final int UPDATE_INTERVAL = 60*60*1000; //	1時間

		User user = mapHashPass.get(hashPassword);
		Long timeNow = System.currentTimeMillis();

		if(user!=null && user.lastLogin>=timeNow-UPDATE_INTERVAL) {
			//Log.d("From Hash Cache");
			return user;
		}

		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		try{
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();
			if(user==null) {
				strSql = "SELECT * FROM users_0000 WHERE hash_password=?";
				statement = connection.prepareStatement(strSql);
				statement.setString(1, hashPassword);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					user = new User(resultSet);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
				//Log.d("From Hash DB");
			}
			if(user!=null) {
				if(user.lastLogin<timeNow-UPDATE_INTERVAL) {
					strSql = "UPDATE users_0000 SET last_login_date=current_timestamp-interval '1 minute' WHERE user_id=?";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, user.userId);
					statement.executeUpdate();
					statement.close();statement=null;
					user.lastLogin = timeNow;
				}
				mapHashPass.putIfAbsent(hashPassword, user);
				mapUserId.putIfAbsent(user.userId, user);
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null)resultSet.close();resultSet=null;}catch(Exception e){;}
			try{if(statement!=null)statement.close();statement=null;}catch(Exception e){;}
			try{if(connection!=null)connection.close();connection=null;}catch(Exception e){;}
		}
		return user;
	}

	public User getUser(int userId) {
		if(userId<=0) return null;

		final int UPDATE_INTERVAL = 60*60*1000; //	1時間

		User user = mapUserId.get(userId);
		Long timeNow = System.currentTimeMillis();

		if(user!=null && user.lastLogin>=timeNow-UPDATE_INTERVAL) {
			//Log.d("From ID Cache");
			return user;
		}

		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		try{
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();
			if(user==null) {
				strSql = "SELECT * FROM users_0000 WHERE user_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, userId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					user = new User(resultSet);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
				//Log.d("From ID DB");
			}
			if(user!=null) {
				if(user.lastLogin<timeNow-UPDATE_INTERVAL) {
					strSql = "UPDATE users_0000 SET last_login_date=current_timestamp-interval '1 minute' WHERE user_id=?";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, user.userId);
					statement.executeUpdate();
					statement.close();statement=null;
					user.lastLogin = timeNow;
				}
				mapUserId.putIfAbsent(userId, user);
				mapHashPass.putIfAbsent(user.hashPass, user);
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null)resultSet.close();resultSet=null;}catch(Exception e){;}
			try{if(statement!=null)statement.close();statement=null;}catch(Exception e){;}
			try{if(connection!=null)connection.close();connection=null;}catch(Exception e){;}
		}
		return user;
	}

	public void clearUser(String hashPassword) {
		//Log.d("Clear Cache By Hash");
		User user = mapHashPass.remove(hashPassword);
		if(user==null) return;
		mapUserId.remove(user.userId);
	}

	public void clearUser(int userId) {
		//Log.d("Clear Cache By UserId");
		User user = mapUserId.remove(userId);
		if(user==null) return;
		mapHashPass.remove(user.hashPass);
	}

	public class User {
		public int userId = -1;
		public String nickName = "no name";
		public String hashPass = "";
		public int safeFilter = Common.SAFE_FILTER_R18;
		public int langId = 0;
		public String fileName = "";
		public boolean emailValid = false;
		public int passportId = Common.PASSPORT_OFF;
		public long lastLogin = -1;
		public int reaction = CUser.REACTION_SHOW;
		public int adMode = CUser.AD_MODE_HIDE;

		public User() {}
		public User(ResultSet resultSet) throws SQLException {
			userId		= resultSet.getInt("user_id");
			hashPass	= resultSet.getString("hash_password");
			nickName	= resultSet.getString("nickname");
			langId		= Math.min(Math.max(resultSet.getInt("lang_id"), 0), 1);
			lastLogin	= resultSet.getTimestamp("last_login_date").getTime();
			fileName	= Util.toString(resultSet.getString("file_name"));
			if(fileName.isEmpty()) fileName = "/img/default_user.jpg";
			emailValid	= Util.toString(resultSet.getString("email")).contains("@");
			passportId	= resultSet.getInt("passport_id");
			reaction	= resultSet.getInt("ng_reaction");
			adMode		= resultSet.getInt("ng_ad_mode");
			if(userId==315) safeFilter = Common.SAFE_FILTER_ALL;
		}
	}
}

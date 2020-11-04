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
	private static final ConcurrentHashMap<String, User> m_mapHashPass = new ConcurrentHashMap<String, User>();
	private static final ConcurrentHashMap<Integer,  User> m_mapUserId = new ConcurrentHashMap<Integer, User>();

	public static class InstanceHolder {
		private static final CacheUsers0000 INSTANCE = new CacheUsers0000();
	}

	private CacheUsers0000() {}

	public static CacheUsers0000 getInstance() {
		return InstanceHolder.INSTANCE;
	}

	public void init(){
	}

	public User getUser(String hashPassword) {
		if(hashPassword==null) return null;

		final int UPDATE_INTERVAL = 60*60*1000; //	1時間

		User user = m_mapHashPass.get(hashPassword);
		Long timeNow = System.currentTimeMillis();

		if(user!=null && user.m_lnLastLogin>=timeNow-UPDATE_INTERVAL) {
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
				if(user.m_lnLastLogin<timeNow-UPDATE_INTERVAL) {
					strSql = "UPDATE users_0000 SET last_login_date=current_timestamp-interval '1 minute' WHERE user_id=?";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, user.m_nUserId);
					statement.executeUpdate();
					statement.close();statement=null;
					user.m_lnLastLogin = timeNow;
				}
				m_mapHashPass.putIfAbsent(hashPassword, user);
				m_mapUserId.putIfAbsent(user.m_nUserId, user);
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

		User user = m_mapUserId.get(userId);
		Long timeNow = System.currentTimeMillis();

		if(user!=null && user.m_lnLastLogin>=timeNow-UPDATE_INTERVAL) {
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
				if(user.m_lnLastLogin<timeNow-UPDATE_INTERVAL) {
					strSql = "UPDATE users_0000 SET last_login_date=current_timestamp-interval '1 minute' WHERE user_id=?";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, user.m_nUserId);
					statement.executeUpdate();
					statement.close();statement=null;
					user.m_lnLastLogin = timeNow;
				}
				m_mapUserId.putIfAbsent(userId, user);
				m_mapHashPass.putIfAbsent(user.m_strHashPass, user);
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
		User user = m_mapHashPass.remove(hashPassword);
		if(user==null) return;
		m_mapUserId.remove(user.m_nUserId);
	}

	public void clearUser(int userId) {
		//Log.d("Clear Cache By UserId");
		User user = m_mapUserId.remove(userId);
		if(user==null) return;
		m_mapHashPass.remove(user.m_strHashPass);
	}

	public class User {
		public int m_nUserId = -1;
		public String m_strNickName = "no name";
		public String m_strHashPass = "";
		public int m_nSafeFilter = Common.SAFE_FILTER_R18;
		public int m_nLangId = 0;
		public String m_strFileName = "";
		public boolean m_bEmailValid = false;
		public int m_nPremiumId = CUser.PREMIUM_OFF;
		public long m_lnLastLogin = -1;
		public int m_nReaction = CUser.REACTION_SHOW;

		public User() {}
		public User(ResultSet resultSet) throws SQLException {
			m_nUserId		= resultSet.getInt("user_id");
			m_strHashPass	= resultSet.getString("hash_password");
			m_strNickName	= resultSet.getString("nickname");
			m_nLangId		= Math.min(Math.max(resultSet.getInt("lang_id"), 0), 1);
			m_lnLastLogin	= resultSet.getTimestamp("last_login_date").getTime();
			m_strFileName	= Util.toString(resultSet.getString("file_name"));
			if(m_strFileName.isEmpty()) m_strFileName = "/img/default_user.jpg";
			m_bEmailValid	= Util.toString(resultSet.getString("email")).contains("@");
			m_nPremiumId	= resultSet.getInt("premiun_id");
			m_nReaction		= resultSet.getInt("ng_reaction");
			if(m_nUserId==315) m_nSafeFilter = Common.SAFE_FILTER_ALL;
		}
	}
}

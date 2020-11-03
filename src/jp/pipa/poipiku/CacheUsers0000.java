package jp.pipa.poipiku;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.concurrent.ConcurrentHashMap;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class CacheUsers0000 {
	private ConcurrentHashMap<String, User> m_mapAccess = new ConcurrentHashMap<String, User>();

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
		final int UPDATE_INTERVAL = 60*60*1000; //	1時間
		User user = null;
		user = m_mapAccess.get(hashPassword);
		Long timeNow = System.currentTimeMillis();

		if(user!=null && user.m_lnLastLogin>=timeNow-UPDATE_INTERVAL) {
			//Log.d("From Cache");
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
				m_mapAccess.putIfAbsent(hashPassword, user);
				//Log.d("From DB");
			}
			if(user!=null && user.m_lnLastLogin<timeNow-UPDATE_INTERVAL) {
				strSql = "UPDATE users_0000 SET last_login_date=current_timestamp-interval '1 minute' WHERE user_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, user.m_nUserId);
				statement.executeUpdate();
				statement.close();statement=null;
				user.m_lnLastLogin = timeNow;
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
		m_mapAccess.remove(hashPassword);
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

		public User() {}
		public User(ResultSet resultSet) throws SQLException {
			m_nUserId		= resultSet.getInt("user_id");
			m_strNickName	= resultSet.getString("nickname");
			m_nLangId		= Math.min(Math.max(resultSet.getInt("lang_id"), 0), 1);
			m_lnLastLogin	= resultSet.getTimestamp("last_login_date").getTime();
			m_strFileName	= Util.toString(resultSet.getString("file_name"));
			if(m_strFileName.isEmpty()) m_strFileName = "/img/default_user.jpg";
			m_bEmailValid	= Util.toString(resultSet.getString("email")).contains("@");
			m_nPremiumId	= resultSet.getInt("premiun_id");
			if(m_nUserId==315) m_nSafeFilter = Common.SAFE_FILTER_ALL;
		}
	}
}

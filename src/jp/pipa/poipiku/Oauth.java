package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Oauth extends Model{
	public int poipikuUserId;
	public String twitterUserId;
	public String accessToken;
	public String tokenSecret;
	public String twitterScreenName;
	public boolean delFlg;

	public Oauth(){}
	public Oauth(ResultSet resultSet) throws SQLException {
		errorKind = ErrorKind.DbError;
		poipikuUserId = resultSet.getInt("flduserid");
		twitterUserId = resultSet.getString("twitter_user_id");
		accessToken = resultSet.getString("fldaccesstoken");
		tokenSecret = resultSet.getString("fldsecrettoken");
		twitterScreenName = resultSet.getString("twitter_screen_name");
		delFlg = resultSet.getBoolean("del_flg");
		errorKind = ErrorKind.None;
	}

	//
	public static boolean activatePoipikuUser(String twitterUserId, int activatePoipikuUserId) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();

			connection.setAutoCommit(false);
			strSql = "UPDATE tbloauth SET del_flg=true WHERE twitter_user_id=? AND fldproviderid=?";
			statement = connection.prepareStatement(strSql);
			statement.setString(1, twitterUserId);
			statement.setInt(2, Common.TWITTER_PROVIDER_ID);
			statement.executeUpdate();
			statement.close();statement = null;

			strSql = "UPDATE tbloauth SET del_flg=false WHERE flduserid=? AND twitter_user_id=? AND fldproviderid=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, activatePoipikuUserId);
			statement.setString(2, twitterUserId);
			statement.setInt(3, Common.TWITTER_PROVIDER_ID);
			statement.executeUpdate();
			statement.close();statement = null;
			connection.commit();


			return true;
		} catch (SQLException e) {
			Log.d(strSql);
			e.printStackTrace();
			return false;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
	}
}

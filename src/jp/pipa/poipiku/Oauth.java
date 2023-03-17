package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
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

	/**
	 * twitterUserIdとpoipikuUserIdを関連づける。
	 * 同一twitterUserIdで複数レコードあったら、その内poipikuUserIdのみを有効化する。
	 * 同一twitterUserId, poipikuUserIdで複数レコードあったら、idが新しいものを有効化する。
	 * @param twitterUserId twitter user id
	 * @param poipikuUserId poipiku user id
	 * @return result
	 */
	public static boolean connectUnrealizmUser(String twitterUserId, int poipikuUserId) {
		Connection connection = null;
		PreparedStatement statement = null;
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

			strSql = "UPDATE tbloauth SET del_flg=false WHERE id=(SELECT id FROM tbloauth WHERE flduserid=? AND twitter_user_id=? AND fldproviderid=? ORDER BY id DESC limit 1)";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, poipikuUserId);
			statement.setString(2, twitterUserId);
			statement.setInt(3, Common.TWITTER_PROVIDER_ID);
			statement.executeUpdate();
			connection.commit();
			statement.close();statement = null;

			return true;
		} catch (SQLException e) {
			Log.d(strSql);
			e.printStackTrace();
			try{if(connection!=null){connection.rollback();}}catch(SQLException ignore){}
			return false;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.setAutoCommit(true); connection.close();connection=null;}}catch(Exception e){;}
		}
	}
}

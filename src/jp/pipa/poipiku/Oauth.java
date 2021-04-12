package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;

public class Oauth extends Model{
	public int poipikuUserId;
	public String twitterUserId;
	public String accessToken;
	public String tokenSecret;
	public String twitterScreenName;
	public boolean delFlg;

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
}

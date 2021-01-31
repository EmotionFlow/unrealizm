package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import jp.pipa.poipiku.util.Util;

public class Genre {
	public int genreId = -1;
	public String genreImage = "/img/default_genre.png";
	public String genreImageBg = "";
	public int createUserId = -1;
	public Timestamp updateDate = new Timestamp(0);
	public String genreName = "";
	public String genreDesc = "";
	public String genreDetail = "";
	public int contentNumTotal = -1;
	public int contentNumWeek = -1;
	public int contentNumDay = -1;
	public int favoNum = -1;

	public Genre() {}
	public Genre(ResultSet resultSet) throws SQLException {
		genreId			= resultSet.getInt("genre_id");
		genreImage		= Util.toString(resultSet.getString("genre_image"));
		genreImageBg	= Util.toString(resultSet.getString("genre_image_bg"));
		createUserId	= resultSet.getInt("create_user_id");
		updateDate		= resultSet.getTimestamp("update_date");
		genreName		= Util.toString(resultSet.getString("genre_name"));
		genreDesc		= Util.toString(resultSet.getString("genre_desc"));
		genreDetail		= Util.toString(resultSet.getString("genre_detail"));
		contentNumTotal	= resultSet.getInt("content_num_total");
		contentNumWeek	= resultSet.getInt("content_num_week");
		contentNumDay	= resultSet.getInt("content_num_day");
		favoNum			= resultSet.getInt("favo_num");
		if(genreImage.isEmpty()) genreImage="/img/default_genre.png";
	}
}

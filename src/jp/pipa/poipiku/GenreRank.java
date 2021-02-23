package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;

import jp.pipa.poipiku.util.Util;

public class GenreRank extends Genre {
	public int rank = 0;

	public GenreRank() {}
	public GenreRank(ResultSet resultSet) throws SQLException {
		genreId			= resultSet.getInt("genre_id");
		genreImage		= Util.toString(resultSet.getString("genre_image"));
		genreImageBg	= Util.toString(resultSet.getString("genre_image_bg"));
		createUserId	= resultSet.getInt("create_user_id");
		updateDate		= resultSet.getTimestamp("update_date");
		genreName		= Util.toString(resultSet.getString("genre_name"));
		genreDesc		= Util.toString(resultSet.getString("genre_desc"));
		genreDetail		= Util.toString(resultSet.getString("genre_detail"));
		rank			= Math.max(resultSet.getInt("rank"), 0);
		if(genreImage.isEmpty()) genreImage="/img/default_genre.png";
	}
}

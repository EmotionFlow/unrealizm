package jp.pipa.poipiku.controller;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;

import javax.imageio.ImageIO;
import javax.naming.InitialContext;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import org.apache.tomcat.util.codec.binary.Base64;


import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.Genre;
import jp.pipa.poipiku.util.ImageUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class UpdateGenreFileC {
	public static final int OK_PARAM = 0;
	public static final int OK_EDIT = 0;
	public static final int ERR_NOT_LOGIN = -1;
	public static final int ERR_FILE_SIZE = -2;
	public static final int ERR_FILE_TYPE = -3;
	public static final int ERR_NOT_PASSPORT = -4;
	public static final int ERR_UNKNOWN = -99;

	public static final int IMAGE_WIDTH_NORMAL = 120;
	public static final int IMAGE_WIDTH_SMALL = 40;

	private final String[] FILE_TYPE = {"icon", "bg"};
	private final String[] COLUMN = {"genre_image", "genre_image_bg"};

	public int userId = -1;
	public int genreId = -1;
	public String encodeImg = "";
	public int type = -1;

	public int getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("UID"));
			genreId = Util.toInt(request.getParameter("GID"));
			encodeImg = Common.TrimAll(Common.CrLfInjection(Common.EscapeInjection(request.getParameter("DATA"))));
			type = Util.toInt(request.getParameter("TY"));
		} catch (Exception e) {
			userId = -1;
			genreId = -1;
			type = -1;
			return ERR_UNKNOWN;
		}
		return OK_PARAM;
	}

	public int getResults(CheckLogin checkLogin, ServletContext context) {
		if(!checkLogin.m_bLogin || checkLogin.m_nUserId!= userId) return ERR_NOT_LOGIN;
		//if(checkLogin.m_nPassportId<=Common.PASSPORT_OFF) return ERR_NOT_PASSPORT;
		if(type<0 || type>=COLUMN.length) return ERR_UNKNOWN;


		int nRtn = ERR_UNKNOWN;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			byte[] imageBinary = Base64.decodeBase64(encodeImg.getBytes());
			if(imageBinary == null) return ERR_FILE_TYPE;
			if(imageBinary.length>1024*1024*5) return ERR_FILE_SIZE;
			BufferedImage cImage = ImageIO.read(new ByteArrayInputStream(imageBinary));
			if(cImage == null) return ERR_FILE_TYPE;

			// check ext
			String ext = ImageUtil.getExt(ImageIO.createImageInputStream(new ByteArrayInputStream(imageBinary)));
			if((!ext.equals("jpeg")) && (!ext.equals("jpg")) && (!ext.equals("gif")) && (!ext.equals("png"))) {
				Log.d("main item type error");
				return ERR_FILE_TYPE;
			}

			// initialize DB
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// get|generate genre id
			Genre genre = Util.getGenre(genreId);
			if(genre.genreId<1) {
				strSql = "INSERT INTO genres(create_user_id, genre_name) VALUES(?, ?) RETURNING genre_id ";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, checkLogin.m_nUserId);
				statement.setString(2, "");
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					genreId = resultSet.getInt("genre_id");
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
				if(genreId<1) return ERR_UNKNOWN;
				genre = Util.getGenre(genreId);
			}

			// save file
			File cDir = new File(context.getRealPath(Util.getUploadGenrePath()));
			if(!cDir.exists()) {
				cDir.mkdirs();
			}
			String strFileName = String.format("%s/genre_%09d_%s_%s.%s",
					Util.getUploadGenrePath(),
					genreId,
					FILE_TYPE[type],
					(new SimpleDateFormat("YYYYMMddHHmmss")).format(new java.util.Date()),
					ext);
			String strRealFileName = context.getRealPath(strFileName);

			FileOutputStream output = new FileOutputStream(strRealFileName);
			output.write(imageBinary);
			output.flush();
			output.close();
			if(type==0) {
				ImageUtil.createThumbNormalize(strRealFileName, strRealFileName+"_40.jpg", IMAGE_WIDTH_SMALL, true);
			}

			// update making last_update
			strSql = String.format("UPDATE genres SET %s=?, update_date=CURRENT_TIMESTAMP WHERE genre_id=?",
					COLUMN[type]);
			statement = connection.prepareStatement(strSql);
			statement.setString(1, strFileName);
			statement.setInt(2, genreId);
			statement.executeUpdate();
			statement.close();statement=null;

			strSql = "REFRESH MATERIALIZED VIEW CONCURRENTLY vw_rank_genre_total;" +
			"REFRESH MATERIALIZED VIEW CONCURRENTLY vw_rank_genre_daily;" +
			"REFRESH MATERIALIZED VIEW CONCURRENTLY vw_rank_genre_weekly;";
			statement = connection.prepareStatement(strSql);
			statement.executeUpdate();
			statement.close();statement=null;

			nRtn = OK_EDIT;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}

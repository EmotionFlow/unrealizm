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
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.ImageUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class UpdateProfileFileC {
	public int m_nUserId = -1;
	public String m_strEncodeImg = "";

	public int GetParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId = Util.toInt(request.getParameter("UID"));
			m_strEncodeImg = Common.TrimAll(Common.CrLfInjection(Common.EscapeInjection(request.getParameter("DATA"))));
		} catch (Exception e) {
			m_nUserId = -1;
			return -99;
		}
		return 0;
	}

	public int GetResults(CheckLogin checkLogin, ServletContext context) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			byte[] imageBinary = Base64.decodeBase64(m_strEncodeImg.getBytes());
			if (imageBinary == null)
				return nRtn;
			if (imageBinary.length > 1024 * 1024 * 5)
				return nRtn;
			BufferedImage cImage = ImageIO.read(new ByteArrayInputStream(imageBinary));
			if (cImage == null)
				return nRtn;

			// check ext
			String ext = ImageUtil.getExt(ImageIO.createImageInputStream(new ByteArrayInputStream(imageBinary)));
			if ((!ext.equals("jpeg")) && (!ext.equals("jpg")) && (!ext.equals("gif")) && (!ext.equals("png"))) {
				Log.d("main item type error");
				return nRtn;
			}

			// save file
			File cDir = new File(context.getRealPath(Common.getUploadUserPath(m_nUserId)));
			if (!cDir.exists()) {
				cDir.mkdirs();
			}
			String strFileName = String.format("%s/profile_%s.%s", Common.getUploadUserPath(m_nUserId),
					(new SimpleDateFormat("YYYYMMddHHmmss")).format(new java.util.Date()), ext);
			String strRealFileName = context.getRealPath(strFileName);
			// ImageIO.write(cImage, "png", new File(strRealFileName));
			FileOutputStream output = new FileOutputStream(strRealFileName);
			output.write(imageBinary);
			output.flush();
			output.close();
			ImageUtil.createThumbProfile(strRealFileName);

			// regist to DB
			dsPostgres = (DataSource) new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// update making last_update
			strSql = "UPDATE users_0000 SET file_name=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strFileName);
			cState.setInt(2, m_nUserId);
			cState.executeUpdate();
			cState.close();
			cState = null;
			CacheUsers0000.getInstance().clearUser(checkLogin.m_strHashPass);
			nRtn = 0;
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}

}

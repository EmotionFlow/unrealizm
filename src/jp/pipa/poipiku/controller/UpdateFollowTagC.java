package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.Genre;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public final class UpdateFollowTagC {
	public static final int FAVO_MAX = 15;
	public static final int OK_INSERT = 1;
	public static final int OK_DELETE = 0;
	public static final int ERR_NOT_LOGIN = -1;
	public static final int ERR_MAX = -2;
	public static final int ERR_UNKNOWN = -99;

	public int m_nUserId = -1;
	public String m_strTagTxt = "";
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId	= Util.toInt(request.getParameter("UID"));
			m_strTagTxt	= Common.TrimAll(request.getParameter("TXT"));
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public int m_nContentsNum = 0;
	public int getResults(CheckLogin checkLogin) {
		if(m_strTagTxt.isEmpty()) return ERR_UNKNOWN;
		Genre genre = Util.getGenre(m_strTagTxt);
		if(genre.genreId<0) return ERR_UNKNOWN;

		int nRtn = ERR_UNKNOWN;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			cConn = DatabaseUtil.dataSource.getConnection();

			boolean bFollowing = false;
			// now following check
			strSql ="SELECT * FROM follow_tags_0000 WHERE user_id=? AND genre_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.setInt(2, genre.genreId);
			cResSet = cState.executeQuery();
			bFollowing = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			if(!bFollowing) {
				strSql = "SELECT count(*) FROM follow_tags_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, checkLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
				if(m_nContentsNum>=FAVO_MAX) return ERR_MAX;

				strSql ="INSERT INTO follow_tags_0000(user_id, tag_txt, genre_id) VALUES(?, ?, ?)";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nUserId);
				cState.setString(2, m_strTagTxt);
				cState.setInt(3, genre.genreId);
				cState.executeUpdate();
				cState.close();cState=null;
				nRtn = OK_INSERT;
			} else {
				strSql ="DELETE FROM follow_tags_0000 WHERE user_id=? AND genre_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nUserId);
				cState.setInt(2, genre.genreId);
				cState.executeUpdate();
				cState.close();cState=null;
				nRtn = OK_DELETE;
			}
		} catch(Exception e) {
			e.printStackTrace();
			nRtn = ERR_UNKNOWN;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception ignored){}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception ignored){}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception ignored){}
		}
		return nRtn;
	}
}
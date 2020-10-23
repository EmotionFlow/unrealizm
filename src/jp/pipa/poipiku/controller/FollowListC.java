package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class FollowListC {
	public static int MODE_FOLLOW = 0;
	public static int MODE_BLOCK = 1;

	public int m_nMode = -1;
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nMode = Math.max(Util.toInt(cRequest.getParameter("MD")), MODE_FOLLOW);
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 36;
	public ArrayList<CUser> m_vContentList = new ArrayList<CUser>();
	public int m_nContentsNum = 0;

	public boolean getResults(CheckLogin cCheckLogin) {
		return getResults(cCheckLogin, false);
	}

	public boolean getResults(CheckLogin cCheckLogin, boolean bContentOnly) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// NEW ARRIVAL
			if(!bContentOnly) {
				if(m_nMode==MODE_FOLLOW) {
					strSql = "SELECT count(*) FROM follows_0000 WHERE user_id=?";
				} else {
					strSql = "SELECT count(*) FROM blocks_0000 WHERE user_id=?";
				}
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cCheckLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			if(m_nMode==MODE_FOLLOW) {
				strSql = "SELECT follow_user_id, nickname, file_name FROM follows_0000 INNER JOIN users_0000 ON follows_0000.follow_user_id=users_0000.user_id WHERE follows_0000.user_id=? ORDER BY upload_date DESC OFFSET ? LIMIT ?";
			} else {
				strSql = "SELECT block_user_id as follow_user_id, nickname, file_name FROM blocks_0000 INNER JOIN users_0000 ON blocks_0000.block_user_id=users_0000.user_id WHERE blocks_0000.user_id=? ORDER BY upload_date DESC OFFSET ? LIMIT ?";
			}
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cCheckLogin.m_nUserId);
			cState.setInt(2, m_nPage * SELECT_MAX_GALLERY);
			cState.setInt(3, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CUser cContent = new CUser();
				cContent.m_nUserId		= cResSet.getInt("follow_user_id");
				cContent.m_strNickName	= Util.toString(cResSet.getString("nickname"));
				cContent.m_strFileName	= Util.toString(cResSet.getString("file_name"));
				if(cContent.m_strFileName.length()<=0) cContent.m_strFileName="/img/default_user.jpg";

				m_vContentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bResult = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bResult;
	}

}

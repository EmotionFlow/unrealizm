package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.CUser;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;

import jp.pipa.poipiku.*;

public class FollowerListC {
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Common.ToInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 30;
	public ArrayList<CUser> m_vContentList = new ArrayList<CUser>();
	public int m_nContentsNum = 0;

	public boolean getResults(CheckLogin cCheckLogin) {
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
			strSql = "SELECT count(*) FROM follows_0000 WHERE follow_user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cCheckLogin.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nContentsNum = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			strSql = "SELECT follows_0000.*, nickname, file_name FROM follows_0000 INNER JOIN users_0000 ON follows_0000.user_id=users_0000.user_id WHERE follows_0000.follow_user_id=? ORDER BY follow_id DESC OFFSET ? LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cCheckLogin.m_nUserId);
			cState.setInt(2, m_nPage * SELECT_MAX_GALLERY);
			cState.setInt(3, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CUser cContent = new CUser();
				cContent.m_nUserId		= cResSet.getInt("user_id");
				cContent.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				cContent.m_strFileName	= Common.ToString(cResSet.getString("file_name"));
				if(cContent.m_strFileName.length()<=0) cContent.m_strFileName="/img/default_user.jpg";

				m_vContentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bResult = true;
		} catch(Exception e) {
			System.out.println(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bResult;
	}
}

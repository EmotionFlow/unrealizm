package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CUser;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.RequestCreator;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public final class PopularRequestCreatorC {
	public int m_nPage = 0;
	public String m_strKeyword = "";
	public void getParam(final HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception e) {
			;
		}
	}

	public int SELECT_MAX_GALLERY = 36;
	public ArrayList<CUser> m_vContentList = new ArrayList<>();
	public int m_nContentsNum = 0;

	public boolean getResults(final CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(final CheckLogin checkLogin, final boolean bContentOnly) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			if(!bContentOnly) {
				// WHERE status IN (2,3)とするか、要検討
				strSql = "WITH request_ranking as (" +
						"    SELECT creator_user_id, count(*) cnt " +
						"    FROM requests GROUP BY creator_user_id " +
						"    ORDER BY cnt DESC LIMIT 500" +
						" )" +
						" SELECT count(*) " +
						" FROM users_0000 u INNER JOIN request_ranking r ON r.creator_user_id=u.user_id" +
						" WHERE u.request_creator_status=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, RequestCreator.Status.Enabled.getCode());
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			strSql = "WITH request_ranking as (" +
					"    SELECT creator_user_id, count(*) cnt " +
					"    FROM requests GROUP BY creator_user_id " +
					"    ORDER BY cnt DESC LIMIT 500" +
					" )" +
					" SELECT u.*, r.cnt request_cnt " +
					" FROM users_0000 u INNER JOIN request_ranking r ON r.creator_user_id=u.user_id" +
					" WHERE u.request_creator_status=?" +
					" ORDER BY request_cnt DESC OFFSET ? LIMIT ?;";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, RequestCreator.Status.Enabled.getCode());
			cState.setInt(2, m_nPage * SELECT_MAX_GALLERY);
			cState.setInt(3, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_vContentList.add(new CUser(cResSet));
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
package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CUser;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class GoToInquiryC {
	public String m_strReturnUrl = "";
	public void GetParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_strReturnUrl = Common.TrimAll(Util.toStringHtml(Common.EscapeInjection(Util.toString(request.getParameter("RET")))));
		}
		catch(Exception e) {
			;
		}
	}

	public CUser m_cUser = new CUser();
	public boolean GetResults(CheckLogin checkLogin) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "SELECT * FROM users_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, checkLogin.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cUser.m_nUserId			= cResSet.getInt("user_id");
				m_cUser.m_strNickName		= Util.toString(cResSet.getString("nickname"));
				m_cUser.m_strEmail			= Util.toStringHtml(cResSet.getString("email"));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			strSql = "SELECT * FROM tbloauth WHERE flduserid=? AND fldproviderid=? AND del_flg=False";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, checkLogin.m_nUserId);
			cState.setInt(2, Common.TWITTER_PROVIDER_ID);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cUser.m_bTweet = true;
				m_cUser.m_strTwitterScreenName = Util.toString(cResSet.getString("twitter_screen_name"));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bRtn = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			bRtn = false;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

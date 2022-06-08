package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CUser;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.ResourceBundleControl;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.EmailUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SendPasswordC {
	public int m_nUserId = -1;
	public String m_strEmail = "";
	public String m_strTwScreenName = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_strEmail = Common.EscapeInjection(Util.toString(request.getParameter("EM"))).toLowerCase();
			m_strTwScreenName = Common.EscapeInjection(Util.toString(request.getParameter("TW"))).toLowerCase();
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public int getResults(CheckLogin checkLogin, ResourceBundleControl _TEX) {
		String subject	= _TEX.T("SendPasswordV.Email.Title");
		String body	= _TEX.T("SendPasswordV.Email.MessageFormat");

		List<CUser> foundUsers = new ArrayList<>();

		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		try{
			cConn = DatabaseUtil.dataSource.getConnection();

			if(!m_strEmail.isEmpty()) {
				strSql = "SELECT user_id, email, password FROM users_0000 WHERE email = ?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, m_strEmail);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CUser user = new CUser();
					user.m_nUserId = cResSet.getInt("user_id");
					user.m_strEmail = cResSet.getString("email");
					user.m_strPassword = Util.toString(cResSet.getString("password"));
					foundUsers.add(user);
				}
				cResSet.close();
				cState.close();
			}
			if(!m_strTwScreenName.isEmpty()) {
				strSql = "SELECT u.user_id, u.email, u.password FROM users_0000 AS u INNER JOIN tbloauth AS a ON u.user_id = a.flduserid WHERE lower(a.twitter_screen_name) = ? AND a.del_flg=false ORDER BY user_id DESC LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, m_strTwScreenName);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CUser user = new CUser();
					user.m_strEmail = cResSet.getString("email");
					if (user.m_strEmail.contains("@")) {
						user.m_nUserId = cResSet.getInt("user_id");
						user.m_strPassword = Util.toString(cResSet.getString("password"));

						// メアドで検索済みだったら、メール送信リストに追加しない。
						boolean bFound = false;
						for(CUser u : foundUsers){
							if(u.m_nUserId==user.m_nUserId){
								bFound = true;
								break;
							}
						}
						if(!bFound){
							foundUsers.add(user);
						}
					}
				}
				cResSet.close();
				cState.close();
			}

			for(CUser u : foundUsers){
				EmailUtil.send(u.m_strEmail, subject, String.format(body, u.m_strPassword));
				Log.d("REMIND MAIL SENT (loginid, userid, email)",
						Integer.toString(m_nUserId),
						Integer.toString(u.m_nUserId),
						u.m_strEmail);
			}
			return foundUsers.size();

		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {if(cResSet != null) cResSet.close();}catch(Exception ignored){;}
			try {if(cState != null) cState.close();}catch(Exception ignored){;}
			try {if(cConn != null) cConn.close();}catch(Exception ignored){;}
		}
		return -1;
	}
}

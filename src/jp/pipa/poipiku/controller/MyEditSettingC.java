package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.Log;

public class MyEditSettingC {
	public String m_strMessage = "";
	public String m_strSelectedMenuId = "";
	public int m_nListPage = 1;
	public String m_strErr="";
	public void GetParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_strMessage = Common.TrimAll(Common.ToStringHtml(Common.EscapeInjection(Common.ToString(request.getParameter("MSG")))));
			m_strSelectedMenuId = Common.TrimAll(Common.ToStringHtml(Common.EscapeInjection(Common.ToString(request.getParameter("MENUID")))));
			m_nListPage = Common.ToIntN(request.getParameter("PG"), 0, 100);
			m_strErr=Common.TrimAll(Common.ToStringHtml(Common.EscapeInjection(Common.ToString(request.getParameter("ERR")))));
		}
		catch(Exception e) {
			;
		}
	}

	public CUser m_cUser = new CUser();
	public boolean m_bUpdate = false;
	public String m_strNewEmail = "";
	public int m_nPublishedContentsTotal = 0;
	public boolean m_bCardInfoExist = false;
	public boolean m_bExchangeCheerPointRequested = false;
	public int m_nCheerPoint = 0;
	public int m_nExchangePoint = 0;
	public int m_nExchangeFee = 0;

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
				m_cUser.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
				m_cUser.m_strProfile		= Common.ToString(cResSet.getString("profile"));
				m_cUser.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
				m_cUser.m_strHeaderFileName	= Common.ToString(cResSet.getString("header_file_name"));
				m_cUser.m_strBgFileName		= Common.ToString(cResSet.getString("bg_file_name"));
				m_cUser.m_nMailComment		= cResSet.getInt("mail_comment");
				m_cUser.m_strEmail			= Common.ToStringHtml(cResSet.getString("email"));
				m_cUser.m_strMuteKeyword	= Common.ToString(cResSet.getString("mute_keyword_list")).trim();
				if(m_cUser.m_strProfile.isEmpty())  m_cUser.m_strProfile = "(no profile)";
				if(m_cUser.m_strFileName.isEmpty()) m_cUser.m_strFileName="/img/default_user.jpg";
				if(m_cUser.m_strHeaderFileName.isEmpty()) m_cUser.m_strHeaderFileName="/img/default_transparency.gif";
				if(m_cUser.m_strBgFileName.isEmpty()) m_cUser.m_strBgFileName="/img/default_transparency.gif";
				m_cUser.m_bDispFollower		= ((m_cUser.m_nMailComment>>>0 & 0x01) == 0x01);
				m_cUser.m_bDispR18			= ((m_cUser.m_nMailComment>>>1 & 0x01) == 0x01);
				//m_cUser.m_bMailBookmark	= ((m_cUser.m_nMailComment>>>2 & 0x01) == 0x01);
				//m_cUser.m_bMailFollow		= ((m_cUser.m_nMailComment>>>3 & 0x01) == 0x01);
				//m_cUser.m_bMailMessage	= ((m_cUser.m_nMailComment>>>4 & 0x01) == 0x01);
				//m_cUser.m_bMailTag		= ((m_cUser.m_nMailComment>>>5 & 0x01) == 0x01);
				m_cUser.m_nReaction			= cResSet.getInt("ng_reaction");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			StringBuilder strMuteKeyword = new StringBuilder();
			if(!m_cUser.m_strMuteKeyword.isEmpty()) {
				String strKeywords[] = m_cUser.m_strMuteKeyword.split(" OR ");
				for(String word : strKeywords) {
					word = word.trim();
					if(word.isEmpty()) continue;
					strMuteKeyword.append(word);
					strMuteKeyword.append(" ");
				}
			}
			m_cUser.m_strMuteKeyword = strMuteKeyword.toString();

			strSql = "SELECT * FROM tbloauth WHERE flduserid=? AND fldproviderid=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, checkLogin.m_nUserId);
			cState.setInt(2, Common.TWITTER_PROVIDER_ID);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cUser.m_bTweet = true;
				m_cUser.m_nAutoTweetWeekDay = cResSet.getInt("auto_tweet_weekday");
				m_cUser.m_nAutoTweetTime = cResSet.getInt("auto_tweet_time");
				m_cUser.m_strAutoTweetDesc = Common.ToString(cResSet.getString("auto_tweet_desc"));
				m_cUser.m_nAutoTweetThumbNum = cResSet.getInt("auto_tweet_thumb_num");
				m_cUser.m_strTwitterScreenName = Common.ToString(cResSet.getString("twitter_screen_name"));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			strSql = "SELECT * FROM temp_emails_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, checkLogin.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_bUpdate = true;
				m_strNewEmail = cResSet.getString("email");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			strSql = "SELECT count(*) as cnt FROM contents_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, checkLogin.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_nPublishedContentsTotal = cResSet.getInt("cnt");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			strSql = "SELECT COUNT(user_id) as cnt FROM follows_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, checkLogin.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cUser.m_nFollowNum = cResSet.getInt("cnt");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			strSql = "SELECT 1 FROM creditcards WHERE user_id=? AND del_flg=false";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, checkLogin.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_bCardInfoExist = true;
			}else{
				m_bCardInfoExist = false;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			strSql = "SELECT 1 FROM cheer_point_exchange_requests WHERE user_id=? AND status=0";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, checkLogin.m_nUserId);
			cResSet = cState.executeQuery();
			m_bExchangeCheerPointRequested = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			strSql = "SELECT sum(remaining_points) FROM cheer_points WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, checkLogin.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nCheerPoint = cResSet.getInt(1);
			} else {
				m_nCheerPoint = 0;
			}
			cResSet.close();cResSet = null;
			cState.close();cState = null;

			if(m_bExchangeCheerPointRequested) {
				strSql = "SELECT exchange_point, payment_fee FROM cheer_point_exchange_requests WHERE user_id=? AND status=0";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, checkLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nExchangePoint = cResSet.getInt(1);
					m_nExchangeFee = cResSet.getInt(2);
				}
				cResSet.close();cResSet = null;
				cState.close();cState = null;
			}
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

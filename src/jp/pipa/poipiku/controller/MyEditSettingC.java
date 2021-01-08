package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class MyEditSettingC {
	public int m_nUserId = -1;
	public String m_strMessage = "";
	public String m_strSelectedMenuId = "";
	public int m_nListPage = 1;
	public String m_strErr="";
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_strMessage = Common.TrimAll(Util.toStringHtml(Common.EscapeInjection(Util.toString(request.getParameter("MSG")))));
			m_strSelectedMenuId = Common.TrimAll(Util.toStringHtml(Common.EscapeInjection(Util.toString(request.getParameter("MENUID")))));
			m_nListPage = Util.toIntN(request.getParameter("PG"), 0, 100);
			m_strErr=Common.TrimAll(Util.toStringHtml(Common.EscapeInjection(Util.toString(request.getParameter("ERR")))));
		} catch(Exception e) {
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
	public Passport m_cPassport = null;

	public boolean getResults(CheckLogin checkLogin) {
		boolean bRtn = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			strSql = "SELECT * FROM users_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				m_cUser.m_nUserId			= resultSet.getInt("user_id");
				m_cUser.m_strNickName		= Util.toString(resultSet.getString("nickname"));
				m_cUser.m_strProfile		= Util.toString(resultSet.getString("profile"));
				m_cUser.m_strFileName		= Util.toString(resultSet.getString("file_name"));
				m_cUser.m_strHeaderFileName	= Util.toString(resultSet.getString("header_file_name"));
				m_cUser.m_strBgFileName		= Util.toString(resultSet.getString("bg_file_name"));
				m_cUser.m_nMailComment		= resultSet.getInt("mail_comment");
				m_cUser.m_strEmail			= Util.toStringHtml(resultSet.getString("email"));
				m_cUser.m_strMuteKeyword	= Util.toString(resultSet.getString("mute_keyword_list")).trim();
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
				m_cUser.m_nReaction			= resultSet.getInt("ng_reaction");
				m_cUser.m_nAdMode			= resultSet.getInt("ng_ad_mode");
				m_cUser.m_nDownload			= resultSet.getInt("ng_download");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

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
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setInt(2, Common.TWITTER_PROVIDER_ID);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				m_cUser.m_bTweet = true;
				m_cUser.m_nAutoTweetWeekDay = resultSet.getInt("auto_tweet_weekday");
				m_cUser.m_nAutoTweetTime = resultSet.getInt("auto_tweet_time");
				m_cUser.m_strAutoTweetDesc = Util.toString(resultSet.getString("auto_tweet_desc"));
				m_cUser.m_nAutoTweetThumbNum = resultSet.getInt("auto_tweet_thumb_num");
				m_cUser.m_strTwitterScreenName = Util.toString(resultSet.getString("twitter_screen_name"));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			strSql = "SELECT * FROM temp_emails_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				m_bUpdate = true;
				m_strNewEmail = resultSet.getString("email");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			strSql = "SELECT count(*) as cnt FROM contents_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				m_nPublishedContentsTotal = resultSet.getInt("cnt");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			strSql = "SELECT COUNT(user_id) as cnt FROM follows_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				m_cUser.m_nFollowNum = resultSet.getInt("cnt");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			strSql = "SELECT 1 FROM creditcards WHERE user_id=? AND del_flg=false";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				m_bCardInfoExist = true;
			}else{
				m_bCardInfoExist = false;
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			strSql = "SELECT 1 FROM cheer_point_exchange_requests WHERE user_id=? AND status=0";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			m_bExchangeCheerPointRequested = resultSet.next();
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			strSql = "SELECT sum(remaining_points) FROM cheer_points WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				m_nCheerPoint = resultSet.getInt(1);
			} else {
				m_nCheerPoint = 0;
			}
			resultSet.close();resultSet = null;
			statement.close();statement = null;

			if(m_bExchangeCheerPointRequested) {
				strSql = "SELECT exchange_point, payment_fee FROM cheer_point_exchange_requests WHERE user_id=? AND status=0";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, checkLogin.m_nUserId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_nExchangePoint = resultSet.getInt(1);
					m_nExchangeFee = resultSet.getInt(2);
				}
				resultSet.close();resultSet = null;
				statement.close();statement = null;
			}

			m_cPassport = new Passport(checkLogin);

			bRtn = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			bRtn = false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

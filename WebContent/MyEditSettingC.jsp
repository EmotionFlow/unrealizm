<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class MyEditSettingCParam {
	public int m_nUserId = -1;
	public String m_strMessage = "";

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId	= Common.ToInt(cRequest.getParameter("ID"));
			m_strMessage = Common.TrimAll(Common.ToStringHtml(Common.EscapeInjection(Common.ToString(cRequest.getParameter("MSG")))));
		}
		catch(Exception e) {
			m_nUserId = -1;
		}
	}
}

class MyEditSettingC {
	CUser m_cUser = new CUser();
	boolean m_bUpdate = false;
	String m_strNewEmail = "";

	public String GetResults(MyEditSettingCParam cParam) {
		String strResult = "OK";
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
			cState.setInt(1, cParam.m_nUserId);
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
				m_cUser.m_strMuteKeyword	= Common.ToString(cResSet.getString("mute_keyword")).trim();
				if(m_cUser.m_strProfile.equals(""))  m_cUser.m_strProfile = "(no profile)";
				if(m_cUser.m_strFileName.equals("")) m_cUser.m_strFileName="/img/default_user.jpg";
				if(m_cUser.m_strHeaderFileName.equals("")) m_cUser.m_strHeaderFileName="/img/default_transparency.gif";
				if(m_cUser.m_strBgFileName.equals("")) m_cUser.m_strBgFileName="/img/default_transparency.gif";
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			StringBuilder strMuteKeyword = new StringBuilder();
			if(!m_cUser.m_strMuteKeyword.isEmpty()) {
				String strKeywords[] = m_cUser.m_strMuteKeyword.split(" ");
				for(String word : strKeywords) {
					word = word.trim();
					if(!word.isEmpty()) {
						word = word.substring(1);
						if(!word.isEmpty()) {
							strMuteKeyword.append(word);
							strMuteKeyword.append(" ");
						}
					}
				}
			}
			m_cUser.m_strMuteKeyword = strMuteKeyword.toString();

			strSql = "SELECT * FROM tbloauth WHERE flduserid=? AND fldproviderid=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, Common.TWITTER_PROVIDER_ID);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cUser.m_bTweet = true;
				m_cUser.m_nAutoTweetWeekDay = cResSet.getInt("auto_tweet_weekday");
				m_cUser.m_nAutoTweetTime = cResSet.getInt("auto_tweet_time");
				m_cUser.m_strAutoTweetDesc = Common.ToString(cResSet.getString("auto_tweet_desc"));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			strSql = "SELECT * FROM temp_emails_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_bUpdate = true;
				m_strNewEmail = cResSet.getString("email");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
		} catch(Exception e) {
			strResult = e.toString();
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return strResult;
	}
}
%>

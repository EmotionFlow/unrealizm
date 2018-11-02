package jp.pipa.poipiku;

import java.net.URLDecoder;
import java.sql.*;

import javax.naming.InitialContext;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import jp.pipa.poipiku.util.*;

public class CheckLogin {
	public boolean m_bLogin = false;
	public int m_nUserId = -1;
	public String m_strNickName = "no name";
	private String m_strHashPass = "";
	public int m_nSafeFilter = 4;
	public int m_nLangId = 0;
	private String m_strFileName = "";

	private void SetCookie(HttpServletResponse cResponse)
	{
		try
		{
			Cookie cLK = new Cookie("POIPIKU_LK" , m_strHashPass);

			cLK.setMaxAge(Integer.MAX_VALUE);
			cLK.setPath("/");

			cResponse.addCookie(cLK);
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	private void GetCookie(HttpServletRequest cRequest)
	{
		try
		{
			Cookie cCookies[] = cRequest.getCookies();
			if(cCookies == null)
			{
				//cookieインスタンスが作成できない
				return;
			}

			for(int i = 0; i < cCookies.length; i++)
			{
				if(cCookies[i].getName().equals("POIPIKU_LK")) {
					m_strHashPass = Common.EscapeInjection(URLDecoder.decode(cCookies[i].getValue(), "UTF-8"));
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}


	private boolean isUserValid() {
		String strSql		= "";
		Timestamp tsLastLogin = null;

		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;

		try{
			if(!m_strHashPass.equals(""))
			{
				dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
				cConn = dsPostgres.getConnection();
				strSql = "SELECT * FROM users_0000 WHERE hash_password=?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, m_strHashPass);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					m_nUserId		= cResSet.getInt("user_id");
					m_strNickName	= cResSet.getString("nickname");
					m_nLangId		= Math.min(Math.max(cResSet.getInt("lang_id"), 0), 1);
					tsLastLogin		= cResSet.getTimestamp("last_login_date");
					m_strFileName	= Common.ToString(cResSet.getString("file_name"));
					if(m_strFileName.length()<=0) m_strFileName = "/img/default_user.jpg";
					m_bLogin = true;
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				if(m_bLogin) {
					if(tsLastLogin.getTime()<System.currentTimeMillis()-300000) { //1*24*60*60*1000
						strSql = "UPDATE users_0000 SET last_login_date=current_timestamp-interval '1 minute' WHERE user_id=?";
						cState = cConn.prepareStatement(strSql);
						cState.setInt(1, m_nUserId);
						cState.executeUpdate();
						cState.close();cState=null;
					}
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
			Log.d(strSql);
			m_bLogin = false;
		} finally {
			try{if(cResSet!=null)cResSet.close();cResSet=null;}catch(Exception e){;}
			try{if(cState!=null)cState.close();cState=null;}catch(Exception e){;}
			try{if(cConn!=null)cConn.close();cConn=null;}catch(Exception e){;}
		}
		return m_bLogin;
	}

	public String GetResults2(HttpServletRequest request, HttpServletResponse response) {
		String strResult = "OK";
		try {
			// useridとハッシュパスワードが保存されているcookie情報を取得
			GetCookie(request);

			if(m_strHashPass.length() <= 0) {
				return strResult;
			}

			if(isUserValid() == false) {
				m_bLogin      = false;
				m_nUserId     = -1;
				m_strNickName = "guest";
				m_strHashPass = "";

				// ログインに失敗したらguestでCookieを上書き
				SetCookie(response);
			}

		} catch(Exception e) {
			strResult = e.toString();
			e.printStackTrace();
		}
		//Log.d(m_nUserId + ":" + m_strNickName + ":" + m_strHashPass);
		return strResult;
	}


	public static boolean isOnline(int nUserId) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();
			strSql = "SELECT * FROM users_0000 WHERE user_id=? AND last_login_date>current_timestamp-interval '1 minute'";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nUserId);
			cResSet = cState.executeQuery();
			bRtn = (cResSet.next());
			cResSet.close();cResSet=null;
			cState.close();cState=null;
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

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
	public String m_strHashPass = "";
	public int m_nSafeFilter = Common.SAFE_FILTER_R18;
	public int m_nLangId = 0;
	public String m_strFileName = "";
	public boolean m_bEmailValid = false;
	public int m_nPremiumId = CUser.PREMIUM_OFF;

	public CheckLogin() {}
	public CheckLogin(HttpServletRequest request, HttpServletResponse response) {
		getResults(request, response);
	}

	private void setCookie(HttpServletResponse response) {
		try {
			Cookie cLK = new Cookie("POIPIKU_LK" , m_strHashPass);
			cLK.setMaxAge(Integer.MAX_VALUE);
			cLK.setPath("/");
			response.addCookie(cLK);
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	private void getCookie(HttpServletRequest request) {
		try {
			Cookie cookies[] = request.getCookies();
			if(cookies == null) {
				//cookieインスタンスが作成できない
				return;
			}
			for(int i = 0; i < cookies.length; i++) {
				if(cookies[i].getName().equals("POIPIKU_LK")) {
					m_strHashPass = Common.EscapeInjection(URLDecoder.decode(cookies[i].getValue(), "UTF-8"));
					break;
				}
			}
			if(m_strHashPass.isEmpty()) {
				request.setCharacterEncoding("UTF-8");
				m_strHashPass = Util.toString(request.getParameter("POIPIKU_LK"));
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	private boolean isUserValid() {
		if(m_strHashPass.isEmpty()) return false;

		CacheUsers0000.User user = CacheUsers0000.getInstance().getUser(m_strHashPass);
		if(user==null) {
			m_bLogin = false;
		} else {
			m_nUserId		= user.m_nUserId;
			m_strNickName	= user.m_strNickName;
			m_nLangId		= user.m_nLangId;
			m_strFileName	= user.m_strFileName;
			m_bEmailValid	= user.m_bEmailValid;
			m_nPremiumId	= user.m_nPremiumId;
			m_bLogin = true;
		}
		return m_bLogin;
	}

	private boolean getResults(HttpServletRequest request, HttpServletResponse response) {
		try {
			// ハッシュパスワードが保存されているcookie情報を取得
			getCookie(request);
			if(!isUserValid()) {
				m_bLogin		= false;
				m_nUserId		= -1;
				m_strNickName	= "guest";
				m_strHashPass	= "";
				// ログインに失敗したらguestでCookieを上書き
				setCookie(response);
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		//Log.d(m_nUserId + ":" + m_strNickName + ":" + m_strHashPass);
		return m_bLogin;
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
			strSql = "SELECT 1 FROM users_0000 WHERE user_id=? AND last_login_date>=current_timestamp-interval '1 minute'";
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

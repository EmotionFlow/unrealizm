package jp.pipa.poipiku;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.pipa.poipiku.cache.CacheUsers0000;
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
	public int m_nPassportId = Common.PASSPORT_OFF;

	public CheckLogin() {}
	public CheckLogin(HttpServletRequest request, HttpServletResponse response) {
		getResults(request, response);
	}

	private void setCookie(HttpServletResponse response) {
		Util.setCookie(response, Common.POIPIKU_LK , m_strHashPass, Integer.MAX_VALUE);
	}

	private void getCookie(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_strHashPass = Util.toString(request.getParameter(Common.POIPIKU_LK_POST));
		} catch (Exception e) {
			;
		}
		if(m_strHashPass.isEmpty()) {
			m_strHashPass = Util.toString(Util.getCookie(request, Common.POIPIKU_LK));
		}
	}

	private boolean validateUser(HttpServletResponse response) {
		CacheUsers0000.User user = CacheUsers0000.getInstance().getUser(m_strHashPass);
		if(user==null) {
			m_nUserId		= -1;
			m_strNickName	= "guest";
			m_strHashPass	= "";
			m_bLogin = false;
			setCookie(response);
		} else {
			m_nUserId		= user.userId;
			m_strNickName	= user.nickName;
			m_nLangId		= user.langId;
			m_strFileName	= user.fileName;
			m_bEmailValid	= user.emailValid;
			m_nPassportId = user.passportId;
			m_bLogin = true;
		}
		return m_bLogin;
	}

	private boolean getResults(HttpServletRequest request, HttpServletResponse response) {
		try {
			// ハッシュパスワードが保存されているcookie情報を取得
			getCookie(request);
			// ユーザ認証・情報取得
			validateUser(response);
		} catch(Exception e) {
			e.printStackTrace();
		}
		//Log.d(m_nUserId + ":" + m_strNickName + ":" + m_strHashPass);
		return m_bLogin;
	}
}

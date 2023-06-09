package jp.pipa.poipiku;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Arrays;
import java.util.List;

import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public final class CheckLogin {
	static private final List<Integer> m_staffIds = Arrays.asList(
			1,          // pipa
			2,          // official
			21808,      // nino
			1708444,    // michi
			1851512,    // picさん
			6230955     // nino作業用
	);
	static private final List<Integer> m_testStaffIds = Arrays.asList(
			2,      // official
			21808,  // nino
			402902,  // snssnssnsさん
			1851512  // picさん
	);
	public boolean m_bLogin = false;
	public int m_nUserId = -1;
	public String m_strNickName = "no name";
	public String m_strHashPass = "";
	public int m_nSafeFilter = Common.SAFE_FILTER_MAX;
	public int m_nLangId = 1;
	public String m_strFileName = "";
	public boolean m_bEmailValid = false;
	public int m_nPassportId = Common.PASSPORT_OFF;
	public CacheUsers0000.User cacheUser = null;

	public CheckLogin() {}
	public CheckLogin(HttpServletRequest request, HttpServletResponse response) {
		getResults(request, response);
	}

	public boolean isStaff(){
		return m_staffIds.contains(m_nUserId);
	}

	static public boolean isStaff(final int userId){
		return m_staffIds.contains(userId);
	}


	private void getCookie(final HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_strHashPass = Util.toString(request.getParameter(Common.UNREALIZM_LK_POST));
		} catch (Exception e) {
			;
		}
		if(m_strHashPass.isEmpty()) {
			m_strHashPass = Util.toString(Util.getCookie(request, Common.UNREALIZM_LK));
		}
	}

	private boolean validateUser(final HttpServletResponse response) {
		cacheUser = CacheUsers0000.getInstance().getUser(m_strHashPass);
		if(cacheUser==null) {
			m_nUserId		= -1;
			m_strNickName	= "guest";
			m_strHashPass	= "";
			m_bLogin        = false;
			Util.setCookie(response, Common.UNREALIZM_LK, m_strHashPass, Integer.MAX_VALUE);
		} else {
			m_nUserId		= cacheUser.userId;
			m_strNickName	= cacheUser.nickName;
			m_nLangId		= cacheUser.langId;
			m_strFileName	= cacheUser.fileName;
			m_bEmailValid	= cacheUser.emailValid;
			m_nPassportId	= cacheUser.passportId;
			m_bLogin = true;
		}
		return m_bLogin;
	}

	private boolean getResults(HttpServletRequest request, HttpServletResponse response) {
		try {
			// ハッシュパスワードが保存されているcookie情報を取得
			getCookie(request);

			// ユーザ認証・情報取得
			if (!validateUser(response)) {
				// 以下の優先順位で、非ログインユーザーの言語設定を取得する。
				// hlパラメータ -> cookie -> http headerのAccept-Language
				final String hlParam = request.getParameter(Common.UR_LANG_ID_POST);
				if (hlParam != null && !hlParam.isEmpty()) {
					m_nLangId = SupportedLocales.findId(hlParam);
				} else {
					final String cookieParam = Util.getCookie(request, Common.UR_LANG_ID);
					if (cookieParam != null && !cookieParam.isEmpty()) {
						m_nLangId = SupportedLocales.findId(cookieParam);
					} else {
						m_nLangId = SupportedLocales
								.getLangIdByRequestHeader(
										request.getHeader("Accept-Language"));
					}
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		//Log.d(m_nUserId + ":" + m_strNickName + ":" + m_strHashPass);
		return m_bLogin;
	}
}

package jp.pipa.poipiku;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.ResourceBundle;
import java.util.ResourceBundle.Control;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.pipa.poipiku.util.Util;


public final class ResourceBundleControl {
	private final ResourceBundle objRb;
	static private final ResourceBundle objRbJa;
	static private final ResourceBundle objRbEn;
	public int ID;
	static public final int ID_EN = 0;
	static public final int ID_JA = 1;

	static {
		objRbJa = CResourceBundleUtil.getJa();
		objRbEn = CResourceBundleUtil.getEn();
	}


	public ResourceBundleControl(HttpServletRequest request, HttpServletResponse response) {
		String strLangParam = "";
		String strLang = "";

		try {
			request.setCharacterEncoding("UTF-8");
			strLangParam = Util.toString(request.getParameter(Common.LANG_ID_POST));
		} catch (Exception ignored) {
			;
		}
		if(strLangParam.isEmpty()) {
			strLang = Util.toString(Util.getCookie(request, Common.LANG_ID));
		} else {
			strLang = strLangParam;
		}

		if(strLang.equals("en")){
			objRb = objRbEn;
			ID = ID_EN;
		} else {
			objRb = objRbJa;
			ID = ID_JA;
		}

		if (!strLangParam.isEmpty()) {
			Util.setCookie(response, Common.LANG_ID, strLangParam, Integer.MAX_VALUE);
		}
	}

	public ResourceBundleControl() {
		objRb = objRbJa;
		ID = ID_JA;
	}

	public String T(String key) {
		return objRb.getString(key);
	}
	public String TJa(String key) {
		return objRbJa.getString(key);
	}
	public String TEn(String key) {
		return objRbEn.getString(key);
	}

	static public class CResourceBundleUtil {
		static final List<Locale> JP = Arrays.asList(Locale.JAPANESE, Locale.ROOT);
		static final List<Locale> ROOT = Arrays.asList(Locale.ROOT, Locale.JAPANESE);

		static final Control CTRL = new ResourceBundle.Control() {
			@Override
			public long getTimeToLive(String baseName, Locale locale) {
				return 5000;
			}
			@Override
			public List<Locale> getCandidateLocales(String baseName, Locale locale) {
				if(locale.equals(Locale.JAPAN) || locale.equals(Locale.JAPANESE)) {
					return JP;
				} else if(locale.equals(Locale.US) || locale.equals(Locale.UK) || locale.equals(Locale.ENGLISH)) {
					return ROOT;
				} else {
					return JP;
				}
			}
		};

		static final Control CTRL_ONLY = new ResourceBundle.Control() {
			public long getTimeToLive(String baseName, Locale locale) {
				return 5000;
			}
		};

		static public ResourceBundle getRoot(){
			return ResourceBundle.getBundle("rs", Locale.ROOT, CTRL);
		}
		static public ResourceBundle getJa(){
			return ResourceBundle.getBundle("rs", Locale.JAPANESE, CTRL_ONLY);
		}
		static public ResourceBundle getEn(){
			return ResourceBundle.getBundle("rs", Locale.ENGLISH, CTRL_ONLY);
		}
	}
}

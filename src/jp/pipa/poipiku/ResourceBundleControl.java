package jp.pipa.poipiku;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.ResourceBundle;
import java.util.ResourceBundle.Control;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;
import org.postgresql.util.PGobject;


public final class ResourceBundleControl {
	private ResourceBundle objRb;

	static private final ResourceBundle objRbJa;
	static private final ResourceBundle objRbEn;

	static {
		objRbJa = CResourceBundleUtil.getJa();
		objRbEn = CResourceBundleUtil.getEn();
	}

	static private Locale getLocale(String langStr) {
		Locale locale;
		String[] lcv = langStr.split("-");
		switch (lcv.length) {
			case 1:
				locale = new Locale(lcv[0]);
				break;
			case 2:
				locale = new Locale(lcv[0], lcv[1]);
				break;
			case 3:
				locale = new Locale(lcv[0], lcv[1], lcv[2]);
				break;
			default:
				locale = new Locale("");
		}
		return locale;
	}

	public ResourceBundleControl(HttpServletRequest request, HttpServletResponse response) {
		/*
		url paramにhlあり
			サポートしている言語 -> rs_??を採用
			サポートしていない言語 -> rs_enを採用
			setCookie

		url paramにhlなし
			CookieにLANGあり -> それ採用
			CookieにLANGなし -> rs_jaを採用
			 */
		String strLangParam = null;
		String strLangCookie = null;

		Locale locale = null;

		try {
			request.setCharacterEncoding("UTF-8");
			strLangParam = request.getParameter(Common.LANG_ID_POST);

			if (strLangParam != null) {
				locale = getLocale(strLangParam);
				objRb = CResourceBundleUtil.get(locale);
				Util.setCookie(response, Common.LANG_ID, strLangParam, Integer.MAX_VALUE);
				return;
			}
		} catch (Exception ignored) {}

		if (strLangParam == null) {
			strLangCookie = Util.getCookie(request, Common.LANG_ID);
			if (strLangCookie == null) {
				objRb = CResourceBundleUtil.getJa();
			} else {
				objRb = CResourceBundleUtil.get(getLocale(strLangCookie));
			}
		}
	}

	public Locale getLocale() {
		return objRb.getLocale();
	}

	public ResourceBundleControl() {
		objRb = objRbJa;
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
		static private final String BASE_NAME = "rs";
		static private final long TIME_TO_LIVE = 30000L;

		static final List<Locale> JP = Arrays.asList(Locale.JAPANESE, Locale.ROOT);
		static final List<Locale> ROOT = Arrays.asList(Locale.ROOT, Locale.ENGLISH);

		static final Control CTRL = new ResourceBundle.Control() {
			@Override
			public long getTimeToLive(String baseName, Locale locale) {
				return TIME_TO_LIVE;
			}
			@Override
			public List<Locale> getCandidateLocales(String baseName, Locale locale) {
				if (locale.equals(Locale.JAPAN) || locale.equals(Locale.JAPANESE)) {
					return JP;
				} else if(locale.equals(Locale.US) || locale.equals(Locale.UK) || locale.equals(Locale.ENGLISH)) {
					return ROOT;
				} else {
					return ROOT;
				}
			}
			@Override
			public List<String> getFormats(String baseName){
				return FORMAT_PROPERTIES;
			}
		};

		static final Control CTRL_ONLY = new ResourceBundle.Control() {
			@Override
			public long getTimeToLive(String baseName, Locale locale) {
				return TIME_TO_LIVE;
			}
			@Override
			public List<String> getFormats(String baseName) {
				return FORMAT_PROPERTIES;
			}
		};

		static public ResourceBundle get(Locale locale) {
			return ResourceBundle.getBundle(BASE_NAME, locale, CTRL);
		}
		static public ResourceBundle getRoot(){
			return ResourceBundle.getBundle(BASE_NAME, Locale.ROOT, CTRL);
		}
		static public ResourceBundle getJa(){
			return ResourceBundle.getBundle(BASE_NAME, Locale.JAPANESE, CTRL_ONLY);
		}
		static public ResourceBundle getEn(){
			return ResourceBundle.getBundle(BASE_NAME, Locale.ENGLISH, CTRL_ONLY);
		}
	}
}

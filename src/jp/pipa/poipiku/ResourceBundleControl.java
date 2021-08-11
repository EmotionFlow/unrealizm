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
	private ResourceBundle objRb;

	public ResourceBundleControl(HttpServletRequest request, HttpServletResponse response) {
		/*
		url paramにhlあり
			サポートしている言語 -> rs_??を採用
			サポートしていない言語 -> rs_enを採用
			採用されたロケールでsetCookieする。

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
				locale = SupportedLocales.getLocale(strLangParam);
				objRb = CResourceBundleUtil.get(locale);
				Util.setCookie(response, Common.LANG_ID, objRb.getLocale().toString(), Integer.MAX_VALUE);
				return;
			}
		} catch (Exception ignored) {}

		if (strLangParam == null) {
			strLangCookie = Util.getCookie(request, Common.LANG_ID);
			if (strLangCookie == null) {
				objRb = CResourceBundleUtil.getJa();
			} else {
				objRb = CResourceBundleUtil.get(SupportedLocales.getLocale(strLangCookie));
			}
		}
	}

	public Locale getLocale() {
		return objRb.getLocale();
	}

	public ResourceBundleControl() {
		objRb = CResourceBundleUtil.getJa();
	}

	public String T(String key) {
		return objRb.getString(key);
	}
	static public String T(Locale locale, String key) {
		return CResourceBundleUtil.get(locale).getString(key);
	}

	static public class CResourceBundleUtil {
		static private final String BASE_NAME = "rs";
		static private final long TIME_TO_LIVE = 30000L;

		static final List<Locale> JP = Arrays.asList(Locale.JAPANESE, Locale.ROOT);
		static final List<Locale> EN = Arrays.asList(Locale.ENGLISH, Locale.ROOT);

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
					return EN;
				} else {
					return EN;
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

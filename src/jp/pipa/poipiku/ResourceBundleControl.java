package jp.pipa.poipiku;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.ResourceBundle;
import java.util.ResourceBundle.Control;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.util.Util;


public class ResourceBundleControl {
	private ResourceBundle objRb;
	private ResourceBundle objRbJa;
	private ResourceBundle objRbEn;
	public int ID = 1;

	public ResourceBundleControl(HttpServletRequest request) {
		String strLang="";

		try {
			request.setCharacterEncoding("UTF-8");
			strLang = Util.toString(request.getParameter(Common.LANG_ID_POST));
		} catch (Exception e) {
			;
		}
		if(strLang.isEmpty()) {
			strLang = Util.toString(Util.getCookie(request, Common.LANG_ID));
		}

		objRbJa = CResourceBundleUtil.getJa();
		objRbEn = CResourceBundleUtil.getEn();

		if(strLang.equals("en")){
			objRb = objRbEn;
			ID = 0;
		} else {
			objRb = objRbJa;
			ID = 1;
		}
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

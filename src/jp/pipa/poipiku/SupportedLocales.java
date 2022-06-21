package jp.pipa.poipiku;

import jp.pipa.poipiku.util.Log;

import java.util.*;

public final class SupportedLocales {
	static public final int ID_DEFAULT = 0;
	static public final Locale LOCALE_DEFAULT = Locale.ENGLISH;
	static public final List<UserLocale> list;

	static {
		List<UserLocale> l = new ArrayList<>();
		l.add(new UserLocale(0, Locale.ENGLISH, "English"));
		l.add(new UserLocale(1, Locale.JAPANESE, "日本語"));
		l.add(new UserLocale(2, Locale.KOREAN, "한국"));
		l.add(new UserLocale(3, Locale.SIMPLIFIED_CHINESE, "简体中文"));
		l.add(new UserLocale(4, Locale.TRADITIONAL_CHINESE, "繁體中文"));
		l.add(new UserLocale(5, new Locale("th"), "ไทย"));
		l.add(new UserLocale(6, new Locale("ru"), "русский"));
		l.add(new UserLocale(7, new Locale("vi"), "Tiếng Việt"));
		l.add(new UserLocale(8, new Locale("es"), "español"));
		list = Collections.unmodifiableList(l);
	}

	static public UserLocale getUserLocale(int id) {
		return list.stream().filter(e -> e.id==id).findFirst().get();
	}

	static public UserLocale getLocaleByRequestHeader(String headerAcceptLanguage) {
		if (headerAcceptLanguage == null || headerAcceptLanguage.isEmpty() || headerAcceptLanguage.equals("*")) {
			return list.get(0);
		}
		String[] langAry = headerAcceptLanguage.trim().split(",");
		String s;
		UserLocale foundLocale = null;
		for (String langStr: langAry) {
			s = langStr.split(";")[0].trim();
			final Locale locale = getLocale(s);
			try {
				if (locale.getLanguage().equals("zh")) {
					foundLocale = list.stream().filter(e -> e.locale.equals(locale)).findFirst().get();
				} else {
					foundLocale = list.stream().filter(e -> e.locale.getLanguage().equals(locale.getLanguage())).findFirst().get();
				}
				break;
			} catch (NoSuchElementException ignored) {}
		}
		return foundLocale==null?list.get(0):foundLocale;
	}

	static public int getLangIdByRequestHeader(String headerAcceptLanguage) {
		return getLocaleByRequestHeader(headerAcceptLanguage).id;
	}

	static public Locale getLocale(String langStr) {
		if (langStr==null || langStr.isEmpty()) {
			return LOCALE_DEFAULT;
		}
		Locale locale;
		String separator = langStr.indexOf("_")>0 ? "_" : "-";
		List<String> lcv = new ArrayList<>(Arrays.asList(langStr.split(separator)));

		if (lcv.get(0).equals("zh")) {
			if (lcv.size() == 3) {
				if (lcv.get(1).equals("cmn")) {
					lcv.remove(1);
				}
			}
			if (lcv.size() >= 2) {
				if (lcv.get(1).equals("Hans") || lcv.get(1).equals("SG")) {
					lcv.set(1, "CN");
				} else if (lcv.get(1).equals("Hant") || lcv.get(1).equals("HK") || lcv.get(1).equals("MO")|| lcv.get(1).equals("TW")) {
					lcv.set(1, "TW");
				} else {
					lcv.set(1, "CN");
				}
			}
			if (lcv.size() == 1) {
				lcv.add("CN");
			}
		}

		locale = switch (lcv.size()) {
			case 1 -> new Locale(lcv.get(0));
			case 2 -> new Locale(lcv.get(0), lcv.get(1));
			case 3 -> new Locale(lcv.get(0), lcv.get(1), lcv.get(2));
			default -> LOCALE_DEFAULT;
		};
		return locale;
	}

	static public int findId(Locale locale) {
		int id;
		try {
			id = list.stream().filter(e -> e.locale.equals(locale)).findFirst().get().id;
		} catch (NoSuchElementException e) {
			id = ID_DEFAULT;
		}
		return id;
	}

	static public int findId(String strLocale) {
		return findId(getLocale(strLocale));
	}

	static public Locale findLocale(int id) {
		Locale locale;
		try {
			locale = list.stream().filter(e -> e.id == id).findFirst().get().locale;
		} catch (NoSuchElementException e) {
			locale = LOCALE_DEFAULT;
		}
		return locale;
	}
}

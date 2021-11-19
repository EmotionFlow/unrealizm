package jp.pipa.poipiku;

import java.util.*;

public final class SupportedLocales {
	static public final int ID_DEFAULT = 0;
	static public final Locale LOCALE_DEFAULT = Locale.ENGLISH;
	static private final List<UserLocale> list;

	static {
		List<UserLocale> l = new ArrayList<>();
		l.add(new UserLocale(0, Locale.ENGLISH));
		l.add(new UserLocale(1, Locale.JAPANESE));
		l.add(new UserLocale(2, Locale.KOREAN));
		l.add(new UserLocale(3, Locale.SIMPLIFIED_CHINESE));
		l.add(new UserLocale(4, Locale.TRADITIONAL_CHINESE));
		l.add(new UserLocale(5, new Locale("th")));
		l.add(new UserLocale(6, new Locale("ru")));
		list = Collections.unmodifiableList(l);
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

		switch (lcv.size()) {
			case 1:
				locale = new Locale(lcv.get(0));
				break;
			case 2:
				locale = new Locale(lcv.get(0), lcv.get(1));
				break;
			case 3:
				locale = new Locale(lcv.get(0), lcv.get(1), lcv.get(2));
				break;
			default:
				locale = LOCALE_DEFAULT;
		}
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

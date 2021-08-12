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
		l.add(new UserLocale(3, Locale.SIMPLIFIED_CHINESE));
		list = Collections.unmodifiableList(l);
	}

	static public Locale getLocale(String langStr) {
		Locale locale;
		String separator = langStr.indexOf("_")>0 ? "_" : "-";
		String[] lcv = langStr.split(separator);
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

package jp.pipa.poipiku;

import java.util.Locale;

public class UserLocale {
	public int id;
	public Locale locale;
	public String label;
	public UserLocale(int _id, Locale _locale, String _label) {
		id = _id;
		locale = _locale;
		label = _label;
	}
}

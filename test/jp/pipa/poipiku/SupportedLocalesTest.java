package jp.pipa.poipiku;

import org.junit.jupiter.api.Test;

import java.util.Locale;

import static org.junit.jupiter.api.Assertions.*;

public class SupportedLocalesTest {
	@Test
	public void testStaticMethods() {
		Locale locale;
		locale = SupportedLocales.findLocale(0);
		assertEquals(locale, Locale.ENGLISH);
		locale = SupportedLocales.findLocale(1);
		assertEquals(locale, Locale.JAPANESE);
		locale = SupportedLocales.findLocale(2);
		assertEquals(locale, Locale.ENGLISH);

		int id;
		id = SupportedLocales.findId(Locale.ENGLISH);
		assertEquals(0, id);
		id = SupportedLocales.findId(Locale.JAPANESE);
		assertEquals(1, id);
		id = SupportedLocales.findId(Locale.CANADA_FRENCH);
		assertEquals(0, id);

	}
}

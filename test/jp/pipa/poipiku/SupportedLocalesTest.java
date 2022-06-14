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
		assertEquals(locale, Locale.KOREAN);

		int id;
		id = SupportedLocales.findId(Locale.ENGLISH);
		assertEquals(0, id);
		id = SupportedLocales.findId(Locale.JAPANESE);
		assertEquals(1, id);
		id = SupportedLocales.findId(Locale.CANADA_FRENCH);
		assertEquals(0, id);

	}

	@Test
	public void testGetLocaleByRequestHeader() {
		assertEquals(0, SupportedLocales.getLangIdByRequestHeader(
				""));
		assertEquals(0, SupportedLocales.getLangIdByRequestHeader(
				"*"));

		assertEquals(1, SupportedLocales.getLangIdByRequestHeader(
				"ja"));
		assertEquals(1, SupportedLocales.getLangIdByRequestHeader(
				"ja,en-US;q=0.9,en;q=0.8"));
		assertEquals(1, SupportedLocales.getLangIdByRequestHeader(
				"ja-JP,en-US;q=0.9,en;q=0.8"));

		assertEquals(0, SupportedLocales.getLangIdByRequestHeader(
				"en"));
		assertEquals(0, SupportedLocales.getLangIdByRequestHeader(
				"en-UK,en-US;q=0.9,en;q=0.8"));
		assertEquals(0, SupportedLocales.getLangIdByRequestHeader(
				"en-US,ja-JP;q=0.9,en;q=0.8"));

		assertEquals(2, SupportedLocales.getLangIdByRequestHeader(
				"ko"));

		assertEquals(3, SupportedLocales.getLangIdByRequestHeader(
				"zh-CN"));
		assertEquals(3, SupportedLocales.getLangIdByRequestHeader(
				"zh-Hans"));
		assertEquals(3, SupportedLocales.getLangIdByRequestHeader(
				"zh-SG"));

		assertEquals(4, SupportedLocales.getLangIdByRequestHeader(
				"zh-TW"));
		assertEquals(4, SupportedLocales.getLangIdByRequestHeader(
				"zh-Hant"));

		assertEquals(1, SupportedLocales.getLangIdByRequestHeader(
				"es, ja-JP;q=0.9"));

		assertEquals(0, SupportedLocales.getLangIdByRequestHeader(
				"es, is;q=0.9,ay;q=0.7"));


	}
}

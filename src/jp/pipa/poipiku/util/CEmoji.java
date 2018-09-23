package jp.pipa.poipiku.util;

import java.util.ArrayList;

import org.apache.commons.lang3.StringUtils;

public class CEmoji {
	private static final String URL = "<img class=\"Twemoji\" draggable=\"false\" alt=\"%s\" src=\"https://twemoji.maxcdn.com/2/72x72/%s.png\" />";

	/*
	private static final Pattern pattern = Pattern.compile("((([\uD83C\uDF00-\uD83D\uDDFF]|[\uD83D\uDE00-\uD83D\uDE4F]|[\uD83D\uDE80-\uD83D\uDEFF]|[\u2600-\u26FF]|[\u2700-\u27BF])[\\x{1F3FB}-\\x{1F3FF}]?))");
	public static String PROTOCOL = "https:";
	public static String BASE = "//twemoji.maxcdn.com/2/";
	public static String SIZE = "72x72";
	public static String EXTENSION = ".png";
	public static String CLASSNAME = "emoji";

	public static String parse2(String text) {
		StringBuffer sb = new StringBuffer();
		Matcher matcher = pattern.matcher(text);
		String iconUrl = null;
		while (matcher.find()) {
			String rawCode = matcher.group(2);
			String iconId = grabTheRightIcon(rawCode);
			iconUrl = PROTOCOL + BASE + SIZE +"/" + iconId + EXTENSION;
			matcher.appendReplacement(sb, "<img class=\"" + CLASSNAME + "\" draggable=\"false\" alt=\"" + rawCode + "\" src=\"" + iconUrl + "\">");
		}
		matcher.appendTail(sb);
		return sb.toString();
	}
	*/

	public static String parse(String rawCode) {
		//return rawCode;
		return String.format(URL, rawCode, grabTheRightIcon(rawCode));
	}


	private static String toCodePoint(String unicodeSurrogates) {
		ArrayList<String> r = new ArrayList<>();
		int c = 0, p = 0, i = 0;
		while (i < unicodeSurrogates.length()) {
			c = unicodeSurrogates.charAt(i++);
			if (p != 0) {
				r.add(Integer.toString((0x10000 + ((p - 0xD800) << 10) + (c - 0xDC00)), 16));
				p = 0;
			} else if (0xD800 <= c && c <= 0xDBFF) {
				p = c;
			} else {
				r.add(Integer.toString(c, 16));
			}
		}
		return StringUtils.join(r, "-");
	}

	private static String grabTheRightIcon(String rawText) {
		// if variant is present as \uFE0F
//		return toCodePoint(
//				rawText.indexOf('\u200D') < 0 ?
//				rawText.replace("\uFE0F", "") :
//				rawText, null);
		return toCodePoint(rawText);
	}
}

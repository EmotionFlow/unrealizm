package jp.pipa.poipiku.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jp.pipa.poipiku.*;

public class NovelUtil {
	public static String genarateHtml(String title, String textBody, String coverFilePath) {
		String strRtn = "";

		try {
			textBody = Util.toStringHtmlTextarea(textBody);
			StringBuilder sbHtml = new StringBuilder();

			// ページの始まり
			sbHtml.append("<div class=\"NovelSection\">");


			// 表紙
			if(!coverFilePath.isEmpty()) {
				sbHtml.append(String.format("<div class=\"NovelCover\"><img class=\"NovelCoverImage\" src=\"%s\" /></div>", coverFilePath));
			}


			// タイトル
			sbHtml.append(String.format("<span class=\"NovelTitle\">%s</span>", title));

			// 目次
			// 章の抽出
			Pattern ptn = Pattern.compile("\\[chapter:(.+)\\]", Pattern.MULTILINE);
			Matcher matcher = ptn.matcher(textBody);
			StringBuilder sbMenu = new StringBuilder();
			int nSectionNum = 0;
			while (matcher.find()) {
				try {
					sbMenu.append(String.format("<span class=\"NovelMenuItem\">%s</span>", matcher.group(1)));
					nSectionNum++;
				} catch(Exception e) {
					e.printStackTrace();
				}
			}
			// 目次の追加
			if(nSectionNum > 0) {
				sbHtml.append(String.format("<span class=\"NovelMenu\">%s</span>", sbMenu.toString()));
			}

			// 本文
			// [newpage]
			textBody = textBody.replaceAll("(?:\r\n|\n|\r)?\\[newpage\\](?:\r\n|\n|\r)?", "</div><div class=\"NovelSection\">");

			// [chapter:章タイトル]
			textBody = textBody.replaceAll("(?:\r\n|\n|\r)?\\[chapter:(.+?)\\](?:\r\n|\n|\r)?", "<span class=\"NovelSectionTitle\">$1</span>");

			// 傍点
			textBody = textBody.replaceAll("《《(.+?)》》", "<span class=\"TextEmphasis\">$1</span>");

			// ルビ
			// カクヨム文法：｜《ルビを入力…》
			// pixiv文法：[[rb:漢字 > ふりがな]]
			textBody = textBody
					.replaceAll("[\\|｜](.+?)《(.+?)》", "<ruby>$1<rt>$2</rt></ruby>")
					.replaceAll("([一-龠]+)《(.+?)》", "<ruby>$1<rt>$2</rt></ruby>")
					.replaceAll("[\\|｜]《(.+?)》", "《$1》")
				.replaceAll("\\[\\[rb:(.+?) &gt; (.+?)\\]\\]", "<ruby>$1<rt>$2</rt></ruby>");

			// URL [[jumpuri:タイトル > リンク先URL]]
			textBody = textBody.replaceAll("\\[\\[jumpuri:(.+?) &gt; (.+?)\\]\\]", "<a class=\"NovelUrl\" href=\"$2\" target=\"_blank\">$1</a>");

			// 挿絵[image:イラストID]
			textBody = textBody.replaceAll("\\[image:(.+?)\\]", "<span class=\"NovelArtWork\" data-iid=\"$1\"></span>");

			// 名前[name:名前]
			textBody = textBody.replaceAll("\\[name:(.+?)\\]", "<span class=\"NovelChangeName\">$1</span>");

			// 改行
			textBody = textBody
				.replace("\r\n", "\n")
				.replace("\r", "\n")
				.replace("\n", "<br />\n");
			//
			sbHtml.append(textBody);


			// ページの終わり <span class="NovelSection">
			sbHtml.append("</div>");
			strRtn = sbHtml.toString();

		} catch(Exception e) {
			strRtn = null;
			Log.d(e.getMessage());
		}
		return strRtn;
	}

	public static String genarateHtmlShort(String title, String textBody, String coverFilePath) {
		String strRtn = "";

		try {
			textBody = Util.toStringHtmlTextarea(textBody);
			StringBuilder sbHtml = new StringBuilder();

			String[] arrBody = Common.SubStrNum(textBody, 1000).replace("\r\n", "\n").replace("\r", "\n").split("\n");
			int nLength = 0;
			for(int nCnt=0; nCnt < arrBody.length; nCnt++) {
				sbHtml.append(arrBody[nCnt]).append("\n");
				nLength += arrBody[nCnt].length();
				if(nLength>300) break;
			}
			textBody = sbHtml.toString();
			sbHtml = new StringBuilder();

			// ページの始まり
			sbHtml.append("<div class=\"NovelSection\">");

			// 表紙
			if(!coverFilePath.isEmpty()) {
				sbHtml.append(String.format("<div class=\"NovelCover\"><img class=\"NovelCoverImage\" src=\"%s\" /></div>", coverFilePath));
			}

			// タイトル
			sbHtml.append(String.format("<span class=\"NovelTitle\">%s</span>", title));

			// 本文
			// [newpage]
			textBody = textBody.replaceAll("(?:\r\n|\n|\r)?\\[newpage\\](?:\r\n|\n|\r)?", "</div><div class=\"NovelSection\">");
			//strBody = strBody.replaceAll("(?:\r\n|\n|\r)?\\[newpage\\](?:\r\n|\n|\r)?", "\n");

			// [chapter:章タイトル]
			textBody = textBody.replaceAll("(?:\r\n|\n|\r)?\\[chapter:(.+)\\](?:\r\n|\n|\r)?", "<span class=\"NovelSectionTitle\">$1</span>");

			// 傍点
			textBody = textBody.replaceAll("《《(.+?)》》", "<span class=\"TextEmphasis\">$1</span>");

			// ルビ
			// カクヨム文法：｜《ルビを入力…》
			// pixiv文法：[[rb:漢字 > ふりがな]]
			textBody = textBody
				.replaceAll("[\\|｜](.+?)《(.+?)》", "<ruby>$1<rt>$2</rt></ruby>")
				.replaceAll("([一-龠]+)《(.+?)》", "<ruby>$1<rt>$2</rt></ruby>")
				.replaceAll("[\\|｜]《(.+?)》", "《$1》")
				.replaceAll("\\[\\[rb:(.+?) > (.+?)\\]\\]", "<ruby>$1<rt>$2</rt></ruby>");

			// URL [[jumpuri:タイトル > リンク先URL]]
			textBody = textBody.replaceAll("\\[\\[jumpuri:(.+?) > (.+?)\\]\\]", "<span class=\"NovelUrl\">$1</span>");

			// 挿絵[image:イラストID]
			textBody = textBody.replaceAll("\\[image:(.+)\\]", "");

			// 名前[name:名前]
			textBody = textBody.replaceAll("\\[name:(.+)\\]", "<span class=\"NovelChangeName\">$1</span>");

			// 改行
			textBody = textBody.replace("\n", "<br />\n");
			//
			sbHtml.append(textBody);


			// ページの終わり <span class="NovelSection">
			sbHtml.append("</div>");
			strRtn = sbHtml.toString();

		} catch(Exception e) {
			strRtn = null;
			Log.d(e.getMessage());
		}
		return strRtn;
	}

}

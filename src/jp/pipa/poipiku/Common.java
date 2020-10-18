package jp.pipa.poipiku;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.time.ZonedDateTime;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.sql.Timestamp;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.util.CCnv;

public class Common {
	public static final int PAGE_BAR_NUM = 2;

	public static int TWITTER_PROVIDER_ID = 1;
	public static String TWITTER_CONSUMER_KEY = "Wh6tHeINW6IQbSd1nJP9i1yUN";
	public static String TWITTER_CONSUMER_SECRET = "kXYW0KkWlfDszfGn0m8lj3aEz6vB3iWzY5M1SO9T8DNM9rXJY0";
	public static String TWITTER_CALLBAK_DOMAIN = "https://poipiku.com";
	public static final String PROF_DEFAULT = "/img/DefaultProfile.jpg";
	public static final String DB_POSTGRESQL = "java:comp/env/jdbc/poipiku";	// for Database

	public static final String TAG_PATTERN = "#([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)";

	public static final String NORMAL_TAG_PATTERN = "[\\s　]([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)";
	public static final String HUSH_TAG_PATTERN = "[^#]#([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)";
	public static final String MY_TAG_PATTERN = "##([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)";

	public static final int NOTIFICATION_TYPE_REACTION = 1;
	public static final int NOTIFICATION_TYPE_FOLLOW = 2;

	public static final int NOTIFICATION_TOKEN_TYPE_IOS = 1;
	public static final int NOTIFICATION_TOKEN_TYPE_ANDROID = 2;

	public static final int NO_NEED_UPDATE[] = {
			118, 119, 120, 121, 122, 123, 124,	// 1系 iPhone
			223, 224, 225, 226, 227, 228, 229	// 2系 Android
	};
	/* falseにしてもdead codeは再コンパイルされないので /inner.Common.jspに移動
	public static final boolean SP_REVIEW = false;	// アップル審査用 true で用ログイン
	*/

	public static String GetPageTitle2(ResourceBundleControl _TEX, String pageName){
		return pageName + " - " + _TEX.T("TopV.TitleBar");
	}

	// favo keyword
	public static final int FOVO_KEYWORD_TYPE_TAG		= 0;
	public static final int FOVO_KEYWORD_TYPE_SEARCH	= 1;

	// Ad ID
	public static final int AD_ID_ALL	= 1;	// ALL
	public static final int AD_ID_R18	= 2;	// R18

	// Publish ID
	public static final int PUBLISH_ID_ALL			= 0;	// ALL
	public static final int PUBLISH_ID_R15			= 1;	// R15
	public static final int PUBLISH_ID_R18			= 2;	// R18
	public static final int PUBLISH_ID_R18G			= 3;	// R18G
	public static final int PUBLISH_ID_PASS			= 4;	// パスワード
	public static final int PUBLISH_ID_LOGIN		= 5;	// ログイン
	public static final int PUBLISH_ID_FOLLOWER		= 6;	// ふぁぼ限定
	public static final int PUBLISH_ID_T_FOLLOWER	= 7;	// ツイッターフォロワー
	public static final int PUBLISH_ID_T_FOLLOW		= 8;	// ツイッターフォロー
	public static final int PUBLISH_ID_T_EACH		= 9;	// ツイッター相互フォロー
	public static final int PUBLISH_ID_T_LIST		= 10;	// ツイッターリスト
	public static final int PUBLISH_ID_LIMITED_TIME	= 11;	// 期間限定
	public static final int PUBLISH_ID_HIDDEN		= 99;	// 非公開
	public static final int PUBLISH_ID_MAX = PUBLISH_ID_HIDDEN;
	public static final String[] PUBLISH_ID_FILE = {
			"",								// 0
			"/img/warning.png",				// 1
			"/img/R-18.png",				// 2
			"/img/R-18.png",				// 3
			"/img/publish_pass.png",		// 4
			"/img/publish_login.png",		// 5
			"/img/publish_follower.png",	// 6
			"/img/publish_t_follower.png",	// 7
			"/img/publish_t_follow.png",	// 8
			"/img/publish_t_each.png",		// 9
			"/img/publish_t_list.png",		// 10
	};


	// Safe Filter
	public static final int SAFE_FILTER_ALL = 0;
	public static final int SAFE_FILTER_R15 = 2;
	public static final int SAFE_FILTER_R18 = 4;
	public static final int SAFE_FILTER_R18G = 6;

	// 表示するカテゴリ一覧
	public static final int CATEGORY_ID_MAX = 24;
	public static final int[] CATEGORY_ID = {
			13,	// 使い回しハロウィン
			4,	// らくがき
			6,	// できた
			10,	// 作業進捗
			7,	// 過去絵を晒す
			5,	// 自主練
			9,	// 供養
			15,	// 描きかけ
			17, // メモ
			23,	// ネタバレ
			16,	// 描けねえ
			22,	// リハビリ
			1,	// 飽きた
			18, // ほぼ白紙
			14,	// お知らせ

//			0,	// いちほ
//			2,	// 力尽きた
//			3,	// ボツ
//			8,	// 黒歴史
//			11,	// 放置絵を晒す
//			11,	// 放置中
//			12,	// 挫折
//			13,	// 使い回しハロウィン
//			19, // ポイピククリスマス
//			20, // 使いまわし年賀状
//			21, // 公式
//			24,	// 使いまわしバレンタイン
	};
	// 上記のうち、常時表示される、企画ものではないもの。
	public static final List<Integer> CATEGORY_ID_REGULER = Collections.unmodifiableList(
		new ArrayList<Integer>() {{
			add(22);	// リハビリ
			add(23);	// ネタバレ
			add(17);	// メモ
			add(16);	// 描けねえ
			add(1);		// 飽きた
			add(18);	// ほぼ白紙
			add(15);	// 描きかけ
			add(9);		// 供養
//			add(11);	// 放置中
			add(4);		// らくがき
			add(10);	// 作業進捗
			add(5);		// 自主練
			add(6);		// できた
			add(7);		// 過去絵を晒す
			add(14);	// お知らせ
		}}
	);

	public static final int EDITOR_UPLOAD = 0;
	public static final int EDITOR_PASTE = 1;
	public static final int EDITOR_BASIC_PAINT = 2;
	public static final int EDITOR_TEXT = 3;
	public static final int EDITOR_ID_MAX = EDITOR_TEXT;

	public static final int[][] EDITOR_DESC_MAX = {
			// normal, premium
			{200, 500},
			{200, 500},
			{200, 500},
			{200, 500}
	};

	public static final int[][] EDITOR_TEXT_MAX = {
			// normal, premium
			{0, 0},
			{0, 0},
			{0, 0},
			{10000, 100000}
	};

	public static String ToString(String strSrc) {
		if(strSrc == null) {
			return "";
		}
		return strSrc;
	}

	public static String ToStringHtmlTextarea(String strSrc) {
		if(strSrc == null) {
			return "";
		}

		strSrc = strSrc.replace("&", "&amp;");
		strSrc = strSrc.replace("<", "&lt;");
		strSrc = strSrc.replaceAll(">", "&gt;");
		strSrc = strSrc.replaceAll("'", "&apos;");
		strSrc = strSrc.replaceAll("\"", "&quot;");

		return strSrc;
	}

	public static String ToStringHtml(String strSrc) {
		if(strSrc == null) {
			return "";
		}
		strSrc = strSrc.replace("\r\n", "\n");
		strSrc = strSrc.replace("\r", "\n");
		strSrc = strSrc.replace("&", "&amp;");
		strSrc = strSrc.replace("<", "&lt;");
		strSrc = strSrc.replaceAll(">", "&gt;");
		strSrc = strSrc.replaceAll("\n", "<br />");
		strSrc = strSrc.replaceAll("'", "&apos;");
		strSrc = strSrc.replaceAll("\"", "&quot;");

		return strSrc;
	}

	public static String CrLfInjection(String strSrc) {
		if(strSrc == null) {
			return "";
		}
		strSrc = strSrc.replace("\r", "");
		strSrc = strSrc.replace("\n", "");

		return strSrc;
	}

	public static int ToInt(String strSrc) {
		int nRet = -1;
		if(strSrc == null) {
			return -1;
		}
		try {
			nRet = Integer.parseInt(strSrc);
		} catch (Exception e) {
			nRet = -1;
		}
		return nRet;
	}

	public static int ToIntN(String strSrc, int nMin, int nMax) {
		int nRet = nMin;
		if(strSrc == null) {
			return nRet;
		}
		try {
			nRet = Integer.parseInt(strSrc);
		} catch (Exception e) {
			nRet = nMin;
		}
		nRet = Math.min(Math.max(nRet, nMin), nMax);

		return nRet;
	}

	public static long ToLong(String strSrc) {
		long lnRet = -1;
		if(strSrc == null) {
			return -1;
		}
		try {
			lnRet = Long.parseLong(strSrc);
		} catch (Exception e) {
			lnRet = -1;
		}
		return lnRet;
	}

	public static boolean ToBoolean(String strSrc){
		try{
			int n = Integer.parseInt(strSrc, 10);
			return ToBoolean(n);
		} catch (NumberFormatException ne){
			boolean b = false;
			b = Boolean.parseBoolean(strSrc);
			return b;
		}
	}

	public static boolean ToBoolean(int strSrc){
		boolean b = false;
		if(strSrc >= 1) b = true;
		return b;
	}

	public static Timestamp ToSqlTimestamp(String strDateTime){
		// ISO format 2011-10-05T14:48:00.000Z を想定
		if(strDateTime!=null && !strDateTime.isEmpty()){
			ZonedDateTime zdt = ZonedDateTime.parse(strDateTime);
			return Timestamp.from(zdt.toInstant());
		} else {
			return null;
		}
	}

	public static String ToYMDHMString(Timestamp ts){
		if(ts==null){return "";}
		LocalDateTime ldt = ts.toLocalDateTime();
		ZonedDateTime zdtSystemDefault = ldt.atZone(ZoneId.systemDefault());
		ZonedDateTime zdtGmt = zdtSystemDefault.withZoneSameInstant(ZoneId.of("GMT"));
		return zdtGmt.format(DateTimeFormatter.ISO_INSTANT);
	}

	public static String EscapeInjection(String strSrc) {
		if(strSrc == null) {
			return "";
		}

		strSrc = strSrc.replace("'", "''");
		strSrc = strSrc.replace("\\", "\\\\");

		return strSrc;
	}

	public static String EscapeQuery(String strSrc) {
		if(strSrc == null) {
			return "";
		}

		strSrc = strSrc.replace("'", "''");
		strSrc = strSrc.replace("%", "\\%");
		strSrc = strSrc.replace("_", "\\_");
		strSrc = strSrc.replace("\\", "\\\\");

		return strSrc;
	}

	public static String TrimAll(String strSrc) {
		if(strSrc == null) {
			return "";
		}

		return strSrc.replaceAll("^[\\s　]*", "").replaceAll("[\\s　]*$", "");
	}

	public static String GetUrl(String strFileName) {
		if(strFileName==null) return "";
		return "//img-cdn.poipiku.com" + strFileName;
	}

	public static String GetLocalImgUrl(String strFileName) {
		if(strFileName==null) return "";
		return "//img.poipiku.com" + strFileName;
	}

	public static String GetPoipikuUrl(String strFileName) {
		if(strFileName==null) return "";
		return "https://poipiku.com" + strFileName;
	}

	public static String GetUploadPath() {
		String path = "/user_img01";
		/*
		Random rnd = new Random();
		int rand = rnd.nextInt(6);

		if(rand==0) {
			path = "user_img5";
		} else if(rand>=1 && rand<=2) {
			path = "user_img6";
		}
		*/
		return path;
	}
	public static String getUploadUserPath(int nUserId) {
		//return String.format("/user_img%02d/%09d", (int)(nUserId/10000)+1, nUserId);
		return String.format("/user_img01/%09d", nUserId);
	}

	public static String SubStrNum(String strSrc, int nNum) {
		if(strSrc==null) return "";
		if(strSrc.length()<=nNum) return strSrc;
		return strSrc.substring(0, nNum);
	}

	public static void copyTransfer(String srcPath, String destPath) throws IOException {
		FileInputStream isSrc = new FileInputStream(srcPath);
		FileChannel srcChannel = isSrc.getChannel();
		FileInputStream isDst = new FileInputStream(destPath);
		FileChannel destChannel = isDst.getChannel();
		try {
			srcChannel.transferTo(0, srcChannel.size(), destChannel);
		} finally {
			srcChannel.close();
			destChannel.close();
			isSrc.close();
			isDst.close();
		}
	}

	public static TimeZone GetTimeZone(HttpServletRequest cRequest){
		String strTimeZone = "UTC";
		try {
			if(cRequest.getLocale().getISO3Language().equals("jpn")) {
				strTimeZone = "JST";
			}
		} catch(Exception e) {
			;
		}
		return TimeZone.getTimeZone(strTimeZone);
	}

	public static boolean CopyFile(String strSrc, String strDst) throws IOException {
		File fileDefaultDot = new File(strDst);
		File dirDefaultDot = fileDefaultDot.getParentFile();
		if (!dirDefaultDot.exists()){
			dirDefaultDot.mkdirs();
		}
		FileInputStream isSrc = new FileInputStream(strSrc);
		FileChannel srcChannel = isSrc.getChannel();
		FileInputStream isDst = new FileInputStream(strDst);
		FileChannel destChannel = isDst.getChannel();
		try {
			srcChannel.transferTo(0, srcChannel.size(), destChannel);
		} finally {
			srcChannel.close();
			destChannel.close();
			isSrc.close();
			isDst.close();
		}

		return true;
	}

	private static String _AutoLink(String strSrc, int nUserId, int nMode, int nSpMode) {
		String ILLUST_LIST = "";
		String MY_ILLUST_LIST = "";
		if(nSpMode==CCnv.SP_MODE_APP){
			ILLUST_LIST = "/SearchIllustByTagAppV.jsp?KWD=";
			MY_ILLUST_LIST = String.format("/IllustListAppV.jsp?ID=%d&KWD=", nUserId);
		}else if(nMode==CCnv.MODE_SP){
			ILLUST_LIST = "/SearchIllustByTagV.jsp?KWD=";
			MY_ILLUST_LIST = String.format("/IllustListPcV.jsp?ID=%d&KWD=", nUserId);
		}else{
			ILLUST_LIST = "/SearchIllustByTagPcV.jsp?KWD=";
			MY_ILLUST_LIST = String.format("/IllustListPcV.jsp?ID=%d&KWD=", nUserId);
		}
		return strSrc
				.replaceAll("(http://|https://){1}[\\w\\.\\-/:;&?,=#!~]+","<a class='AutoLink' href='$0' target='_blank'>$0</a>")
				//.replaceAll("([^#])(#)([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", String.format("$1<a class=\"AutoLink\" href=\"javascript:void(0)\" onclick=\"moveTagSearch('%s', '$3')\">$2$3</a>", ILLUST_LIST))
				.replaceAll("([^#])(#)([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", String.format("$1<a class=\"AutoLink\" href=\"%s$3\">$2$3</a>", ILLUST_LIST))
				//.replaceAll("(##)([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", String.format("<a class=\"AutoLinkMyTag\" href=\"javascript:void(0)\" onclick=\"moveTagSearch('%s', '$2')\">$0</a>", MY_ILLUST_LIST))
				.replaceAll("(##)([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", String.format("<a class=\"AutoLinkMyTag\" href=\"%s$2\">$0</a>", MY_ILLUST_LIST))
				.replaceAll("@([0-9a-zA-Z_]{3,15})","<a class='AutoLink' href='https://twitter.com/$1' target='_blank'>$0</a>");

	}

	public static String AutoLink(String strSrc, int nUserId, int nMode) {
		return _AutoLink(strSrc, nUserId, nMode, CCnv.SP_MODE_WVIEW);
	}

	public static String AutoLink(String strSrc, int nUserId, int nMode, int nSpMode) {
		return _AutoLink(strSrc, nUserId, nMode, nSpMode);
	}

	public static String EscapeSqlLike(String strSrc, String strEscape) {
		return "%" + EscapeSqlLikeExact(strSrc, strEscape) + "%";
	}

	public static String EscapeSqlLikeExact(String strSrc, String strEscape) {
		String strRtn = strSrc;
		if(strEscape==null) strEscape="";
		strRtn = replaceAll(strRtn, strEscape, strEscape+strEscape);
		strRtn = replaceAll(strRtn, "_", strEscape+"_");
		strRtn = replaceAll(strRtn, "%", strEscape+"%");
		return strRtn;
	}

	public static String replaceAll(String str, String target, String replacement) {
		return Pattern.compile(Pattern.quote(target), Pattern.CASE_INSENSITIVE).matcher(str).replaceAll(
				Matcher.quoteReplacement(replacement));
	}

	public static void rmDir(File f) {
		if (!f.exists()) return;

		if (f.isFile()) {
			f.delete();
		} else if (f.isDirectory()) {
			File[] files = f.listFiles();

			for (int i = 0; i < files.length; i++) {
				rmDir(files[i]);
			}

			f.delete();
		}
	}
}

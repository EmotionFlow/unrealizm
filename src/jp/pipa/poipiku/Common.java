package jp.pipa.poipiku;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.util.CCnv;

import static java.util.stream.Collectors.joining;

public final class Common {
	private Common(){}

	public static final String GLOBAL_IP_ADDRESS = "118.238.233.16";

	public static final String CONTENTS_ROOT = "/var/www/html/poipiku_img";
	public static final String CONTENTS_CACHE_DIR = "user_img00";
	public static final String CONTENTS_STORAGE_DIR = "user_img01";

	// APIリターンコード
	public static final int API_OK = 1;
	public static final int API_NG = 0;

	// ページバー設定
	public static final int PAGE_BAR_NUM = 2;

	public static final int TWITTER_PROVIDER_ID = 1;
	public static final String TWITTER_CONSUMER_KEY = "Wh6tHeINW6IQbSd1nJP9i1yUN";
	public static final String TWITTER_CONSUMER_SECRET = "kXYW0KkWlfDszfGn0m8lj3aEz6vB3iWzY5M1SO9T8DNM9rXJY0";
	public static final String TWITTER_CALLBAK_DOMAIN = "https://poipiku.com";
	public static final String TWITTER_API_REQUEST_TOKEN = "https://api.twitter.com/oauth/request_token";
	public static final String TWITTER_API_ACCESS_TOKEN = "https://api.twitter.com/oauth/access_token";
	public static final String TWITTER_API_AUTHORIZE = "https://api.twitter.com/oauth/authorize";
	public static final String TWITTER_API_AUTHENTICATE = "https://api.twitter.com/oauth/authenticate";
	public static final String PROF_DEFAULT = "/img/DefaultProfile.jpg";
	public static final String DB_POSTGRESQL = "java:comp/env/jdbc/poipiku";	// for Database

	public static final String TAG_PATTERN = "#([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)";

	public static final String NORMAL_TAG_PATTERN = "[\\s　]([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)";
	public static final String HUSH_TAG_PATTERN = "[^#]#([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)";
	public static final String MY_TAG_PATTERN = "##([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)";

	public static final String SLACK_WEBHOOK_ERROR = "https://hooks.slack.com/services/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";

	// お知らせ一覧種別
	public static final int NOTIFICATION_TYPE_REACTION = 1;
	public static final int NOTIFICATION_TYPE_FOLLOW = 2;
	public static final int NOTIFICATION_TYPE_REQUEST = 3;
	public static final int NOTIFICATION_TYPE_GIFT = 4;
	public static final int NOTIFICATION_TYPE_REQUEST_STARTED = 5;
	public static final int NOTIFICATION_TYPE_REPLY_REACTION = 6;
	// お知らせ一覧サムネ種別
	public static final int CONTENT_TYPE_IMAGE = 1;
	public static final int CONTENT_TYPE_TEXT = 2;
	public static final int CONTENT_TYPE_MOVIE = 3;	// 未使用変更OK
	// お知らせ一覧スマホ通知種別
	public static final int NOTIFICATION_TOKEN_TYPE_IOS = 1;
	public static final int NOTIFICATION_TOKEN_TYPE_ANDROID = 2;

	public static final int NO_NEED_UPDATE[] = {
			126, 127, 128, 129, 130, 130, 131,	// 1系 iPhone
			229, 230, 231, 232, 233, 234, 235	// 2系 Android
	};
	/* falseにしてもdead codeは再コンパイルされないので /inner.Common.jspに移動
	public static final boolean SP_REVIEW = false;	// アップル審査用 true で用ログイン
	*/

	public static String GetPageTitle2(ResourceBundleControl _TEX, String pageName){
		return pageName + " - " + _TEX.T("TopV.TitleBar");
	}

	// Ad ID
	public static final int AD_ID_ALL	= 1;	// ALL
	public static final int AD_ID_R18	= 2;	// R18

	// Open ID
	public static final int OPEN_ID_PUBLISH = 0;
	public static final int OPEN_ID_NG_RECENT = 1;
	public static final int OPEN_ID_HIDDEN = 2;

	// Publish ID
	public static final int PUBLISH_ID_ALL			= 0;	// ALL
	public static final int PUBLISH_ID_R15			= 1;	// R15
	public static final int PUBLISH_ID_R18			= 2;	// R18
	public static final int PUBLISH_ID_R18G			= 3;	// R18G
	public static final int PUBLISH_ID_PASS			= 4;	// パスワード
	public static final int PUBLISH_ID_LOGIN		= 5;	// ログイン
	public static final int PUBLISH_ID_FOLLOWER		= 6;	// ふぁぼ限定
	public static final int PUBLISH_ID_T_FOLLOWER	= 7;	// ツイッターフォロワー
	public static final int PUBLISH_ID_T_FOLLOWEE	= 8;	// ツイッターフォロー
	public static final int PUBLISH_ID_T_EACH		= 9;	// ツイッター相互フォロー
	public static final int PUBLISH_ID_T_LIST		= 10;	// ツイッターリスト
	//廃止：public static final int PUBLISH_ID_LIMITED_TIME	= 11;	// 期間限定
	public static final int PUBLISH_ID_T_RT		    = 12;	// ツイッターリツイート
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
			"",		// 11
			"/img/publish_t_rt.png",		// 12
	};

	// 投稿・更新画面で選択可能な公開指定
	public static final int[] PUBLISH_ID = {
			PUBLISH_ID_ALL,			// 全体
			PUBLISH_ID_R15,			// ワンクッション
			PUBLISH_ID_R18,			// R18
			PUBLISH_ID_PASS,		// パスワード
			PUBLISH_ID_LOGIN,		// ログイン限定
			PUBLISH_ID_FOLLOWER,	// ふぁぼ限定
			PUBLISH_ID_T_FOLLOWER,	// ツイッターフォロワー限定
			PUBLISH_ID_T_FOLLOWEE,	// ツイッターフォロー限定
			PUBLISH_ID_T_EACH,		// ツイッター相互フォロー限定
			PUBLISH_ID_T_LIST,		// ツイッターリスト限定
			PUBLISH_ID_T_RT,		// ツイッターRT限定
			PUBLISH_ID_HIDDEN		// 非公開
	};

	// Safe Filter
	public static final int SAFE_FILTER_ALL = 0;
	public static final int SAFE_FILTER_R15 = 2;
	public static final int SAFE_FILTER_R18 = 4;
	public static final int SAFE_FILTER_R18G = 6;

	// 表示するカテゴリ一覧
	public static final int CATEGORY_ID_MAX = 32;
	public static final int[] CATEGORY_ID = {
			4,	// らくがき
			6,	// できた
			10,	// 作業進捗
			7,	// 過去絵を晒す
			9,	// 供養
			5,	// 自主練
			23,	// ネタバレ
			17,	// メモ
			30,	// 尻を叩く
			15,	// 描きかけ
			16,	// 描けねえ
			22,	// リハビリ
			32,	// お品書き
			14,	// お知らせ

//			0,	// いちほ
//			1,	// 飽きた
//			2,	// 力尽きた
//			3,	// ボツ
//			8,	// 黒歴史
//			11,	// 放置絵を晒す
//			11,	// 放置中
//			12,	// 挫折
//			13,	// 使い回しハロウィン
//			18,	// ほぼ白紙
//			19, // 使い回しクリスマス
//			21, // 公式
//			24,	// 使いまわしバレンタイン
//			25,	// 胸キュン
//			26,	// 今年の振り返り
//			27, // 煩悩を晒せ
//			28,	// 200万祝ってください
//			29,	// 腐女子は見た
//			31,	// 1111
	};

	public static final int EDITOR_UPLOAD = 0;
	public static final int EDITOR_PASTE = 1;
	public static final int EDITOR_BASIC_PAINT = 2;
	public static final int EDITOR_TEXT = 3;
	public static final int EDITOR_ID_MAX = EDITOR_TEXT;

	// ポイパス
	public static final int PASSPORT_OFF = 0;
	public static final int PASSPORT_ON = 1;

	public static final int[][] EDITOR_DESC_MAX = {
			// normal, PASSPORT
			{200, 3000},
			{200, 3000},
			{200, 3000},
			{200, 3000}
	};

	public static final int[][] EDITOR_TEXT_MAX = {
			// normal, PASSPORT
			{0, 0},
			{0, 0},
			{0, 0},
			{100000, 1000000}
	};

	public static final int[] EMOJI_MAX = {
			// normal, PASSPORT
			10, 100
	};

	public static final int[] BOOKMARK_NUM = {
			// normal, PASSPORT
			1000, 10000
	};

	public static final int[] UPLOAD_FILE_MAX = {
			// normal, PASSPORT
			200, 400
//			200, 200
	};

	public static final int[] UPLOAD_FILE_TOTAL_SIZE = {
			// normal, PASSPORT
			50, 100
//			50, 50
	};

	public static final int[] GENRE_NUM = {
			// normal, PASSPORT
			10, 100
	};

	// アップロードエラーコード
	public static final int UPLOAD_FILE_TOTAL_ERROR = -999;
	public static final int UPLOAD_FILE_TYPE_ERROR = -998;

	// Cookie Key
	public static final String POIPIKU_LK = "POIPIKU_LK";
	public static final String POIPIKU_LK_POST = "POIPIKU_LK";
	public static final String LANG_ID = "LANG";
	public static final String LANG_ID_POST = "hl";
	public static final String POIPIKU_INFO = "POIPIKU_INFO";
	public static final String CLIENT_TIMEZONE_OFFSET = "TZ_OFFSET";

	// lang_id
	public static int LANG_ID_OTHER = 0;
	public static int LANG_ID_JP = 1;
	public static int LANG_ID_EN = 0;

	public static String CrLfInjection(String strSrc) {
		if(strSrc == null) {
			return "";
		}
		strSrc = strSrc.replace("\r", "");
		strSrc = strSrc.replace("\n", "");

		return strSrc;
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

	public static String TrimHeadBlankLines(final String str){
		if(str == null || str.isEmpty()){
			return "";
		}
		String[] lines = str.split("\n");

		String l = null;
		int i=0;
		for (String line : lines) {
			if (line.replaceAll("^[\\s　]*$", "").isEmpty()) {
				i++;
			} else {
				l = line;
				break;
			}
		}

		if (l != null) {
			return str.substring(str.indexOf(l));
		} else {
			return str;
		}
	}

	public static String GetUrl(final String strFileName) {
		if(strFileName==null) return "";
		return "//img.poipiku.com" + strFileName;
	}

	public static String GetOrgImgUrl(final String strFileName) {
		if(strFileName==null) return "";
		return "//img-org.poipiku.com" + strFileName;
	}

	public static String GetPoipikuUrl(final String strFileName) {
		if(strFileName==null) return "";
		return "https://poipiku.com" + strFileName;
	}

	public static String GetUploadTemporaryPath() {
		return "/user_img_tmp";
		/*
		Random rnd = new Random();
		int rand = rnd.nextInt(6);

		if(rand==0) {
			path = "user_img5";
		} else if(rand>=1 && rand<=2) {
			path = "user_img6";
		}
		return path;
		*/
	}

	public static String getUploadContentsPath(int nUserId) {
		//return String.format("/user_img%02d/%09d", (int)(nUserId/10000)+1, nUserId);
		//return String.format("/user_img01/%09d", nUserId);
		return String.format("/user_img00/%09d", nUserId);
	}

	public static String getUploadUsersPath(int nUserId) {
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
			ILLUST_LIST = "/SearchIllustByTagPcV.jsp?KWD=";
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

	public static String AutoLinkHtml(String strSrc, int nSpMode) {
		String ILLUST_LIST = "";
		if(nSpMode==CCnv.SP_MODE_APP){
			ILLUST_LIST = "/SearchIllustByTagAppV.jsp?KWD=";
		}else{
			ILLUST_LIST = "/SearchIllustByTagPcV.jsp?KWD=";
		}
		return strSrc
				.replaceAll("(http://|https://){1}[\\w\\.\\-/:;&?,=#!~]+","<a class='AutoLink' href='$0' target='_blank'>$0</a>")
				//.replaceAll("([^#])(#)([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", String.format("$1<a class=\"AutoLink\" href=\"javascript:void(0)\" onclick=\"moveTagSearch('%s', '$3')\">$2$3</a>", ILLUST_LIST))
				.replaceAll("([^#])(#)([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", String.format("$1<a class=\"AutoLink\" href=\"%s$3\">$2$3</a>", ILLUST_LIST))
				.replaceAll("@([0-9a-zA-Z_]{3,15})","<a class='AutoLink' href='https://twitter.com/$1' target='_blank'>$0</a>");
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

	public static String getGoogleTransformLinkHtml(String jspPage, String target, String langCode, String langName){
		final String translateUrlFormat = "https://poipiku-com.translate.goog/%s?hl=ja&_x_tr_sl=ja&_x_tr_tl=%s&_x_tr_hl=ja";
		final String aTag="<a target=\"%s\" href=\"%s\">%s</a>";
		return String.format(
				aTag,
				target,
				String.format(translateUrlFormat, jspPage, langCode),
				langName
				);
	}

	public static String getCgiParamStr(Map<String, String> keyValues) {
		return keyValues.entrySet()
				.stream()
				.map(e -> e.getKey() + "=" + e.getValue())
				.collect(joining("&"));
	}

	enum AppEnv {
		Development, Production
	}
	public static AppEnv appEnv;
	public static boolean isDevEnv(){
		return appEnv == AppEnv.Development;
	}

	static {
		String prop = System.getProperty("APP_ENVIRONMENT");
		if (prop != null && prop.equals("development")) {
			appEnv = AppEnv.Development;
		} else {
			appEnv = AppEnv.Production;
		}
	}
}

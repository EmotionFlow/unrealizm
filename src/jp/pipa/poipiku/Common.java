package jp.pipa.poipiku;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.util.CCnv;
import jp.pipa.poipiku.util.Log;

import static java.util.stream.Collectors.joining;

public final class Common {
	private Common(){}

	public static final String URL_ROOT = "https://unrealizm.com/";

	public static final String GLOBAL_IP_ADDRESS = "118.238.233.16";

	public static final String CONTENTS_ROOT = "/var/www/html/ai_poipiku_img";
	public static final String CONTENTS_DIR_REGEX = "user_img[0-9][0-9]";
	public static final String[] CONTENTS_STORAGE_DIR_ARY = {"user_img01","user_img02","user_img03"};
	public static final String[] CURRENT_CONTENTS_STORAGE_DIR_ARY = {"user_img02","user_img03"};

	// APIリターンコード
	public static final int API_OK = 1;
	public static final int API_NG = 0;

	// ページバー設定
	public static final int PAGE_BAR_NUM = 2;

	public static final int TWITTER_PROVIDER_ID = 1;
	public static final String TWITTER_CONSUMER_KEY = "XFIQFJo00gRsM795rB7ET7e08";
	public static final String TWITTER_CONSUMER_SECRET = "zgycvLD4qpeyywGP9LWBgn4nnOj7G8dP6GzvxgWhfbSqmZGwbp";
	public static final String TWITTER_CALLBAK_DOMAIN = "https://unrealizm.com";
	public static final String TWITTER_API_REQUEST_TOKEN = "https://api.twitter.com/oauth/request_token";
	public static final String TWITTER_API_ACCESS_TOKEN = "https://api.twitter.com/oauth/access_token";
	public static final String TWITTER_API_AUTHORIZE = "https://api.twitter.com/oauth/authorize";
	public static final String TWITTER_API_AUTHENTICATE = "https://api.twitter.com/oauth/authenticate";
	public static final String PROF_DEFAULT = "/img/DefaultProfile.jpg";
	public static final String DB_POSTGRESQL = "java:comp/env/jdbc/ai_poipiku";	// for Database
	public static final String DB_POSTGRESQL_REPLICA = "java:comp/env/jdbc/ai_poipiku_replica";	// for Database

	public static final String TAG_PATTERN = "#([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)";

	public static final String NORMAL_TAG_PATTERN = "[\\s　]([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)";
	public static final String HUSH_TAG_PATTERN = "[^#]#([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)";
	public static final String MY_TAG_PATTERN = "##([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)";

	public static final int TAG_MAX_NUM = 20;
	public static final int TAG_MAX_LENGTH = 64;

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
	public static final int PUBLISH_ID_ALL			= 0;	// XX限定なし
	public static final int PUBLISH_ID_R15			= 1;	// [廃止] R15。safe_filterに統合
	public static final int PUBLISH_ID_R18			= 2;	// [廃止] R18。safe_filterに統合
	public static final int PUBLISH_ID_R18G			= 3;	// [廃止] R18G。safe_filterに統合
	public static final int PUBLISH_ID_PASS			= 4;	// [廃止] パスワード。passwordに統合
	public static final int PUBLISH_ID_LOGIN		= 5;	// ログイン限定
	public static final int PUBLISH_ID_FOLLOWER		= 6;	// こそフォロ限定
	public static final int PUBLISH_ID_T_FOLLOWER	= 7;	// ツイッターフォロワー限定
	public static final int PUBLISH_ID_T_FOLLOWEE	= 8;	// ツイッターフォロー限定
	public static final int PUBLISH_ID_T_EACH		= 9;	// ツイッター相互フォロー限定
	public static final int PUBLISH_ID_T_LIST		= 10;	// ツイッターリスト限定
	//廃止：public static final int PUBLISH_ID_LIMITED_TIME	= 11;	// [廃止済] 期間限定
	public static final int PUBLISH_ID_T_RT		    = 12;	// ツイッターリツイート限定
	public static final int PUBLISH_ID_HIDDEN		= 99;	// [廃止予定] 非公開。open_idに統合
	public static final int PUBLISH_ID_MAX = PUBLISH_ID_HIDDEN;
	public static final String[] PUBLISH_ID_FILE = {
			"",								// 0
			"/img/warning.png",				// [廃止]1 SAFE_FILTER_FILEへ移行
			"/img/R-18.png",				// [廃止]2 SAFE_FILTER_FILEへ移行
			"/img/R-18.png",				// [廃止]3 SAFE_FILTER_FILEへ移行
			"/img/publish_pass.png",		// [廃止]4 PASSWORD_FILEへ移行
			"/img/publish_login.png",		// 5
			"/img/publish_follower.png",	// 6
			"/img/publish_t_follower.png",	// 7
			"/img/publish_t_follow.png",	// 8
			"/img/publish_t_each.png",		// 9
			"/img/publish_t_list.png",		// 10
			"",		// 11
			"/img/publish_t_rt.png",		// 12
	};

	public static final String[] SAFE_FILTER_FILE = {
			"",                             // 0
			"/img/warning.png",				// 1
			"/img/R-18.png",				// 2
			"/img/R-18.png",				// 3
			"/img/R-18_plus.png",			// 4
	};

	public static final String PASSWORD_FILE = "/img/publish_pass.png";

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
	public static final int SAFE_FILTER_R18_PLUS = 8;
	public static final int SAFE_FILTER_MAX = 8;

	// 表示するカテゴリ一覧
	public static final int CATEGORY_ID_MAX = 11;
	public static final int CATEGORY_ID_OTHER = 0;
	public static final int[] CATEGORY_ID = {
			1,  // Stable-Diffusion
			7,  // Mage
			9,  // ERNIE-ViLG
			10, // りんな＠AI画家(twitter)
			11, // お絵描きばりぐっどくん(LINE)
			8,  // Cyber punk Anime Diffusion
			2,  // Midjourney
			3,  // NovelAI
			4,  // DALL-E
//			5,  // AIピカソ
//			6,  // mimic
			CATEGORY_ID_OTHER, // その他
	};

	public static final String[] CATEGORY_SITE = {
			/* 0:その他 */               "",
			/* 1:Stable-Diffusion */    "https://huggingface.co/spaces/stabilityai/stable-diffusion",
			/* 2:Midjourney */          "https://www.midjourney.com/home/",
			/* 3:NovelAI */             "https://novelai.net/",
			/* 4:DALL-E */              "https://openai.com/dall-e-2/",
			/* 5:AIピカソ */             "https://apps.apple.com/jp/app/ai%E3%83%94%E3%82%AB%E3%82%BD-ai%E3%81%8A%E7%B5%B5%E6%8F%8F%E3%81%8D%E3%82%A2%E3%83%97%E3%83%AA/id1642181654",
			/* 6:mimic */               "https://illustmimic.com/",
			/* 7:Mage */                "https://www.mage.space/",
			/* 8:Cyber punk Anime Diffusion */ "https://huggingface.co/spaces/DGSpitzer/DGS-Diffusion-Space",
			/* 9:ERNIE-ViLG */                 "https://huggingface.co/spaces/PaddlePaddle/ERNIE-ViLG",
			/* 10:りんな＠AI画家(twitter) */     "https://twitter.com/ms_rinna/status/1567844022240313344",
			/* 11:ばりぐっどくん(LINE) */  "https://page.line.me/877ieiqs",
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
			{100, 100},
			{100, 100},
			{100, 100},
			{100, 100}
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
			4, 400
	};

	public static final int[] UPLOAD_FILE_TOTAL_SIZE = {
			// normal, PASSPORT
			10, 10
//			50, 50
	};

	public static final int[] GENRE_NUM = {
			// normal, PASSPORT
			10, 100
	};

	public static final int[][] EDITOR_PROMPT_MAX = {
			// normal, PASSPORT
			{3000, 3000},
			{3000, 3000},
			{3000, 3000},
			{3000, 3000}
	};

	public static final int[][] EDITOR_OTHER_PARAMS_MAX = {
			// normal, PASSPORT
			{1000, 1000},
			{1000, 1000},
			{1000, 1000},
			{1000, 1000},
	};


	// アップロードエラーコード
	public static final int UPLOAD_FILE_TOTAL_ERROR = -999;
	public static final int UPLOAD_FILE_TYPE_ERROR = -998;

	// Cookie Key
	public static final String UNREALIZM_LK = "UNREALIZM_LK";
	public static final String UNREALIZM_LK_POST = "UR_LK";
	public static final String UR_LANG_ID = "UR_LANG";
	public static final String UR_LANG_ID_POST = "hl";
	public static final String UNREALIZM_INFO = "UNREALIZM_INFO";
	public static final String CLIENT_TIMEZONE_OFFSET = "TZ_OFFSET";

	// lang_id
	// SupportedLocalesに移行した

	// 検索履歴取得範囲
	public static final int[] SEARCH_LOG_SUGGEST_MAX = {
			// normal, PASSPORT
			5, 30
	};
	public static final int[] SEARCH_LOG_SUGGEST_DAYS = {
			// normal, PASSPORT
			7, 30
	};
	public static final int SEARCH_LOG_CACHE_MINUTES = 60;

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
		return "//img.unrealizm.com" + strFileName;
	}

	public static String GetOrgImgUrl(final String strFileName) {
		if(strFileName==null) return "";
		return "//img-org.unrealizm.com" + strFileName;
	}

	public static String GetUnrealizmUrl(final String strFileName) {
		if(strFileName==null) return "";
		return "https://unrealizm.com" + strFileName;
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

	private static int userImageCounter = 0;
	synchronized public static String getUploadContentsPath(int nUserId) {
		userImageCounter++;
		if (userImageCounter >= CURRENT_CONTENTS_STORAGE_DIR_ARY.length) userImageCounter = 0;
		return String.format("/%s/%09d", CURRENT_CONTENTS_STORAGE_DIR_ARY[userImageCounter], nUserId);
	}

	public static String getUploadUsersPath(int nUserId) {
		return String.format("/user_img%02d/%09d", (nUserId % 2) + 2, nUserId);
	}

	public static String getUserProfRealPath(int userId) {
		return CONTENTS_ROOT + Common.getUploadUsersPath(userId);
	}

	public static String makeUserProfDir(int userId) {
		final String profPath = getUserProfRealPath(userId);
		Path destDir = Paths.get(profPath);
		if (!Files.exists(destDir)) {
			if (!destDir.toFile().mkdir()) {
				Log.d("mkdir failed " + profPath);
				return null;
			}
		}
		return profPath;
	}

	public static List<String> getUploadContentsPathList(int userId) {
		List<String> list = new LinkedList<>();
		for (String s : CONTENTS_STORAGE_DIR_ARY) {
			list.add("/%s/%09d".formatted(s, userId));
		}
		return list;
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

		final String result = strSrc
				.replaceAll("(http://|https://){1}[\\w\\.\\-/:;&?,=#!~]+",
						"<a class='AutoLink' href='$0' target='_blank'>$0</a>")
				.replaceAll("([^#])(#)([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)",
						String.format(
								"$1<a class=\"AutoLink\" href=\"%s$3\">$2$3</a>",
								ILLUST_LIST)
				)
				.replaceAll("(##)([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)",
						String.format(
								"<a class=\"AutoLinkMyTag\" href=\"%s$2\">$0</a>",
								MY_ILLUST_LIST)
				)
				.replaceAll("@([0-9a-zA-Z_]{3,15})",
						"<a class='AutoLink' href='https://twitter.com/$1' target='_blank'>$0</a>");
		return result;

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
		if (f == null || !f.exists()) return;

		if (f.isFile()) {
			f.delete();
		} else if (f.isDirectory()) {
			File[] files = f.listFiles();
			if (files != null) {
				for (File file : files) {
					rmDir(file);
				}
			}
			f.delete();
		}
	}

	public static String getGoogleTransformLinkHtml(String jspPage, String target, String langCode, String langName){
		final String translateUrlFormat = "https://unrealizm-com.translate.goog/%s?hl=ja&_x_tr_sl=ja&_x_tr_tl=%s&_x_tr_hl=ja";
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

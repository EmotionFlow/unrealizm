package jp.pipa.poipiku;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.util.*;

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
			114, 115, 116, 117, 118, 119, 120,	// 1系 iPhone
			221, 222, 223, 224, 225, 226, 227	// 2系 Android
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
	public static final int AD_ID_ALL	= 0;	// ALL
	public static final int AD_ID_R18	= 1;	// R18

	// Publish ID
	public static final int PUBLISH_ID_ALL			= 0;	// ALL
	public static final int PUBLISH_ID_R15			= 1;	// R15
	public static final int PUBLISH_ID_R18			= 2;	// R18
	public static final int PUBLISH_ID_R18G			= 3;	// R18G
	public static final int PUBLISH_ID_PASS			= 4;	// パスワード
	public static final int PUBLISH_ID_LOGIN		= 5;	// ログイン
	public static final int PUBLISH_ID_FOLLOWER		= 6;	// フォロワー
	public static final int PUBLISH_ID_T_FOLLOWER	= 7;	// ツイッターフォロワー
	public static final int PUBLISH_ID_T_FOLLOW		= 8;	// ツイッターフォロー
	public static final int PUBLISH_ID_T_EACH		= 9;	// ツイッター相互フォロー
	public static final int PUBLISH_ID_T_LIST		= 10;	// ツイッターリスト
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
	public static final int CATEGORY_ID_MAX = 23;
	public static final int[] CATEGORY_ID = {
			22,	// リハビリ
			23,	// ネタバレ
			17, // メモ
			16,	// 描けねえ
			1,	// 飽きた
			18, // ほぼ白紙
			15,	// 描きかけ
			9,	// 供養
			11,	// 放置中
			4,	// らくがき
			10,	// 作業進捗
			5,	// 自主練
			6,	// できた
			7,	// 過去絵を晒す
//			21, // 公式
			14,	// お知らせ
//			19, // メリクリ

//			0,	// いちほ
//			2,	// 力尽きた
//			3,	// ボツ
//			8,	// 黒歴史
//			11,	// 放置絵を晒す
//			12,	// 挫折
//			13,	// 使い回しハロウィン
//			20, // あけおめ
	};

	public static final int EMOJI_KEYBORD_MAX = 64;
	public static final int EMOJI_CAT_RECENT = 0;
	public static final int EMOJI_CAT_POPULAR = 1;
	public static final int EMOJI_CAT_FOOD = 2;
	public static final int EMOJI_CAT_ALL = 3;
	// For Event
	public static final String[] EMOJI_LIST_EVENT = {
			"🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃","🎃",
		};
	// 絵文字
	public static final String[][] EMOJI_LIST = {
			// 人気
			{},
			// よく使う
			{},
			/*
			// シェアハピ(ポッキーの日)
			{
				"🍓", "🍀", "💐", "😚", "👫", "👬", "👭", "🍼", "💞",
			},
			*/
			/*
			// お菓子(ハロウィン用)
			{
				"🍼", "🍭", "🍬", "🍩", "🍪", "🍫", "🍮", "🍰", "🍦", "🍧",  "🍠", "🍷",
				"🍸", "🍹", "🍺", "🍻", "🍄", "🍇", "🍌", "🍎", "🍏", "🍑", "🍒", "🍓",
			},
			*/
			// おやつ(通常)
			{
				"☕", "🍵", "🍼", "🍡", "🍭", "🍬", "🍩", "🍪", "🍫", "🍮", "🍰", "🎂", "🍦", "🍧", "🍨", "🍯", "🍢", "🍖",
				"🍙", "🍥","🍗", "🍔", "🍟", "🍕", "🍳", "🍲", "🍱", "🍘", "🍚", "🍞", "🍛", "🍜", "🍝", "🍠", "🍣", "🍤",
				"🍶", "🍷", "🍸", "🍹", "🍺", "🍻", "🍄", "🌰", "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🍎", "🍏", "🍐",
				"🍑", "🍒", "🍓", "🍅", "🍆", "🌽", "💊",
			},
			/*
			// 植物
			{
				"💐", "🌸", "💮", "🌹", "🌺", "🌻", "🌼", "🌷", "🌱", "🌲", "🌳", "🌴", "🌵", "🌾", "🌿", "☘", "🍀", "🍁",
				"🍂", "🍃",
			},
			// emotion
			{
				"💪", "🙏", "👣", "👀", "👅", "👄", "💋", "❤", "❣", "💘", "💓", "💔", "💕", "💖", "💗", "💙", "💚", "💛",
				"💜", "💝", "💞", "💟", "💌", "💤", "💨", "💫", "⭐",
			},
			*/
			// 全て
			{
				// Unicode Version 6.1 https://emojipedia.org/unicode-6.1/
				"😀", "😗", "😙", "😛",
				// Unicode Version 6.0 https://emojipedia.org/unicode-6.0/
				"😁", "😂", "😃", "😄", "😆", "😉", "😊", "😋", "😎", "😍", "😘", "😚", "😏", "😌", "😜", "😝", "😢", "😭", "😇", "😺", "😸", "😹", "😻", "😼", "😽", "😿", "👶", "👦", "👧", "👨", "👩", "👴", "👵", "👮", "💂", "👷", "👸", "👳", "👲", "👱", "👰", "👼", "🎅", "🙍", "🙎", "🙆", "💁", "🙋", "🙇", "💆", "💇", "🚶", "🏃", "💃", "👯", "🛀", "👥", "🏇", "🏂", "🏄", "🚣", "🏊", "🚴", "🚵", "👫", "👬", "👭", "💏", "💑", "👪", "💪", "👈", "👉", "👆", "✋", "👌", "👍", "✊", "👊", "👏", "👐", "🙌", "🙏", "💅", "👂", "👃", "👣", "👀", "👄", "💋", "💘", "💓", "💕", "💖", "💗", "💙", "💚", "💛", "💜", "💝", "💞", "💟", "💌", "💫", "👓", "👔", "👕", "👖", "👗", "👘", "👙", "👚", "👛", "👜", "👝", "🎒", "👞", "👟", "👠", "👡", "👢", "👑", "👒", "🎩", "🎓", "💄", "💍", "💎", "🐵", "🐒", "🐶", "🐕", "🐩", "🐺", "🐱", "🐈", "🐯", "🐅", "🐆", "🐴", "🐎", "🐮", "🐂", "🐃", "🐄", "🐷", "🐖", "🐗", "🐽", "🐏", "🐑", "🐐", "🐪", "🐫", "🐘", "🐭", "🐁", "🐀", "🐹", "🐰", "🐇", "🐻", "🐨", "🐼", "🐾", "🐔", "🐓", "🐣", "🐤", "🐥", "🐦", "🐧", "🐸", "🐊", "🐢", "🐍", "🐲", "🐉", "🐳", "🐋", "🐬", "🐟", "🐠", "🐡", "🐙", "🐚", "🐞", "💐", "🌸", "💮", "🌹", "🌺", "🌻", "🌼", "🌷", "🌱", "🌲", "🌳", "🌴", "🌵", "🌾", "🌿", "🍀", "🍁", "🍂", "🍃", "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🍎", "🍏", "🍐", "🍑", "🍒", "🍓", "🍅", "🍆", "🌽", "🍄", "🌰", "🍞", "🍖", "🍗", "🍔", "🍟", "🍕", "🍳", "🍲", "🍱", "🍘", "🍙", "🍚", "🍛", "🍜", "🍝", "🍠", "🍢", "🍣", "🍤", "🍥", "🍡", "🍦", "🍧", "🍨", "🍩", "🍪", "🎂", "🍰", "🍫", "🍬", "🍭", "🍮", "🍯", "🍼", "🍵", "🍶", "🍷", "🍸", "🍹", "🍺", "🍻", "🍴", "🌍", "🌎", "🌏", "🌐", "🗾", "🌋", "🗻", "🏠", "🏡", "🏢", "🏣", "🏤", "🏥", "🏦", "🏨", "🏩", "🏪", "🏫", "🏬", "🏭", "🏯", "🏰", "💒", "🗼", "🗽", "🌁", "🌃", "🌄", "🌅", "🌆", "🌇", "🌉", "🌌", "🎠", "🎡", "🎢", "💈", "🎪", "🚂", "🚃", "🚄", "🚅", "🚆", "🚇", "🚈", "🚉", "🚊", "🚝", "🚞", "🚋", "🚌", "🚍", "🚎", "🚐", "🚑", "🚒", "🚓", "🚔", "🚕", "🚖", "🚗", "🚘", "🚙", "🚚", "🚛", "🚜", "🚲", "🚏", "🚨", "🚥", "🚦", "🚧", "🚤", "🚢", "💺", "🚁", "🚟", "🚠", "🚡", "🚀", "⏳", "⏰", "⏱", "⏲", "🕛", "🕧", "🕐", "🕜", "🕑", "🕝", "🕒", "🕞", "🕓", "🕟", "🕔", "🕠", "🕕", "🕡", "🕖", "🕢", "🕗", "🕣", "🕘", "🕤", "🕙", "🕥", "🕚", "🕦", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘", "🌙", "🌛", "🌜", "🌝", "🌞", "🌟", "🌠", "🌀", "🌈", "🌂", "🌊", "🎃", "🎄", "🎆", "🎇", "✨", "🎈", "🎉", "🎊", "🎋", "🎍", "🎎", "🎏", "🎐", "🎑", "🎀", "🎁", "🎫", "🏆", "🏀", "🏈", "🏉", "🎾", "🎳", "🎣", "🎽", "🎿", "🎯", "🎱", "🔮", "🎮", "🎰", "🎲", "🃏", "🎴", "🎭", "🎨", "🔈", "🔉", "🔊", "📢", "📣", "📯", "🔔", "🎼", "🎵", "🎶", "🎤", "🎧", "📻", "🎷", "🎸", "🎹", "🎺", "🎻", "📱", "📲", "📞", "📟", "📠", "🔋", "🔌", "💻", "💽", "💾", "💿", "📀", "🎥", "🎬", "📺", "📷", "📹", "📼", "🔍", "🔎", "💡", "🔦", "🏮", "📔", "📕", "📖", "📗", "📘", "📙", "📚", "📓", "📒", "📃", "📜", "📄", "📰", "📑", "🔖", "💰", "💴", "💵", "💶", "💷", "💸", "💳", "💹", "💱", "💲", "📧", "📨", "📩", "📤", "📥", "📦", "📫", "📪", "📬", "📭", "📮", "📝", "💼", "📁", "📂", "📅", "📆", "📇", "📈", "📊", "📋", "📌", "📍", "📎", "📏", "📐", "🔒", "🔓", "🔏", "🔐", "🔑", "🔨", "🔫", "🔧", "🔩", "🔗", "🔬", "🔭", "📡", "💉", "💊", "🚪", "🚿", "🛁", "🗿", "🏧", "🚰", "🛂", "🛃", "🛄", "🛅", "🚸", "🔃", "🔄", "🔛", "🔜", "🔝", "🔯", "⛎", "🔀", "🔁", "🔂", "⏩", "⏭", "⏯", "⏪", "⏮", "🔼", "⏫", "🎦", "🔅", "🔆", "📶", "📳", "📴", "🔱", "✅", "➕", "🔟", "💯", "🔠", "🔡", "🔢", "🔣", "🔤", "🅰", "🆎", "🅱", "🆑", "🆒", "🆓", "🆔", "🆕", "🅾", "🆗", "🆙", "🈁", "🈷", "🈶", "🉐", "🈹", "🈸", "🈴", "🈳", "🈺", "🈵", "🔶", "🔷", "🔸", "🔹", "🔺", "💠", "🔘", "🔴", "🔵", "🏁", "🚩", "🎌", "🇱", "🇴", "🇻", "🇪",
				// Unicode Version 5.2 https://emojipedia.org/unicode-5.2/
				"⛷", "⛹", "⛑", "⛰", "⛪", "⛩", "⛲", "⛺", "⛽", "⛵", "⛴", "⛅", "⛱", "⛄", "⚽", "⚾", "⛳", "⛸", "⛓", "⭕", "🅿", "🈯",
				// Unicode Version 5.1 https://emojipedia.org/unicode-5.1/
				"⭐", "🀄",
				// Unicode Version 5.0 https://emojipedia.org/unicode-5.0/

				// Unicode Version 4.1 https://emojipedia.org/unicode-4.1/
				"☘", "⚓", "⚒", "⚔", "⚙", "⚖", "⚗", "⚰", "⚱", "⚛", "♾", "⚕", "⚜",
				// Unicode Version 4.0 https://emojipedia.org/unicode-4.0/
				"☕", "⬆", "⬅", "⏏",
				// Unicode Version 3.2 https://emojipedia.org/unicode-3.2/
				"⤴",
				// Unicode Version 3.0 https://emojipedia.org/unicode-3.0/
				"ℹ",
				// Unicode Version 1.1 https://emojipedia.org/unicode-1.1/
				"☺", "☝", "✌", "✍", "❤", "❣", "♨", "✈", "⌛", "⌚", "☀", "❄", "☃", "☄", "♠", "♥", "♦", "♣", "♟", "☎", "⌨", "✉", "✏", "✒", "✂", "↗", "➡", "↖", "↕", "↔", "↩", "↪", "✡", "☸", "☯", "✝", "☦", "☪", "☮", "♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓", "▶", "◀", "♀", "♂", "✳", "❇", "‼", "©", "®", "™", "Ⓜ", "㊗", "㊙",
			}
		};

	//private static String[] FORBITTED_EMOJI = {"👎"};

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

	public static String AutoLink(String strSrc, int nUserId, int nMode) {
		String ILLUST_LIST = (nMode==CCnv.MODE_SP)?"/SearchIllustByTagV.jsp?KWD=":"/SearchIllustByTagPcV.jsp?KWD=";
		String MY_ILLUST_LIST = (nMode==CCnv.MODE_SP)?String.format("/IllustListV.jsp?ID=%d&KWD=", nUserId):String.format("/IllustListPcV.jsp?ID=%d&KWD=", nUserId);
		return strSrc
				.replaceAll("(http://|https://){1}[\\w\\.\\-/:;&?,=#!~]+","<a class='AutoLink' href='$0' target='_blank'>$0</a>")
				//.replaceAll("([^#])(#)([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", String.format("$1<a class=\"AutoLink\" href=\"javascript:void(0)\" onclick=\"moveTagSearch('%s', '$3')\">$2$3</a>", ILLUST_LIST))
				.replaceAll("([^#])(#)([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", String.format("$1<a class=\"AutoLink\" href=\"%s$3\">$2$3</a>", ILLUST_LIST))
				//.replaceAll("(##)([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", String.format("<a class=\"AutoLinkMyTag\" href=\"javascript:void(0)\" onclick=\"moveTagSearch('%s', '$2')\">$0</a>", MY_ILLUST_LIST))
				.replaceAll("(##)([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", String.format("<a class=\"AutoLinkMyTag\" href=\"%s$2\">$0</a>", MY_ILLUST_LIST))
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
}

package jp.pipa.poipiku;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class Emoji {
	static final int EMOJI_KEYBORD_LINE_DEFAULT = 3;
	//static final int EMOJI_KEYBORD_LINE_MAX = 6;
	static final int EMOJI_KEYBORD_PC = 14;
	//static final int EMOJI_KEYBORD_SP = 8;
	static final int EMOJI_KEYBORD_MAX = EMOJI_KEYBORD_PC*EMOJI_KEYBORD_LINE_DEFAULT;

	public static final int EMOJI_CAT_RECENT = 0;
	public static final int EMOJI_CAT_POPULAR = 1;
	public static final int EMOJI_CAT_FOOD = 2;
	public static final int EMOJI_CAT_OTHER = 3;
	public static final int EMOJI_CAT_CHEER = 4;

	public static final int EMOJI_CHEER_NUM = 16;

	private static final Emoji INSTANCE = new Emoji();
	private Emoji() {}
	public static Emoji getInstance() {
		return INSTANCE;
	}

	public String[][] EMOJI_LIST;
	public List<String> EMOJI_ALL_ARRAY;

	public void init(){
		EMOJI_ALL_ARRAY = Arrays.asList(EMOJI_ALL);

		// 人気
		List<String> listPopular = new ArrayList<>();
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		try {
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();
			strSql = "SELECT description FROM vw_rank_emoji_daily ORDER BY rank DESC LIMIT ?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, EMOJI_KEYBORD_MAX);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				listPopular.add(Util.toString(resultSet.getString(1)).trim());
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}

		List<List<String>> list;
		list = new ArrayList<>();
		list.add(new ArrayList<>()); // 0.人気
		list.add(listPopular); // 1.よく使う
		list.add(new ArrayList<>(Arrays.asList(EMOJI_OYATSU_ALL))); // 2.おやつ
		list.add(new ArrayList<>(EMOJI_ALL_ARRAY)); // 3.その他
		list.add(new ArrayList<>(EMOJI_ALL_ARRAY)); // 4.ポチ袋

		EMOJI_LIST = new String[5][];
		for (int i=0; i<list.size(); i++) {
			EMOJI_LIST[i] = (String[]) list.get(i).toArray(new String[0]);
		}
	}

	// For Event
	public static final boolean EMOJI_EVENT = false;
	//public static final String EMOJI_EVENT_CHAR = "💝";		// X'mas
	public static final String EMOJI_EVENT_CHAR = "🎃";	//Halloween
	public static final String[] EMOJI_EVENT_LIST = {
			EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,
			EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,
			EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,
			EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,
	};

	// 絵文字
	public static final String[] EMOJI_ALL = {
			// Unicode Version 6.1 https://emojipedia.org/unicode-6.1/
			"😀", "😗", "😙",
			// Unicode Version 6.0 https://emojipedia.org/unicode-6.0/
			"😁", "😂", "😃", "😄", "😆", "😉", "😊", "😋", "😎", "😍", "😘", "😚", "😏", "😌", "😜", "😝", "😢", "😭", "😇", "😺", "😸", "😹",
			"😻", "😼", "😽", "😿", "👶", "👦", "👧", "👨", "👩", "👴", "👵", "👮", "💂", "👷", "👸", "👳", "👲", "👱", "👰", "👼", "🎅", "🙍",
			"🙎", "🙆", "💁", "🙋", "🙇", "💆", "💇", "🚶", "🏃", "💃", "👯", "🛀", "👥", "🏇", "🏂", "🏄", "🚣", "🏊", "🚴", "🚵", "👫", "👬",
			"👭", "💏", "💑", "👪", "💪", "👈", "👉", "👆", "✋", "👌", "👍", "✊", "👊", "👏", "👐", "🙌", "🙏", "💅", "👂", "👃", "👣", "👀",
			"👄", "💋", "💘", "💓", "💕", "💖", "💗", "💙", "💚", "💛", "💜", "💝", "💞", "💟", "💌", "💫", "👓", "👔", "👕", "👖", "👗", "👘",
			"👙", "👚", "👛", "👜", "👝", "🎒", "👞", "👟", "👠", "👡", "👢", "👑", "👒", "🎩", "🎓", "💄", "💍", "💎", "🐵", "🐒", "🐶", "🐕",
			"🐩", "🐺", "🐱", "🐈", "🐯", "🐅", "🐆", "🐴", "🐎", "🐮", "🐂", "🐃", "🐄", "🐷", "🐖", "🐗", "🐽", "🐏", "🐑", "🐐", "🐪", "🐫",
			"🐘", "🐭", "🐁", "🐀", "🐹", "🐰", "🐇", "🐻", "🐨", "🐼", "🐾", "🐔", "🐓", "🐣", "🐤", "🐥", "🐦", "🐧", "🐸", "🐊", "🐢", "🐍",
			"🐲", "🐉", "🐳", "🐋", "🐬", "🐟", "🐠", "🐡", "🐙", "🐚", "🐞", "💐", "🌸", "💮", "🌹", "🌺", "🌻", "🌼", "🌷", "🌱", "🌲", "🌳",
			"🌴", "🌵", "🌾", "🌿", "🍀", "🍁", "🍂", "🍃", "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🍎", "🍏", "🍐", "🍑", "🍒", "🍓", "🍅",
			"🍆", "🌽", "🍄", "🌰", "🍞", "🍖", "🍗", "🍔", "🍟", "🍕", "🍳", "🍲", "🍱", "🍘", "🍙", "🍚", "🍛", "🍜", "🍝", "🍠", "🍢", "🍣",
			"🍤", "🍥", "🍡", "🍦", "🍧", "🍨", "🍩", "🍪", "🎂", "🍰", "🍫", "🍬", "🍭", "🍮", "🍯", "🍼", "🍵", "🍶", "🍷", "🍸", "🍹", "🍺",
			"🍻", "🍴", "🌍", "🌎", "🌏", "🌐", "🗾", "🌋", "🗻", "🏠", "🏡", "🏢", "🏣", "🏤", "🏥", "🏦", "🏨", "🏩", "🏪", "🏫", "🏬", "🏭",
			"🏯", "🏰", "💒", "🗼", "🗽", "🌁", "🌃", "🌄", "🌅", "🌆", "🌇", "🌉", "🌌", "🎠", "🎡", "🎢", "💈", "🎪", "🚂", "🚃", "🚄", "🚅",
			"🚆", "🚇", "🚈", "🚉", "🚊", "🚝", "🚞", "🚋", "🚌", "🚍", "🚎", "🚐", "🚑", "🚒", "🚓", "🚔", "🚕", "🚖", "🚗", "🚘", "🚙", "🚚",
			"🚛", "🚜", "🚲", "🚏", "🚨", "🚥", "🚦", "🚧", "🚤", "🚢", "💺", "🚁", "🚟", "🚠", "🚡", "🚀", "⏳", "⏰", "⏱", "⏲", "🕛", "🕧",
			"🕐", "🕜", "🕑", "🕝", "🕒", "🕞", "🕓", "🕟", "🕔", "🕠", "🕕", "🕡", "🕖", "🕢", "🕗", "🕣", "🕘", "🕤", "🕙", "🕥", "🕚", "🕦",
			"🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘", "🌙", "🌛", "🌜", "🌝", "🌞", "🌟", "🌠", "🌀", "🌈", "🌂", "🌊", "🎃", "🎄", "🎆", "🎇",
			"✨", "🎈", "🎉", "🎊", "🎋", "🎍", "🎎", "🎏", "🎐", "🎑", "🎀", "🎁", "🎫", "🏆", "🏀", "🏈", "🏉", "🎾", "🎳", "🎣", "🎽", "🎿",
			"🎯", "🎱", "🔮", "🎮", "🎰", "🎲", "🃏", "🎴", "🎭", "🎨", "🔈", "🔉", "🔊", "📢", "📣", "📯", "🔔", "🎼", "🎵", "🎶", "🎤", "🎧",
			"📻", "🎷", "🎸", "🎹", "🎺", "🎻", "📱", "📲", "📞", "📟", "📠", "🔋", "🔌", "💻", "💽", "💾", "💿", "📀", "🎥", "🎬", "📺", "📷",
			"📹", "📼", "🔍", "🔎", "💡", "🔦", "🏮", "📔", "📕", "📖", "📗", "📘", "📙", "📚", "📓", "📒", "📃", "📜", "📄", "📰", "📑", "🔖",
			"💰", "💴", "💵", "💶", "💷", "💸", "💳", "💹", "💱", "💲", "📧", "📨", "📩", "📤", "📥", "📦", "📫", "📪", "📬", "📭", "📮", "📝",
			"💼", "📁", "📂", "📅", "📆", "📇", "📈", "📊", "📋", "📌", "📍", "📎", "📏", "📐", "🔒", "🔓", "🔏", "🔐", "🔑", "🔨", "🔫", "🔧",
			"🔩", "🔗", "🔬", "🔭", "📡", "💉", "💊", "🚪", "🚿", "🛁", "🗿", "🏧", "🚰", "🛂", "🛃", "🛄", "🛅", "🚸", "🔃", "🔄", "🔛", "🔜",
			"🔝", "🔯", "⛎", "🔀", "🔁", "🔂", "⏩", "⏭", "⏯", "⏪", "⏮", "🔼", "⏫", "🎦", "🔅", "🔆", "📶", "📳", "📴", "🔱", "✅", "➕",
			"🔟", "💯", "🔠", "🔡", "🔢", "🔣", "🔤", "🅰", "🆎", "🅱", "🆑", "🆒", "🆓", "🆔", "🆕", "🅾", "🆗", "🆙", "🈁", "🈷", "🈶", "🉐", "🈹",
			"🈸", "🈴", "🈳", "🈺", "🈵", "🔶", "🔷", "🔸", "🔹", "🔺", "💠", "🔘", "🔴", "🔵", "🏁", "🚩", "🎌", "🇱", "🇴", "🇻", "🇪",
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
			"☺", "☝", "✌", "✍", "❤", "❣", "♨", "✈", "⌛", "⌚", "☀", "❄", "☃", "☄", "♠", "♥", "♦", "♣", "♟", "☎", "⌨", "✉", "✏", "✒", "↗", "➡", "↖",
			"↕", "↔", "↩", "↪", "✡", "☸", "☯", "✝", "☦", "☪", "☮", "♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓", "▶", "◀", "♀", "♂", "✳", "❇",
			"‼", "©", "®", "™", "Ⓜ", "㊗", "㊙",
	};

	public static final String[] EMOJI_OYATSU_ALL = {
			"☕", "🍵", "🍼", "🍡", "🍭", "🍬", "🍩", "🍪", "🍫", "🍮", "🍰", "🎂", "🍦", "🍧", "🍨", "🍯", "🍢", "🍖",
			"🍙", "🍥","🍗", "🍔", "🍟", "🍕", "🍳", "🍲", "🍱", "🍘", "🍚", "🍞", "🍛", "🍜", "🍝", "🍠", "🍣", "🍤",
			"🍶", "🍷", "🍸", "🍹", "🍺", "🍻", "🍄", "🌰", "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🍎", "🍏", "🍐",
			"🍑", "🍒", "🍓", "🍅", "🍆", "🌽", "💊",
	};


	public static final String[][] __EMOJI_LIST = {
			// 人気
			{},
			// よく使う
			{},
			/*
			// 使いまわしバレンタイン
			{
				"🇱", "🇴", "🇻", "🇪", "❤", "❣", "♥", "💒", "🏩", "💏", "💑", "😍", "😻", "💞", "💟", "💌", "💘", "💓", "💕", "💖", "💗", "💙", "💚", "💛", "💜", "💝",
			},
			*/
			/*
			// 使いまわし年賀状
			{
				"🐭", "🐮", "🐯", "🐰", "🐲", "🐍", "🐎", "🐑", "🐵", "🐔", "🐶", "🐗", "💴", "💰", "👛", "🍱", "🗻", "🍆", "🎍", "🌄", "⛩", "🙏", "🍊",
			},
			*/
			/*
			// x'mas
			{
				"🎅", "🎄", "🎁", "💝", "🍰", "🎉", "🎀", "⛄", "❄", "🌟",
			},
			*/
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
			// おやつ
			{},
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
			// その他
			{},
			// ポチ袋
			{}
	};

	//private static String[] FORBITTED_EMOJI = {"👎"};

	public static ArrayList<String> getDefaultEmoji(int nUserId) {
		ArrayList<String> vResult = new ArrayList<String>();

		if(EMOJI_EVENT) {	// イベント用
			for(String emoji : EMOJI_EVENT_LIST) {
				vResult.add(emoji);
			}
		} else {	// 通常時
			DataSource dataSource = null;
			Connection connection = null;
			PreparedStatement statement = null;
			ResultSet resultSet = null;
			String strSql = "";
			try {
				dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
				connection = dataSource.getConnection();

				if(nUserId>0) {
					strSql = "SELECT description FROM vw_comments_0000_last_7days WHERE user_id=? GROUP BY description ORDER BY count(description) DESC LIMIT ?";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, nUserId);
					statement.setInt(2, EMOJI_KEYBORD_MAX);
					resultSet = statement.executeQuery();
					while (resultSet.next()) {
						vResult.add(Util.toString(resultSet.getString(1)).trim());
					}
					resultSet.close();resultSet=null;
					statement.close();statement=null;
					if(vResult.size()>0 && vResult.size()<EMOJI_KEYBORD_MAX){
						strSql = "SELECT description FROM vw_rank_emoji_daily WHERE description NOT IN(SELECT description FROM vw_comments_0000_last_7days WHERE user_id=?) ORDER BY rank DESC LIMIT ?";
						statement = connection.prepareStatement(strSql);
						statement.setInt(1, nUserId);
						statement.setInt(2, EMOJI_KEYBORD_MAX-vResult.size());
						resultSet = statement.executeQuery();
						while (resultSet.next()) {
							vResult.add(Util.toString(resultSet.getString(1)).trim());
						}
						resultSet.close();resultSet=null;
						statement.close();statement=null;
					}
				}
				if(vResult.size()<EMOJI_KEYBORD_MAX){
					strSql = "SELECT description FROM vw_rank_emoji_daily ORDER BY rank DESC LIMIT ?";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, EMOJI_KEYBORD_MAX-vResult.size());
					resultSet = statement.executeQuery();
					while (resultSet.next()) {
						vResult.add(Util.toString(resultSet.getString(1)).trim());
					}
					resultSet.close();resultSet=null;
					statement.close();statement=null;
				}

				/*
				// vw_user_emoji_minuteバージョン
				if(nUserId>0) {
					strSql = "SELECT description FROM vw_user_emoji_minute WHERE user_id=? ORDER BY description_count DESC LIMIT ?";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, nUserId);
					statement.setInt(2, EMOJI_KEYBORD_MAX);
					resultSet = statement.executeQuery();
					while (resultSet.next()) {
						vResult.add(Util.toString(resultSet.getString(1)).trim());
					}
					resultSet.close();resultSet=null;
					statement.close();statement=null;
					if(vResult.size()>0 && vResult.size()<EMOJI_KEYBORD_MAX){
						strSql = "SELECT description FROM vw_rank_emoji_daily WHERE description NOT IN("+strSql+") ORDER BY rank DESC LIMIT ?";
						statement = connection.prepareStatement(strSql);
						statement.setInt(1, nUserId);
						statement.setInt(2, EMOJI_KEYBORD_MAX);
						statement.setInt(3, EMOJI_KEYBORD_MAX-vResult.size());
						resultSet = statement.executeQuery();
						while (resultSet.next()) {
							vResult.add(Util.toString(resultSet.getString(1)).trim());
						}
						resultSet.close();resultSet=null;
						statement.close();statement=null;
					}
				}
				if(vResult.size()<EMOJI_KEYBORD_MAX){
					strSql = "SELECT description FROM vw_rank_emoji_daily ORDER BY rank DESC LIMIT ?";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, EMOJI_KEYBORD_MAX-vResult.size());
					resultSet = statement.executeQuery();
					while (resultSet.next()) {
						vResult.add(Util.toString(resultSet.getString(1)).trim());
					}
					resultSet.close();resultSet=null;
					statement.close();statement=null;
				}
				*/
			} catch(Exception e) {
				Log.d(strSql);
				e.printStackTrace();
			} finally {
				try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
				try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
				try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
			}
		}
		return vResult;
	}
}

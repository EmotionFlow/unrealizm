package jp.pipa.poipiku;

import javax.naming.InitialContext;
import javax.sql.*;

import java.sql.Array;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Emoji {
    public static final int EMOJI_KEYBORD_MAX = 64;
    public static final int EMOJI_CAT_RECENT = 0;
    public static final int EMOJI_CAT_POPULAR = 1;
    public static final int EMOJI_CAT_FOOD = 2;
    public static final int EMOJI_CAT_OTHER = 3;
    public static final int EMOJI_CAT_CHEER = 4;

    private static final Emoji INSTANCE = new Emoji();
    private Emoji() {}
    public static Emoji getInstance() {
        return INSTANCE;
    }

    public String[][] EMOJI_LIST;
    public List<String> EMOJI_CHEER_ARRAY;
    public List<String> EMOJI_ALL_ARRAY;

    public void init(){
        EMOJI_ALL_ARRAY = Arrays.asList(EMOJI_ALL);

        List<List<String>> list;
        list = new ArrayList<>();
        list.add(new ArrayList<>()); // 0.人気
        list.add(new ArrayList<>()); // 1.よく使う
        list.add(new ArrayList<>(Arrays.asList(EMOJI_OYATSU_ALL))); // 2.おやつ
        list.add(new ArrayList<>(EMOJI_ALL_ARRAY)); // 3.その他
        list.add(new ArrayList<>()); // 4.ポチ袋

        // ポチ袋（前日TOP16）
        String strSql = "SELECT description, count(description) cnt" +
                " FROM comments_0000" +
                " WHERE upload_date BETWEEN current_timestamp - interval '24 hours' AND current_timestamp" +
                " GROUP BY description" +
                " ORDER BY cnt DESC" +
                " LIMIT 16";
        DataSource dsPostgres = null;
        Connection cConn = null;
        PreparedStatement cState = null;
        ResultSet cResSet = null;

        try {
            Class.forName("org.postgresql.Driver");
            dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
            cConn = dsPostgres.getConnection();

            cState = cConn.prepareStatement(strSql);
            cResSet = cState.executeQuery();

            while(cResSet.next()){
                list.get(EMOJI_CAT_CHEER).add(cResSet.getString(1));
            }

            cResSet.close();cResSet=null;
            cState.close();cState=null;
            cConn.close();cConn=null;

        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
            try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
            try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
        }

        // その他とおやつからポチ袋絵文字を除外する
        list.get(EMOJI_CAT_FOOD).removeAll(list.get(EMOJI_CAT_CHEER));
        list.get(EMOJI_CAT_OTHER).removeAll(list.get(EMOJI_CAT_CHEER));

        EMOJI_CHEER_ARRAY = list.get(EMOJI_CAT_CHEER);
        EMOJI_LIST = new String[5][];
        for (int i=0; i<list.size(); i++) {
            EMOJI_LIST[i] = (String[]) list.get(i).toArray(new String[0]);
        }
    }

    // For Event
    public static final boolean EMOJI_EVENT = false;
    public static final String EMOJI_EVENT_CHAR = "💝";		// X'mas
    //public static final String EMOJI_EVENT_CHAR = "🎃";	//Halloween
    public static final String[] EMOJI_EVENT_LIST = {
            EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,
            EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,
            EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,
            EMOJI_EVENT_CHAR,EMOJI_EVENT_CHAR,
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
            // おやつ(おやつ全てからポチ袋を除いたもの)
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
            // その他(全てからポチ袋を除いたもの)
            {},
            // ポチ袋
            {}
    };

    //private static String[] FORBITTED_EMOJI = {"👎"};

}

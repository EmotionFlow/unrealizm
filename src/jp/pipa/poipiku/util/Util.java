package jp.pipa.poipiku.util;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

import javax.naming.InitialContext;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import jp.pipa.poipiku.*;

public final class Util {
	private static final Map<String, String> GenEiFontMapDakuten;
	private static final Map<String, String> GenEiFontMapHanDakuten;
	private static final Map<String, String> GenEiFontMapOther;
	static {
		Map<String, String> mapDakuten = new LinkedHashMap<>();
		char c = (char) 0xe082;
		mapDakuten.put("あ", Character.toString(c++));
		mapDakuten.put("い", Character.toString(c++));
		mapDakuten.put("え", Character.toString(c++));
		mapDakuten.put("お", Character.toString(c++));
		mapDakuten.put("ん", Character.toString(c++));

		mapDakuten.put("ア", Character.toString(c++));
		mapDakuten.put("イ", Character.toString(c++));
		mapDakuten.put("エ", Character.toString(c++));
		mapDakuten.put("オ", Character.toString(c++));
		mapDakuten.put("ン", Character.toString(c++));

		c = (char) 0xe09a;
		mapDakuten.put("な", Character.toString(c++));
		mapDakuten.put("に", Character.toString(c++));
		mapDakuten.put("ぬ", Character.toString(c++));
		mapDakuten.put("ね", Character.toString(c++));
		mapDakuten.put("の", Character.toString(c++));

		mapDakuten.put("ま", Character.toString(c++));
		mapDakuten.put("み", Character.toString(c++));
		mapDakuten.put("む", Character.toString(c++));
		mapDakuten.put("め", Character.toString(c++));
		mapDakuten.put("も", Character.toString(c++));

		mapDakuten.put("や", Character.toString(c++));
		mapDakuten.put("ゆ", Character.toString(c++));
		mapDakuten.put("よ", Character.toString(c++));

		mapDakuten.put("ら", Character.toString(c++));
		mapDakuten.put("り", Character.toString(c++));
		mapDakuten.put("る", Character.toString(c++));
		mapDakuten.put("れ", Character.toString(c++));
		mapDakuten.put("ろ", Character.toString(c++));

		mapDakuten.put("わ", Character.toString(c++));
		mapDakuten.put("ゐ", Character.toString(c++));
		mapDakuten.put("ゑ", Character.toString(c++));
		mapDakuten.put("を", Character.toString(c++));

		mapDakuten.put("ぁ", Character.toString(c++));
		mapDakuten.put("ぃ", Character.toString(c++));
		mapDakuten.put("ぅ", Character.toString(c++));
		mapDakuten.put("ぇ", Character.toString(c++));
		mapDakuten.put("ぉ", Character.toString(c++));

		mapDakuten.put("ゕ", Character.toString(c++));
		mapDakuten.put("ゖ", Character.toString(c++));
		mapDakuten.put("っ", Character.toString(c++));
		mapDakuten.put("ゃ", Character.toString(c++));
		mapDakuten.put("ゅ", Character.toString(c++));
		mapDakuten.put("ょ", Character.toString(c++));
		mapDakuten.put("ゎ", Character.toString(c++));

		mapDakuten.put("ナ", Character.toString(c++));
		mapDakuten.put("ニ", Character.toString(c++));
		mapDakuten.put("ヌ", Character.toString(c++));
		mapDakuten.put("ネ", Character.toString(c++));
		mapDakuten.put("ノ", Character.toString(c++));

		mapDakuten.put("マ", Character.toString(c++));
		mapDakuten.put("ミ", Character.toString(c++));
		mapDakuten.put("ム", Character.toString(c++));
		mapDakuten.put("メ", Character.toString(c++));
		mapDakuten.put("モ", Character.toString(c++));

		mapDakuten.put("ヤ", Character.toString(c++));
		mapDakuten.put("ユ", Character.toString(c++));
		mapDakuten.put("ヨ", Character.toString(c++));

		mapDakuten.put("ラ", Character.toString(c++));
		mapDakuten.put("リ", Character.toString(c++));
		mapDakuten.put("ル", Character.toString(c++));
		mapDakuten.put("レ", Character.toString(c++));
		mapDakuten.put("ロ", Character.toString(c++));

		mapDakuten.put("ァ", Character.toString(c++));
		mapDakuten.put("ィ", Character.toString(c++));
		mapDakuten.put("ゥ", Character.toString(c++));
		mapDakuten.put("ェ", Character.toString(c++));
		mapDakuten.put("ォ", Character.toString(c++));

		mapDakuten.put("ヵ", Character.toString(c++));
		mapDakuten.put("ヶ", Character.toString(c++));
		mapDakuten.put("ッ", Character.toString(c++));

		mapDakuten.put("ャ", Character.toString(c++));
		mapDakuten.put("ュ", Character.toString(c++));
		mapDakuten.put("ョ", Character.toString(c++));
		mapDakuten.put("ヮ", Character.toString(c++));

		GenEiFontMapDakuten = Collections.unmodifiableMap(mapDakuten);

		Map<String, String> mapHanDakuten = new LinkedHashMap<>();
		c = (char) 0xe08c;
		mapHanDakuten.put("か", Character.toString(c++));
		mapHanDakuten.put("き", Character.toString(c++));
		mapHanDakuten.put("く", Character.toString(c++));
		mapHanDakuten.put("け", Character.toString(c++));
		mapHanDakuten.put("こ", Character.toString(c++));

		mapHanDakuten.put("カ", Character.toString(c++));
		mapHanDakuten.put("キ", Character.toString(c++));
		mapHanDakuten.put("ク", Character.toString(c++));
		mapHanDakuten.put("ケ", Character.toString(c++));
		mapHanDakuten.put("コ", Character.toString(c++));

		mapHanDakuten.put("セ", Character.toString(c++));
		mapHanDakuten.put("ツ", Character.toString(c++));
		mapHanDakuten.put("ト", Character.toString(c++));
		mapHanDakuten.put("ㇷ", Character.toString(c++));

		GenEiFontMapHanDakuten = Collections.unmodifiableMap(mapHanDakuten);

		Map<String, String> mapOther = new LinkedHashMap<>();
		mapOther.put("!!!", Character.toString((char) 0xe007));
		mapOther.put("!!", Character.toString((char) 0xe002));
		mapOther.put("\\?\\?", Character.toString((char) 0xe003));
		mapOther.put("\\?!", Character.toString((char) 0xe004));
		mapOther.put("!\\?", Character.toString((char) 0xe005));
		mapOther.put("!", Character.toString((char) 0xe000));
		mapOther.put("\\?", Character.toString((char) 0xe001));
		GenEiFontMapOther = Collections.unmodifiableMap(mapOther);

	}

	public static String getHashPass(final String strPassword) {
		String strRtn = "";
		try {
			MessageDigest md5 = MessageDigest.getInstance("SHA-256");
			md5.reset();
			md5.update((strPassword + Math.random()).getBytes());
			byte[] hash= md5.digest();
			StringBuilder sb= new StringBuilder();
			for (int b : hash) {
				int d = b;
				if (d < 0) d += 256;
				String m = Integer.toString(d, 16);
				if (d < 16) {
					m = String.format("%1$02x", d);
				}
				sb.append(m);
			}
			strRtn = sb.toString();
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			;
		}
		return strRtn;
	}


	public static String toString(final String strSrc) {
		return strSrc == null ? "" : strSrc;
	}

	public static String toStringHtml(String strSrc) {
		if(strSrc == null) return "";

		strSrc = strSrc.replace("\r\n", "\n")
						.replace("\r", "\n")
						.replace("&", "&amp;")
						.replace("<", "&lt;")
						.replaceAll(">", "&gt;")
						.replaceAll("\n", "<br />")
						.replaceAll("'", "&apos;")
						.replaceAll("\"", "&quot;");

		return strSrc;
	}

	public static String toStringHtmlTextarea(String strSrc) {
		if(strSrc == null) return "";

		strSrc = strSrc.replace("&", "&amp;")
						.replace("<", "&lt;")
						.replaceAll(">", "&gt;")
						.replaceAll("'", "&apos;")
						.replaceAll("\"", "&quot;");

		return strSrc;
	}


	public static int toInt(final String strSrc) {
		if(strSrc == null) return -1;

		int nRet;
		try {
			nRet = Integer.parseInt(strSrc);
		} catch (Exception e) {
			nRet = -1;
		}
		return nRet;
	}

	public static int toIntN(final String strSrc, final int nMin, final int nMax) {
		if(strSrc == null) return nMin;

		int nRet;
		try {
			nRet = Integer.parseInt(strSrc);
		} catch (Exception e) {
			nRet = nMin;
		}
		nRet = Math.min(Math.max(nRet, nMin), nMax);

		return nRet;
	}

	public static int toIntN(final int nSrc, final int nMin, final int nMax) {
		return Math.min(Math.max(nSrc, nMin), nMax);
	}

	public static long toLong(final String strSrc) {
		if(strSrc == null) return -1;

		long nRet;
		try {
			nRet = Long.parseLong(strSrc);
		} catch (Exception e) {
			nRet = -1;
		}
		return nRet;
	}

	public static boolean toBoolean(final String strSrc){
		if(strSrc == null) return false;

		try{
			int n = Integer.parseInt(strSrc, 10);
			return toBoolean(n);
		} catch (NumberFormatException ne){
			boolean b = false;
			b = Boolean.parseBoolean(strSrc);
			return b;
		}
	}

	public static boolean toBoolean(final int strSrc){
		boolean b = false;
		if(strSrc >= 1) b = true;
		return b;
	}

	public static Timestamp toSqlTimestamp(final String strSrc){
		if(strSrc == null) return null;
		if(strSrc.isEmpty()) return null;

		// ISO format 2011-10-05T14:48:00.000Z を想定
		ZonedDateTime zdt = ZonedDateTime.parse(strSrc);
		return Timestamp.from(zdt.toInstant());
	}

	public static String toYMDHMString(final Timestamp ts){
		if(ts==null) return "";

		LocalDateTime ldt = ts.toLocalDateTime();
		ZonedDateTime zdtSystemDefault = ldt.atZone(ZoneId.systemDefault());
		ZonedDateTime zdtGmt = zdtSystemDefault.withZoneSameInstant(ZoneId.of("GMT"));
		return zdtGmt.format(DateTimeFormatter.ISO_INSTANT);
	}

	public static boolean isSmartPhone(final HttpServletRequest request) {
		final String useragent = toString(request.getHeader("user-agent"));
		//String strReferer = toString(request.getHeader("Referer"));

		//if(strReferer.indexOf("poipiku.com")<0) {
			if(	(useragent.indexOf("iPhone")>=0 && useragent.indexOf("iPad")<0) ||
					useragent.indexOf("iPod")>=0 ||
					(useragent.indexOf("Android")>=0 && useragent.indexOf("Mobile")>=0)) {
				return true;
			}
		//}
		return false;
	}

	public static boolean isIOS(HttpServletRequest request) {
		String strUa = toString(request.getHeader("user-agent"));
		return (strUa.indexOf("iPhone")>=0 || strUa.indexOf("iPad")>=0 || strUa.indexOf("iPod")>=0);
	}

	public static boolean needUpdate(int nVersion) {
		for(int ver : Common.NO_NEED_UPDATE) {
			if(nVersion==ver) return false;
		}
		return true;
	}

	public static String changeExtension(String inputData, String extention) {
		String returnVal = null;

		if (inputData == null || extention == null || inputData.isEmpty() || extention.isEmpty()) return "";

		File in = new File(inputData);
		String fileName = in.getName();

		if (fileName.lastIndexOf(".") < 0) {
			returnVal = inputData + "." + extention;
		} else {
			int postionOfFullPath = inputData.lastIndexOf("."); // フルパスの
			String pathWithoutExt = inputData.substring(0, postionOfFullPath);
			returnVal = pathWithoutExt + "." + extention;
		}
		return returnVal;
	}

	public static String toDescString(String strSrc) {
		if(strSrc == null) {
			return "";
		}
		//strSrc = deleteCrLf(strSrc);
		strSrc = strSrc.replace("&", "&amp;");
		strSrc = strSrc.replace("<", "&lt;");
		strSrc = strSrc.replaceAll(">", "&gt;");
		strSrc = strSrc.replaceAll("'", "&apos;");
		strSrc = strSrc.replaceAll("\"", "&quot;");

		return strSrc;
	}

	public static String deleteCrLf(String strSrc) {
		if(strSrc == null) {
			return "";
		}
		strSrc = strSrc.replace("\r", "");
		strSrc = strSrc.replace("\n", "");
		return strSrc;
	}

	public static String replaceCrLf2Space(String strSrc) {
		if(strSrc == null) {
			return "";
		}
		strSrc = strSrc.replace("\r", " ");
		strSrc = strSrc.replace("\n", " ");
		return strSrc;
	}

	public static String subStrNum(String strSrc, int nNum) {
		if(strSrc==null) return "";
		if(strSrc.length()<=nNum) return strSrc;
		return strSrc.substring(0, nNum);
	}

	public static String poipiku_336x280_sp_mid(CheckLogin checkLogin) {
		if(checkLogin.m_nPassportId>=Common.PASSPORT_ON) return "";
		StringBuilder sbRtn = new StringBuilder();

		sbRtn.append("<div class=\"SideBarMid\">");
		int nRand = (int)(Math.random()*10000);
		sbRtn.append("<!-- /4789880/poipiku/poipikumobile_336x280_mid -->");
		sbRtn.append("<div id='div-gpt-ad-1592940074228-").append(nRand).append("'>");

		// adrea
		//sbRtn.append("<script src=\"//ad.adpon.jp/fr.js?fid=2fbe0897-f359-45ae-9561-dc172561ce91\"></script>");

		// Ad Manager
		sbRtn.append("<script>");
		sbRtn.append("googletag.cmd.push(function() {");
		sbRtn.append("googletag.defineSlot('/4789880/poipiku/poipikumobile_336x280_mid', [[336, 280], [300, 250]], 'div-gpt-ad-1592940074228-").append(nRand).append("').addService(googletag.pubads());");
		sbRtn.append("googletag.enableServices();");
		sbRtn.append("googletag.display('div-gpt-ad-1592940074228-").append(nRand).append("');");
		sbRtn.append("});");
		sbRtn.append("</script>");

		sbRtn.append("</div>");
		sbRtn.append("</div>");
		return sbRtn.toString();

	}

	public static String poipiku_336x280_pc_mid(CheckLogin checkLogin) {
		if(checkLogin.m_nPassportId>=Common.PASSPORT_ON) return "";
		StringBuilder sbRtn = new StringBuilder();
		sbRtn.append("<div class=\"PcSideBarAd\">");
		sbRtn.append("<!-- /4789880/poipiku/poipiku_336x280_mid -->");
		int nRand = (int)(Math.random()*10000);
		sbRtn.append("<div id='div-gpt-ad-1592940074228-").append(nRand).append("'>");
		sbRtn.append("<script>");
		sbRtn.append("googletag.cmd.push(function() {");
		sbRtn.append("googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid', [[336, 280], [300, 250]], 'div-gpt-ad-1592940074228-").append(nRand).append("').addService(googletag.pubads());");
		sbRtn.append("googletag.enableServices();");
		sbRtn.append("googletag.display('div-gpt-ad-1592940074228-").append(nRand).append("');");
		sbRtn.append("});");
		sbRtn.append("</script>");
		sbRtn.append("</div>");
		sbRtn.append("</div>");
		return sbRtn.toString();
	}

	private static final List<String> vBot = Arrays.asList(
			"ia_archiver",
			"archive.org_bot",
			"Baidu",
			"BecomeBot",
			"bingbot",
			"DotBot",
			//"Googlebot",
			"Hatena",
			"heritr",
			"ICC-Crawler",
			"ichiro",
			"MJ12bo",
			"msnbot",
			"NaverBot",
			"OutfoxBot",
			"Pockey",
			"Purebot",
			"SiteBot",
			"Steeler",
			"TurnitinBot",
			"Twiceler",
			"Websi",
			"Wget",
			"Y!J",
			"Yahoo!",
			"YandexBot",
			"Yeti",
			"YodaoBot",
			"Pinterestbot");

	public static boolean isBot(final HttpServletRequest request) {
		final String agent =  Util.toString(request.getHeader("user-agent")).trim();
		if(agent.isEmpty()) return true;
		return vBot.contains(agent);
	}

	public static String toSingle(String strSrc) {
		String han = "1234567890";
		String zen = "１２３４５６７８９０";
		String strDst = strSrc;
		for(int i=0; i<zen.length(); i++) {
			strDst = strDst.replace(zen.charAt(i), han.charAt(i));
		}
		return strDst;
	}

	public static String getTwitterIntentURL(String strText, String strUrl) throws UnsupportedEncodingException {
		StringBuffer sb = new StringBuffer();
		sb.append("https://twitter.com/intent/tweet?text=")
				.append(URLEncoder.encode(strText, "UTF-8"))
				.append("&url=")
				.append(URLEncoder.encode(strUrl, "UTF-8"));
		return sb.toString();
	}

	/*
	public static String getKana(String strTxt) {
		if(strTxt.trim().isEmpty()) return "";
		StringBuilder sbRet = new StringBuilder();
		try {
			Tokenizer tokenizer = new Tokenizer();
			List<Token> tokens = tokenizer.tokenize(strTxt.trim());
			for (Token token : tokens) {
				sbRet.append(token.getReading());
			}
		} catch(Exception e) {
			;
		}
		boolean bConvert = false;
		for(int i=0; i<sbRet.length(); i++) {
			if(sbRet.charAt(i)!='*') {
				bConvert = true;
				break;
			}
		}
		return (bConvert)?sbRet.toString():"";
	}
	*/


	public static void deleteFile(String strFileName) {
		if(strFileName==null || strFileName.isEmpty()) return;
		File oDelFile = new File(strFileName);
		if(!oDelFile.isFile()) return;
		if(oDelFile.exists()) oDelFile.delete();
	}

	public static void setCookie(HttpServletResponse response, String name, String value, int expiry) {
		try {
			Cookie cLK = new Cookie(name , value);
			cLK.setMaxAge(expiry);
			cLK.setPath("/");
			response.addCookie(cLK);
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public static String getCookie(HttpServletRequest request, String name) {
		String value = null;
		try {
			Cookie cookies[] = request.getCookies();
			if(cookies == null) return null;
			for(Cookie cookie : cookies) {
				if(cookie.getName().equals(name)) {
					value = Common.EscapeInjection(URLDecoder.decode(cookie.getValue(), "UTF-8"));
					break;
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		return value;
	}

	public static void deleteCookie(HttpServletResponse response, String name) {
		setCookie(response, name, "", -1);
	}

	public static Genre getGenre(int genreId) {
		String strSql = "";
		Genre genre = new Genre();
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// Get info_list
			strSql = "SELECT * FROM genres WHERE genre_id=? LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, genreId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				genre = new Genre(resultSet);
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
		return genre;
	}

	public static Genre getGenre(String genreName) {
		String strSql = "";
		Genre genre = new Genre();
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// Get info_list
			strSql = "SELECT * FROM genres WHERE genre_name=? LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setString(1, genreName);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				genre = new Genre(resultSet);
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
		return genre;
	}

	public static String getUploadGenrePath() {
		String path = "/user_img01/genre_img";
		return path;
	}

	public static String escapeJsonString(CharSequence cs) {
		final byte BACKSLASH = 0x5C;
		final byte[] BS = new byte[]{BACKSLASH, 0x62};  /* \\b */
		final byte[] HT = new byte[]{BACKSLASH, 0x74};  /* \\t */
		final byte[] LF = new byte[]{BACKSLASH, 0x6E};  /* \\n */
		final byte[] FF = new byte[]{BACKSLASH, 0x66};  /* \\f */
		final byte[] CR = new byte[]{BACKSLASH, 0x72};  /* \\r */
		try (
				ByteArrayOutputStream strm = new ByteArrayOutputStream();
		) {
			byte[] bb = cs.toString().getBytes(StandardCharsets.UTF_8);
			for (byte b : bb) {
				if (b == 0x08 /* BS */) {
					strm.write(BS);
				} else if (b == 0x09 /* HT */) {
					strm.write(HT);
				} else if (b == 0x0A /* LF */) {
					strm.write(LF);
				} else if (b == 0x0C /* FF */) {
					strm.write(FF);
				} else if (b == 0x0D /* CR */) {
					strm.write(CR);
				} else if (
					b == 0x22 /* " */
					|| b == 0x2F /* / */
					|| b == BACKSLASH /* \\ */
				) {
					strm.write(BACKSLASH);
					strm.write(b);
				} else {
					strm.write(b);
				}
			}
			return new String(strm.toByteArray(), StandardCharsets.UTF_8);
		} catch (IOException e) {
			e.printStackTrace();
			throw new RuntimeException(e);
		}
	}

	private static String _replaceForGenEiFontDakuten(String text, final String target, final char replace) {
		text = text.replaceAll(target + "゛", Character.toString(replace));
		text = text.replaceAll(target + "ﾞ", Character.toString(replace));
		return text;
	}
	
	public static String replaceForGenEiFont(String str) {
		if (str==null || str.isEmpty()) return str;
		String s = str;
		for (Map.Entry<String, String> entry : GenEiFontMapDakuten.entrySet()) {
			s = s.replaceAll(entry.getKey() + "゛", entry.getValue());
			s = s.replaceAll(entry.getKey() + "ﾞ", entry.getValue());
		}
		for (Map.Entry<String, String> entry : GenEiFontMapHanDakuten.entrySet()) {
			s = s.replaceAll(entry.getKey() + "゜", entry.getValue());
			s = s.replaceAll(entry.getKey() + "ﾟ", entry.getValue());
		}
		for (Map.Entry<String, String> entry : GenEiFontMapOther.entrySet()) {
			s = s.replaceAll(entry.getKey(), entry.getValue());
		}
		return s;
	}
}

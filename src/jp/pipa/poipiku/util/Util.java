package jp.pipa.poipiku.util;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;

import javax.naming.InitialContext;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import jp.pipa.poipiku.*;

public class Util {
	public static String getHashPass(String strPassword) {
		String strRtn = "";
		try {
			MessageDigest md5 = MessageDigest.getInstance("SHA-256");
			md5.reset();
			md5.update((strPassword + Math.random()).getBytes());
			byte[] hash= md5.digest();
			StringBuffer sb= new StringBuffer();
			for(int i=0; i<hash.length; i++) {
				int d = hash[i];
				if(d < 0) d += 256;
				String m = Integer.toString(d, 16);
				if(d < 16) {
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


	public static String toString(String strSrc) {
		if(strSrc == null) return "";

		return strSrc;
	}

	public static String toStringHtml(String strSrc) {
		if(strSrc == null) return "";

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

	public static String toStringHtmlTextarea(String strSrc) {
		if(strSrc == null) return "";

		strSrc = strSrc.replace("&", "&amp;");
		strSrc = strSrc.replace("<", "&lt;");
		strSrc = strSrc.replaceAll(">", "&gt;");
		strSrc = strSrc.replaceAll("'", "&apos;");
		strSrc = strSrc.replaceAll("\"", "&quot;");

		return strSrc;
	}


	public static int toInt(String strSrc) {
		if(strSrc == null) return -1;

		int nRet = -1;
		try {
			nRet = Integer.parseInt(strSrc);
		} catch (Exception e) {
			nRet = -1;
		}
		return nRet;
	}

	public static int toIntN(String strSrc, int nMin, int nMax) {
		if(strSrc == null) return nMin;

		int nRet = nMin;
		try {
			nRet = Integer.parseInt(strSrc);
		} catch (Exception e) {
			nRet = nMin;
		}
		nRet = Math.min(Math.max(nRet, nMin), nMax);

		return nRet;
	}

	public static long toLong(String strSrc) {
		if(strSrc == null) return -1;

		long nRet = -1;
		try {
			nRet = Long.parseLong(strSrc);
		} catch (Exception e) {
			nRet = -1;
		}
		return nRet;
	}

	public static boolean toBoolean(String strSrc){
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

	public static boolean toBoolean(int strSrc){
		boolean b = false;
		if(strSrc >= 1) b = true;
		return b;
	}

	public static Timestamp toSqlTimestamp(String strSrc){
		if(strSrc == null) return null;
		if(strSrc.isEmpty()) return null;

		// ISO format 2011-10-05T14:48:00.000Z を想定
		ZonedDateTime zdt = ZonedDateTime.parse(strSrc);
		return Timestamp.from(zdt.toInstant());
	}

	public static String toYMDHMString(Timestamp ts){
		if(ts==null) return "";

		LocalDateTime ldt = ts.toLocalDateTime();
		ZonedDateTime zdtSystemDefault = ldt.atZone(ZoneId.systemDefault());
		ZonedDateTime zdtGmt = zdtSystemDefault.withZoneSameInstant(ZoneId.of("GMT"));
		return zdtGmt.format(DateTimeFormatter.ISO_INSTANT);
	}

	public static boolean isSmartPhone(HttpServletRequest request) {
		String strUuserAgent = toString(request.getHeader("user-agent"));
		//String strReferer = toString(request.getHeader("Referer"));

		//if(strReferer.indexOf("poipiku.com")<0) {
			if(	(strUuserAgent.indexOf("iPhone")>=0 && strUuserAgent.indexOf("iPad")<0) ||
					strUuserAgent.indexOf("iPod")>=0 ||
					(strUuserAgent.indexOf("Android")>=0 && strUuserAgent.indexOf("Mobile")>=0)) {
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

	public static boolean isBot(HttpServletRequest request) {
		String agent =  Util.toString(request.getHeader("user-agent")).trim();
		if(agent.isEmpty()) return true;
		final List<String> vBot = Arrays.asList(
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

}

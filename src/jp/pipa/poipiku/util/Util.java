package jp.pipa.poipiku.util;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
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


	public static ArrayList<String> getDefaultEmoji(int nUserId, int nLimitNum) {
		ArrayList<String> vResult = new ArrayList<String>();

		if(Common.EMOJI_EVENT) {	// イベント用
			for(String emoji : Common.EMOJI_EVENT_LIST) {
				vResult.add(emoji);
			}
		} else {	// 通常時
			DataSource dsPostgres = null;
			Connection cConn = null;
			PreparedStatement cState = null;
			ResultSet cResSet = null;
			String strSql = "";
			try {
				dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
				cConn = dsPostgres.getConnection();

				if(nUserId>0) {
					strSql = "SELECT description, count(description) FROM comments_0000 WHERE user_id=? AND upload_date>CURRENT_DATE-7 GROUP BY description ORDER BY count(description) DESC LIMIT ?";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, nUserId);
					cState.setInt(2, nLimitNum);
					cResSet = cState.executeQuery();
					while (cResSet.next()) {
						vResult.add(Common.ToString(cResSet.getString(1)).trim());
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;
					if(vResult.size()>0 && vResult.size()<nLimitNum){
						strSql = "SELECT description FROM vw_rank_emoji_daily WHERE description NOT IN(SELECT description FROM comments_0000 WHERE user_id=? AND upload_date>CURRENT_DATE-7 GROUP BY description ORDER BY count(description) DESC LIMIT ?) ORDER BY rank DESC LIMIT ?";
						cState = cConn.prepareStatement(strSql);
						cState.setInt(1, nUserId);
						cState.setInt(2, nLimitNum);
						cState.setInt(3, nLimitNum-vResult.size());
						cResSet = cState.executeQuery();
						while (cResSet.next()) {
							vResult.add(Common.ToString(cResSet.getString(1)).trim());
						}
						cResSet.close();cResSet=null;
						cState.close();cState=null;
					}
				}
				if(vResult.size()<nLimitNum){
					strSql = "SELECT description FROM vw_rank_emoji_daily ORDER BY rank DESC LIMIT ?";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, nLimitNum-vResult.size());
					cResSet = cState.executeQuery();
					while (cResSet.next()) {
						vResult.add(Common.ToString(cResSet.getString(1)).trim());
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;
				}
			} catch(Exception e) {
				Log.d(strSql);
				e.printStackTrace();
			} finally {
				try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
				try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
				try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
			}
		}
		return vResult;
	}


	public static String toString(String strSrc) {
		if(strSrc == null) {
			return "";
		}
		return strSrc;
	}


	public static int toInt(String strSrc) {
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

	public static long toLong(String strSrc) {
		long nRet = -1;
		if(strSrc == null) {
			return -1;
		}
		try {
			nRet = Long.parseLong(strSrc);
		} catch (Exception e) {
			nRet = -1;
		}
		return nRet;
	}

	public static boolean isSmartPhone(HttpServletRequest request) {
		String strUuserAgent = toString(request.getHeader("user-agent"));
		String strReferer = toString(request.getHeader("Referer"));

		if(strReferer.indexOf("galleria.emotionflow.com")<0) {
			if(	(strUuserAgent.indexOf("iPhone")>=0 && strUuserAgent.indexOf("iPad")<0) ||
					strUuserAgent.indexOf("iPod")>=0 ||
					(strUuserAgent.indexOf("Android")>=0 && strUuserAgent.indexOf("Mobile")>=0)) {
				return true;
			}
		}
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
		strSrc = deleteCrLf(strSrc);
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

	public static String subStrNum(String strSrc, int nNum) {
		if(strSrc==null) return "";
		if(strSrc.length()<=nNum) return strSrc;
		return strSrc.substring(0, nNum);
	}

	public static String poipiku_320x250_sp_mid() {
		//return adpon_all();
		StringBuilder sbRtn = new StringBuilder();
		sbRtn.append("<div class=\"SideBarMid\">");
		sbRtn.append("<script async src=\"//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js\"></script>");
		sbRtn.append("<!-- poipiku_320x250_sp_mid -->");
		sbRtn.append("<ins class=\"adsbygoogle\"");
		sbRtn.append("style=\"display:inline-block;width:300px;height:250px\"");
		sbRtn.append("data-ad-client=\"ca-pub-9388519601000159\"");
		sbRtn.append("data-ad-slot=\"8188361534\"></ins>");
		sbRtn.append("<script>");
		sbRtn.append("(adsbygoogle = window.adsbygoogle || []).push({});");
		sbRtn.append("</script>");
		sbRtn.append("</div>");
		return sbRtn.toString();
	}

	public static String poipiku_300x250_bottom_right() {
		//return adpon_all();
		StringBuilder sbRtn = new StringBuilder();
		sbRtn.append("<div class=\"PcSideBarAd\">");
		sbRtn.append("<script async src=\"//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js\"></script>");
		sbRtn.append("<!-- poipiku_300x250_bottom_right -->");
		sbRtn.append("<ins class=\"adsbygoogle\"");
		sbRtn.append("style=\"display:inline-block;width:300px;height:250px\"");
		sbRtn.append("data-ad-client=\"ca-pub-9388519601000159\"");
		sbRtn.append("data-ad-slot=\"6315134980\"></ins>");
		sbRtn.append("<script>");
		sbRtn.append("(adsbygoogle = window.adsbygoogle || []).push({});");
		sbRtn.append("</script>");
		sbRtn.append("</div>");
		return sbRtn.toString();
	}

	public static String poipiku_336x280_bottom_right() {
		//return adpon_all();
		StringBuilder sbRtn = new StringBuilder();
		sbRtn.append("<div class=\"PcSideBarAd\">");
		sbRtn.append("<script async src=\"//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js\"></script>");
		sbRtn.append("<!-- poipiku_336x280_bottom_right -->");
		sbRtn.append("<ins class=\"adsbygoogle\"");
		sbRtn.append("style=\"display:inline-block;width:336px;height:280px\"");
		sbRtn.append("data-ad-client=\"ca-pub-9388519601000159\"");
		sbRtn.append("data-ad-slot=\"5086719699\"></ins>");
		sbRtn.append("<script>");
		sbRtn.append("(adsbygoogle = window.adsbygoogle || []).push({});");
		sbRtn.append("</script>");
		sbRtn.append("</div>");
		return sbRtn.toString();
	}

	public static String adpon_all () {
		int nRand=(int)(Math.random()*10000);
		StringBuilder sbRtn = new StringBuilder();
		sbRtn.append("<div id=\""+nRand+"\" class=\"PcSideBarAd\">");
		sbRtn.append("<script async>");
		sbRtn.append("getScriptOutput(\"//ad.adpon.jp/fr.js?fid=2fbe0897-f359-45ae-9561-dc172561ce91\", function(html) {");
		sbRtn.append("$(\"#"+nRand+"\").append(html)");
		sbRtn.append("});");
		sbRtn.append("</script>");
		sbRtn.append("</div>");
		return sbRtn.toString();
	}

	public static String jikoku_hyou (HttpServletRequest request) {
		String strUuserAgent = toString(request.getHeader("user-agent"));
		String strLink = (strUuserAgent.indexOf("Android")>=0)?
				"https://play.google.com/store/apps/details?id=jp.pipa.timetable&hl=ja":
				"https://apps.apple.com/jp/app/%E6%99%82%E5%88%BB%E8%A1%A8zero/id1474329285?mt=8";
		StringBuilder sbRtn = new StringBuilder();
		sbRtn.append("<div class=\"SideBarMid\">");
		sbRtn.append(String.format("<a style=\"display:block;text-align:center;\" href=\"%s\">", strLink));
		sbRtn.append("<img src=\"/event/20191016/banner03.png\" />");
		sbRtn.append("</a>");
		sbRtn.append("</div>");
		return sbRtn.toString();
	}

	public static boolean isBot(String strUuserAgent) {
		if(strUuserAgent==null) return false;
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
				"YodaoBot");
		return vBot.contains(strUuserAgent);
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

}

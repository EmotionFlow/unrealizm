package com.emotionflow.poipiku;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import com.emotionflow.poipiku.Common;
import com.emotionflow.poipiku.ResourceBundleControl;

public class Common {
	public static final int PAGE_BAR_NUM = 2;

	public static int TWITTER_PROVIDER_ID = 1;
	public static String TWITTER_CONSUMER_KEY = "kzEqWQyT9X8GozWdCT2E6TNr3";
	public static String TWITTER_CONSUMER_SECRET = "6QfxAs3iP3LtBX5EYZq64r8xlQjo8dx8e8pJKcpgnGSb5x5GzW";
	public static String TWITTER_CALLBAK_DOMAIN = "https://poipiku.com";

	public static String GetPageTitle2(ResourceBundleControl _TEX, String pageName){
		return pageName + " - " + _TEX.T("TopV.TitleBar");
	}

	public static final String PROF_DEFAULT = "/img/DefaultProfile.jpg";

	// for Database
	public static final String DB_POSTGRESQL = "java:comp/env/jdbc/poipiku";

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

	public static String getProfUrl(int nUserId){
		return getProfPath(nUserId);
	}

	public static String getProfPath(int nUserId){
		return String.format("/user_img01/%09d/prof.jpg", nUserId);
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

	public static String AutoLink(String strSrc) {
		return strSrc
				.replaceAll("(http://|https://){1}[\\w\\.\\-/:;&?,=#!~]+","<a class='AutoLink' href='$0' target='_blank'>$0</a>")
				.replaceAll("(#)([\\w|\\p{InHiragana}|\\p{InKatakana}|\\p{InHalfwidthAndFullwidthForms}|\\p{InCJKUnifiedIdeographs}]+)"," <a class=\"AutoLink\" href=\"/SearchIllustByTagV.jsp?KWD=$2\">$0</a>");
	}

	public static String AutoLinkPc(String strSrc) {
		return strSrc
				.replaceAll("(http://|https://){1}[\\w\\.\\-/:;&?,=#!~]+","<a class=\"AutoLink\" href=\"$0\" target=\"_blank\">$0</a>")
				.replaceAll("(#)([\\w|\\p{InHiragana}|\\p{InKatakana}|\\p{InHalfwidthAndFullwidthForms}|\\p{InCJKUnifiedIdeographs}]+)"," <a class=\"AutoLink\" href=\"/SearchIllustByTagPcV.jsp?KWD=$2\">$0</a>");
	}

	/*
	static String AutoLinkTwitter(String strSrc) {
		return strSrc
			.replaceAll("(http://|https://){1}[\\w\\.\\-/:;&?,=#!~]+","<a href=\"$0\" target=\"_blank\">$0</a>")
			.replaceAll("\\B(@)([0-9|a-z|A-Z|_]+)","<a href=\"http://twitter.com/$2\" target=\"_blank\">$0</a>")
			.replaceAll("(#)([\\w|\\p{InHiragana}|\\p{InKatakana}|\\p{InHalfwidthAndFullwidthForms}|\\p{InCJKUnifiedIdeographs}]+)","<a href=\"https://twitter.com/hashtag/$2\" target=\"_blank\">$0</a>")
			.replaceAll("[\\r\\n]+[\\s]+", "\n")
			.replaceAll("\\n", "<br />");
	}
	*/

	public static String EscapeSqlLike(String strSrc, String strEscape) {
		return "%" + EscapeSqlLikeExact(strSrc, strEscape) + "%";
		/*
		String strRtn = strSrc;
		if(strEscape==null) strEscape="";
		strRtn = replaceAll(strRtn, strEscape, strEscape+strEscape);
		strRtn = replaceAll(strRtn, "_", strEscape+"_");
		strRtn = replaceAll(strRtn, "%", strEscape+"%");
		return "%"+strRtn+"%";
		*/
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


	public static final String USER_AGENT = "PipaTegaki";
	public static boolean isAndroidWeb(HttpServletRequest request) {
		String strUuserAgent = Common.ToString(request.getHeader("user-agent"));
		System.out.println(strUuserAgent);

		if(strUuserAgent.indexOf("Android")>=0 && strUuserAgent.indexOf(USER_AGENT)<0) return true;
		return false;
	}

	public static boolean isIPhoneWeb(HttpServletRequest request) {
		String strUuserAgent = Common.ToString(request.getHeader("user-agent"));
		System.out.println(strUuserAgent);

		if((strUuserAgent.indexOf("iPhone")>=0 || strUuserAgent.indexOf("iPad")>=0 || strUuserAgent.indexOf("iPod")>=0) && strUuserAgent.indexOf(USER_AGENT)<0) return true;
		return false;
	}

	public static boolean isSmartPhone(HttpServletRequest request) {
		String strUuserAgent = ToString(request.getHeader("user-agent"));
		String strReferer = ToString(request.getHeader("Referer"));

		if(strReferer.indexOf("galleria.emotionflow.com")<0) {
			if(	(strUuserAgent.indexOf("iPhone")>=0 && strUuserAgent.indexOf("iPad")<0) ||
				strUuserAgent.indexOf("iPod")>=0 ||
				(strUuserAgent.indexOf("Android")>=0 && strUuserAgent.indexOf("Mobile")>=0)) {
				return true;
			}
		}
		return false;
	}
}

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

	public static final String[][] CATEGORY_EMOJI = {
			// いちほ
			{"&#x2615","&#x1f375","&#x1F358","&#x1F361","&#x1F366","&#x1F367","&#x1F368","&#x1F369","&#x1F36A","&#x1F36B",
			"&#x1F353","&#x1F352","&#x1F36C","&#x1F36D","&#x1F36E","&#x1F370"},
			// 飽きた
			{"&#x1F3D6","&#x1F3DD","&#x1F379","&#x1F37F","&#x1F50B","&#x1F4A1","&#x1F50C","&#x26A1","&#x1F35E","&#x1F360",
			"&#x1F957","&#x1F95E","&#x1F950","&#x1F32D","&#x1F35F","&#x1f964"},
			// 力尽きた
			{"&#x1F356","&#x1F357","&#x1f953","&#x1f969","&#x1F359","&#x1F35A","&#x1F32E","&#x1F32F","&#x1F354","&#x1F355",
			"&#x1F35B","&#x1F35C","&#x1F371","&#x1F958","&#x1F959","&#x2668"},
			// ボツ
			{"&#x1F377","&#x1F378","&#x1F37A","&#x1F4A8","&#x1F680","&#x1F943",
			"&#x1F4A5","&#x1F62D","&#x1F37C","&#x1F4A4","&#x1F4A6","&#x1F608","&#x1f648","&#x1f649","&#x1f64a","&#x1f6cc"},
			// らくがき
			{"&#x203C","&#x1f60e","&#x1f619","&#x1f989","&#x1f408","&#x1f31e","&#x26C4","&#x1F43E",
			"&#x1F300","&#x27BF","&#x3030","&#x1f3b6","&#x1F344","&#x1F60F","&#x1F47B","&#x1F60B"},
			// 壁打ち
			{"&#x270D","&#x23F3","&#x1F939","&#x1F94B","&#x1F48E","&#x1F3CB","&#x1F4AA","&#x23F0","&#x1f93a","&#x1F4B0",
			"&#x1F336","&#x1f3db","&#x1f525","&#x2604","&#x1F30A","&#x1F34C"},
			// 完成
			{"&#x2728","&#x1F308","&#x1F340","&#x1F365","&#x1F37B","&#x1F382","&#x1F38A","&#x1F3AF","&#x1F44F","&#x1F463",
			"&#x1F498","&#x1F4B4","&#x1F618","&#x1F61C","&#x1F923","&#x1f924",},
			// 過去絵を晒す
			{"&#x1F4CC","&#x1F49D","&#x1F381","&#x1F98B","&#x1f31f","&#x1f3c6","&#x1f396","&#x1f3c5","&#x1f47c","&#x1f607","&#x1F380",
			"&#x1f339","&#x1F48B","&#x1F451","&#x1f490","&#x1f929"},
			// 黒歴史
			{"&#x2620","&#x1F480","&#x1F631","&#x1F31A","&#x1f576","&#x271D","&#x2626","&#x2721","&#x1F52F","&#x262F","&#x264B",
			"&#x1F52E","&#x2694","&#x1F5E1","&#x269C","&#x1F531"},
			// 供養
			{"&#x1F64F","&#x1F64F","&#x1F64F","&#x1F64F","&#x1F64F","&#x1F64F","&#x1F64F","&#x1F64F","&#x1F64F","&#x1F64F",
			"&#x1F64F","&#x1F64F","&#x1F64F","&#x1F64F","&#x1F64F","&#x1F64F"},
			// 予備
			{"&#x1F362","&#x1F34B","&#x1F350","&#x1F34F","&#x1F34E","&#x1F34A","&#x1F95D","&#x1f3b2","&#x1f452","&#x1f6d0",
			"&#x26B1","&#x26EA","&#x26E9","&#x1F320","&#x26B0","&#x1F4DD","&#x1F64F","&#x270F","&#x1F914","&#x1F421",
			"&#x1F30B","&#x1F389","&#x1F942","&#x1F4A3","&#x1F4A2","&#x1F94A","&#x1f5ef","&#x1f643","&#x1F603","&#x1F609",
			"&#x1F3B0","&#x1F41E","&#x1f4ab","&#x1F338","&#x1F388","&#x1F6E1","&#x1f549"},
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

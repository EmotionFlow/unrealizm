package jp.pipa.poipiku.util;

import java.io.File;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

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
		for(String emoji : Common.EMOJI_LIST_EVENT) {
			vResult.add(emoji);
		}
		/*
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
		*/
		return vResult;
	}


	public static String toString(String strSrc) {
		if(strSrc == null) {
			return "";
		}
		return strSrc;
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

}

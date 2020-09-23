package jp.pipa.poipiku.util;

import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CTag;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.ResourceBundleControl;

public class ABTestUtil {
	public static final int TYPE_USER_ILLUST = 0;
	public static final int MODE_PC = 0;
	public static final int MODE_SP = 1;
	public static final int VIEW_LIST = 0;
	public static final int VIEW_DETAIL = 1;
	public static final int SP_MODE_WVIEW = 0;
	public static final int SP_MODE_APP = 1;


	// ユーザの一覧が見たいのか、ジャンルが見たいのか判定
	static public final int MAX_USER_LIST_CONTENTS = 6;
	static public final int MAX_GENRE_LIST_CONTENTS = 6;
	static public boolean isIllustViewTest_UserList_GenreList(HttpServletRequest request, int userId, int contentId) {
		boolean exist = false;

		if (!Util.isSmartPhone(request)) return false;

		String strReferer = Util.toString(request.getHeader("Referer"));
		if((strReferer.indexOf("poipiku.com")>=0) || (strReferer.indexOf("poipiku-dev.com")>=0)) return false;

		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			dataSource = (DataSource) new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// user contents num
			boolean contentsExits = false;
			strSql = "SELECT COUNT(*) FROM contents_0000 WHERE user_id=? AND open_id<>2";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				contentsExits = (resultSet.getInt(1)>=MAX_USER_LIST_CONTENTS);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			if(!contentsExits) return false;

			// genre tag
			String tag = "";
			strSql = "SELECT tag_txt FROM tags_0000 WHERE content_id=? AND tag_type=1 ORDER BY tag_id LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				tag = Util.toString(resultSet.getString(1)).trim();
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			if(tag.isEmpty()) return false;

			// genre contents num
			strSql = "SELECT count(*) FROM tags_0000 WHERE tag_txt=? AND tag_type=1";
			statement = connection.prepareStatement(strSql);
			statement.setString(1, tag);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				contentsExits = (resultSet.getInt(1)>=MAX_GENRE_LIST_CONTENTS);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			exist = contentsExits;
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return exist;
	}

	static public ArrayList<CContent> getUserContentList(int userId, int userListNum){
		ArrayList<CContent> contents = new ArrayList<CContent>();
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			dataSource = (DataSource) new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// user contents
			strSql = "SELECT * FROM contents_0000 WHERE user_id=? AND open_id<>2 ORDER BY content_id DESC LIMIT ?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			statement.setInt(2, userListNum);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				contents.add(content);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return contents;
	}

	static public String getTitleTag(int contentId) {
		String tag = "";
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			dataSource = (DataSource) new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// genre tag
			strSql = "SELECT tag_txt FROM tags_0000 WHERE content_id=? AND tag_type=1 ORDER BY tag_id LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				tag = Util.toString(resultSet.getString(1)).trim();
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return tag;
	}

	static public ArrayList<CTag> getAllTag(int contentId) {
		ArrayList<CTag> tags = new ArrayList<CTag>();
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			dataSource = (DataSource) new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// genre tag
			strSql = "SELECT tag_txt FROM tags_0000 WHERE content_id=? AND tag_type=1 ORDER BY tag_id";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CTag tag = new CTag(resultSet);
				tags.add(tag);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return tags;
	}

	static public ArrayList<CContent> getGenreContentList(int contentId, int userListNum){
		ArrayList<CContent> contents = new ArrayList<CContent>();
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			dataSource = (DataSource) new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// genre tag
			String tag = getTitleTag(contentId);
			if(tag.isEmpty()) return contents;

			// genre contents
			strSql = "SELECT * FROM contents_0000 WHERE open_id<>2 AND content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=? AND tag_type=1) ORDER BY content_id DESC LIMIT ?";
			statement = connection.prepareStatement(strSql);
			statement.setString(1, tag);
			statement.setInt(2, userListNum);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				contents.add(content);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return contents;
	}



	private static String getContentsFileNumHtml(CContent cContent){
		return (cContent.m_nFileNum>1)?String.format("<i class=\"far fa-clone\"></i>%d", cContent.m_nFileNum):"";
	}

	public static String toThumbHtml_UserList(CContent cContent, ResourceBundleControl _TEX) {
		String SEARCH_CATEGORY = "/NewArrivalPcV.jsp";

		String ILLUST_VIEW = String.format("/IllustListPcV_UserList.jsp?ID=%d", cContent.m_nUserId);

		StringBuilder strRtn = new StringBuilder();
		String strFileNum = getContentsFileNumHtml(cContent);

		strRtn.append(String.format("<a class=\"IllustThumb\" href=\"%s\">", ILLUST_VIEW));

		String strFileUrl = "";
		switch(cContent.m_nPublishId) {
			case Common.PUBLISH_ID_R15:
			case Common.PUBLISH_ID_R18:
			case Common.PUBLISH_ID_R18G:
			case Common.PUBLISH_ID_PASS:
			case Common.PUBLISH_ID_LOGIN:
			case Common.PUBLISH_ID_FOLLOWER:
			case Common.PUBLISH_ID_T_FOLLOWER:
			case Common.PUBLISH_ID_T_FOLLOW:
			case Common.PUBLISH_ID_T_EACH:
			case Common.PUBLISH_ID_T_LIST:
				strFileUrl = Common.PUBLISH_ID_FILE[cContent.m_nPublishId];
				break;
			case Common.PUBLISH_ID_ALL:
			case Common.PUBLISH_ID_HIDDEN:
		default:
			strFileUrl = Common.GetUrl(cContent.m_strFileName);
			break;
		}

		strRtn.append("<span class=\"IllustThumbImg\"");

		if(cContent.m_nOpenId==0 || cContent.m_nOpenId==1){
			strRtn.append(String.format("style=\"background-image:url('%s_360.jpg')\"></span>", strFileUrl));
		} else {
			strRtn.append(String.format("style=\"background: rgba(0,0,0,.7) url('%s_360.jpg');", strFileUrl))
			.append("background-blend-mode: darken;background-size: cover;background-position: 50% 50%;\"></span>");
		}

		strRtn.append("<span class=\"IllustInfo\">");
		strRtn.append(
			String.format("<span class=\"Category C%d\" onclick=\"location.href='%s?CD=%d';return false;\">%s</span>",
			cContent.m_nCategoryId,
			SEARCH_CATEGORY,
			cContent.m_nCategoryId,
			_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))
			)
		);
		strRtn.append("</span>");	// IllustInfo

		strRtn.append("<span class=\"IllustInfoBottom\">");
		if(cContent.m_nFileNum>1){
			strRtn.append("<span class=\"Num\">").append(strFileNum).append("</span>");
		}
		strRtn.append("</span>");	// IllustInfoBottom

		strRtn.append("</a>");

		return strRtn.toString();
	}


	public static String toThumbHtml_GenreList(CContent cContent, String tag, ResourceBundleControl _TEX) {
		String SEARCH_CATEGORY = "/NewArrivalPcV.jsp";
		String encTag = tag;
		try {encTag = URLEncoder.encode(tag, "UTF-8");} catch (Exception e) {;}
		String ILLUST_VIEW = String.format("/SearchIllustByTagPc_GenreListV.jsp?KWD=%s", encTag);

		StringBuilder strRtn = new StringBuilder();
		String strFileNum = getContentsFileNumHtml(cContent);

		strRtn.append(String.format("<a class=\"IllustThumb\" href=\"%s\">", ILLUST_VIEW));

		String strFileUrl = "";
		switch(cContent.m_nPublishId) {
			case Common.PUBLISH_ID_R15:
			case Common.PUBLISH_ID_R18:
			case Common.PUBLISH_ID_R18G:
			case Common.PUBLISH_ID_PASS:
			case Common.PUBLISH_ID_LOGIN:
			case Common.PUBLISH_ID_FOLLOWER:
			case Common.PUBLISH_ID_T_FOLLOWER:
			case Common.PUBLISH_ID_T_FOLLOW:
			case Common.PUBLISH_ID_T_EACH:
			case Common.PUBLISH_ID_T_LIST:
				strFileUrl = Common.PUBLISH_ID_FILE[cContent.m_nPublishId];
				break;
			case Common.PUBLISH_ID_ALL:
			case Common.PUBLISH_ID_HIDDEN:
		default:
			strFileUrl = Common.GetUrl(cContent.m_strFileName);
			break;
		}

		strRtn.append("<span class=\"IllustThumbImg\"");

		if(cContent.m_nOpenId==0 || cContent.m_nOpenId==1){
			strRtn.append(String.format("style=\"background-image:url('%s_360.jpg')\"></span>", strFileUrl));
		} else {
			strRtn.append(String.format("style=\"background: rgba(0,0,0,.7) url('%s_360.jpg');", strFileUrl))
			.append("background-blend-mode: darken;background-size: cover;background-position: 50% 50%;\"></span>");
		}

		strRtn.append("<span class=\"IllustInfo\">");
		strRtn.append(
			String.format("<span class=\"Category C%d\" onclick=\"location.href='%s?CD=%d';return false;\">%s</span>",
			cContent.m_nCategoryId,
			SEARCH_CATEGORY,
			cContent.m_nCategoryId,
			_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))
			)
		);
		strRtn.append("</span>");	// IllustInfo

		strRtn.append("<span class=\"IllustInfoBottom\">");
		if(cContent.m_nFileNum>1){
			strRtn.append("<span class=\"Num\">").append(strFileNum).append("</span>");
		}
		strRtn.append("</span>");	// IllustInfoBottom

		strRtn.append("</a>");

		return strRtn.toString();
	}

	public static String toThumbHtml_UserContentClk(CContent cContent, ResourceBundleControl _TEX) {
		String SEARCH_CATEGORY = "/NewArrivalPcV.jsp";

		String ILLUST_VIEW = String.format("/IllustViewPc_UserContentClkV.jsp?ID=%d&TD=%d", cContent.m_nUserId, cContent.m_nContentId);

		StringBuilder strRtn = new StringBuilder();
		String strFileNum = getContentsFileNumHtml(cContent);

		strRtn.append(String.format("<a class=\"IllustThumb\" href=\"%s\">", ILLUST_VIEW));

		String strFileUrl = "";
		switch(cContent.m_nPublishId) {
			case Common.PUBLISH_ID_R15:
			case Common.PUBLISH_ID_R18:
			case Common.PUBLISH_ID_R18G:
			case Common.PUBLISH_ID_PASS:
			case Common.PUBLISH_ID_LOGIN:
			case Common.PUBLISH_ID_FOLLOWER:
			case Common.PUBLISH_ID_T_FOLLOWER:
			case Common.PUBLISH_ID_T_FOLLOW:
			case Common.PUBLISH_ID_T_EACH:
			case Common.PUBLISH_ID_T_LIST:
				strFileUrl = Common.PUBLISH_ID_FILE[cContent.m_nPublishId];
				break;
			case Common.PUBLISH_ID_ALL:
			case Common.PUBLISH_ID_HIDDEN:
		default:
			strFileUrl = Common.GetUrl(cContent.m_strFileName);
			break;
		}

		strRtn.append("<span class=\"IllustThumbImg\"");

		if(cContent.m_nOpenId==0 || cContent.m_nOpenId==1){
			strRtn.append(String.format("style=\"background-image:url('%s_360.jpg')\"></span>", strFileUrl));
		} else {
			strRtn.append(String.format("style=\"background: rgba(0,0,0,.7) url('%s_360.jpg');", strFileUrl))
			.append("background-blend-mode: darken;background-size: cover;background-position: 50% 50%;\"></span>");
		}

		strRtn.append("<span class=\"IllustInfo\">");
		strRtn.append(
			String.format("<span class=\"Category C%d\" onclick=\"location.href='%s?CD=%d';return false;\">%s</span>",
			cContent.m_nCategoryId,
			SEARCH_CATEGORY,
			cContent.m_nCategoryId,
			_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))
			)
		);
		strRtn.append("</span>");	// IllustInfo

		strRtn.append("<span class=\"IllustInfoBottom\">");
		if(cContent.m_nFileNum>1){
			strRtn.append("<span class=\"Num\">").append(strFileNum).append("</span>");
		}
		strRtn.append("</span>");	// IllustInfoBottom

		strRtn.append("</a>");

		return strRtn.toString();
	}

	public static String toThumbHtml_TagContentClk(CContent cContent, ResourceBundleControl _TEX) {
		String SEARCH_CATEGORY = "/NewArrivalPcV.jsp";

		String ILLUST_VIEW = String.format("/IllustViewPc_TagContentClkV.jsp?ID=%d&TD=%d", cContent.m_nUserId, cContent.m_nContentId);

		StringBuilder strRtn = new StringBuilder();
		String strFileNum = getContentsFileNumHtml(cContent);

		strRtn.append(String.format("<a class=\"IllustThumb\" href=\"%s\">", ILLUST_VIEW));

		String strFileUrl = "";
		switch(cContent.m_nPublishId) {
			case Common.PUBLISH_ID_R15:
			case Common.PUBLISH_ID_R18:
			case Common.PUBLISH_ID_R18G:
			case Common.PUBLISH_ID_PASS:
			case Common.PUBLISH_ID_LOGIN:
			case Common.PUBLISH_ID_FOLLOWER:
			case Common.PUBLISH_ID_T_FOLLOWER:
			case Common.PUBLISH_ID_T_FOLLOW:
			case Common.PUBLISH_ID_T_EACH:
			case Common.PUBLISH_ID_T_LIST:
				strFileUrl = Common.PUBLISH_ID_FILE[cContent.m_nPublishId];
				break;
			case Common.PUBLISH_ID_ALL:
			case Common.PUBLISH_ID_HIDDEN:
		default:
			strFileUrl = Common.GetUrl(cContent.m_strFileName);
			break;
		}

		strRtn.append("<span class=\"IllustThumbImg\"");

		if(cContent.m_nOpenId==0 || cContent.m_nOpenId==1){
			strRtn.append(String.format("style=\"background-image:url('%s_360.jpg')\"></span>", strFileUrl));
		} else {
			strRtn.append(String.format("style=\"background: rgba(0,0,0,.7) url('%s_360.jpg');", strFileUrl))
			.append("background-blend-mode: darken;background-size: cover;background-position: 50% 50%;\"></span>");
		}

		strRtn.append("<span class=\"IllustInfo\">");
		strRtn.append(
			String.format("<span class=\"Category C%d\" onclick=\"location.href='%s?CD=%d';return false;\">%s</span>",
			cContent.m_nCategoryId,
			SEARCH_CATEGORY,
			cContent.m_nCategoryId,
			_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))
			)
		);
		strRtn.append("</span>");	// IllustInfo

		strRtn.append("<span class=\"IllustInfoBottom\">");
		if(cContent.m_nFileNum>1){
			strRtn.append("<span class=\"Num\">").append(strFileNum).append("</span>");
		}
		strRtn.append("</span>");	// IllustInfoBottom

		strRtn.append("</a>");

		return strRtn.toString();
	}
}

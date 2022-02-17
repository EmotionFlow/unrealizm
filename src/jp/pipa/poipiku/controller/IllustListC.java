package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class IllustListC {
	public int m_nUserId = -1;
	public String m_strTagKeyword = "";
	public int m_nPage = 0;
	public String m_strAccessIp = "";
	public boolean m_bDispUnPublished = false;

	public static final int TIMEZONE_OFFSET_DEFAULT = -9;
	public float clientTimezoneOffset = TIMEZONE_OFFSET_DEFAULT;

	public enum SortBy implements CodeEnum<SortBy> {
		None(0),
		Description(1),
		CreatedAt(2),
		UpdatedAt(3);

		static public SortBy byCode(int _code) {
			return CodeEnum.getEnum(SortBy.class, _code);
		}
		@Override
		public int getCode() {
			return code;
		}

		private final int code;

		private SortBy(int code) {
			this.code = code;
		}
	}
	public SortBy sortBy = SortBy.None;
	public boolean sortOrderAsc = false;
	public int categoryFilterId = -1;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId		= Util.toInt(cRequest.getParameter("ID"));
			m_strTagKeyword = Common.TrimAll(Common.CrLfInjection(cRequest.getParameter("KWD")));
			m_nPage			= Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
			m_strAccessIp	= cRequest.getRemoteAddr();
			sortBy          = SortBy.byCode(Util.toInt(cRequest.getParameter("SBY")));
			if (sortBy == null) sortBy = SortBy.None;
			sortOrderAsc    = Util.toBoolean(cRequest.getParameter("SASC"));
			categoryFilterId = Util.toInt(cRequest.getParameter("CAT"));
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public Map<String, String> getParamKeyValueMap() {
		Map<String, String> keyValues = new HashMap<>();
		if (m_nUserId > 0) keyValues.put("ID", Integer.toString(m_nUserId));
		if (!m_strTagKeyword.isEmpty()) keyValues.put("KWD", m_strTagKeyword);
		if (m_nPage > 0) keyValues.put("PG", Integer.toString(m_nPage));
		if (sortBy != SortBy.None) keyValues.put("SBY", Integer.toString(sortBy.getCode()));
		if (sortOrderAsc) keyValues.put("SASC", "1");
		if (categoryFilterId>=0) keyValues.put("CAT", Integer.toString(categoryFilterId));
		return keyValues;
	}

	public String getSortAscParam(SortBy _sortBy) {
		return this.sortBy == _sortBy && !this.sortOrderAsc ? "&SASC=1" : "";
	}


	public CUser m_cUser = new CUser();
	public String twitterScreenName;
	public ArrayList<CContent> m_vContentList = new ArrayList<>();
	public ArrayList<CTag> m_vCategoryList = new ArrayList<>();
	public int SELECT_MAX_GALLERY = 15;
	public boolean m_bOwner = false;
	public boolean m_bFollow = false;
	public boolean m_bBlocking = false;
	public boolean m_bBlocked = false;
	public int m_nContentsNum = 0;
	public int m_nContentsNumTotal = 0;

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}
	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		String strSql = "";
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		int idx = 1;

		if(m_nUserId < 1) {
			return false;
		}
		if(checkLogin.m_nUserId == m_nUserId) {
			m_bOwner = true;
		}

		Pin pin = null;
		List<Pin> pins = Pin.selectByUserId(m_nUserId);

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			connection = DatabaseUtil.dataSource.getConnection();

			if(!bContentOnly) {
				// author profile
				strSql = "SELECT u.*, oa.twitter_screen_name" +
						" FROM users_0000 u" +
						" LEFT JOIN tbloauth oa on user_id=flduserid" +
						" WHERE user_id=? AND del_flg = FALSE";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nUserId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					m_cUser.m_nUserId			= resultSet.getInt("user_id");
					m_cUser.m_strNickName		= Util.toString(resultSet.getString("nickname"));
					m_cUser.m_strProfile		= Util.toString(resultSet.getString("profile"));
					m_cUser.m_strFileName		= Util.toString(resultSet.getString("file_name"));
					m_cUser.m_strHeaderFileName	= Util.toString(resultSet.getString("header_file_name"));
					m_cUser.m_strBgFileName		= Util.toString(resultSet.getString("bg_file_name"));
					m_cUser.m_nMailComment		= resultSet.getInt("mail_comment");
					m_cUser.m_nTwitterAccountPublicMode = resultSet.getInt("twitter_account_public_mode");
					if (m_cUser.m_nTwitterAccountPublicMode == CUser.TW_PUBLIC_ON) {
						twitterScreenName = resultSet.getString("twitter_screen_name");
					}
					//if(m_cUser.m_strProfile.isEmpty())  m_cUser.m_strProfile = "";
					if(m_cUser.m_strFileName.isEmpty()) m_cUser.m_strFileName="/img/default_user.jpg";
					m_cUser.m_bDispFollower		= ((m_cUser.m_nMailComment>>>0 & 0x01) == 0x01);
					//m_cUser.m_bMailHeart		= ((m_cUser.m_nMailComment>>>1 & 0x01) == 0x01);
					//m_cUser.m_bMailBookmark	= ((m_cUser.m_nMailComment>>>2 & 0x01) == 0x01);
					//m_cUser.m_bMailFollow		= ((m_cUser.m_nMailComment>>>3 & 0x01) == 0x01);
					//m_cUser.m_bMailMessage	= ((m_cUser.m_nMailComment>>>4 & 0x01) == 0x01);
					//m_cUser.m_bMailTag		= ((m_cUser.m_nMailComment>>>5 & 0x01) == 0x01);
					m_cUser.m_nPassportId		= resultSet.getInt("passport_id");
					m_cUser.m_nAdMode			= resultSet.getInt("ng_ad_mode");
					m_cUser.setRequestEnabled(resultSet);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;

				if(m_cUser.m_strHeaderFileName.isEmpty()) {
					strSql = "SELECT * FROM contents_0000 WHERE publish_id=0 AND open_id<>2 AND safe_filter=0 AND user_id=? ORDER BY content_id DESC LIMIT 1";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, m_nUserId);
					resultSet = statement.executeQuery();
					if(resultSet.next()) {
						m_cUser.m_strHeaderFileName	= Util.toString(resultSet.getString("file_name")) + "_640.jpg";
					}
					resultSet.close();resultSet=null;
					statement.close();statement=null;
				} else {
					m_cUser.m_strHeaderFileName += "_640.jpg";
				}

				// flags
				if(m_bOwner) {
					strSql = "SELECT COUNT(user_id) as content_num FROM follows_0000 WHERE user_id=?";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, m_nUserId);
					resultSet = statement.executeQuery();
					if(resultSet.next()) {
						m_cUser.m_nFollowNum = resultSet.getInt("content_num");
					}
					resultSet.close();resultSet=null;
					statement.close();statement=null;

					strSql = "SELECT COUNT(follow_user_id) as content_num FROM follows_0000 WHERE follow_user_id=?";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, m_nUserId);
					resultSet = statement.executeQuery();
					if(resultSet.next()) {
						m_cUser.m_nFollowerNum = resultSet.getInt("content_num");
					}
					resultSet.close();resultSet=null;
					statement.close();statement=null;
					checkLogin.m_nSafeFilter = Math.max(checkLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
				} else {
					// follow
					strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, checkLogin.m_nUserId);
					statement.setInt(2, m_nUserId);
					resultSet = statement.executeQuery();
					if(resultSet.next()) {
						m_bFollow = true;
						checkLogin.m_nSafeFilter = Math.max(checkLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
					}
					resultSet.close();resultSet=null;
					statement.close();statement=null;

					// blocking
					strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, checkLogin.m_nUserId);
					statement.setInt(2, m_nUserId);
					resultSet = statement.executeQuery();
					if(resultSet.next()) {
						m_bBlocking = true;
					}
					resultSet.close();resultSet=null;
					statement.close();statement=null;

					// blocked
					strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, m_nUserId);
					statement.setInt(2, checkLogin.m_nUserId);
					resultSet = statement.executeQuery();
					if(resultSet.next()) {
						m_bBlocked = true;
					}
					resultSet.close();resultSet=null;
					statement.close();statement=null;
				}

				// User contents total number
				String strOpenCnd = (!m_bOwner || (m_bOwner&&!m_bDispUnPublished))?" AND open_id<>2":"";
				strSql = String.format("SELECT COUNT(*) FROM contents_0000 WHERE user_id=? %s", strOpenCnd);
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, m_nUserId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_nContentsNumTotal = resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;

				// tag
				strSql = String.format("SELECT tag_txt FROM tags_0000 WHERE tag_type=3 AND content_id IN(SELECT content_id FROM contents_0000 WHERE user_id=? %s) GROUP BY tag_txt ORDER BY max(upload_date) DESC", strOpenCnd);
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nUserId);
				resultSet = statement.executeQuery();
				while(resultSet.next()) {
					m_vCategoryList.add(new CTag(resultSet));
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			if(m_bBlocking || m_bBlocked) return true;

			// tag
			final String strTagCond = (
					m_strTagKeyword.isEmpty()) ?
					"" : "AND content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=? AND tag_type=3) ";

			//TODO category
			final String strCategoryCond =
					categoryFilterId < 0 ?
							"" : "AND category_id = ?";

			//TODO free-word

			// full open for owner
			String strOpenCnd = (!m_bOwner || (m_bOwner&&!m_bDispUnPublished))?"AND open_id<>2 ":"";

			String strSqlFromWhere = "FROM contents_0000 "
					+ "WHERE user_id=? "
					+ "AND safe_filter<=? "
					+ strTagCond
					+ strCategoryCond
					+ strOpenCnd;

			List<CContent> pinContents = new ArrayList<>();
			if (!pins.isEmpty()) {
				strSql = "SELECT * " + strSqlFromWhere + " AND content_id=?";
				statement = connection.prepareStatement(strSql);
				idx = 1;
				statement.setInt(idx++, m_nUserId);
				statement.setInt(idx++, checkLogin.m_nSafeFilter);
				if(!strTagCond.isEmpty()) {
					statement.setString(idx++, m_strTagKeyword);
				}
				if(!strCategoryCond.isEmpty()) {
					statement.setInt(idx++, categoryFilterId);
				}
				statement.setInt(idx++, pins.get(0).contentId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					CContent cContent;
					if (m_nPage == 0) {
						if (clientTimezoneOffset == TIMEZONE_OFFSET_DEFAULT) {
							cContent = new CContent(resultSet);
						} else {
							cContent = new CContent(resultSet, clientTimezoneOffset);
						}

						final CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
						cContent.m_cUser.m_strNickName	= Util.toString(user.nickName);
						cContent.m_cUser.m_strFileName	= Util.toString(user.fileName);
						cContent.pinOrder = 1;
					} else {
						cContent = new CContent();
					}
					pinContents.add(cContent);
				}
			}

			//TODO order by
			final String strOrderBy;
			if (sortBy == SortBy.None) {
				strOrderBy = "ORDER BY content_id DESC ";
			} else {
				final String orderDesc = sortOrderAsc ? "" : "DESC ";
				if (sortBy == SortBy.Description) {
					strOrderBy = "ORDER BY description " + orderDesc;
				} else if(sortBy == SortBy.CreatedAt) {
					strOrderBy = "ORDER BY created_at " + orderDesc + "NULLS LAST, content_id " + orderDesc;
				} else if(sortBy == SortBy.UpdatedAt) {
					strOrderBy = "ORDER BY updated_at " + orderDesc + "NULLS LAST, content_id " + orderDesc;
				} else {
					strOrderBy = "ORDER BY content_id DESC ";
				}
			}

			// gallery
			strSql = "SELECT COUNT(*) " + strSqlFromWhere;
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, m_nUserId);
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if(!strTagCond.isEmpty()) {
				statement.setString(idx++, m_strTagKeyword);
			}
			if(!strCategoryCond.isEmpty()) {
				statement.setInt(idx++, categoryFilterId);
			}
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				m_nContentsNum = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			strSql = "SELECT * " + strSqlFromWhere
					+ strOrderBy
					+ "OFFSET ? LIMIT ?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, m_nUserId);
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if(!strTagCond.isEmpty()) {
				statement.setString(idx++, m_strTagKeyword);
			}
			if(!strCategoryCond.isEmpty()) {
				statement.setInt(idx++, categoryFilterId);
			}

			final int offset;
			final int limit;
			if (m_nPage == 0 && !pinContents.isEmpty()) {
				offset = 0;
				limit = SELECT_MAX_GALLERY - pinContents.size();
				m_vContentList.add(pinContents.get(0));
			} else {
				offset = m_nPage * SELECT_MAX_GALLERY - pinContents.size();
				limit = SELECT_MAX_GALLERY;
			}

			statement.setInt(idx++, offset);
			statement.setInt(idx++, limit);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent cContent;
				if (clientTimezoneOffset == TIMEZONE_OFFSET_DEFAULT) {
					cContent = new CContent(resultSet);
				} else {
					cContent = new CContent(resultSet, clientTimezoneOffset);
				}
				if (!pins.isEmpty() && cContent.m_nContentId == pins.get(0).contentId) {
					continue;
				}
				final CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
				cContent.m_cUser.m_strNickName	= Util.toString(user.nickName);
				cContent.m_cUser.m_strFileName	= Util.toString(user.fileName);
				m_vContentList.add(cContent);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;


			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

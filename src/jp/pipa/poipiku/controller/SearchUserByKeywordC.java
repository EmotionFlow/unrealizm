package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class SearchUserByKeywordC {
	public int m_nPage = 0;
	public String m_strKeyword = "";
	public String ipAddress = "";
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Util.toInt(request.getParameter("PG")), 0);
			m_strKeyword = Common.TrimAll(request.getParameter("KWD"));
			ipAddress = request.getRemoteAddr();
		}
		catch(Exception ignored) {
			;
		}
	}

	public int SELECT_MAX_GALLERY = 36;
	public ArrayList<CUser> m_vContentList = new ArrayList<CUser>();
	public int m_nContentsNum = 0;
	private static final String PG_HINT = "/*+ BitmapIndexScan(users_0000_nickname_pgidx) */";

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean result = false;
		CacheUsers0000 users  = CacheUsers0000.getInstance();
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		if(m_strKeyword.isEmpty()) return result;
		try {
			connection = DatabaseUtil.dataSource.getConnection();

			sql = PG_HINT + " SELECT user_id FROM users_0000 WHERE nickname &@~ ? LIMIT 10000";
			statement = connection.prepareStatement(sql);
			statement.setString(1, m_strKeyword);
			resultSet = statement.executeQuery();

			List<Integer> userIds = new ArrayList<>();
			while (resultSet.next()) {
				userIds.add(resultSet.getInt(1));
			}
			if(!bContentOnly) {
				m_nContentsNum = userIds.size();
			}
			Collections.sort(userIds);
			Collections.reverse(userIds);

			if (m_nPage < 4) {
				KeywordSearchLog.insert(checkLogin.m_nUserId, m_strKeyword, "",
						m_nPage, KeywordSearchLog.SearchTarget.Users, userIds.size(), ipAddress);
			}

			int offset = m_nPage * SELECT_MAX_GALLERY;
			int toIndex = offset + Math.min(m_nContentsNum<=0 ? 0 : m_nContentsNum-1, SELECT_MAX_GALLERY);
			toIndex = Math.min(toIndex, m_nContentsNum-1);
			List<Integer> subList = null;
			if (offset < toIndex) {
				subList = userIds.subList(offset, toIndex);
			}

			if (subList != null) {
				for (int userId : subList) {
					CacheUsers0000.User cashUser = users.getUser(userId);
					if(cashUser==null) continue;
					CUser user = new CUser(cashUser);
					m_vContentList.add(user);
				}
			}

			resultSet.close();resultSet=null;
			statement.close();statement=null;

			result = true;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return result;
	}
}

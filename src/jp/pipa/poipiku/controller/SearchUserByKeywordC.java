package jp.pipa.poipiku.controller;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class SearchUserByKeywordC {
	public int m_nPage = 0;
	public String m_strKeyword = "";
	public String encodedKeyword = "";
	public String ipAddress = "";
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Util.toInt(request.getParameter("PG")), 0);
			m_strKeyword = Common.TrimAll(request.getParameter("KWD"));
			if (!m_strKeyword.isEmpty() && m_strKeyword.indexOf("@") == 0) {
				m_strKeyword = m_strKeyword.replaceFirst("@", "");
			}
			encodedKeyword = URLEncoder.encode(m_strKeyword, StandardCharsets.UTF_8);
			ipAddress = request.getRemoteAddr();
		}
		catch(Exception ignored) {
			;
		}
	}

	public int SELECT_MAX_GALLERY = 9;
	public ArrayList<CUser> selectByNicknameUsers = new ArrayList<>();
	public ArrayList<CUser> selectByProfileUsers = new ArrayList<>();
	public int m_nContentsNum = 0;

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		if(m_strKeyword.isEmpty()) return false;

		boolean result = false;
		try (Connection connection = DatabaseUtil.replicaDataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement("""
             SELECT * FROM users_0000 WHERE nickname &@~ ? ORDER BY always_null, user_id DESC OFFSET ? LIMIT ?
             """)
		)
		{
			statement.setString(1, m_strKeyword);
			statement.setInt(2, m_nPage * SELECT_MAX_GALLERY);
			statement.setInt(3, SELECT_MAX_GALLERY);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CUser u = new CUser(resultSet);
				u.m_strProfile = resultSet.getString("profile");
				u.m_strHeaderFileName = resultSet.getString("header_file_name");
				selectByNicknameUsers.add(u);
			}
			result = true;
		} catch(Exception e) {
			e.printStackTrace();
		}

		try (Connection connection = DatabaseUtil.replicaDataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement("""
             SELECT * FROM users_0000 WHERE profile &@~ ? ORDER BY always_null, user_id DESC OFFSET ? LIMIT ?
             """)
		)
		{
			statement.setString(1, m_strKeyword);
			statement.setInt(2, m_nPage * SELECT_MAX_GALLERY);
			statement.setInt(3, SELECT_MAX_GALLERY);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CUser u = new CUser(resultSet);
				u.m_strProfile = resultSet.getString("profile");
				u.m_strHeaderFileName = resultSet.getString("header_file_name");
				selectByNicknameUsers.add(u);
			}
			result = true;
		} catch(Exception e) {
			e.printStackTrace();
		}

		if (m_nPage < 4) {
			KeywordSearchLog.insert(checkLogin.m_nUserId, m_strKeyword, "",
					m_nPage, KeywordSearchLog.SearchTarget.Users, selectByNicknameUsers.size() + selectByProfileUsers.size(), ipAddress);
		}

		return result;
	}
}

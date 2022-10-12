package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

import javax.servlet.http.HttpServletRequest;
import java.sql.*;
import java.util.*;

public class DeleteSearchLogC {
	String searchType = "";
	String targetKW = "";

	public void getParam(HttpServletRequest request) {
		searchType = request.getParameter("type");
		targetKW = request.getParameter("keyword");
	}

	public int getResults(CheckLogin checkLogin) {
		int  nResult = -1;

		List<KeywordSearchLog.SearchTarget> targetCodes = new ArrayList<>();
		if (searchType.equals("Contents") || searchType.equals("Tags")) {
			targetCodes.add(KeywordSearchLog.SearchTarget.Contents);
			targetCodes.add(KeywordSearchLog.SearchTarget.Tags);
		} else if (searchType.equals("Users")) {
			targetCodes.add(KeywordSearchLog.SearchTarget.Users);
		}

		String sql = "UPDATE keyword_search_logs SET is_hide = TRUE WHERE user_id = ? AND keywords = ?";
		if (targetCodes.size() > 0) {
			sql += " AND search_target_code IN (?";
			for (int i=1; i<targetCodes.size(); i++) { sql += ",?"; }
			sql += ")";
		}

		try (Connection connection = DatabaseUtil.dataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setString(2, targetKW);
			for (int i=0; i<targetCodes.size(); i++) { statement.setInt(3+i, targetCodes.get(i).getCode()); }

			nResult = statement.executeUpdate();
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return nResult;
	}
}

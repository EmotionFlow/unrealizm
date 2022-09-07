package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

import javax.servlet.http.HttpServletRequest;
import java.sql.*;
import java.util.*;

public class GetSearchLogC {
	public List<String> keywords = null;
	String searchType = "";

	public void getParam(HttpServletRequest request) {
		searchType = request.getParameter("type");
	}

	public int getResults(CheckLogin checkLogin) {
		int  nResult = -1;
		keywords = new ArrayList<>();

		List<KeywordSearchLog.SearchTarget> targetCodes = new ArrayList<>();
		if (searchType.equals("Contents") || searchType.equals("Tags")) {
			targetCodes.add(KeywordSearchLog.SearchTarget.Contents);
			targetCodes.add(KeywordSearchLog.SearchTarget.Tags);
		} else if (searchType.equals("Users")) {
			targetCodes.add(KeywordSearchLog.SearchTarget.Users);
		}

		String sql = "SELECT keywords FROM keyword_search_logs WHERE user_id=? AND created_at > now() - ?::INTERVAL";

		if (targetCodes.size() > 0) {
			sql += " AND search_target_code IN (?";
			for (int i=1; i<targetCodes.size(); i++) { sql += ",?"; }
			sql += ")";
		}

		sql += " GROUP BY keywords ORDER BY MAX(created_at) DESC LIMIT ?";

		try (Connection connection = DatabaseUtil.replicaDataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setString(2, String.valueOf(Common.SEARCH_LOG_SUGGEST_DAYS[checkLogin.m_nPassportId]) + " day");
			for (int i=0; i<targetCodes.size(); i++) { statement.setInt(3+i, targetCodes.get(i).getCode()); }
			statement.setInt(3 + targetCodes.size(), Common.SEARCH_LOG_SUGGEST_MAX[checkLogin.m_nPassportId]);

			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				keywords.add(resultSet.getString("keywords"));
			}

			nResult = keywords.size();
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return nResult;
	}
}

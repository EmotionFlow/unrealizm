package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

import javax.servlet.http.HttpServletRequest;
import java.sql.*;
import java.util.*;

public class GetSearchSuggestionC {
	public List<String> keywords = null;
	public String searchInput = "";
	String searchType = "";

	public void getParam(HttpServletRequest request) {
		searchType = request.getParameter("type");
		searchInput = request.getParameter("input");
	}

	public int getResults(CheckLogin checkLogin) {
		int  nResult = -1;
		keywords = new ArrayList<>();
		String muteKeywords = "";

		List<KeywordSearchLog.SearchTarget> targetCodes = new ArrayList<>();
		if (searchType.equals("Contents") || searchType.equals("Tags")) {
			targetCodes.add(KeywordSearchLog.SearchTarget.Contents);
			targetCodes.add(KeywordSearchLog.SearchTarget.Tags);
		} else if (searchType.equals("Users")) {
			targetCodes.add(KeywordSearchLog.SearchTarget.Users);
		}

		String subSql = """
			SELECT id, keywords, result_num,
			RANK() OVER(PARTITION BY keywords ORDER BY id DESC) AS rank_
			FROM keyword_search_logs WHERE keywords &@~ ? AND keywords &@~ ? AND result_num > 0 AND ng = 0
			""";

		if (targetCodes.size() > 0) {
			subSql += " AND search_target_code IN (?";
			for (int i=1; i<targetCodes.size(); i++) { subSql += ",?"; }
			subSql += ")";
		}
		String sql = "SELECT keywords FROM (" + subSql + ") AS kw WHERE rank_ = 1 ORDER BY result_num DESC, id DESC LIMIT ?";

		try (Connection connection = DatabaseUtil.replicaDataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(sql);
		) {
			if(checkLogin.m_bLogin && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
				muteKeywords = SqlUtil.getMuteKeyWord(connection, checkLogin.m_nUserId);
			}

			statement.setString(1, searchInput);
			statement.setString(2, "-(" + muteKeywords + ")");
			for (int i=0; i<targetCodes.size(); i++) { statement.setInt(3 + i, targetCodes.get(i).getCode()); }
			statement.setInt(3 + targetCodes.size(), 5);

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

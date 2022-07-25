package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;
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
		if(!checkLogin.m_bLogin){return nResult;}

		List<KeywordSearchLog.SearchTarget> targetCodes = new ArrayList<>();
		if (searchType.equals("Contents") || searchType.equals("Tags")) {
			targetCodes.add(KeywordSearchLog.SearchTarget.Contents);
			targetCodes.add(KeywordSearchLog.SearchTarget.Tags);
		} else if (searchType.equals("Users")) {
			targetCodes.add(KeywordSearchLog.SearchTarget.Users);
		} else {
			targetCodes.add(KeywordSearchLog.SearchTarget.Undefined);
		}

		String sql = "SELECT keywords FROM keyword_search_logs WHERE user_id=? AND search_target_code IN (?";
		for (int i=1; i<targetCodes.size(); i++) { sql += ",?"; }
		sql += ") GROUP BY keywords ORDER BY MAX(created_at) DESC LIMIT ?";
		try (Connection connection = DatabaseUtil.dataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, checkLogin.m_nUserId);
			for (int i=0; i<targetCodes.size(); i++) { statement.setInt(2+i, targetCodes.get(i).getCode()); }
			statement.setInt(2 + targetCodes.size(), Common.SEARCH_LOG_SUGGEST_MAX);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				keywords.add(resultSet.getString("keywords"));
			}

			nResult = keywords.size();
		} catch(Exception e) {
			e.printStackTrace();
		}
		return nResult;
	}
}

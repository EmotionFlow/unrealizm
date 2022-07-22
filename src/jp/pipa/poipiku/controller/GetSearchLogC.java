package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.*;
import java.util.*;

public class GetSearchLogC {
	public List<String> keywords = null;

	public int getResults(CheckLogin checkLogin) {
		int  nResult = -1;
		keywords = new ArrayList<>();
		if(!checkLogin.m_bLogin){return nResult;}

		String sql = "SELECT keywords FROM keyword_search_logs WHERE user_id=? GROUP BY keywords ORDER BY MAX(created_at) DESC LIMIT ?";
		try (Connection connection = DatabaseUtil.dataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setInt(2, Common.SEARCH_LOG_SUGGEST_MAX);
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

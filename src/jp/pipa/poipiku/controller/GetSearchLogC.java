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

		String sql = "SELECT keywords FROM (SELECT DISTINCT ON (keywords) * FROM keyword_search_logs WHERE user_id=?) kw ORDER BY created_at DESC";
		try (Connection connection = DatabaseUtil.dataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, checkLogin.m_nUserId);
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

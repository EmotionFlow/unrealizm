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
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		keywords = new ArrayList<>();
		if(!checkLogin.m_bLogin){return nResult;}

		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "SELECT keywords FROM (SELECT DISTINCT ON (keywords) * FROM keyword_search_logs WHERE user_id=?) kw ORDER BY created_at DESC";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				keywords.add(resultSet.getString("keywords"));
			}

			nResult = keywords.size();

		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return nResult;
	}
}

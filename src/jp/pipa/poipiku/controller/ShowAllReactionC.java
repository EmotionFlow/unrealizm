package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ShowAllReactionC {
	public int contentId = -1;

	public void getParam(HttpServletRequest request) {
		try {
			contentId = Util.toInt(request.getParameter("IID"));
			request.setCharacterEncoding("UTF-8");
		} catch(Exception e) {
			contentId = -1;
		}
	}

	public int contentUserId = -1;
	public String comments = "";
	public int lastCommentId = -1;
	public boolean getResults() {
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();

			statement = connection.prepareStatement("SELECT user_id FROM contents_0000 WHERE content_id=?");
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				contentUserId = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if (contentUserId > 0) {
				statement = connection.prepareStatement("SELECT comment_id, description FROM comments_0000 WHERE content_id=? ORDER BY comment_id");
				statement.setInt(1, contentId);
				resultSet = statement.executeQuery();
				StringBuilder sb = new StringBuilder();
				while (resultSet.next()) {
					lastCommentId = resultSet.getInt(1);
					sb.append(resultSet.getString(2));
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
				comments = sb.toString();
				bRtn = true;
			}
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

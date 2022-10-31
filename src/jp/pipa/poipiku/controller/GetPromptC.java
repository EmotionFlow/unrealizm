package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.KeywordSearchLog;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class GetPromptC {
	int contentId = -1;
	public void getParam(HttpServletRequest request) {
		contentId = Util.toInt(request.getParameter("ID"));
	}

	public String prompt = "";
	public String otherParams = "";
	public int categoryId = -1;
	public boolean getResults(CheckLogin checkLogin) {
		if (contentId < 0) return false;

		try (Connection connection = DatabaseUtil.replicaDataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement("""
                SELECT category_id, ai_prompt, ai_other_params FROM contents_0000 WHERE content_id = ?
				""");
		) {
			statement.setInt(1, contentId);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				categoryId = resultSet.getInt("category_id");
				prompt = resultSet.getString("ai_prompt");
				otherParams = resultSet.getString("ai_other_params");
			}

		} catch(Exception e) {
			e.printStackTrace();
		}
		return true;
	}
}

package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class IncrementAiPromptCopyNumC extends Controller{
	public int contentId = -1;
	public int ownerUserId = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			contentId = Util.toInt(request.getParameter("IID"));
			ownerUserId = Util.toInt(request.getParameter("UID"));
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public boolean getResults(final CheckLogin checkLogin) {
		if(contentId < 0 || ownerUserId < 0) {
			return false;
		}

		boolean result = false;

		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement("""
                UPDATE poipiku.public.contents_0000 SET ai_prompt_copy_num = ai_prompt_copy_num + 1
                WHERE user_id=? AND content_id=?
				""")){
			statement.setInt(1, ownerUserId);
			statement.setInt(2, contentId);
			statement.executeUpdate();
			result = true;
		} catch (SQLException throwables) {
			throwables.printStackTrace();
			result = false;
		}

		return result;
	}
}

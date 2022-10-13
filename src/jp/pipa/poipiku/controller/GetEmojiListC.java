package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Emoji;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class GetEmojiListC {
	public int contentId = -1;
	public int categoryId = -1;
	public boolean miniList = false;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			contentId = Util.toInt(request.getParameter("IID"));
			categoryId = Util.toIntN(request.getParameter("CAT"), 0, Emoji.EMOJI_CAT_CHEER);
			miniList = Util.toBoolean(request.getParameter("MINI"));
		} catch(Exception ignored) {}
	}

	public boolean cheerNg = false;

	/*
					RECENT  POPULAR  FOOD    OTHER   CHEER
		notLogin    []      static   static  static  []
		Login       vEmoji  static   static  static  static
	 */
	public String[] getResults(CheckLogin checkLogin) {
		String[] EMOJI_LIST = Emoji.getInstance().EMOJI_LIST[categoryId];

		if(categoryId ==Emoji.EMOJI_CAT_RECENT && !checkLogin.m_bLogin) return EMOJI_LIST;
		if(categoryId ==Emoji.EMOJI_CAT_POPULAR) return EMOJI_LIST;
		if(categoryId ==Emoji.EMOJI_CAT_FOOD) return EMOJI_LIST;
		if(categoryId ==Emoji.EMOJI_CAT_OTHER) return EMOJI_LIST;

		if(categoryId ==Emoji.EMOJI_CAT_CHEER) {
			if(checkLogin.m_bLogin){
				final String sql = "SELECT cheer_ng FROM contents_0000 WHERE content_id=?";
				try (
						Connection connection = DatabaseUtil.dataSource.getConnection();
						PreparedStatement statement = connection.prepareStatement(sql)
						) {
					statement.setInt(1, contentId);
					ResultSet resultSet = statement.executeQuery();
					if (resultSet.next()) {
						cheerNg = resultSet.getBoolean("cheer_ng");
					}
				} catch (Exception e) {
					Log.d(sql);
					e.printStackTrace();
				}
			} else {
				cheerNg = true;
			}
		} else {
			ArrayList<String> vEmoji;
			if (categoryId == Emoji.EMOJI_CAT_RECENT) {
				vEmoji = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
			} else {
				vEmoji = Emoji.getDefaultEmoji(-1);
			}
			EMOJI_LIST = vEmoji.toArray(new String[0]);
		}
		return EMOJI_LIST;
	}
}
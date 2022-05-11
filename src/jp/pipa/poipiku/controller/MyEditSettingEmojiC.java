package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;

public class MyEditSettingEmojiC {
	public CommentTemplate commentTemplate;
	public List<UserWaveTemplate> userWaveTemplateList;
	public boolean getResults(CheckLogin checkLogin) {
		commentTemplate = new CommentTemplate();
		if (!commentTemplate.select(checkLogin.m_nUserId, 0)) {
			commentTemplate.chars = Emoji.REPLY_EMOJI_DEFAULT;
		}
		userWaveTemplateList = UserWaveTemplate.select(checkLogin.m_nUserId);
		return true;
	}
}

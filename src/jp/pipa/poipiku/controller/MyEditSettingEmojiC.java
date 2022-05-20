package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import java.util.List;

public class MyEditSettingEmojiC {
	public CommentTemplate commentTemplate;
	public List<UserWaveTemplate> userWaveTemplateList;
	public boolean userWaveEnabled = false;
	public boolean userWaveCommentEnabled = false;
	public boolean getResults(CheckLogin checkLogin) {
		commentTemplate = new CommentTemplate();
		if (!commentTemplate.select(checkLogin.m_nUserId, 0)) {
			commentTemplate.chars = Emoji.REPLY_EMOJI_DEFAULT;
		}
		userWaveTemplateList = UserWaveTemplate.selectAll(checkLogin.m_nUserId);
		if (!userWaveTemplateList.isEmpty()) {
			userWaveEnabled = UserWaveTemplate.isEnabled(userWaveTemplateList);
			userWaveCommentEnabled = UserWaveTemplate.isCommentEnabled(userWaveTemplateList);
			userWaveTemplateList.removeIf(e -> e.dispOrder<0);
		} else {
			userWaveEnabled = true;
			userWaveCommentEnabled = false;
		}
		return true;
	}
}

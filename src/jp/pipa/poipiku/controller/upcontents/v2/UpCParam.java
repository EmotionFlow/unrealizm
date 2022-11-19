package jp.pipa.poipiku.controller.upcontents.v2;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.SupportedLocales;
import jp.pipa.poipiku.UserLocale;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.lang.reflect.Field;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;

public class UpCParam {
	public int userId = -1;
	public int categoryId = 0;
	public String description = "";
	public String aiPrompt = "";
	public String aiNegativePrompt = "";
	public String aiOtherPrams = "";
	public String tagList = "";
	public int editorId = Common.EDITOR_UPLOAD;

	public boolean isPublish = true;
	public boolean isTimeLimited = false;
	public Timestamp publishStart = null;
	public Timestamp publishEnd = null;
	public boolean isNsfw = false;
	public int safeFilterId = Common.SAFE_FILTER_ALL;
	public boolean isConditionalShow = false;
	public int publishId = Common.PUBLISH_ID_ALL;
	public boolean isNoPassword = true;
	public String password = "";
	public boolean isShowFirst = false;
	public boolean isTweet = false;
	public boolean isTweetWithImage = false;
	public boolean isTwitterCardThumbnail = true;
	public boolean isCheerNg = true;
	public String twitterListId = "";
	public boolean isShowRecently = true;

	public int genre = -1;
	public int requestId = -1;
	public String privateNote = "";
	public HashMap<Integer, String> descriptionTranslations = new HashMap<>();

	protected void GetParams(HttpServletRequest request) throws Exception{
		request.setCharacterEncoding("UTF-8");
		userId = Util.toInt(request.getParameter("UID"));
		categoryId = Util.toIntN(request.getParameter("CAT"), 0, Common.CATEGORY_ID_MAX);
		genre = Util.toInt(request.getParameter("GD"));
		requestId = Util.toInt(request.getParameter("RID"));
		privateNote = Util.deleteInvalidChar(Common.TrimAll(request.getParameter("NOTE")));

		description = Util.deleteInvalidChar(Common.TrimAll(request.getParameter("DES")));
		description = description.replace("＃", "#").replace("♯", "#").replace("\r\n", "\n").replace("\r", "\n");
		if(description.startsWith("#")) description =" "+ description;
		description = Util.deleteInvalidChar(description);

		aiPrompt = Util.toString(Common.TrimAll(request.getParameter("AI_PRMPT")).replace("\r\n", "\n").replace("\r", "\n"));
		aiNegativePrompt = Util.toString(Common.TrimAll(request.getParameter("AI_NG_PRMPT")).replace("\r\n", "\n").replace("\r", "\n"));
		aiOtherPrams = Util.toString(Common.TrimAll(request.getParameter("AI_PARAMS")).replace("\r\n", "\n").replace("\r", "\n"));

		tagList = Util.deleteInvalidChar(Common.SubStrNum(Common.TrimAll(request.getParameter("TAG")), 100));
		tagList = tagList.replace("＃", "#").replace("♯", "#").replace("\r\n", " ").replace("\r", " ").replace("　", " ");
		tagList = Util.deleteInvalidChar(tagList);

		editorId = Util.toIntN(request.getParameter("ED"), 0, Common.EDITOR_ID_MAX);

		isPublish = Util.toBoolean(request.getParameter("OPTION_PUBLISH"));

		isTimeLimited = !Util.toBoolean(request.getParameter("OPTION_NOT_TIME_LIMITED"));
		publishStart = Util.toSqlTimestamp(request.getParameter("TIME_LIMITED_START"));
		publishEnd = Util.toSqlTimestamp(request.getParameter("TIME_LIMITED_END"));

		isNsfw = !Util.toBoolean(request.getParameter("OPTION_NOT_PUBLISH_NSFW"));
		safeFilterId = Util.toInt(request.getParameter("NSFW_VAL"));

		isConditionalShow = !Util.toBoolean(request.getParameter("OPTION_NO_CONDITIONAL_SHOW"));
		publishId = Util.toInt(request.getParameter("SHOW_LIMIT_VAL"));

		isNoPassword = Util.toBoolean(request.getParameter("OPTION_NO_PASSWORD"));
		password = Util.deleteInvalidChar(Common.SubStrNum(Common.TrimAll(request.getParameter("PASSWORD_VAL")), 16));

		isShowFirst = Util.toBoolean(request.getParameter("OPTION_SHOW_FIRST"));
		isTweet = Util.toBoolean(request.getParameter("OPTION_TWEET"));
		isTweetWithImage = Util.toBoolean(request.getParameter("OPTION_TWEET_IMAGE"));
		isTwitterCardThumbnail = Util.toBoolean(request.getParameter("OPTION_TWITTER_CARD_THUMBNAIL"));
		isCheerNg = Util.toBoolean(request.getParameter("OPTION_CHEER_NG"));
		isShowRecently = Util.toBoolean(request.getParameter("OPTION_RECENT"));

		twitterListId = Common.TrimAll(request.getParameter("TWITTER_LIST_ID"));

		for (UserLocale userLocale: SupportedLocales.list) {
			String s = request.getParameter("DES" + userLocale.id);
			if (s != null) {
				descriptionTranslations.put(userLocale.id, s.trim());
			}
		}

		// format tag list
		if(!tagList.isEmpty()) {
			ArrayList<String> listTag = new ArrayList<String>();
			String[] tags = tagList.split(" ");
			for(String tag : tags) {
				tag = tag.trim();
				if(tag.isEmpty()) continue;
				if(!tag.startsWith("#")) {
					tag = "#"+tag;
				}
				listTag.add(tag);
			}
			tagList = "";
			if(listTag.size()>0) {
				List<String> listTagUnique = new ArrayList<>(new LinkedHashSet<String>(listTag));
				if(listTagUnique.size()>0) {
					tagList = " " + String.join(" ", listTagUnique);
				}
			}
		}
	};

	protected int ErrorOccurred(Exception e) {
		e.printStackTrace();
		userId = -1;
		return -99;
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append("Class: " + this.getClass().getCanonicalName() + "\n");
		sb.append("Settings:\n");
		if (this.getClass().getSuperclass() != null) {
			for (Field field : this.getClass().getSuperclass().getDeclaredFields()) {
				try {
					field.setAccessible(true);
					sb.append(field.getName() + " = " + field.get(this) + "\n");
				} catch (IllegalAccessException e) {
					sb.append(field.getName() + " = " + "access denied\n");
				}
			}
		}

		for (Field field : this.getClass().getDeclaredFields()) {
			try {
				field.setAccessible(true);
				sb.append(field.getName() + " = " + field.get(this) + "\n");
			} catch (IllegalAccessException e) {
				sb.append(field.getName() + " = " + "access denied\n");
			}
		}
		return sb.toString();
	}
};

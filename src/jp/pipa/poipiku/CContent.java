package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

import jp.pipa.poipiku.util.Util;

public final class CContent {
	public static final int BOOKMARK_NONE = 0;
	public static final int BOOKMARK_BOOKMARKING = 1;
	public static final int BOOKMARK_LIMIT = 2;

	//contents_0000.tweet_when_published
	public static final int TWEET_CONCURRENT = 1;       // 0001
	public static final int TWEET_WITH_THUMBNAIL = 2;   // 0010
	public static final int TWITTER_CARD_THUMBNAIL = 4; // 0100

	public int m_nContentId = 0;
	public int m_nCategoryId = 0;
	public String m_strDescription = "";
	public String m_strDescriptionTranslated = null; // 閲覧ユーザーのlangIdに一致する翻訳があったらここに格納する。
	public boolean m_bLimitedTimePublish = false;
	public Timestamp m_timeUploadDate = new Timestamp(0);
	public Timestamp m_timeEndDate = new Timestamp(0);
	public int m_nUserId = 0;
	public int m_nOpenId = 0;
	public boolean m_bNotRecently = false;
	public int m_nEditorId = Common.EDITOR_UPLOAD;
	public String m_strFileName = "";
	public int m_nFileNum = 0;
	public int m_nBookmarkNum = 0;
	public int m_nSafeFilter = 0;
	public int m_nFileWidth = 0;
	public int m_nFileHeight = 0;
	public String m_strTagList = "";
	public int m_nPublishId = 0;
	public int publishAllNum = 0;
	public String m_strPassword = "";
	public CUser m_cUser = new CUser();
	public String m_strListId = "";
	public String m_strTweetId = "";
	public int m_nTweetWhenPublished = 0;
	public ArrayList<CComment> m_vComment = new ArrayList<>();
	public String m_strCommentsListsCache = "";
	public int m_nCommentsListsCacheLastId = 0;
	public ArrayList<CContentAppend> m_vContentAppend = new ArrayList<>();
	public boolean m_bCheerNg = true;
	public String m_strTextBody = "";
	public int m_nGenreId = 1;
	public int m_nRequestId = -1;
	public String title = "";
	public String novelHtml = "";
	public String novelHtmlShort = "";
	public int novelDirection = 0;
	public int pinOrder = -1;
	public String privateNote = "";
	public Timestamp createdAt = null;
	public Timestamp updatedAt = null;

	public int m_nBookmarkState = BOOKMARK_NONE; // アクセスユーザがこのコンテンツをブックマークしてるかのフラグ

	static final String SRC_IMG_PATH = "/var/www/html/poipiku";    // 最後の/はDBに入っている
	
	public boolean isHideThumbImg = false;
	public String thumbImgUrl = null;

	public enum OpenId implements CodeEnum<CContent.OpenId> {
		Undefined(-1),
		Open(0),
		OpenAvoidNewArrivals(1),
		Hide(2);
		private final int code;
		private OpenId(int code) {
			this.code = code;
		}

		static public CContent.OpenId byCode(int _code) {
			return CodeEnum.getEnum(CContent.OpenId.class, _code);
		}

		@Override
		public int getCode() {
			return code;
		}
	}

	public enum ColumnType implements CodeEnum<CContent.ColumnType> {
		Undefined(-1),
		Description(0);
		private final int code;
		private ColumnType(int code) {
			this.code = code;
		}

		static public CContent.ColumnType byCode(int _code) {
			return CodeEnum.getEnum(CContent.ColumnType.class, _code);
		}

		@Override
		public int getCode() {
			return code;
		}
	}


	public static int getSafeFilterDB(int publishId){
		int safe_filter = Common.SAFE_FILTER_ALL;
		switch(publishId) {
			case Common.PUBLISH_ID_R15:
				safe_filter = Common.SAFE_FILTER_R15;
				break;
			case Common.PUBLISH_ID_R18:
				safe_filter = Common.SAFE_FILTER_R18;
				break;
			case Common.PUBLISH_ID_R18G:
				safe_filter = Common.SAFE_FILTER_R18G;
				break;
		}
		return safe_filter;
	}

	public static int getTweetWhenPublishedId(boolean isTweetTxt, boolean isTweetImg, boolean isTwitterCardThumbnail) {
		int ret = 0;
		if(isTweetTxt) ret += TWEET_CONCURRENT;
		if(isTweetImg) ret += TWEET_WITH_THUMBNAIL;
		if(isTwitterCardThumbnail) ret += TWITTER_CARD_THUMBNAIL;
		return ret;
	}

	public boolean isTweetConcurrent() {
		return (m_nTweetWhenPublished & TWEET_CONCURRENT) != 0;
	}

	public boolean isTweetWithThumbnail() {
		return (m_nTweetWhenPublished & TWEET_WITH_THUMBNAIL) != 0;
	}

	public boolean isTwitterCardThumbnail() {
		return (m_nTweetWhenPublished & TWITTER_CARD_THUMBNAIL) != 0;
	}

	public void set(ResultSet resultSet) throws SQLException {
		m_nContentId		= resultSet.getInt("content_id");
		m_nCategoryId		= resultSet.getInt("category_id");
		m_strDescription	= Util.toString(resultSet.getString("description"));
		m_bLimitedTimePublish=resultSet.getBoolean("limited_time_publish");
		m_timeUploadDate	= resultSet.getTimestamp("upload_date");
		m_timeEndDate		= resultSet.getTimestamp("end_date");
		m_nUserId			= resultSet.getInt("user_id");
		m_nOpenId			= resultSet.getInt("open_id");
		m_bNotRecently		= resultSet.getBoolean("not_recently");
		m_strFileName		= Util.toString(resultSet.getString("file_name"));
		m_nFileNum			= resultSet.getInt("file_num");
		m_nBookmarkNum		= resultSet.getInt("bookmark_num");
		m_nSafeFilter		= resultSet.getInt("safe_filter");
		m_nFileWidth		= resultSet.getInt("file_width");
		m_nFileHeight		= resultSet.getInt("file_height");
		m_strTagList		= Util.toString(resultSet.getString("tag_list"));
		m_nPublishId		= resultSet.getInt("publish_id");
		publishAllNum       = resultSet.getInt("publish_all_num");
		m_strListId			= Util.toString(resultSet.getString("list_id"));
		m_cUser.m_nUserId	= resultSet.getInt("user_id");
		m_nEditorId			= resultSet.getInt("editor_id");
		m_strPassword		= Util.toString(resultSet.getString("password"));
		m_strTweetId		= Util.toString(resultSet.getString("tweet_id"));
		m_nTweetWhenPublished=resultSet.getInt("tweet_when_published");
		m_bCheerNg			= resultSet.getBoolean("cheer_ng");
		m_strTextBody		= Util.toString(resultSet.getString("text_body"));
		m_nGenreId			= resultSet.getInt("genre_id");
		title				= Util.toString(resultSet.getString("title"));
		novelHtml			= Util.toString(resultSet.getString("novel_html"));
		novelHtmlShort		= Util.toString(resultSet.getString("novel_html_short"));
		novelDirection		= Util.toIntN(resultSet.getInt("novel_direction"), 0, 1);
		privateNote         = Util.toString(resultSet.getString("private_note"));
		createdAt           = resultSet.getTimestamp("created_at");
		updatedAt           = resultSet.getTimestamp("updated_at");

		// 後方互換
		if (novelHtml.isEmpty()) {
			novelHtml = Util.toStringHtml(m_strTextBody);
		}
		if (novelHtmlShort.isEmpty()) {
			novelHtmlShort = Util.toStringHtml(Util.subStrNum(m_strTextBody, 500));
		}

		if(m_nPublishId==0 && m_nSafeFilter>0) {
			switch(m_nSafeFilter) {
				case Common.SAFE_FILTER_R15:
					m_nPublishId = Common.PUBLISH_ID_R15;
					break;
				case Common.SAFE_FILTER_R18:
					m_nPublishId = Common.PUBLISH_ID_R18;
					break;
				case Common.SAFE_FILTER_R18G:
				default:
					m_nPublishId = Common.PUBLISH_ID_R18G;
					break;
			}
		}
	}

	public CContent() {}
	public CContent(ResultSet resultSet) throws SQLException {
		set(resultSet);
	}
	public CContent(ResultSet resultSet, float timeZoneOffset) throws SQLException {
		set(resultSet);
		updateDateTimeWithTimeZoneOffset(createdAt, timeZoneOffset);
		updateDateTimeWithTimeZoneOffset(updatedAt, timeZoneOffset);
	}

	public boolean nowAvailable() {
		return (m_nOpenId == OpenId.Open.getCode() ||m_nOpenId == OpenId.OpenAvoidNewArrivals.getCode());
	}

	public boolean isValidPublishId() {
		return m_nPublishId==Common.PUBLISH_ID_ALL
				|| m_nPublishId==Common.PUBLISH_ID_LOGIN
				|| m_nPublishId==Common.PUBLISH_ID_FOLLOWER
				|| m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER
				|| m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE
				|| m_nPublishId==Common.PUBLISH_ID_T_EACH
				|| m_nPublishId==Common.PUBLISH_ID_T_LIST
				|| m_nPublishId==Common.PUBLISH_ID_T_RT;
	}

	public void setThumb() {
		isHideThumbImg = false;
		switch(m_nPublishId) {
			case Common.PUBLISH_ID_R15:
			case Common.PUBLISH_ID_R18:
			case Common.PUBLISH_ID_R18G:
			case Common.PUBLISH_ID_PASS:
			case Common.PUBLISH_ID_LOGIN:
			case Common.PUBLISH_ID_FOLLOWER:
			case Common.PUBLISH_ID_T_FOLLOWER:
			case Common.PUBLISH_ID_T_FOLLOWEE:
			case Common.PUBLISH_ID_T_EACH:
			case Common.PUBLISH_ID_T_LIST:
				if (publishAllNum == 0) {
					thumbImgUrl = Common.PUBLISH_ID_FILE[m_nPublishId];
					isHideThumbImg = true;
				} else {
					thumbImgUrl = m_strFileName + "_640.jpg";
					isHideThumbImg = false;
				}
				break;
			case Common.PUBLISH_ID_HIDDEN:
				thumbImgUrl="/img/poipiku_icon_512x512_2.png";
				break;
			case Common.PUBLISH_ID_ALL:
			default:
				if (m_strFileName.isEmpty()) {
					thumbImgUrl = "/img/poipiku_icon_512x512_2.png";
				} else {
					thumbImgUrl = m_strFileName + "_640.jpg";
				}
				break;
		}
	}


	public String getThumbnailFilePath() {
		final String s;
		switch (m_nPublishId) {
			case Common.PUBLISH_ID_R15:
			case Common.PUBLISH_ID_R18:
			case Common.PUBLISH_ID_R18G:
			case Common.PUBLISH_ID_PASS:
			case Common.PUBLISH_ID_LOGIN:
			case Common.PUBLISH_ID_FOLLOWER:
			case Common.PUBLISH_ID_T_FOLLOWER:
			case Common.PUBLISH_ID_T_FOLLOWEE:
			case Common.PUBLISH_ID_T_EACH:
			case Common.PUBLISH_ID_T_LIST:
				s = Common.PUBLISH_ID_FILE[m_nPublishId];
				break;
			case Common.PUBLISH_ID_ALL:
			case Common.PUBLISH_ID_HIDDEN:
			default:
				s = m_strFileName;
				break;
		}
		if (!s.isEmpty()) {
			return String.format("%s%s_360.jpg", SRC_IMG_PATH, s);
		} else {
			return "";
		}
	}

	private void updateDateTimeWithTimeZoneOffset(Timestamp timestamp, float timeZoneOffset){
		if (timestamp != null) {
			long jst, offsetTime;
			jst = timestamp.getTime();
			offsetTime = jst + (long)((9 + timeZoneOffset) * 60 * 60 * 1000);
			timestamp = new Timestamp(offsetTime);
		}
	}
}

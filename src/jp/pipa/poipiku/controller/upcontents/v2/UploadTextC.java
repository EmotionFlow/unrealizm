package jp.pipa.poipiku.controller.upcontents.v2;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.controller.Controller;
import jp.pipa.poipiku.controller.DeliverRequestC;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.NovelUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;

public final class UploadTextC extends UpC {
	private int contentId = -99;
	public int openId = -1;
	public boolean deliverRequestResult;
	public int GetResults(UploadTextCParam upParam, CheckLogin checkLogin) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		int idx = 0;

		DeliverRequestC deliverRequestC = null;
		if (upParam.requestId > 0) {
			deliverRequestC = new DeliverRequestC(checkLogin, upParam.requestId);
			if (deliverRequestC.errorKind != Controller.ErrorKind.None) {
				return contentId;
			}
		}

		try {
			// regist to DB
			connection = DatabaseUtil.dataSource.getConnection();

			// get content id
			ArrayList<String> lColumns = new ArrayList<>(
					Arrays.asList(
							"user_id", "genre_id", "category_id", "description", "private_note",
							"tag_list", "publish_id", "password_enabled", "password",
							"list_id", "safe_filter", "editor_id", "cheer_ng",
							"open_id", "tweet_when_published", "limited_time_publish",
							"title", "text_body", "novel_html", "novel_html_short", "novel_direction"));

			if(upParam.isTimeLimited){
				if(upParam.publishStart == null && upParam.publishEnd == null){
					throw new Exception("m_nPublishId is 'limited time', but start and end is null.");
				}
				if(upParam.publishStart != null || upParam.publishEnd != null){
					if(upParam.publishStart != null ){
						lColumns.add("upload_date");
					}
					if(upParam.publishEnd != null ){
						lColumns.add("end_date");
					}
				}
			}

			final String textBody = Common.SubStrNum(upParam.textBody, Common.EDITOR_TEXT_MAX[upParam.editorId][checkLogin.m_nPassportId]);
			ArrayList<String> lVals = new ArrayList<>();
			lColumns.forEach(c -> lVals.add("?"));
			sql = String.format(
					"INSERT INTO contents_0000(%s, created_at, updated_at) VALUES(%s, %s) RETURNING content_id",
					String.join(",", lColumns),
					String.join(",", lVals),
					checkLogin.m_nPassportId==Common.PASSPORT_OFF ? "null, null" : "now(), now()"
			);

			statement = connection.prepareStatement(sql);
			idx = 1;
			statement.setInt(idx++, upParam.userId);
			statement.setInt(idx++, upParam.genre);
			statement.setInt(idx++, upParam.categoryId);
			statement.setString(idx++, Common.SubStrNum(upParam.description, Common.EDITOR_DESC_MAX[upParam.editorId][checkLogin.m_nPassportId]));
			statement.setString(idx++, upParam.privateNote);
			statement.setString(idx++, upParam.tagList);

			if (!upParam.isConditionalShow) {
				statement.setInt(idx++, Common.PUBLISH_ID_ALL);
			} else {
				statement.setInt(idx++, upParam.publishId);
			}

			statement.setBoolean(idx++, !upParam.isNoPassword);
			statement.setString(idx++, upParam.password);

			statement.setString(idx++, upParam.twitterListId);

			if (upParam.isNsfw) {
				statement.setInt(idx++, upParam.safeFilterId);
			} else {
				statement.setInt(idx++, Common.SAFE_FILTER_ALL);
			}

			statement.setInt(idx++, upParam.editorId);
			statement.setBoolean(idx++, upParam.isCheerNg);

			openId = GetOpenId(
					-1,
					upParam.isPublish ? Common.PUBLISH_ID_ALL : Common.OPEN_ID_HIDDEN,
					!upParam.isShowRecently,
					upParam.isTimeLimited,
					upParam.isTimeLimited,
					upParam.publishStart,
					upParam.publishEnd,
					null,null);
			statement.setInt(idx++, openId);
			statement.setInt(idx++, CContent.getTweetWhenPublishedId(upParam.isTweet, upParam.isTweetWithImage, upParam.isTwitterCardThumbnail));

			statement.setBoolean(idx++, upParam.isTimeLimited);
			if (upParam.isTimeLimited) {
				if (upParam.publishStart != null) {
					statement.setTimestamp(idx++, upParam.publishStart);
				}
				if (upParam.publishEnd != null) {
					statement.setTimestamp(idx++, upParam.publishEnd);
				}
			}

			statement.setString(idx++, upParam.title);
			statement.setString(idx++, textBody);
			statement.setString(idx++, NovelUtil.genarateHtml(upParam.title, textBody, ""));
			statement.setString(idx++, NovelUtil.genarateHtmlShort(upParam.title, textBody, ""));
			statement.setInt(idx++, upParam.novelDirection);

			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				contentId = resultSet.getInt("content_id");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			AddTags(upParam.description, upParam.tagList, contentId, connection);

			if (deliverRequestC != null) {
				deliverRequestResult = deliverRequestC.getResults(contentId);
			}

		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return contentId;
	}
}

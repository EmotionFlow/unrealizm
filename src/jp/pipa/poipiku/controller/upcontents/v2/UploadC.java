package jp.pipa.poipiku.controller.upcontents.v2;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.ContentTranslation;
import jp.pipa.poipiku.controller.Controller;
import jp.pipa.poipiku.controller.DeliverRequestC;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Arrays;

public final class UploadC extends UpC {
	private int contentId = -99;
	public int openId = -1;
	public boolean deliverRequestResult;
	public int GetResults(UploadCParam upParam, CheckLogin checkLogin) {
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
			connection = DatabaseUtil.dataSource.getConnection();

			// get content id
			ArrayList<String> lColumns = new ArrayList<>(
					Arrays.asList(
							"user_id", "genre_id", "category_id", "description", "private_note",
							"tag_list", "publish_id", "publish_all_num", "password_enabled", "password", "list_id", "safe_filter",
							"editor_id", "cheer_ng", "tweet_when_published", "limited_time_publish"));

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

			if (!upParam.isShowFirst) {
				statement.setNull(idx++, Types.INTEGER);
			} else {
				statement.setInt(idx++, 1);
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

			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				contentId = resultSet.getInt("content_id");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			AddTags(upParam.description, upParam.tagList, contentId, connection);

			upParam.descriptionTranslations.forEach((key, value) -> {
				if (!value.isEmpty()) {
					ContentTranslation.upsert(contentId, key, CContent.ColumnType.Description, value, upParam.userId);
				}
			});

			if (deliverRequestC != null) {
				deliverRequestResult = deliverRequestC.getResults(contentId);
			}

			openId = upParam.isPublish ? Common.PUBLISH_ID_ALL : Common.OPEN_ID_HIDDEN;

		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return contentId;
	}
}

package jp.pipa.poipiku.controller.upcontents.v2;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.CTweet;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;

public final class UpdateC extends UpC {
	public static boolean doUpdateContentIdTransaction (Connection connection, int oldContentId, int newContentId) throws SQLException {
		PreparedStatement statement = null;
		String strSql = "";
		try{
			// transaction
			connection.setAutoCommit(false);
			String[] lUpdateTable = {"contents_0000", "bookmarks_0000", "comments_0000", "comments_desc_cache", "contents_appends_0000", "rank_contents_total", "tags_0000", "requests", "pins", "content_translations"};
			for(String t : lUpdateTable){
				strSql = "UPDATE " + t + " SET content_id=? WHERE content_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, newContentId);
				statement.setInt(2, oldContentId);
				statement.executeUpdate();
			}
			connection.commit();
		}catch(Exception e){
			Log.d(strSql);
			e.printStackTrace();
			connection.rollback();
			return false;
		}finally{
			if(statement!=null){statement.close();};statement=null;
			connection.setAutoCommit(true);
		}

		return true;
	}


	public int GetResults(UpdateCParam upParam, CheckLogin checkLogin) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 0;
		int publishIdPresent = -1;
		String tweetId = "";
		int openIdPresent = 2;
		Timestamp uploadDatePresent = new Timestamp(0);
		Timestamp endDatePresent = new Timestamp(0);
		boolean limitedTimePublishPresent = false;
		Integer newContentId = null;
		int nEditorId = Common.EDITOR_UPLOAD;

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			strSql = "SELECT open_id, publish_id, publish_all_num, tweet_id, limited_time_publish, upload_date, end_date, editor_id" +
					" FROM contents_0000 WHERE user_id=? AND content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, upParam.userId);
			statement.setInt(2, upParam.contentId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				openIdPresent = resultSet.getInt("open_id");
				publishIdPresent = resultSet.getInt("publish_id");
				tweetId = resultSet.getString("tweet_id");
				limitedTimePublishPresent = resultSet.getBoolean("limited_time_publish");
				uploadDatePresent = resultSet.getTimestamp("upload_date");
				endDatePresent = resultSet.getTimestamp("end_date");
				nEditorId = Math.max(resultSet.getInt("editor_id"), Common.EDITOR_UPLOAD);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch(Exception e) {
			e.printStackTrace();
			return -100;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
		}

		try {
			// create statement
			boolean bToPublish = false;
			int newOpenId = GetOpenId(
				openIdPresent,
				!upParam.isPublish ? Common.OPEN_ID_HIDDEN : Common.PUBLISH_ID_ALL,
				!upParam.isShowRecently,
				upParam.isTimeLimited,
				limitedTimePublishPresent,
				upParam.publishStart,
				upParam.publishEnd,
				uploadDatePresent,
				endDatePresent);
			String sqlUpdate =  "UPDATE contents_0000";
			ArrayList<String> lColumns = new ArrayList<>(Arrays.asList(
					"genre_id=?", "category_id=?", "open_id=?",
					"description=?", "private_note=?",
					"tag_list=?", "publish_id=?",
					"publish_all_num=?",
					"password_enabled=?", "password=?",
					"list_id=?", "safe_filter=?", "cheer_ng=?",
					"tweet_when_published=?",
					"not_recently=?", "limited_time_publish=?"
			));

			if (checkLogin.m_nPassportId==Common.PASSPORT_OFF) {
				lColumns.add("updated_at=NULL");
			}

			if(!upParam.isTimeLimited){
				// これまで非公開で、今後公開したい。
				if(openIdPresent==Common.OPEN_ID_HIDDEN && upParam.isPublish){
					bToPublish = true;
					lColumns.add("upload_date=now()");
				}
			} else {
				// 期間限定
				if(upParam.publishStart == null && upParam.publishEnd == null){
					throw new Exception("m_nPublishId is 'limited time', but start and end is null.");
				} else {
					if(upParam.publishStart != null ){
						lColumns.add("upload_date=?");
					}
					if(upParam.publishEnd != null ){
						lColumns.add("end_date=?");
					}
				}
			}

			String sqlSet = "SET " + String.join(",", lColumns);
			String sqlWhere = "WHERE user_id=? AND content_id=?";

			strSql = String.join(" ", Arrays.asList(sqlUpdate, sqlSet, sqlWhere));
			statement = connection.prepareStatement(strSql);
			try {
				idx = 1;
				// set values
				statement.setInt(idx++, upParam.genre);
				statement.setInt(idx++, upParam.categoryId);
				statement.setInt(idx++, newOpenId);
				statement.setString(idx++, Common.SubStrNum(upParam.description, Common.EDITOR_DESC_MAX[nEditorId][checkLogin.m_nPassportId]));
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

				statement.setBoolean(idx++, upParam.isCheerNg);
				statement.setInt(idx++, CContent.getTweetWhenPublishedId(upParam.isTweet, upParam.isTweetWithImage, upParam.isTwitterCardThumbnail));
				statement.setBoolean(idx++, !upParam.isShowRecently);

				statement.setBoolean(idx++, upParam.isTimeLimited);
				if (upParam.isTimeLimited) {
					if (upParam.publishStart != null) {
						statement.setTimestamp(idx++, upParam.publishStart);
					}
					if (upParam.publishEnd != null) {
						statement.setTimestamp(idx++, upParam.publishEnd);
					}
				}

				// set where params
				statement.setInt(idx++, upParam.userId);
				statement.setInt(idx++, upParam.contentId);

				statement.executeUpdate();
			} catch(Exception e) {
				e.printStackTrace();
				return -200;
			}
			statement.close();statement=null;

			// content_idを振り直す
			// 処理更新時は、 https://github.com/gochipon/poipiku_script にもその内容を反映させること。
			if(bToPublish){
				try{
					strSql = "INSERT INTO content_id_histories VALUES(?, nextval('contents_0000_content_id_seq'::regclass)) RETURNING new_id";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, upParam.contentId);
					resultSet = statement.executeQuery();
					if(resultSet.next()) {
						newContentId = resultSet.getInt("new_id");
					} else {
						throw new Exception("new content id is null.");
					}
				}catch(Exception e){
					Log.d(strSql);
					e.printStackTrace();
					return -300;
				}finally{
					if(resultSet!=null){resultSet.close();};resultSet=null;
					if(statement!=null){statement.close();};statement=null;
				}

				boolean bUpdateResult = doUpdateContentIdTransaction(connection,  upParam.contentId, newContentId);
				if(!bUpdateResult){
					try{
						strSql = "DELETE FROM content_id_histories WHERE old_id=?";
						statement = connection.prepareStatement(strSql);
						statement.setInt(1, upParam.contentId);
						statement.executeUpdate();
					}catch(Exception e){
						Log.d(strSql);
						e.printStackTrace();
					}finally{
						if(statement!=null){statement.close();};statement=null;
					}
					return -400;
				}
			}

			final int contentId = newContentId==null ? upParam.contentId : newContentId;

			// Delete old tags
			if (!upParam.description.isEmpty() || !upParam.tagList.isEmpty()) {
				strSql = "DELETE FROM tags_0000 WHERE content_id=?;";
				statement = connection.prepareStatement(strSql);
				try {
					statement.setInt(1, contentId);
					statement.executeUpdate();
				} catch(Exception e) {
					e.printStackTrace();
					return -500;
				}
				statement.close();statement=null;
			}

			// Add tags
			AddTags(upParam.description, upParam.tagList, contentId, connection);

			upParam.descriptionTranslations.forEach((key, value) -> {
				if (!value.isEmpty()) {
					ContentTranslation.upsert(contentId, key, CContent.ColumnType.Description, value, upParam.userId);
				} else {
					ContentTranslation.delete(contentId, key, CContent.ColumnType.Description);
				}
			});

			// もし、(期間限定OFFからONに変更
			//      || (期間限定 & (非公開中|公開中&期間変更あり))
			//		 & 同時ツイートON ＆ 前のツイートを削除 & 削除対象ツイートあり
			// だったら、ツイート削除→UPDATE tweet_id=NULL
			if ((
					(!limitedTimePublishPresent && upParam.isTimeLimited)
					|| (upParam.isTimeLimited && (openIdPresent==Common.OPEN_ID_HIDDEN || openIdPresent!=Common.OPEN_ID_HIDDEN && (!uploadDatePresent.equals(upParam.publishStart) || !endDatePresent.equals(upParam.publishEnd))))
				)
				&& (upParam.isTweet || upParam.isTweetWithImage)
				&& upParam.isDeleteTweet
				&& !tweetId.isEmpty()
				){
				CTweet cTweet = new CTweet();
				if(cTweet.GetResults(upParam.userId)){
					if(cTweet.Delete(tweetId)!=CTweet.OK){
						Log.d("Delete tweet failed.");
						// 処理自体は続行する
					}
					strSql = "UPDATE contents_0000 SET tweet_id=NULL WHERE content_id=?";
					statement = connection.prepareStatement(strSql);
					try {
						statement.setInt(1,  contentId);
						statement.executeUpdate();
					} catch(Exception e) {
						e.printStackTrace();
						return -600;
					}
					statement.close();statement=null;
				}
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			return -700;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return newContentId==null?upParam.contentId :newContentId;
	}
}

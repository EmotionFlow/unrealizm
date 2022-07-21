package jp.pipa.poipiku.controller.upcontents.v2;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.CTweet;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.NovelUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;

public final class UpdateTextC extends UpC {
	public int GetResults(UpdateTextCParam upParam, CheckLogin checkLogin) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		int idx = 0;
		int nPublishIdPresend = -1;
		String strTweetId = "";
		int nOpenIdPresent = 2;
		Timestamp tsUploadDatePresent = new Timestamp(0);
		Timestamp tsEndDatePresent = new Timestamp(0);
		boolean bLimitedTimePublishPresent = false;
		Integer nNewContentId = null;
		int nEditorId = Common.EDITOR_UPLOAD;
		String strTextTitle = "";
		String strTextBody = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			sql = "SELECT open_id, publish_id, tweet_id, limited_time_publish, upload_date, end_date, editor_id, text_body, title FROM contents_0000 WHERE user_id=? AND content_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, upParam.userId);
			statement.setInt(2, upParam.contentId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				nOpenIdPresent = resultSet.getInt("open_id");
				nPublishIdPresend = resultSet.getInt("publish_id");
				strTweetId = resultSet.getString("tweet_id");
				bLimitedTimePublishPresent = resultSet.getBoolean("limited_time_publish");
				tsUploadDatePresent = resultSet.getTimestamp("upload_date");
				tsEndDatePresent = resultSet.getTimestamp("end_date");
				nEditorId = Math.max(resultSet.getInt("editor_id"), Common.EDITOR_UPLOAD);
				strTextTitle = resultSet.getString("title");
				strTextBody = resultSet.getString("text_body");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch(Exception e) {
			e.printStackTrace();
			return -100;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
		}

		try {
			// create statement
			boolean bToPublish = false;
			int nOpenId = GetOpenId(
				nOpenIdPresent,
				upParam.publishId,
				!upParam.isShowRecently,
				upParam.isTimeLimited,
				bLimitedTimePublishPresent,
				upParam.publishStart,
				upParam.publishEnd,
				tsUploadDatePresent,
				tsEndDatePresent);
			String sqlUpdate =  "UPDATE contents_0000";
			ArrayList<String> lColumns = new ArrayList<>(Arrays.asList(						"genre_id=?", "category_id=?", "open_id=?",
					"description=?", "private_note=?",
					"tag_list=?", "publish_id=?",
					"password_enabled=?", "password=?",
					"list_id=?", "safe_filter=?", "cheer_ng=?",
					"tweet_when_published=?",
					"not_recently=?", "limited_time_publish=?",
					"title=?", "text_body=?", "novel_html=?",
					"novel_html_short=?", "novel_direction=?"
			));

			if (checkLogin.m_nPassportId == Common.PASSPORT_ON
					&& (!strTextBody.equals(upParam.textBody) || !strTextTitle.equals(upParam.title))
			) {
				lColumns.add("updated_at=now()");
			}

			if(!upParam.isTimeLimited){
				// これまで非公開で、今後公開したい。
				if(nOpenIdPresent==Common.OPEN_ID_HIDDEN && upParam.isPublish){
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

			sql = String.join(" ", Arrays.asList(sqlUpdate, sqlSet, sqlWhere));
			String textBody = Common.SubStrNum(upParam.textBody, Common.EDITOR_TEXT_MAX[upParam.editorId][checkLogin.m_nPassportId]);
			statement = connection.prepareStatement(sql);
			try {
				// set values
				idx = 1;
				statement.setInt(idx++, upParam.genre);
				statement.setInt(idx++, upParam.categoryId);
				statement.setInt(idx++, nOpenId);
				statement.setString(idx++, Common.SubStrNum(upParam.description, Common.EDITOR_DESC_MAX[nEditorId][checkLogin.m_nPassportId]));
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

				statement.setBoolean(idx++, upParam.isCheerNg);
				statement.setInt(idx++, CContent.getTweetWhenPublishedId(upParam.isTweet, upParam.isTweetWithImage, upParam.isTwitterCardThumbnail));
				statement.setBoolean(idx++, upParam.isShowRecently);

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
					sql = "INSERT INTO content_id_histories VALUES(?, nextval('contents_0000_content_id_seq'::regclass)) RETURNING new_id";
					statement = connection.prepareStatement(sql);
					statement.setInt(1, upParam.contentId);
					resultSet = statement.executeQuery();
					if(resultSet.next()) {
						nNewContentId = resultSet.getInt("new_id");
					} else {
						throw new Exception("new content id is null.");
					}
				}catch(Exception e){
					Log.d(sql);
					e.printStackTrace();
					return -300;
				}finally{
					if(resultSet!=null){resultSet.close();};resultSet=null;
					if(statement!=null){statement.close();};statement=null;
				}

				if(nNewContentId!=null){
					boolean bUpdateFaild = false;
					try{
						// transaction
						connection.setAutoCommit(false);
						String[] lUpdateTable = {"contents_0000", "bookmarks_0000", "comments_0000", "comments_desc_cache", "contents_appends_0000", "rank_contents_total", "tags_0000", "requests", "pins", "content_translations"};
						for(String t : lUpdateTable){
							sql = "UPDATE " + t + " SET content_id=? WHERE content_id=?";
							statement = connection.prepareStatement(sql);
							statement.setInt(1, nNewContentId);
							statement.setInt(2, upParam.contentId);
							statement.executeUpdate();
						}
						connection.commit();
					}catch(Exception e){
						bUpdateFaild = true;
						Log.d(sql);
						e.printStackTrace();
						connection.rollback();
					}finally{
						if(statement!=null){statement.close();};statement=null;
						connection.setAutoCommit(true);
					}
					if(bUpdateFaild){
						try{
							nNewContentId=null;
							sql = "DELETE FROM content_id_histories WHERE old_id=?";
							statement = connection.prepareStatement(sql);
							statement.setInt(1, upParam.contentId);
							statement.executeUpdate();
						}catch(Exception e){
							Log.d(sql);
							e.printStackTrace();
						}finally{
							if(statement!=null){statement.close();};statement=null;
						}
						return -400;
					}
				}
			}

			// Delete old tags
			if (!upParam.description.isEmpty() || !upParam.tagList.isEmpty()) {
				sql = "DELETE FROM tags_0000 WHERE content_id=?;";
				statement = connection.prepareStatement(sql);
				try {
					statement.setInt(1, nNewContentId==null?upParam.contentId :nNewContentId);
					statement.executeUpdate();
				} catch(Exception e) {
					e.printStackTrace();
					return -500;
				}
				statement.close();statement=null;
			}

			// Add tags
			AddTags(upParam.description, upParam.tagList, nNewContentId==null?upParam.contentId :nNewContentId, connection);

			// もし、(期間限定OFFからONに変更 || (期間限定 & (非公開中|公開中&期間変更あり))
			//		 & 同時ツイートON ＆ 前のツイートを削除 & 削除対象ツイートあり
			// だったら、ツイート削除→UPDATE tweet_id=NULL
			if ((
					(!bLimitedTimePublishPresent && upParam.isTimeLimited)
					|| (upParam.isTimeLimited && (nOpenIdPresent==2 || nOpenIdPresent!=2 && (!tsUploadDatePresent.equals(upParam.publishStart) || !tsEndDatePresent.equals(upParam.publishEnd))))
				)
				&& (upParam.isTweet || upParam.isTweetWithImage)
				&& upParam.isDeleteTweet
				&& !strTweetId.isEmpty()
				){
				CTweet cTweet = new CTweet();
				if(cTweet.GetResults(upParam.userId)){
					if(cTweet.Delete(strTweetId)!=CTweet.OK){
						Log.d("Delete tweet failed.");
						// 処理自体は続行する
					}
					sql = "UPDATE contents_0000 SET tweet_id=NULL WHERE content_id=?";
					statement = connection.prepareStatement(sql);
					try {
						statement.setInt(1,  nNewContentId==null?upParam.contentId :nNewContentId);
						statement.executeUpdate();
					} catch(Exception e) {
						e.printStackTrace();
						return -600;
					}
					statement.close();statement=null;
				}
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return -700;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return  nNewContentId==null?upParam.contentId :nNewContentId;
	}
}

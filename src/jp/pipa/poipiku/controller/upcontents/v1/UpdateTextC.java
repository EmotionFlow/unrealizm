package jp.pipa.poipiku.controller.upcontents.v1;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;

import jp.pipa.poipiku.util.*;
import jp.pipa.poipiku.*;

public final class UpdateTextC extends UpC {
	public int GetResults(UpdateTextCParam cParam, CheckLogin checkLogin) {
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
			statement.setInt(1, cParam.m_nUserId);
			statement.setInt(2, cParam.m_nContentId);
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
				cParam.m_nPublishId,
				cParam.m_bNotRecently,
				cParam.m_bLimitedTimePublish,
				bLimitedTimePublishPresent,
				cParam.m_tsPublishStart,
				cParam.m_tsPublishEnd,
				tsUploadDatePresent,
				tsEndDatePresent);
			String sqlUpdate =  "UPDATE contents_0000";
			ArrayList<String> lColumns = new ArrayList<>();
				lColumns.addAll(Arrays.asList(
					"genre_id=?", "category_id=?", "open_id=?", "description=?", "private_note=?",
					"text_body=?", "tag_list=?", "publish_id=?", "password_enabled=?", "password=?",
					"list_id=?", "safe_filter=?", "cheer_ng=?", "tweet_when_published=?",
					"not_recently=?", "limited_time_publish=?", "title=?", "novel_html=?",
					"novel_html_short=?", "novel_direction=?"
					));

			if (checkLogin.m_nPassportId == Common.PASSPORT_ON
					&& (!strTextBody.equals(cParam.m_strTextBody) || !strTextTitle.equals(cParam.title))
			) {
				lColumns.add("updated_at=now()");
			}

			if(!cParam.m_bLimitedTimePublish){
				// これまで非公開で、今後公開したい。
				if(nPublishIdPresend==Common.PUBLISH_ID_HIDDEN && cParam.m_nPublishId!=Common.PUBLISH_ID_HIDDEN){
					bToPublish = true;
					lColumns.add("upload_date=current_timestamp");
				}
			} else {
				// 期間限定
				if(cParam.m_tsPublishStart == null && cParam.m_tsPublishEnd == null){
					throw new Exception("m_nPublishId is 'limited time', but start and end is null.");
				} else {
					if(cParam.m_tsPublishStart != null ){
						lColumns.add("upload_date=?");
					}
					if(cParam.m_tsPublishEnd != null ){
						lColumns.add("end_date=?");
					}
				}
			}

			String sqlSet = "SET " + String.join(",", lColumns);
			String sqlWhere = "WHERE user_id=? AND content_id=?";

			sql = String.join(" ", Arrays.asList(sqlUpdate, sqlSet, sqlWhere));
			String textBody = Common.SubStrNum(cParam.m_strTextBody, Common.EDITOR_TEXT_MAX[cParam.m_nEditorId][checkLogin.m_nPassportId]);
			statement = connection.prepareStatement(sql);
			try {
				idx = 1;
				// set values
				statement.setInt(idx++, cParam.genre);
				statement.setInt(idx++, cParam.m_nCategoryId);
				statement.setInt(idx++, nOpenId);
				statement.setString(idx++, Common.SubStrNum(cParam.m_strDescription, Common.EDITOR_DESC_MAX[nEditorId][checkLogin.m_nPassportId]));
				statement.setString(idx++, cParam.privateNote);
				statement.setString(idx++, textBody);
				statement.setString(idx++, cParam.m_strTagList);
				statement.setInt(idx++, cParam.m_nPublishId);
				statement.setBoolean(idx++, cParam.m_nPublishId == Common.PUBLISH_ID_PASS);
				statement.setString(idx++, cParam.m_strPassword);
				statement.setString(idx++, cParam.m_strListId);
				statement.setInt(idx++, CContent.getSafeFilterDB(cParam.m_nPublishId));
				statement.setBoolean(idx++, cParam.m_bCheerNg);
				statement.setInt(idx++, CContent.getTweetWhenPublishedId(cParam.m_bTweetTxt, cParam.m_bTweetImg, cParam.m_bTwitterCardThumbnail));
				statement.setBoolean(idx++, cParam.m_bNotRecently);
				statement.setBoolean(idx++, cParam.m_bLimitedTimePublish);
				statement.setString(idx++, cParam.title);
				statement.setString(idx++, NovelUtil.genarateHtml(cParam.title, textBody, ""));
				statement.setString(idx++, NovelUtil.genarateHtmlShort(cParam.title, textBody, ""));
				statement.setInt(idx++, cParam.novelDirection);

				if(cParam.m_bLimitedTimePublish){
					if(cParam.m_tsPublishStart != null ){
						statement.setTimestamp(idx++, cParam.m_tsPublishStart);
					}
					if(cParam.m_tsPublishEnd != null ){
						statement.setTimestamp(idx++, cParam.m_tsPublishEnd);
					}
				}

				// set where params
				statement.setInt(idx++, cParam.m_nUserId);
				statement.setInt(idx++, cParam.m_nContentId);

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
					statement.setInt(1, cParam.m_nContentId);
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
							statement.setInt(2, cParam.m_nContentId);
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
							statement.setInt(1, cParam.m_nContentId);
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
			if (!cParam.m_strDescription.isEmpty() || !cParam.m_strTagList.isEmpty()) {
				sql = "DELETE FROM tags_0000 WHERE content_id=?;";
				statement = connection.prepareStatement(sql);
				try {
					statement.setInt(1, nNewContentId==null?cParam.m_nContentId:nNewContentId);
					statement.executeUpdate();
				} catch(Exception e) {
					e.printStackTrace();
					return -500;
				}
				statement.close();statement=null;
			}

			// Add tags
			AddTags(cParam.m_strDescription, cParam.m_strTagList, nNewContentId==null?cParam.m_nContentId:nNewContentId, connection);

			// もし、(期間限定OFFからONに変更 || (期間限定 & (非公開中|公開中&期間変更あり))
			//		 & 同時ツイートON ＆ 前のツイートを削除 & 削除対象ツイートあり
			// だったら、ツイート削除→UPDATE tweet_id=NULL
			if ((
					(!bLimitedTimePublishPresent && cParam.m_bLimitedTimePublish)
					|| (cParam.m_bLimitedTimePublish && (nOpenIdPresent==2 || nOpenIdPresent!=2 && (!tsUploadDatePresent.equals(cParam.m_tsPublishStart) || !tsEndDatePresent.equals(cParam.m_tsPublishEnd))))
				)
				&& (cParam.m_bTweetTxt || cParam.m_bTweetImg)
				&& cParam.m_bDeleteTweet
				&& !strTweetId.isEmpty()
				){
				CTweet cTweet = new CTweet();
				if(cTweet.GetResults(cParam.m_nUserId)){
					if(cTweet.Delete(strTweetId)!=CTweet.OK){
						Log.d("Delete tweet failed.");
						// 処理自体は続行する
					}
					sql = "UPDATE contents_0000 SET tweet_id=NULL WHERE content_id=?";
					statement = connection.prepareStatement(sql);
					try {
						statement.setInt(1,  nNewContentId==null?cParam.m_nContentId:nNewContentId);
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
		return  nNewContentId==null?cParam.m_nContentId:nNewContentId;
	}
}
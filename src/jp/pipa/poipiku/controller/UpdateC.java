package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.TimeZone;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import jp.pipa.poipiku.util.*;
import jp.pipa.poipiku.*;

public class UpdateC extends UpC {
	public int GetResults(UpdateCParam cParam) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int safe_filter = Common.SAFE_FILTER_ALL;
		int idx = 0;
		int nPublishIdPresend = -1;
		String strTweetId = "";
		int nOpenIdPresent = 2;
		Timestamp tsUploadDatePresent = new Timestamp(0);
		Timestamp tsEndDatePresent = new Timestamp(0);
		boolean bLimitedTimePublishPresent = false;
		Integer nNewContentId = null;

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "SELECT open_id, publish_id, tweet_id, limited_time_publish, upload_date, end_date FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				nOpenIdPresent = cResSet.getInt("open_id");
				nPublishIdPresend = cResSet.getInt("publish_id");
				strTweetId = cResSet.getString("tweet_id");
				bLimitedTimePublishPresent = cResSet.getBoolean("limited_time_publish");
				tsUploadDatePresent = cResSet.getTimestamp("upload_date");
				tsEndDatePresent = cResSet.getTimestamp("end_date");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
		} catch(Exception e) {
			e.printStackTrace();
			return -100;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
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
			ArrayList<String> lColumns = new ArrayList<String>();
				lColumns.addAll(Arrays.asList(
					"category_id=?", "open_id=?", "description=?", "tag_list=?", "publish_id=?",
					"password=?", "list_id=?", "safe_filter=?", "tweet_when_published=?",
					"not_recently=?", "limited_time_publish=?"
					));

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

			strSql = String.join(" ", Arrays.asList(sqlUpdate, sqlSet, sqlWhere));
			cState = cConn.prepareStatement(strSql);
			try {
				idx = 1;
				// set values
				cState.setInt(idx++, cParam.m_nCategoryId);
				cState.setInt(idx++, nOpenId);
				cState.setString(idx++, Common.SubStrNum(cParam.m_strDescription, 200));
				cState.setString(idx++, cParam.m_strTagList);
				cState.setInt(idx++, cParam.m_nPublishId);
				cState.setString(idx++, cParam.m_strPassword);
				cState.setString(idx++, cParam.m_strListId);
				cState.setInt(idx++, GetSafeFilterDB(cParam.m_nPublishId));
				cState.setInt(idx++, GetTweetParamDB(cParam.m_bTweetTxt, cParam.m_bTweetImg));
				cState.setBoolean(idx++, cParam.m_bNotRecently);
				cState.setBoolean(idx++, cParam.m_bLimitedTimePublish);

				if(cParam.m_bLimitedTimePublish){
					if(cParam.m_tsPublishStart != null ){
						cState.setTimestamp(idx++, cParam.m_tsPublishStart);
					}
					if(cParam.m_tsPublishEnd != null ){
						cState.setTimestamp(idx++, cParam.m_tsPublishEnd);
					}
				}

				// set where params
				cState.setInt(idx++, cParam.m_nUserId);
				cState.setInt(idx++, cParam.m_nContentId);

				cState.executeUpdate();
			} catch(Exception e) {
				e.printStackTrace();
				return -200;
			}
			cState.close();cState=null;

			// content_idを振り直す
			// 処理更新時は、 https://github.com/gochipon/poipiku_script にもその内容を反映させること。
			if(bToPublish){
				try{
					strSql = "INSERT INTO content_id_histories VALUES(?, nextval('contents_0000_content_id_seq'::regclass)) RETURNING new_id";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, cParam.m_nContentId);
					cResSet = cState.executeQuery();
					if(cResSet.next()) {
						nNewContentId = cResSet.getInt("new_id");
					} else {
						throw new Exception("new content id is null.");
					}
				}catch(Exception e){
					Log.d(e.getMessage());
					e.printStackTrace();
					return -300;
				}finally{
					cResSet.close();cResSet=null;
					cState.close();cState=null;
				}

				if(nNewContentId!=null){
					boolean bUpdateFaild = false;
					try{
						// transaction
						cConn.setAutoCommit(false);
						String[] lUpdateTable = {"contents_0000", "bookmarks_0000", "comments_0000", "contents_appends_0000", "rank_contents_total", "tags_0000"};
						for(String t : lUpdateTable){
							strSql = "UPDATE " + t + " SET content_id=? WHERE content_id=?";
							cState = cConn.prepareStatement(strSql);
							cState.setInt(1, nNewContentId);
							cState.setInt(2, cParam.m_nContentId);
							cState.executeUpdate();
						}
						cConn.commit();
					}catch(Exception e){
						bUpdateFaild = true;
						Log.d(e.getMessage());
						e.printStackTrace();
						cConn.rollback();
					}finally{
						cState.close();cState=null;
						cConn.setAutoCommit(true);
					}
					if(bUpdateFaild){
						try{
							nNewContentId=null;
							strSql = "DELETE FROM content_id_histories WEHRE old_id=?";
							cState = cConn.prepareStatement(strSql);
							cState.setInt(1, cParam.m_nContentId);
							cState.executeUpdate();
						}catch(Exception e){
							Log.d(e.getMessage());
							e.printStackTrace();
							cConn.rollback();
						}finally{
							cState.close();cState=null;
							cConn.setAutoCommit(true);
						}
						return -400;
					}
				}
			}

			// Delete old tags
			if (!cParam.m_strDescription.isEmpty() || !cParam.m_strTagList.isEmpty()) {
				strSql = "DELETE FROM tags_0000 WHERE content_id=?;";
				cState = cConn.prepareStatement(strSql);
				try {
					cState.setInt(1, nNewContentId==null?cParam.m_nContentId:nNewContentId);
					cState.executeUpdate();
				} catch(Exception e) {
					e.printStackTrace();
					return -500;
				}
				cState.close();cState=null;
			}

			// Add tags
			AddTags(cParam.m_strDescription, cParam.m_strTagList, nNewContentId==null?cParam.m_nContentId:nNewContentId, cConn, cState);

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
					strSql = "UPDATE contents_0000 SET tweet_id=NULL WHERE content_id=?";
					cState = cConn.prepareStatement(strSql);
					try {
						cState.setInt(1,  nNewContentId==null?cParam.m_nContentId:nNewContentId);
						cState.executeUpdate();
					} catch(Exception e) {
						e.printStackTrace();
						return -600;
					}
					cState.close();cState=null;
				}
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			return -700;
		} finally {
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return  nNewContentId==null?cParam.m_nContentId:nNewContentId;
	}
}

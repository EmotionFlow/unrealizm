package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "SELECT publish_id, tweet_id FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				nPublishIdPresend = cResSet.getInt("publish_id");
				strTweetId = cResSet.getString("tweet_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
		}

		try {
			// create statement
			int nOpenId = GetOpenId(
				cParam.m_nPublishId,
				cParam.m_bNotRecently,
				cParam.m_bLimitedTimePublish,
				cParam.m_tsPublishStart,
				cParam.m_tsPublishEnd);
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
			}
			cState.close();cState=null;

			// Delete old tags
			if (!cParam.m_strDescription.isEmpty() || !cParam.m_strTagList.isEmpty()) {
				strSql = "DELETE FROM tags_0000 WHERE content_id=?;";
				cState = cConn.prepareStatement(strSql);
				try {
					cState.setInt(1, cParam.m_nContentId);
					cState.executeUpdate();
				} catch(Exception e) {
					e.printStackTrace();
				}
				cState.close();cState=null;
			}

			// Add tags
			AddTags(cParam.m_strDescription, cParam.m_strTagList, cParam.m_nContentId, cConn, cState);

			// もし、期間限定&開始日時変更＆同時ツイートON＆前のツイートを削除だったら、ツイート削除→ツイート→UPDATE tweet_id=NULL
			Log.d(String.format("%b, %b, %b, %b, %s", cParam.m_bLimitedTimePublish, cParam.m_bTweetTxt, cParam.m_bTweetImg, cParam.m_bDeleteTweet, strTweetId));
			if ( cParam.m_bLimitedTimePublish && (cParam.m_bTweetTxt || cParam.m_bTweetImg) && cParam.m_bDeleteTweet && !strTweetId.isEmpty()){
				Log.d("delete tweet " + strTweetId);
				CTweet cTweet = new CTweet();
				if(cTweet.GetResults(cParam.m_nUserId)){
					cTweet.Delete(strTweetId);
					strSql = "UPDATE contents_0000 SET tweet_id=NULL WHERE content_id=?";
					cState = cConn.prepareStatement(strSql);
					try {
						cState.setInt(1, cParam.m_nContentId);
						Log.d("executeUpdate");
						cState.executeUpdate();
					} catch(Exception e) {
						e.printStackTrace();
					}
					cState.close();cState=null;
				}
			}


		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return cParam.m_nContentId;
	}
}

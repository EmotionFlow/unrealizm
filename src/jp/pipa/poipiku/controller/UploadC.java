package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import jp.pipa.poipiku.util.*;
import jp.pipa.poipiku.*;

public class UploadC extends UpC {
	protected int m_nContentId = -99;
	public int deliverRequestResult = 0;
	public int GetResults(UploadCParam cParam, CheckLogin checkLogin) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 0;

		Request poipikuRequest = null;
		if (cParam.requestId > 0) {
			poipikuRequest = new Request(cParam.requestId);
			if (poipikuRequest.creatorUserId != checkLogin.m_nUserId) {
				deliverRequestResult = -98;
				Log.d(String.format("クリエイターではないユーザーによる不正アクセス %d, %d, %d", poipikuRequest.id, poipikuRequest.creatorUserId, checkLogin.m_nUserId));
				return m_nContentId;
			}
		}

		try {
			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// get content id
			ArrayList<String> lColumns = new ArrayList<>(
					Arrays.asList(
							"user_id", "genre_id", "category_id", "description",
							"tag_list", "publish_id", "password", "list_id", "safe_filter",
							"editor_id", "cheer_ng", "tweet_when_published", "limited_time_publish"));

			if(cParam.m_bLimitedTimePublish){
				if(cParam.m_tsPublishStart == null && cParam.m_tsPublishEnd == null){throw new Exception("m_nPublishId is 'limited time', but start and end is null.");};
				if(cParam.m_tsPublishStart != null || cParam.m_tsPublishEnd != null){
					if(cParam.m_tsPublishStart != null ){
						lColumns.add("upload_date");
					}
					if(cParam.m_tsPublishEnd != null ){
						lColumns.add("end_date");
					}
				}
			}

			ArrayList<String> lVals = new ArrayList<>();
			lColumns.forEach(c -> lVals.add("?"));
			strSql = String.format("INSERT INTO contents_0000(%s) VALUES(%s) RETURNING content_id", String.join(",", lColumns), String.join(",", lVals));

			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, cParam.m_nUserId);
			cState.setInt(idx++, cParam.genre);
			cState.setInt(idx++, cParam.m_nCategoryId);
			cState.setString(idx++, Common.SubStrNum(cParam.m_strDescription, Common.EDITOR_DESC_MAX[cParam.m_nEditorId][checkLogin.m_nPassportId]));
			cState.setString(idx++, cParam.m_strTagList);
			cState.setInt(idx++, cParam.m_nPublishId);
			cState.setString(idx++, cParam.m_strPassword);
			cState.setString(idx++, cParam.m_strListId);
			cState.setInt(idx++, GetSafeFilterDB(cParam.m_nPublishId));
			cState.setInt(idx++, cParam.m_nEditorId);
			cState.setBoolean(idx++, cParam.m_bCheerNg);
			cState.setInt(idx++, GetTweetParamDB(cParam.m_bTweetTxt, cParam.m_bTweetImg));
			cState.setBoolean(idx++, cParam.m_bLimitedTimePublish);

			if(cParam.m_bLimitedTimePublish){
				if(cParam.m_tsPublishStart != null){
					cState.setTimestamp(idx++, cParam.m_tsPublishStart);
				}
				if(cParam.m_tsPublishEnd != null ){
					cState.setTimestamp(idx++, cParam.m_tsPublishEnd);
				}
			}

			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_nContentId = cResSet.getInt("content_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			AddTags(cParam.m_strDescription, cParam.m_strTagList, m_nContentId, cConn);

			if (poipikuRequest != null) {
				deliverRequestResult = poipikuRequest.deliver(m_nContentId);
				Log.d(String.format("ID %d deliver(%d) responce: %d", poipikuRequest.id, m_nContentId, deliverRequestResult));
			} else {
				deliverRequestResult = 0;
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return m_nContentId;
	}
}

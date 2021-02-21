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

public class UploadTextC extends UpC {
	protected int m_nContentId = -99;
	public int GetResults(UploadTextCParam cParam, CheckLogin checkLogin) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 0;

		try {
			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// get content id
			ArrayList<String> lColumns = new ArrayList<String>();
			lColumns.addAll(Arrays.asList("user_id", "genre_id", "category_id", "description", "text_body", "tag_list", "publish_id", "password", "list_id", "safe_filter", "editor_id", "cheer_ng", "open_id", "tweet_when_published", "limited_time_publish"));

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

			// open_id更新
			int nOpenId = GetOpenId(
				-1,
				cParam.m_nPublishId,
				cParam.m_bNotRecently,
				cParam.m_bLimitedTimePublish,
				cParam.m_bLimitedTimePublish,
				cParam.m_tsPublishStart,
				cParam.m_tsPublishEnd,
				null,null);


			ArrayList<String> lVals = new ArrayList<String>();
			lColumns.forEach(c -> lVals.add("?"));
			strSql = String.format("INSERT INTO contents_0000(%s) VALUES(%s) RETURNING content_id", String.join(",", lColumns), String.join(",", lVals));

			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, cParam.m_nUserId);
			cState.setInt(idx++, cParam.genre);
			cState.setInt(idx++, cParam.m_nCategoryId);
			cState.setString(idx++, Common.SubStrNum(cParam.m_strDescription, Common.EDITOR_DESC_MAX[cParam.m_nEditorId][checkLogin.m_nPassportId]));
			cState.setString(idx++, Common.SubStrNum(cParam.m_strTextBody, Common.EDITOR_TEXT_MAX[cParam.m_nEditorId][checkLogin.m_nPassportId]));
			cState.setString(idx++, cParam.m_strTagList);
			cState.setInt(idx++, cParam.m_nPublishId);
			cState.setString(idx++, cParam.m_strPassword);
			cState.setString(idx++, cParam.m_strListId);
			cState.setInt(idx++, GetSafeFilterDB(cParam.m_nPublishId));
			cState.setInt(idx++, cParam.m_nEditorId);
			cState.setBoolean(idx++, cParam.m_bCheerNg);
			cState.setInt(idx++, nOpenId);
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

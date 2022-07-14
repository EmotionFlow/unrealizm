package jp.pipa.poipiku.controller.upcontents.v1;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Arrays;

import jp.pipa.poipiku.controller.Controller;
import jp.pipa.poipiku.controller.DeliverRequestC;
import jp.pipa.poipiku.util.*;
import jp.pipa.poipiku.*;

public final class UploadC extends UpC {
	private int m_nContentId = -99;
	public boolean deliverRequestResult;
	public int GetResults(UploadCParam cParam, CheckLogin checkLogin) {
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 0;

		DeliverRequestC deliverRequestC = null;
		if (cParam.requestId > 0) {
			deliverRequestC = new DeliverRequestC(checkLogin, cParam.requestId);
			if (deliverRequestC.errorKind != Controller.ErrorKind.None) {
				return m_nContentId;
			}
		}

		try {
			// regist to DB
			cConn = DatabaseUtil.dataSource.getConnection();

			// get content id
			ArrayList<String> lColumns = new ArrayList<>(
					Arrays.asList(
							"user_id", "genre_id", "category_id", "description", "private_note",
							"tag_list", "publish_id", "publish_all_num", "password_enabled", "password", "list_id", "safe_filter",
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
			strSql = String.format(
					"INSERT INTO contents_0000(%s, created_at, updated_at) VALUES(%s, %s) RETURNING content_id",
					String.join(",", lColumns),
					String.join(",", lVals),
					checkLogin.m_nPassportId==Common.PASSPORT_OFF ? "null, null" : "now(), now()"
			);

			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, cParam.m_nUserId);
			cState.setInt(idx++, cParam.genre);
			cState.setInt(idx++, cParam.m_nCategoryId);
			cState.setString(idx++, Common.SubStrNum(cParam.m_strDescription, Common.EDITOR_DESC_MAX[cParam.m_nEditorId][checkLogin.m_nPassportId]));
			cState.setString(idx++, cParam.privateNote);
			cState.setString(idx++, cParam.m_strTagList);
			cState.setInt(idx++, cParam.m_nPublishId);
			if (cParam.m_nPublishAllNum <= 0) {
				cState.setNull(idx++, Types.INTEGER);
			} else {
				cState.setInt(idx++, cParam.m_nPublishAllNum);
			}
			cState.setBoolean(idx++, cParam.m_nPublishId == Common.PUBLISH_ID_PASS);
			cState.setString(idx++, cParam.m_strPassword);
			cState.setString(idx++, cParam.m_strListId);
			cState.setInt(idx++, CContent.getSafeFilterDB(cParam.m_nPublishId));
			cState.setInt(idx++, cParam.m_nEditorId);
			cState.setBoolean(idx++, cParam.m_bCheerNg);
			cState.setInt(idx++, CContent.getTweetWhenPublishedId(cParam.m_bTweetTxt, cParam.m_bTweetImg, cParam.m_bTwitterCardThumbnail));
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

			cParam.descriptionTranslations.forEach((key, value) -> {
				if (!value.isEmpty()) {
					ContentTranslation.upsert(m_nContentId, key, CContent.ColumnType.Description, value, cParam.m_nUserId);
				}
			});

			if (deliverRequestC != null) {
				deliverRequestResult = deliverRequestC.getResults(m_nContentId);
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

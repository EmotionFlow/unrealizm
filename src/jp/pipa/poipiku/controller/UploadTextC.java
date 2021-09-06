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

public final class UploadTextC extends UpC {
	protected int m_nContentId = -99;
	public boolean deliverRequestResult;
	public int GetResults(UploadTextCParam cParam, CheckLogin checkLogin) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
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
			connection = DatabaseUtil.dataSource.getConnection();

			// get content id
			ArrayList<String> lColumns = new ArrayList<>(
					Arrays.asList(
							"user_id", "genre_id", "category_id", "description",
							"text_body", "tag_list", "publish_id", "password",
							"list_id", "safe_filter", "editor_id", "cheer_ng",
							"open_id", "tweet_when_published", "limited_time_publish",
							"title", "novel_html", "novel_html_short", "novel_direction"));

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


			String textBody = Common.SubStrNum(cParam.m_strTextBody, Common.EDITOR_TEXT_MAX[cParam.m_nEditorId][checkLogin.m_nPassportId]);
			ArrayList<String> lVals = new ArrayList<>();
			lColumns.forEach(c -> lVals.add("?"));
			sql = String.format("INSERT INTO contents_0000(%s, updated_at) VALUES(%s, now()) RETURNING content_id", String.join(",", lColumns), String.join(",", lVals));

			statement = connection.prepareStatement(sql);
			idx = 1;
			statement.setInt(idx++, cParam.m_nUserId);
			statement.setInt(idx++, cParam.genre);
			statement.setInt(idx++, cParam.m_nCategoryId);
			statement.setString(idx++, Common.SubStrNum(cParam.m_strDescription, Common.EDITOR_DESC_MAX[cParam.m_nEditorId][checkLogin.m_nPassportId]));
			statement.setString(idx++, textBody);
			statement.setString(idx++, cParam.m_strTagList);
			statement.setInt(idx++, cParam.m_nPublishId);
			statement.setString(idx++, cParam.m_strPassword);
			statement.setString(idx++, cParam.m_strListId);
			statement.setInt(idx++, CContent.getSafeFilterDB(cParam.m_nPublishId));
			statement.setInt(idx++, cParam.m_nEditorId);
			statement.setBoolean(idx++, cParam.m_bCheerNg);
			statement.setInt(idx++, nOpenId);
			statement.setInt(idx++, CContent.getTweetWhenPublishedId(cParam.m_bTweetTxt, cParam.m_bTweetImg, cParam.m_bTwitterCardThumbnail));
			statement.setBoolean(idx++, cParam.m_bLimitedTimePublish);
			statement.setString(idx++, cParam.title);
			statement.setString(idx++, NovelUtil.genarateHtml(cParam.title, textBody, ""));
			statement.setString(idx++, NovelUtil.genarateHtmlShort(cParam.title, textBody, ""));
			statement.setInt(idx++, cParam.novelDirection);

			if(cParam.m_bLimitedTimePublish){
				if(cParam.m_tsPublishStart != null){
					statement.setTimestamp(idx++, cParam.m_tsPublishStart);
				}
				if(cParam.m_tsPublishEnd != null ){
					statement.setTimestamp(idx++, cParam.m_tsPublishEnd);
				}
			}

			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				m_nContentId = resultSet.getInt("content_id");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			AddTags(cParam.m_strDescription, cParam.m_strTagList, m_nContentId, connection);

			if (deliverRequestC != null) {
				deliverRequestResult = deliverRequestC.getResults(m_nContentId);
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return m_nContentId;
	}
}

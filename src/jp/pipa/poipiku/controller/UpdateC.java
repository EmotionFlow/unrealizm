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

public class UpdateC extends UpC {
	public int GetResults(UpdateParamC cParam) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int safe_filter = Common.SAFE_FILTER_ALL;
		int idx = 0;
		int nPublishIdPresend = -1;

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "SELECT publish_id FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				nPublishIdPresend = cResSet.getInt("publish_id");
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
			int nOpenId = cParam.m_nOpenId;
			String sqlUpdate =  "UPDATE contents_0000";
			ArrayList<String> lColumns = new ArrayList<String>();
				lColumns.addAll(Arrays.asList("category_id=?", "open_id=?", "description=?", "tag_list=?", "publish_id=?", "password=?", "list_id=?", "safe_filter=?", "tweet_when_published=?"));

			if(cParam.m_nPublishId != Common.PUBLISH_ID_LIMITED_TIME){
				if(nPublishIdPresend==Common.PUBLISH_ID_HIDDEN && cParam.m_nPublishId!=Common.PUBLISH_ID_HIDDEN){
					lColumns.add("upload_date=current_timestamp");
				}
			} else {
				if(cParam.m_tsPublishStart == null && cParam.m_tsPublishEnd == null){throw new Exception("m_nPublishId is 'limited time', but start and end is null.");};
				if(cParam.m_tsPublishStart != null || cParam.m_tsPublishEnd != null){
					if(cParam.m_tsPublishStart != null ){
						lColumns.add("upload_date=?");
						nOpenId = GetOpenIdDB(cParam.m_tsPublishStart);
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

				if(cParam.m_nPublishId == Common.PUBLISH_ID_LIMITED_TIME){
					cState.setTimestamp(idx++, cParam.m_tsPublishStart);
					cState.setTimestamp(idx++, cParam.m_tsPublishEnd);
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

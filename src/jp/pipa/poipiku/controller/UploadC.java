package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import jp.pipa.poipiku.util.*;
import jp.pipa.poipiku.*;

public class UploadC extends UpC {
    protected int m_nContentId = -99;
	public int GetResults(UploadParamC cParam) {
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
			lColumns.addAll(Arrays.asList("user_id", "category_id", "description", "tag_list", "publish_id", "password", "list_id", "safe_filter", "editor_id", "tweet_when_published"));

			if(cParam.m_nPublishId == Common.PUBLISH_ID_LIMITED_TIME){
				if(cParam.m_tsPublishStart == null && cParam.m_tsPublishEnd == null){throw new Exception("m_nPublishId is 'limited time', but start and end is null.");};

				Timestamp tsNow = new Timestamp(System.currentTimeMillis());
				if(cParam.m_tsPublishStart != null || cParam.m_tsPublishEnd != null){
					lColumns.add("open_id");
					if(cParam.m_tsPublishStart != null ){
						lColumns.add("upload_date");
						if(cParam.m_tsPublishStart.before(tsNow)){
							cParam.m_nOpenId = 0;
						} else {
							cParam.m_nOpenId = 3;
						}
					}
					Log.d(String.format("openid: %d", cParam.m_nOpenId));
					if(cParam.m_tsPublishEnd != null ){
						lColumns.add("end_date");
					}
				}
			}

			ArrayList<String> lVals = new ArrayList<String>();
			lColumns.forEach(c -> lVals.add("?"));
			strSql = String.format("INSERT INTO contents_0000(%s) VALUES(%s) RETURNING content_id", String.join(",", lColumns), String.join(",", lVals));

			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, cParam.m_nUserId);
			cState.setInt(idx++, cParam.m_nCategoryId);
			cState.setString(idx++, Common.SubStrNum(cParam.m_strDescription, 200));
			cState.setString(idx++, cParam.m_strTagList);
			cState.setInt(idx++, cParam.m_nPublishId);
			cState.setString(idx++, cParam.m_strPassword);
			cState.setString(idx++, cParam.m_strListId);
			cState.setInt(idx++, GetSafeFilterDB(cParam.m_nPublishId));
			cState.setInt(idx++, cParam.m_nEditorId);
			cState.setInt(idx++, GetTweetParamDB(cParam.m_bTweetTxt, cParam.m_bTweetImg));

			if(cParam.m_tsPublishStart != null || cParam.m_tsPublishEnd != null){
				cState.setInt(idx++, cParam.m_nOpenId);
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

			// Add tags
			// from description
			if (!cParam.m_strDescription.isEmpty()) {
                // hush tag
                InsertIntoTags(cParam.m_strDescription, Common.HUSH_TAG_PATTERN, 1, cConn, cState);
                // my tag
                InsertIntoTags(cParam.m_strDescription, Common.MY_TAG_PATTERN, 3, cConn, cState);
			}
			// from tag list
			if (!cParam.m_strTagList.isEmpty()) {
                // normal tag
                InsertIntoTags(cParam.m_strTagList, Common.NORMAL_TAG_PATTERN, 1, cConn, cState);
				// hush tag
                InsertIntoTags(cParam.m_strTagList, Common.HUSH_TAG_PATTERN, 1, cConn, cState);
				// my tag
                InsertIntoTags(cParam.m_strTagList, Common.MY_TAG_PATTERN, 3, cConn, cState);
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

    protected void InsertIntoTags(String tag_list, String match_pattern, int tag_type, Connection cConn, PreparedStatement cState) throws SQLException{
        Pattern ptn = Pattern.compile(match_pattern, Pattern.MULTILINE);
        Matcher matcher = ptn.matcher(" "+tag_list.replaceAll("　", " ")+"\n");
        String strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type) VALUES(?, ?, ?) ON CONFLICT DO NOTHING;";
        cState = cConn.prepareStatement(strSql);
        for (int nNum=0; matcher.find() && nNum<20; nNum++) {
            try {
                cState.setString(1,Common.SubStrNum(matcher.group(1), 64));
                cState.setInt(2, m_nContentId);
                cState.setInt(3, tag_type);
                cState.executeUpdate();
            } catch(Exception e) {
                Log.d("tag duplicate:"+matcher.group(1));
            }
        }
        cState.close();cState=null;
    }
}

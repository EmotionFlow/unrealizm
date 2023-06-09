package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import javax.servlet.ServletContext;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class UploadFileTweetC {
	private ServletContext m_cServletContext = null;

	public UploadFileTweetC(ServletContext cServletContext){
		m_cServletContext = cServletContext;
	}

	public int GetResults(CheckLogin checkLogin, UploadFileTweetCParam cParam, ResourceBundleControl _TEX) {
		int nRtn = -1;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			// regist to DB
			cConn = DatabaseUtil.dataSource.getConnection();

			// 存在チェック & 本文 & 1枚目取得
			CContent content = null;
			ArrayList<String> vFileList = new ArrayList<String>();
			strSql ="SELECT contents_0000.*, nickname FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE contents_0000.user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				content = new CContent(cResSet);
				content.m_cUser.m_strNickName	= Util.toString(cResSet.getString("nickname"));
				content.setThumb();
				String strFileName = content.thumbImgUrl;
				Log.d(strFileName);
				if(!strFileName.isEmpty()) {
					vFileList.add(m_cServletContext.getRealPath(strFileName));
				}
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(content == null) return nRtn;

			// 2枚目以降取得
			if(content.m_nPublishId==Common.PUBLISH_ID_ALL && content.m_nSafeFilter<Common.SAFE_FILTER_R15 && content.m_nFileNum>1) {
				int limit = (checkLogin.m_nPassportId>=Common.PASSPORT_ON)?400:3;
				strSql = "SELECT * FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id ASC LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nContentId);
				cState.setInt(2, limit);
				cResSet = cState.executeQuery();
				while(cResSet.next()) {
					String strFileName = Util.toString(cResSet.getString("file_name"));
					if(!strFileName.isEmpty()) {
						vFileList.add(m_cServletContext.getRealPath(strFileName));
					}
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			// Tweetインスタンス準備
			CTweet cTweet = new CTweet();
			if (!cTweet.GetResults(cParam.m_nUserId)) return nRtn;

			// 本文作成
			String strTwitterMsg = CTweet.generateWithTweetMsg(content, _TEX);

			// 前のツイート削除
			Integer nResultDeleteTweet=null;
			if(cParam.m_nOptDeleteTweet==1 && !content.m_strTweetId.isEmpty()){
				nResultDeleteTweet = cTweet.Delete(content.m_strTweetId);
				if(nResultDeleteTweet!=CTweet.OK){
					if (nResultDeleteTweet == CTweet.ERR_INVALID_OR_EXPIRED_TOKEN){
						nRtn = -203;
					} else if (nResultDeleteTweet == CTweet.ERR_RATE_LIMIT_EXCEEDED){
						nRtn = -202;
					} else {
						nRtn = nResultDeleteTweet;
					}
				}
			}

			// ツイート
			Integer nResultTweet=null;
			if(nResultDeleteTweet==null || (nResultDeleteTweet!=null && nResultDeleteTweet!=CTweet.ERR_INVALID_OR_EXPIRED_TOKEN)){
				if(cParam.m_nOptImage==0 || vFileList.size()<=0) {	// text only
					nResultTweet = cTweet.Tweet(strTwitterMsg);
				} else { // with image
					nResultTweet = cTweet.Tweet(strTwitterMsg, vFileList, false);
				}

				if (nResultTweet!=CTweet.OK){
					if (nResultTweet == CTweet.ERR_USER_IS_OVER_DAILY_STATUS_UPDATE_LIMIT){
						nRtn = -104;
					} else if (nResultTweet == CTweet.ERR_INVALID_OR_EXPIRED_TOKEN){
						nRtn = -103;
					} else if (nResultTweet == CTweet.ERR_RATE_LIMIT_EXCEEDED){
						nRtn = -102;
					} else {
						nRtn = nResultTweet;
					}
				} else {
					if(cTweet.getLastTweetId()>0) {
						strSql ="UPDATE contents_0000 SET tweet_id=? WHERE contents_0000.user_id=? AND content_id=?";
						cState = cConn.prepareStatement(strSql);
						cState.setString(1, Long.toString(cTweet.getLastTweetId()));
						cState.setInt(2, cParam.m_nUserId);
						cState.setInt(3, cParam.m_nContentId);
						cState.executeUpdate();
						cState.close();cState=null;
					}
				}
			}

			if(nResultTweet!=null && nResultTweet==CTweet.OK){
				nRtn = content.m_nContentId;
			}

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception ignored){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception ignored){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception ignored){;}
		}
		return nRtn;
	}
}
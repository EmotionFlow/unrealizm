package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

import static jp.pipa.poipiku.util.ContentAccessVerificationUtil.*;

public final class IllustDetailC {
	public int ownerUserId = -1;
	public int contentId = -1;
	public int appendId = -1;
	public String password = "";

	// -1: 未定義(=0), 0: 指定された１枚だけ, 1: 指定画像以降全部
	public int showMode = -1;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			ownerUserId = Util.toInt(cRequest.getParameter("ID"));
			contentId = Util.toInt(cRequest.getParameter("TD"));
			appendId = Util.toInt(cRequest.getParameter("AD"));
			password = Util.toString(cRequest.getParameter("PAS"));
		} catch(Exception e) {
			contentId = -1;
		}
	}

	private String paramToString() {
		return String.format("ID:%d, TD:%d ,AD:%d", ownerUserId, contentId, appendId);
	}

	public CContent content = new CContent();
	public List<CContentAppend> contentAppendList = new ArrayList<>();
	public boolean isOwner = false;
	public int downloadCode = CUser.DOWNLOAD_OFF;
	public boolean isDownloadable = false;
	public boolean isRequestClient = false;
	public boolean getResults(CheckLogin checkLogin) {
		String strSql = "";
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			// author profile
			strSql = "SELECT passport_id, ng_download FROM users_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, ownerUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				if (resultSet.getInt("passport_id") == 1) {
					downloadCode = resultSet.getInt("ng_download");
				}
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			isRequestClient = verifyRequestClient(content, checkLogin);

			// content main
			String strOpenCnd = (ownerUserId !=checkLogin.m_nUserId && !isRequestClient) ? " AND open_id<>2" : "";
			strSql = String.format("SELECT * FROM contents_0000 WHERE user_id=? AND content_id=? %s", strOpenCnd);
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, ownerUserId);
			statement.setInt(2, contentId);
			resultSet = statement.executeQuery();
			if(resultSet.next()){
				content = new CContent(resultSet);
				bRtn = true;
			} else {
				Log.d("record not found");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			isOwner = content.m_cUser.m_nUserId==checkLogin.m_nUserId;

			if (showMode == 1 && content.isPasswordEnabled()) {
				if (password.isEmpty() || !verifyPassword(content, password)) {
					Log.d(String.format("Pw認証に失敗した(%s, %s)", content.m_strPassword, password));
					return false;
				}
			}

			if(!isOwner && !isRequestClient) {
				if (content.m_nPublishId == Common.PUBLISH_ID_LOGIN && !verifyPoipassLogin(checkLogin)) return false;

				if (content.m_nSafeFilter == Common.SAFE_FILTER_R18_PLUS && !verifyR18Plus(checkLogin)) return false;
				if (content.m_nPublishId == Common.PUBLISH_ID_FOLLOWER && !verifyPoipassFollower(content, checkLogin)) return false;
				if (!content.nowAvailable()) return false;

				if (content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER
						|| content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE
						|| content.m_nPublishId==Common.PUBLISH_ID_T_EACH) {
					int resultCode = verifyTwitterFollowing(content, checkLogin, CTweet.FRIENDSHIP_UNDEF).code;
					if (resultCode < 0) return false;
				}
				if (content.m_nPublishId==Common.PUBLISH_ID_T_LIST) {
					int resultCode = verifyTwitterOpenList(content, checkLogin).code;
					if (resultCode < 0) return false;
				}
				if (content.m_nPublishId==Common.PUBLISH_ID_T_RT && !verifyTwitterRetweet(content, checkLogin)) return false;


				if (showMode == 1
						&& content.m_nPublishId == Common.PUBLISH_ID_T_RT
						&& content.publishAllNum > 0
						&& appendId < 0) {
					// RT限定かつ最初の一枚だけ公開で１枚目がタップされた時は、続きを表示しない。
					showMode = 0;
				}
			}

			if(bRtn && (appendId > 0 || showMode == 1)) {
				bRtn = false;
				strSql = "SELECT file_name FROM contents_appends_0000 WHERE content_id=?";
				if (showMode <= 0) {
					strSql += " AND append_id=?";
				} else {
					if (appendId > 0) {
						strSql += " AND append_id >= ?";
					}
					strSql += " ORDER BY append_id";
				}
				statement = connection.prepareStatement(strSql);

				int idx = 1;
				statement.setInt(idx++, contentId);
				if (appendId > 0) statement.setInt(idx++, appendId);
				resultSet = statement.executeQuery();
				while(resultSet.next()) {
					CContentAppend contentAppend = new CContentAppend();
					contentAppend.m_strFileName = Util.toString(resultSet.getString("file_name"));
					contentAppendList.add(contentAppend);
				}
				bRtn = true;
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			isDownloadable = false;
			if(isOwner || isRequestClient){
				// 自分のコンテンツ or エアスケブを依頼したユーザは必ずダウンロードできる
				isDownloadable = true;
			} else {
				// コンテンツ保有者がポイパス特典でダウンロードOKとしているケース
				isDownloadable = (content.m_nEditorId != Common.EDITOR_TEXT) && (downloadCode == CUser.DOWNLOAD_ON);
			}

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return bRtn;
	}
}

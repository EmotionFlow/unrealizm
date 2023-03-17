package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class NewArrivalGridC {

	public int m_nCategoryId = 0;
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nCategoryId = Util.toInt(cRequest.getParameter("CD"));
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 24;
	public ArrayList<CContent> contentList = new ArrayList<CContent>();
	public int m_nEndId = -1;
	public int m_nContentsNum = 0;
	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 1;

		try {
			CacheUsers0000 users = CacheUsers0000.getInstance();
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			String strCondCat = (m_nCategoryId>=0)?" AND category_id=?":"";

			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCondMute = "";
			if(checkLogin.m_bLogin && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
				strMuteKeyword = SqlUtil.getMuteKeyWord(cConn, checkLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "AND content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ";
				}
			}

			// NEW ARRIVAL
			if(!bContentOnly) {
				m_nContentsNum = 9999;
			}

			StringBuilder sb = new StringBuilder();
			sb.append("SELECT contents_0000.* ");
			if(checkLogin.m_bLogin){
				sb.append(" follows_0000.follow_user_id");
			} else {
				sb.append(" NULL as follow_user_id");
			}
			sb.append(" FROM (contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id)");
			if(checkLogin.m_bLogin){
				sb.append(" LEFT JOIN follows_0000 ON contents_0000.user_id=follows_0000.follow_user_id AND follows_0000.user_id=?");
			}
			sb.append(" WHERE open_id=0");
			if(checkLogin.m_bLogin){
				sb.append(" AND contents_0000.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND contents_0000.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?)");
			}
			if(!strCondCat.isEmpty()){
				sb.append(strCondCat);
			}
			if(!strCondMute.isEmpty()){
				sb.append(strCondMute);
			}
			sb.append(" AND safe_filter<=?");
			sb.append(" ORDER BY content_id DESC NULLS LAST OFFSET ? LIMIT ?");
			strSql = new String(sb);

			cState = cConn.prepareStatement(strSql);
			idx = 1;
			if(checkLogin.m_bLogin){
				cState.setInt(idx++, checkLogin.m_nUserId); // follows_0000.user_id=?
				cState.setInt(idx++, checkLogin.m_nUserId); // user_id=?
				cState.setInt(idx++, checkLogin.m_nUserId); // block_user_id=?
			}
			if(!strCondCat.isEmpty()){
				cState.setInt(idx++, m_nCategoryId); // AND category_id=?
			}
			if(!strCondMute.isEmpty()){
				cState.setString(idx++, strMuteKeyword);
			}
			cState.setInt(idx++, checkLogin.m_nSafeFilter); // safe_filter<=?
			cState.setInt(idx++, m_nPage * SELECT_MAX_GALLERY);
			cState.setInt(idx++, SELECT_MAX_GALLERY); // LIMIT ?
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
				cContent.m_cUser.m_strNickName	= Util.toString(user.nickName);
				cContent.m_cUser.m_strFileName	= Util.toString(user.fileName);
				cContent.m_cUser.m_nReaction	= user.reaction;
				if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";
				cContent.m_cUser.m_nFollowing = (cContent.m_nUserId == checkLogin.m_nUserId)?CUser.FOLLOW_HIDE:(cResSet.getInt("follow_user_id")>0)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				m_nEndId = cContent.m_nContentId-1;
				contentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bResult = true;

			// Each Comment
			GridUtil.getEachComment(cConn, contentList);
			// Bookmark
			contentList = GridUtil.getEachBookmark(cConn, contentList, checkLogin);
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bResult;
	}
}

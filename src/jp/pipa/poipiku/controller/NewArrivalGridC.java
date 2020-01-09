package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class NewArrivalGridC {

	public int m_nCategoryId = 0;
	public int m_nMode = 0;
	public int m_nStartId = -1;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nCategoryId = Common.ToInt(cRequest.getParameter("CD"));
			m_nMode = Common.ToInt(cRequest.getParameter("MD"));
			m_nStartId = Common.ToInt(cRequest.getParameter("SD"));
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 17;
	public int SELECT_MAX_DATE = 30;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public int m_nEndId = -1;
	public int m_nContentsNum = 0;
	public boolean getResults(CheckLogin cCheckLogin) {
		return getResults(cCheckLogin, false);
	}

	public boolean getResults(CheckLogin cCheckLogin, boolean bContentOnly) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 1;

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();


			String strMuteKeyword = "";
			String strCond = "";
			if(cCheckLogin.m_bLogin) {
				strSql = "SELECT mute_keyword FROM users_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cCheckLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					strMuteKeyword = Common.ToString(cResSet.getString(1)).trim();
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
				if(!strMuteKeyword.isEmpty()) {
					strCond = "AND description &@~ ?";
				}
			}

			String strCondCat = (m_nCategoryId>=0)?"AND category_id=?":"";
			String strCondStart = (m_nStartId>0)?"AND content_id<?":"";

			// NEW ARRIVAL
			if(!bContentOnly) {
				m_nContentsNum = 9999;
				/*
				if(m_nCategoryId>=0) {
					strSql = String.format("SELECT count(*) FROM contents_0000 WHERE open_i==0 AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=? %s %s", strCondCat, strCond);
					cState = cConn.prepareStatement(strSql);
					idx = 1;
					cState.setInt(idx++, cCheckLogin.m_nUserId);
					cState.setInt(idx++, cCheckLogin.m_nUserId);
					cState.setInt(idx++, cCheckLogin.m_nSafeFilter);
					cState.setInt(idx++, m_nCategoryId);
					if(!strMuteKeyword.isEmpty()) {
						cState.setString(idx++, strMuteKeyword);
					}
					cResSet = cState.executeQuery();
					if (cResSet.next()) {
						m_nContentsNum = cResSet.getInt(1);
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;
				} else {
					m_nContentsNum = 9999;
				}
				*/
			}

			strSql = String.format("SELECT contents_0000.*, nickname, ng_reaction, users_0000.file_name as user_file_name, follows_0000.follow_user_id FROM (contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id) LEFT JOIN follows_0000 ON contents_0000.user_id=follows_0000.follow_user_id AND follows_0000.user_id=? WHERE open_id=0 AND contents_0000.upload_date>CURRENT_DATE-%d AND contents_0000.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND contents_0000.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=? %s %s %s ORDER BY content_id DESC LIMIT ?", SELECT_MAX_DATE, strCondStart, strCondCat, strCond);

			StringBuilder sb = new StringBuilder();
			sb.append("SELECT contents_0000.*, nickname, ng_reaction, users_0000.file_name as user_file_name,");
			if(cCheckLogin.m_bLogin){
				sb.append(" follows_0000.follow_user_id");
			} else {
				sb.append(" NULL as follow_user_id");
			}
			sb.append(" FROM (contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id)");
			if(cCheckLogin.m_bLogin){
				sb.append(" LEFT JOIN follows_0000 ON contents_0000.user_id=follows_0000.follow_user_id AND follows_0000.user_id=?");
			}
			sb.append(String.format(" WHERE open_id=0 AND contents_0000.upload_date>CURRENT_DATE-%d", SELECT_MAX_DATE));
			if(cCheckLogin.m_bLogin){
				sb.append(" AND contents_0000.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND contents_0000.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=?");
			}

			if(m_nStartId>0){
				sb.append(" ").append(strCondStart);
			}
			if(m_nCategoryId>=0){
				sb.append(" ").append(strCondCat);
			}

			if(cCheckLogin.m_bLogin && !strMuteKeyword.isEmpty()){
				sb.append(" ").append(strCond);
			}
			sb.append(" ORDER BY content_id DESC LIMIT ?");
			strSql = new String(sb);

			Log.d(strSql);

			cState = cConn.prepareStatement(strSql);
			idx = 1;
			if(cCheckLogin.m_bLogin){
				cState.setInt(idx++, cCheckLogin.m_nUserId); // follows_0000.user_id=?
				cState.setInt(idx++, cCheckLogin.m_nUserId); // user_id=?
				cState.setInt(idx++, cCheckLogin.m_nUserId); // block_user_id=?
				cState.setInt(idx++, cCheckLogin.m_nSafeFilter); // safe_filter<=?
			}
			if(m_nStartId>0) {
				cState.setInt(idx++, m_nStartId); // content_id<?
			}
			if(m_nCategoryId>=0) {
				cState.setInt(idx++, m_nCategoryId); // AND category_id=?
			}
			if(cCheckLogin.m_bLogin && !strMuteKeyword.isEmpty()) {
				cState.setString(idx++, strMuteKeyword);
			}
			cState.setInt(idx++, SELECT_MAX_GALLERY); // LIMIT ?
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				cContent.m_cUser.m_strFileName	= Common.ToString(cResSet.getString("user_file_name"));
				if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";
				cContent.m_cUser.m_nReaction = cResSet.getInt("ng_reaction");
				cContent.m_cUser.m_nFollowing = (cContent.m_nUserId == cCheckLogin.m_nUserId)?CUser.FOLLOW_HIDE:(cResSet.getInt("follow_user_id")>0)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				m_nEndId = cContent.m_nContentId;
				m_vContentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Each append image
			GridUtil.getEachImage(cConn, m_vContentList);
			// Each Comment
			GridUtil.getEachComment(cConn, m_vContentList);
			// Bookmark
			if(cCheckLogin.m_bLogin) {
				GridUtil.getEachBookmark(cConn, m_vContentList, cCheckLogin);
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

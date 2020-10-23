package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class MyHomeTagPcC {
	public int n_nUserId = -1;
	public int n_nVersion = 0;
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			n_nVersion = Util.toInt(cRequest.getParameter("VER"));
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 15;
	public int SELECT_MAX_EMOJI = GridUtil.SELECT_MAX_EMOJI;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public int m_nContentsNum = 0;
	public int m_nContentsNumTotal = 0;
	public int m_nEndId = -1;

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

			// サーチタグの存在確認
			boolean bSearchTag = false;
			strSql = "SELECT tag_txt FROM follow_tags_0000 WHERE user_id=? AND type_id=0 LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cCheckLogin.m_nUserId);
			cResSet = cState.executeQuery();
			bSearchTag = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// サーチキーワード
			String strSearchKeyword = SqlUtil.getSearhKeyWord(cConn, cCheckLogin.m_nUserId);

			// サーチタグ&サーチキーワード共に無い場合はそのまま終了
			if (!bSearchTag && strSearchKeyword.isEmpty()) return true;

			// ミュートキーワード
			String strMuteKeyword = SqlUtil.getMuteKeyWord(cConn, cCheckLogin.m_nUserId);

			// ブロックユーザクエリ
			String strCondBlock = SqlUtil.getBlockUserSql(cConn, cCheckLogin.m_nUserId);
			// 非ブロックユーザクエリ
			String strCondBlocked = SqlUtil.getBlockedUserSql(cConn, cCheckLogin.m_nUserId);
			// サーチキーワードクエリ
			String strCondSearch = (!strSearchKeyword.isEmpty())?" OR contents_0000.content_id IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?)":"";
			// ミュートキーワードクエリ
			String strCondMute = (!strMuteKeyword.isEmpty())?" AND contents_0000.content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?)":"";

			// NEW ARRIVAL
			if(!bContentOnly) {
				StringBuilder sb = new StringBuilder();
				sb.append("SELECT count(*)");
				sb.append(" FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id");
				sb.append(" LEFT JOIN follows_0000 ON contents_0000.user_id=follows_0000.follow_user_id AND follows_0000.user_id=?");
				sb.append(" WHERE open_id<>2");
				sb.append(strCondBlock);
				sb.append(strCondBlocked);
				sb.append(" AND safe_filter<=?");
				sb.append(" AND (content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt IN(SELECT tag_txt FROM follow_tags_0000 WHERE user_id=? AND type_id=0) AND tag_type=1)");
				sb.append(strCondSearch);
				sb.append(")");
				sb.append(strCondMute);
				cState = cConn.prepareStatement(sb.toString());
				idx = 1;
				cState.setInt(idx++, cCheckLogin.m_nUserId); // follows_0000.user_id=?
				if(!strCondBlock.isEmpty()) cState.setInt(idx++, cCheckLogin.m_nUserId); // blocks_0000.user_id=?
				if(!strCondBlocked.isEmpty()) cState.setInt(idx++, cCheckLogin.m_nUserId); // blocks_0000.block_user_id=?
				cState.setInt(idx++, cCheckLogin.m_nSafeFilter); // safe_filter<=?
				cState.setInt(idx++, cCheckLogin.m_nUserId); // follow_tags_0000.user_id=?
				if(!strCondSearch.isEmpty()) cState.setString(idx++, strSearchKeyword);
				if(!strCondMute.isEmpty()) cState.setString(idx++, strMuteKeyword);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				// PC版右ペイン用
				idx = 1;
				strSql = "SELECT COUNT(*) FROM contents_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNumTotal = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			StringBuilder sb = new StringBuilder();
			sb.append("SELECT contents_0000.*, nickname, ng_reaction, users_0000.file_name as user_file_name, follows_0000.follow_user_id");
			sb.append(" FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id");
			sb.append(" LEFT JOIN follows_0000 ON contents_0000.user_id=follows_0000.follow_user_id AND follows_0000.user_id=?");
			sb.append(" WHERE open_id<>2");
			sb.append(strCondBlock);
			sb.append(strCondBlocked);
			sb.append(" AND safe_filter<=?");
			sb.append(" AND (content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt IN(SELECT tag_txt FROM follow_tags_0000 WHERE user_id=? AND type_id=0) AND tag_type=1)");
			sb.append(strCondSearch);
			sb.append(")");
			sb.append(strCondMute);
			sb.append(" ORDER BY content_id DESC OFFSET ? LIMIT ?");
			cState = cConn.prepareStatement(sb.toString());
			idx = 1;
			cState.setInt(idx++, cCheckLogin.m_nUserId); // follows_0000.user_id=?
			if(!strCondBlock.isEmpty()) cState.setInt(idx++, cCheckLogin.m_nUserId); // blocks_0000.user_id=?
			if(!strCondBlocked.isEmpty()) cState.setInt(idx++, cCheckLogin.m_nUserId); // blocks_0000.block_user_id=?
			cState.setInt(idx++, cCheckLogin.m_nSafeFilter); // safe_filter<=?
			cState.setInt(idx++, cCheckLogin.m_nUserId); // follow_tags_0000.user_id=?
			if(!strCondSearch.isEmpty()) cState.setString(idx++, strSearchKeyword);
			if(!strCondMute.isEmpty()) cState.setString(idx++, strMuteKeyword);
			cState.setInt(idx++, m_nPage * SELECT_MAX_GALLERY);
			cState.setInt(idx++, SELECT_MAX_GALLERY); // LIMIT ?
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				cContent.m_cUser.m_strNickName	= Util.toString(cResSet.getString("nickname"));
				cContent.m_cUser.m_strFileName	= Util.toString(cResSet.getString("user_file_name"));
				if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";
				cContent.m_cUser.m_nReaction = cResSet.getInt("ng_reaction");
				cContent.m_cUser.m_nFollowing = (cContent.m_nUserId == cCheckLogin.m_nUserId)?CUser.FOLLOW_HIDE:(cResSet.getInt("follow_user_id")>0)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				m_nEndId = cContent.m_nContentId;
				m_vContentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

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


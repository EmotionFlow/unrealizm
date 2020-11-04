package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class MyHomeC {
	public int n_nUserId = -1;
	public int n_nVersion = 0;
	public int m_nMode = CCnv.MODE_PC;
	public int m_nStartId = -1;
	public int m_nViewMode = CCnv.VIEW_LIST;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			n_nVersion = Util.toInt(cRequest.getParameter("VER"));
			m_nMode = Util.toInt(cRequest.getParameter("MD"));
			m_nStartId = Util.toInt(cRequest.getParameter("SD"));
			n_nUserId = Util.toInt(cRequest.getParameter("ID"));
			m_nViewMode = Util.toInt(cRequest.getParameter("VD"));
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 10;
	public int SELECT_MAX_EMOJI = GridUtil.SELECT_MAX_EMOJI;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public int m_nContentsNum = 0;
	public int m_nContentsNumTotal = 0;
	public int m_nEndId = -1;

	public boolean getResults(CheckLogin cCheckLogin) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 1;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCondMute = "";
			if(cCheckLogin.m_bLogin && cCheckLogin.m_nPremiumId>=CUser.PREMIUM_ON) {
				strMuteKeyword = SqlUtil.getMuteKeyWord(cConn, cCheckLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "AND content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ";
				}
			}
			String strCondStart = (m_nStartId>0)?"AND content_id<? ":"";

			StringBuilder sb = new StringBuilder();
			sb.append("SELECT * FROM contents_0000 ")
			.append("WHERE open_id<>2 ")
			.append("AND user_id IN ((SELECT follow_user_id FROM follows_0000 WHERE user_id=?) UNION ALL (SELECT ?)) ");
			if(!strCondMute.isEmpty()) {
				sb.append(strCondMute);
			}
			if(!strCondStart.isEmpty()) {
				sb.append(strCondStart);
			}
			sb.append("AND safe_filter<=? ");
			sb.append("ORDER BY content_id DESC LIMIT ?");
			strSql = new String(sb);

			// NEW ARRIVAL
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			if(!strCondMute.isEmpty()) {
				cState.setString(idx++, strMuteKeyword);
			}
			if(!strCondStart.isEmpty()) {
				cState.setInt(idx++, m_nStartId);
			}
			cState.setInt(idx++, cCheckLogin.m_nSafeFilter);
			cState.setInt(idx++, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
				cContent.m_cUser.m_strNickName	= Util.toString(user.m_strNickName);
				cContent.m_cUser.m_strFileName	= Util.toString(user.m_strFileName);
				cContent.m_cUser.m_nReaction	= user.m_nReaction;
				cContent.m_cUser.m_nFollowing = CUser.FOLLOW_HIDE;
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

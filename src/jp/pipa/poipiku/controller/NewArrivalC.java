package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class NewArrivalC {

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


	public int SELECT_MAX_GALLERY = 15;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public int m_nEndId = -1;
	public int m_nContentsNum = 0;

	public boolean getResults(CheckLogin cCheckLogin) {
		return getResults(cCheckLogin, false);
	}

	public boolean getResults(CheckLogin cCheckLogin, boolean bContentOnly) {
		boolean bResult = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			String strCondCat = (m_nCategoryId>=0)?" AND category_id=?":"";

			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCondMute = "";
			if(cCheckLogin.m_bLogin && cCheckLogin.m_nPremiumId>=CUser.PREMIUM_ON) {
				strMuteKeyword = SqlUtil.getMuteKeyWord(connection, cCheckLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "AND content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ";
				}
			}

			// NEW ARRIVAL
			if(!bContentOnly) {
				m_nContentsNum = 9999;
			}

			StringBuilder sb = new StringBuilder();
			sb.append("SELECT * FROM contents_0000 WHERE open_id=0 ");
			if(cCheckLogin.m_bLogin){
				sb.append("AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ");
			}
			if(!strCondCat.isEmpty()){
				sb.append(strCondCat);
			}
			if(!strCondMute.isEmpty()){
				sb.append(strCondMute);
			}
			sb.append("AND safe_filter<=? ");
			sb.append("ORDER BY content_id DESC OFFSET ? LIMIT ?");
			strSql = new String(sb);

			statement = connection.prepareStatement(strSql);
			idx = 1;
			if(cCheckLogin.m_bLogin){
				statement.setInt(idx++, cCheckLogin.m_nUserId);
				statement.setInt(idx++, cCheckLogin.m_nUserId);
			}
			if(!strCondCat.isEmpty()){
				statement.setInt(idx++, m_nCategoryId);
			}
			if(!strCondMute.isEmpty()){
				statement.setString(idx++, strMuteKeyword);
			}
			statement.setInt(idx++, cCheckLogin.m_nSafeFilter);
			statement.setInt(idx++, m_nPage * SELECT_MAX_GALLERY);
			statement.setInt(idx++, SELECT_MAX_GALLERY);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_cUser.m_strNickName	= Util.toString(user.m_strNickName);
				content.m_cUser.m_strFileName	= Util.toString(user.m_strFileName);
				m_nEndId = content.m_nContentId;
				m_vContentList.add(content);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bResult = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bResult;
	}
}

package com.emotionflow.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import com.emotionflow.poipiku.*;

public class PopularTagListC {
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Common.ToInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 100;
	public ArrayList<CTag> m_vContentList = new ArrayList<CTag>();
	public int m_nContentsNum = 0;

	public boolean getResults(CheckLogin cCheckLogin) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// NEW ARRIVAL
			m_nContentsNum = SELECT_MAX_GALLERY;

			strSql = "select tag_txt FROM tags_0000 group by tag_txt order by count(*) desc offset ? limit ?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nPage*SELECT_MAX_GALLERY);
			cState.setInt(2, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_vContentList.add(new CTag(cResSet));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bResult = true;
		} catch(Exception e) {
			System.out.println(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bResult;
	}
}

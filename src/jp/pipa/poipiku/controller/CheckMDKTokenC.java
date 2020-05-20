package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class CheckMDKTokenC {
	public int getResults(CheckLogin cCheckLogin) {
		int  nResult = -1;
		if(!cCheckLogin.m_bLogin){return nResult;}

		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "SELECT 1 FROM mdk_token WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cCheckLogin.m_nUserId);
			Log.d("cCheckLogin.m_nUserId", Integer.toString(cCheckLogin.m_nUserId));
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				nResult = 1;
			} else {
				nResult = 0;
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nResult;
	}
}

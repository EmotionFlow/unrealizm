package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class DeleteCreditCardC {
    public DeleteCreditCardC(){}

    public boolean GetResults(DeleteCreditCardCParam cParam) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "UPDATE creditcards SET del_flg=true WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.executeUpdate();

			bRtn = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.CreditCard;
import jp.pipa.poipiku.settlement.Agent;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.*;


public class CheckCreditCardC {
	DataSource dsPostgres = null;
	Connection cConn = null;
	PreparedStatement cState = null;
	ResultSet cResSet = null;


	private int verify(int nUserId) throws SQLException {
		int nResult = -1;
		CreditCard creditCard = new CreditCard(nUserId, Agent.EPSILON);
		creditCard.select();

		if (!creditCard.isExist) {
			nResult = 0;
		} else {
			if (creditCard.isExpired(1) || creditCard.isInvalid) {
				creditCard.delete();
				nResult = 0;
			} else {
				nResult = 1;
			}
		}
		return nResult;
	}

	public int getResults(CheckLogin checkLogin) {
		int  nResult = -1;
		if(!checkLogin.m_bLogin){return nResult;}

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			nResult = verify(checkLogin.m_nUserId);

		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception ignored){}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception ignored){}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception ignored){}
		}
		return nResult;
	}
}

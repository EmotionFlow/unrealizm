package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDateTime;

class CardToken {
	public boolean isExist = false;
	public Timestamp updatedAt = null;
	public LocalDateTime dtCardExpire = null;
	public void setExpire(String MMYY){
		int mm = Integer.parseInt(MMYY.split("/")[0]);
		int yy = Integer.parseInt(MMYY.split("/")[1]);
		dtCardExpire = LocalDateTime.of(2000+yy, mm, 1, 0, 0, 0);
	}
	public boolean passingFromLastUpdated(int nDay){
		return updatedAt.getTime() + nDay * 24 * 3600 * 1000 < System.currentTimeMillis();
	}
	public boolean isExpired(int nMarginMonth){
		return dtCardExpire.plusMonths(-nMarginMonth).compareTo(LocalDateTime.now()) < 0;
	}
}

public class CheckCreditCardC {
	private static final int AGENT_VERITRANS = 1;
	private static final int AGENT_EPSILON = 2;

	DataSource dsPostgres = null;
	Connection cConn = null;
	PreparedStatement cState = null;
	ResultSet cResSet = null;

	private CardToken selectToken(int nUserId, int nAgentId) throws SQLException {
		CardToken t = new CardToken();

		String strSql = "SELECT card_expire, updated_at FROM creditcards WHERE user_id=? AND agent_id=? AND del_flg=false";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, nUserId);
		cState.setInt(2, nAgentId);

		Log.d("cCheckLogin.m_nUserId", Integer.toString(nUserId));
		cResSet = cState.executeQuery();
		Timestamp updatedAt = null;
		String strCardExpire = null;
		if(cResSet.next()){
			t.isExist = true;
			updatedAt = cResSet.getTimestamp("updated_at");
			strCardExpire = cResSet.getString("card_expire");
			t.updatedAt = updatedAt;
			t.setExpire(strCardExpire);
		}
		cResSet.close();cResSet=null;
		cState.close();cState=null;

		return t;
	}

	private void deleteToken(int nUserId, int nAgentId) throws SQLException{
		String strSql = "UPDATE creditcards SET del_flg=true WHERE user_id=? AND agent_id=?";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, nUserId);
		cState.setInt(2, nAgentId);
		cState.executeUpdate();
		Log.d("CC_EXPIRE カード情報削除 " + nUserId);
		cState.close();cState=null;
	}

	private int verify(int nUserId, int nAgentId) throws SQLException{
		int  nResult = -1;
		CardToken cardToken = selectToken(nUserId, nAgentId);

		if(!cardToken.isExist){
			nResult = 0;
		} else {
			if(nAgentId == AGENT_VERITRANS) {
				if (cardToken.isExpired(1) || cardToken.passingFromLastUpdated(300)) {
					deleteToken(nUserId, AGENT_VERITRANS);
					nResult = 0;
				} else {
					nResult = 1;
				}
			}else if(nAgentId==AGENT_EPSILON){
				if (cardToken.isExpired(1)) {
					deleteToken(nUserId, AGENT_VERITRANS);
					nResult = 0;
				} else {
					nResult = 1;
				}
			}
		}
		return nResult;
	}

	public int getResults(CheckLogin cCheckLogin) {
		int  nResult = -1;
		if(!cCheckLogin.m_bLogin){return nResult;}

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			nResult = verify(cCheckLogin.m_nUserId, AGENT_EPSILON);

		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nResult;
	}
}

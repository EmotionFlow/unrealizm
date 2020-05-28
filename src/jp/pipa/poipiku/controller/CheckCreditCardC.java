package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;

public class CheckCreditCardC {
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

			strSql = "SELECT expire, updated_at FROM mdk_creditcards WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cCheckLogin.m_nUserId);
			Log.d("cCheckLogin.m_nUserId", Integer.toString(cCheckLogin.m_nUserId));
			cResSet = cState.executeQuery();
			Timestamp updatedAt = null;
			String strCardExpire = null;
			if(cResSet.next()){
				updatedAt = cResSet.getTimestamp("updated_at");
				strCardExpire = cResSet.getString("expire");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			if(updatedAt != null) {
				boolean bExpired = false;
				if(updatedAt.getTime() + 300 * 24 * 3600 * 1000 < System.currentTimeMillis() ){
					Log.d("CC_EXPIRE 最終取引から３００日経過している" + cCheckLogin.m_nUserId);
					bExpired = true;
				}else{
					int mm = Integer.parseInt(strCardExpire.split("/")[0]);
					int yy = Integer.parseInt(strCardExpire.split("/")[1]);
					LocalDateTime dtCardExpire = LocalDateTime.of(2000+yy, mm, 1, 0, 0, 0);
					Log.d(dtCardExpire.toString());
					if(dtCardExpire.plusMonths(-1).compareTo(LocalDateTime.now()) < 0) {
						Log.d("CC_EXPIRE カードの期限が一ヶ月を切っている " + cCheckLogin.m_nUserId);
						bExpired = true;
					}
				}
				if(bExpired){
					strSql = "DELETE FROM mdk_creditcards WHERE user_id=?";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, cCheckLogin.m_nUserId);
					cState.executeUpdate();
					Log.d("CC_EXPIRE カード情報削除 " + cCheckLogin.m_nUserId);
					cState.close();cState=null;
					nResult = 0;
				} else {
					nResult = 1;
				}
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

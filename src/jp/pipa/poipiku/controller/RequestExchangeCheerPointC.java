package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.settlement.Agent;
import jp.pipa.poipiku.settlement.epsilon.User;
import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class RequestExchangeCheerPointC {
    public RequestExchangeCheerPointC(){}

    public boolean GetResults(RequestExchangeCheerPointCParam cParam) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		ArrayList<Integer> cardIds = new ArrayList<>();

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// すでに支払い待ちのレコードがあったら、要求を受け付けずエラーとする
			strSql = "SELECT 1 FROM cheer_point_exchange_requests WHERE user_id=? AND status=0 limit 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			while(cResSet.next()){
				return false;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// 交換していないポイントの合計を検索
			int nTotalCheerPoint = 0;
			strSql = "SELECT sum(remaining_points) FROM cheer_points WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			while(cResSet.next()){
				nTotalCheerPoint = cResSet.getInt(1);
			}
			if(nTotalCheerPoint>=0){
				return false;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// 支払い待ちでINSERT
			int idx = 1;
			strSql = "INSERT INTO cheer_point_exchange_requests(" +
					"user_id, exchange_point, commission_fee, payment_fee, f_code, f_name, f_subcode, ac_code, ac_name, status)" +
					" VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(idx++, cParam.m_nUserId);
			cState.setInt(idx++, nTotalCheerPoint);
			cState.setInt(idx++, 300);
			cState.setInt(idx++, nTotalCheerPoint-300);
			cState.setString(idx++, cParam.m_strFinancialCode);
			cState.setString(idx++, cParam.m_strFinancialName);
			cState.setString(idx++, cParam.m_strFinancialSubCode);
			cState.setString(idx++, cParam.m_strAccountCode);
			cState.setString(idx++, cParam.m_strAccountName);
			cState.setInt(idx++, 0);
			cState.executeUpdate();
			cState.close();cState=null;

			bRtn = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			bRtn = false;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

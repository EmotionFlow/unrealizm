package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class RequestExchangeCheerPointC {
    public RequestExchangeCheerPointC(){}

    public boolean GetResults(RequestExchangeCheerPointCParam cParam) {
    	// おそらく不正アクセス
    	if (cParam.m_nExchangePoints < 400) {
    		Log.d("最低限度を下回るポイントの交換を請求された");
    		return false;
		}

		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// すでに支払い待ちのレコードがあったら、要求を受け付けずエラーとする
			strSql = "SELECT 1 FROM cheer_point_exchange_requests WHERE user_id=? AND status=0 limit 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()){
				Log.d("すでに支払い待ちのレコードがある");
				return false;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// 交換していないポイントの合計を検索
			int nTotalCheerPoint = 0;
			ArrayList<String> exchangePointIds = new ArrayList<>();
			strSql = "SELECT id, remaining_points FROM cheer_points WHERE user_id=? AND remaining_points>0 ORDER BY created_at ASC";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			while(cResSet.next()){
				nTotalCheerPoint += cResSet.getInt(2);
				exchangePointIds.add(Integer.toString(cResSet.getInt(1)));

				if (nTotalCheerPoint == cParam.m_nExchangePoints) {
					break;
				}else if(nTotalCheerPoint > cParam.m_nExchangePoints){
					Log.d("Viewから受け付けた交換ポイントの数値が不正");
					return false;
				}
			}

			// 不正アクセスか、多重実行
			if(nTotalCheerPoint<cParam.m_nExchangePoints){
				Log.d("指定されたポイントを所持していない");
				return false;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			cConn.close();cConn=null;

			cConn = dsPostgres.getConnection();
			String strRequestId = "";
			try {
				// start transaction
				cConn.setAutoCommit(false);

				// 請求IDを発行する
				strRequestId = Long.toString(System.currentTimeMillis()) + "-" + Integer.toString(cParam.m_nUserId);

				// 支払い請求を支払い待ちでINSERT
				int idx = 1;
				strSql = "INSERT INTO cheer_point_exchange_requests(" +
						"request_id, user_id, exchange_point, commission_fee, payment_fee, f_code, f_name, f_subcode, f_subname, ac_code, ac_name, status)" +
						" VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
				cState = cConn.prepareStatement(strSql);
				cState.setString(idx++, strRequestId);
				cState.setInt(idx++, cParam.m_nUserId);
				cState.setInt(idx++, nTotalCheerPoint);
				cState.setInt(idx++, 300);
				cState.setInt(idx++, nTotalCheerPoint-300);
				cState.setString(idx++, cParam.m_strFinancialCode);
				cState.setString(idx++, cParam.m_strFinancialName);
				cState.setString(idx++, cParam.m_strFinancialSubCode);
				cState.setString(idx++, cParam.m_strFinancialSubName);
				cState.setString(idx++, cParam.m_strAccountCode);
				cState.setString(idx++, cParam.m_strAccountName);
				cState.setInt(idx++, 0);
				cState.executeUpdate();
				cState.close();cState=null;

				// 交換対象ポイントを引き、請求と紐づける
				strSql = "UPDATE cheer_points" +
						" SET paying_points = remaining_points, remaining_points = 0, exchange_request_id = ?, updated_at = CURRENT_TIMESTAMP" +
						" WHERE user_id=? AND exchange_request_id IS NULL AND id IN(" +
						String.join(",", exchangePointIds) +
						")";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, strRequestId);
				cState.setInt(2, cParam.m_nUserId);
				cState.executeUpdate();

				// do transaction
				cConn.commit();
				cState.close();cState=null;
			} catch (SQLException sqlException) {
				Log.d("transaction fail");
				Log.d(strSql);
				sqlException.printStackTrace();
				cConn.rollback();
			} finally {
				cConn.setAutoCommit(true);
				cConn.close();cConn=null;
			}

			// もし支払い待ちのレコードが複数存在したら、それは不正な状態であるため、INSERTした請求レコードをDELETEする。
			// TODO ゆくゆくは複数請求可としたい
			cConn = dsPostgres.getConnection();
			strSql = "SELECT count(*) AS cnt FROM cheer_point_exchange_requests WHERE user_id=? AND status=0";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			int nRequests = 2;
			if(cResSet.next()){
				nRequests = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(nRequests>1){
				Log.d("請求レコードを発行したが、多重発行されているのでロールバックする");
				strSql = "DELETE FROM cheer_point_exchange_requests WHERE user_id=? AND request_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setString(2, strRequestId);
				cState.executeUpdate();
				cState.close();cState=null;
			}

			// TODO 支払いキャンセル実装
			// TODO 締め（CSV）→消し込み 実装

			bRtn = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			try{if(cConn!=null){cConn.rollback();}}catch(SQLException ignore){}
			bRtn = false;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

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

public class DeleteCreditCardC {
    public DeleteCreditCardC(){}

    public boolean GetResults(DeleteCreditCardCParam cParam) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// SELECT
			strSql = "SELECT id, agent_id, agent_user_id FROM creditcards WHERE user_id=? AND del_flg=false";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cResSet = cState.executeQuery();

			while(cResSet.next()){
				// EPSILONだったら、退会処理
				if (cResSet.getInt("agent_id") == Agent.EPSILON) {
					User epsilonUser = new User(cResSet.getString("agent_user_id"));
					if (!epsilonUser.deleteUserInfo()) {
						Log.d("イプシロンユーザ情報削除に失敗: ", cParam.m_nUserId);
					}
				}
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			strSql = "UPDATE creditcards SET del_flg=true WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.executeUpdate();

			bRtn = true;
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

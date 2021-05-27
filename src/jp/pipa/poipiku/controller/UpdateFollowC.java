package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.FollowUser;
import jp.pipa.poipiku.ResourceBundleControl;
import jp.pipa.poipiku.util.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UpdateFollowC {
	public int GetResults(UpdateFollowCParam cParam, ResourceBundleControl _TEX) {
		int nRtn = -1;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			cConn = DatabaseUtil.dataSource.getConnection();

			boolean bCanFollow = true;
			// blocking
			strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nFollowedUserId);
			cResSet = cState.executeQuery();
			bCanFollow = !cResSet.next();
			cResSet.close();cResSet = null;
			cState.close();cState = null;

			// blocked
			strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nFollowedUserId);
			cState.setInt(2, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			bCanFollow = !cResSet.next();
			cResSet.close();
			cResSet = null;
			cState.close();
			cState = null;


			boolean bFollowing = false;
			// now following check
			strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nFollowedUserId);
			cResSet = cState.executeQuery();
			bFollowing = cResSet.next();
			cResSet.close();
			cResSet = null;
			cState.close();
			cState = null;


			if (bCanFollow && !bFollowing) {
				// check limit
				strSql = "SELECT count(*) FROM follows_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					if (cResSet.getInt(1) > FollowUser.FOLLOWING_MAX) {
						return -2;
					}
				}
				cResSet.close();cResSet = null;
				cState.close();cState = null;

				strSql = "INSERT INTO follows_0000(user_id, follow_user_id) VALUES(?, ?)";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nFollowedUserId);
				cState.executeUpdate();
				cState.close();
				cState = null;
				nRtn = 1;
			} else {
				strSql = "DELETE FROM follows_0000 WHERE user_id=? AND follow_user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nFollowedUserId);
				cState.executeUpdate();
				cState.close();
				cState = null;
				nRtn = 2;
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}


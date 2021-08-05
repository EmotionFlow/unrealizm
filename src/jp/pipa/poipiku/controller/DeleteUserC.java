package jp.pipa.poipiku.controller;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.naming.InitialContext;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.WriteBackFile;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class DeleteUserC {
	public int m_nUserId = -1;
	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId = Util.toInt(cRequest.getParameter("UID"));
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	private ServletContext m_cServletContext = null;
	public int GetResults(CheckLogin checkLogin, HttpServletRequest request) {
		m_cServletContext = request.getServletContext();
		Log.d(String.format("DeleteUser, %d, %s", checkLogin.m_nUserId, request.getRemoteAddr()));

		int nRtn = 0;
		if(!checkLogin.m_bLogin || (checkLogin.m_nUserId != m_nUserId)) {
			return 0;
		}else if(checkLogin.m_nPassportId>0){
			Log.d("passport id > 0");
			return -1;
		}

		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		String strSql = "";

		try {
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);

			// もらった絵文字だけ消す
			// delete comment
			connection = dataSource.getConnection();
			strSql ="DELETE FROM comments_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?)";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;

			connection = dataSource.getConnection();
			strSql ="DELETE FROM comments_desc_cache WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?)";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;

			// delete info_lists
			connection = dataSource.getConnection();
			strSql ="DELETE FROM info_lists WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;

			// delete tags
			connection = dataSource.getConnection();
			strSql = "DELETE FROM tags_0000 WHERE tags_0000.content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?)";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;

			// delete bookmark
			connection = dataSource.getConnection();
			strSql = "DELETE FROM bookmarks_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?)";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			strSql = "DELETE FROM bookmarks_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;

			// delete follow
			connection = dataSource.getConnection();
			strSql = "DELETE FROM follows_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			strSql = "DELETE FROM follows_0000 WHERE follow_user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;

			// delete blocks
			connection = dataSource.getConnection();
			strSql = "DELETE FROM blocks_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			strSql = "DELETE FROM blocks_0000 WHERE block_user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;

			// delete append data
			connection = dataSource.getConnection();
			strSql ="DELETE FROM contents_appends_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?)";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;

			// delete content data
			connection = dataSource.getConnection();
			strSql = "DELETE FROM contents_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;

			///////
			connection = dataSource.getConnection();

			// delete temp email
			strSql = "DELETE FROM temp_emails_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;

			// delete oauth
			strSql = "DELETE FROM tbloauth WHERE flduserid=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;

			// delete token
			strSql = "DELETE FROM notification_tokens_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;
			//////

			// delete order, payment info
			connection = dataSource.getConnection();
			strSql = "UPDATE orders SET del_flg=true, updated_at=now() WHERE customer_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;

			// delete request_creators
			connection = dataSource.getConnection();
			strSql = "DELETE FROM request_creators WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;

			// delete credit card
			DeleteCreditCardCParam deleteCreditCardCParam = new DeleteCreditCardCParam();
			deleteCreditCardCParam.m_nUserId = m_nUserId;
			DeleteCreditCardC deleteCreditCardC = new DeleteCreditCardC();
			deleteCreditCardC.GetResults(deleteCreditCardCParam);

			// delete user
			connection = dataSource.getConnection();
			strSql = "DELETE FROM users_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.executeUpdate();
			statement.close();statement=null;
			connection.close();connection=null;

			// delete files
			File fileDel;
			fileDel= new File(m_cServletContext.getRealPath(Common.getUploadUsersPath(m_nUserId)));
			Common.rmDir(fileDel);
			fileDel= new File(m_cServletContext.getRealPath(Common.getUploadContentsPath(m_nUserId)));
			Common.rmDir(fileDel);

			// キャッシュからもユーザを消す
			CacheUsers0000 users0000 = CacheUsers0000.getInstance();
			users0000.clearUser(m_nUserId);

			WriteBackFile.deleteByUserId(m_nUserId);

			nRtn = 1;

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(statement != null) statement.close();statement=null;} catch(Exception e) {;}
			try{if(connection != null) connection.close();connection=null;}catch(Exception e){;}
		}

		if(nRtn>0) {
			Log.d(String.format("DeleteUserV Complete:%d", m_nUserId));
		} else {
			Log.d(String.format("DeleteUserV Failed:%d", m_nUserId));
		}
		return nRtn;
	}
}

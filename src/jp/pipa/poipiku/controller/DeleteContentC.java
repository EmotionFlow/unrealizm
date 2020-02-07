package jp.pipa.poipiku.controller;

import java.sql.*;

import javax.naming.InitialContext;
import javax.servlet.ServletContext;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class DeleteContentC {
    CContent cContent = null;
    private ServletContext m_cServletContext = null;

    public DeleteContentC(ServletContext context){
        m_cServletContext = context;
    }

    public boolean GetResults(DeleteContentCParam cParam) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// イラスト存在確認(不正アクセス対策)
			if(cParam.m_nUserId==1) {
				strSql = "SELECT * FROM contents_0000 WHERE content_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nContentId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					cContent = new CContent(cResSet);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			} else {
				strSql = "SELECT * FROM contents_0000 WHERE content_id=? AND user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nContentId);
				cState.setInt(2, cParam.m_nUserId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					cContent = new CContent(cResSet);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}
			if(cContent==null) {
				return false;
			}

			// delete step comment
			strSql ="DELETE FROM comments_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			// delete tags
			strSql ="DELETE FROM tags_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			// delete bookmark
			strSql ="DELETE FROM bookmarks_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			// delete append files
			strSql ="SELECT * FROM contents_appends_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			while(cResSet.next()) {
				CContentAppend cContentAppend = new CContentAppend(cResSet);
				try{
					ImageUtil.deleteFiles(m_cServletContext.getRealPath(cContentAppend.m_strFileName));
				} catch (Exception e) {
					Log.d("connot delete content_append file : " + cContentAppend.m_strFileName);
				}
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			// delete append data
			strSql ="DELETE FROM contents_appends_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			// delete content data
			strSql ="DELETE FROM contents_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;
			// delete files
			try{
				ImageUtil.deleteFiles(m_cServletContext.getRealPath(cContent.m_strFileName));
			} catch (Exception e) {
				Log.d("connot delete content file : " + cContent.m_strFileName);
			}

			// delete tweet
			if(cParam.m_nUserId==cContent.m_nUserId && cParam.m_nDeleteTweet==1 && !cContent.m_strTweetId.isEmpty()){
				CTweet cTweet = new CTweet();
				if(cTweet.GetResults(cParam.m_nUserId)) {
					if(cTweet.Delete(cContent.m_strTweetId)!=CTweet.OK){
						Log.d("cTweet.Delete() failed");
					}
				} else {
					Log.d("cTweet.GetResult() failed");
				}
			}

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

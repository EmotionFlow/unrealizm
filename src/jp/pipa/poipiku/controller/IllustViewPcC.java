package jp.pipa.poipiku.controller;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public final class IllustViewPcC {
	public int ownerUserId = -1;
	public int contentId = -1;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_bIsBot        = Util.isBot(cRequest);
			ownerUserId = Util.toInt(cRequest.getParameter("ID"));
			contentId = Util.toInt(cRequest.getParameter("TD"));
		} catch(Exception e) {
			contentId = -1;
		}
	}

	private Integer searchContentIdHistory(Connection cConn, int nContentId) throws SQLException {
		final int SEARCH_MAX = 100;
		int cid = nContentId;
		String strSql = "SELECT new_id FROM content_id_histories WHERE old_id=?";

		PreparedStatement statement = null;
		ResultSet resultSet = null;

		try {
			statement = cConn.prepareStatement(strSql);
			for(int i=0; i<SEARCH_MAX; i++){
				statement.setInt(1, cid);
				resultSet = statement.executeQuery();
				if(resultSet.next()){
					cid = resultSet.getInt("new_id");
				}else{
					break;
				}
			}
		}finally {
			if(resultSet!=null){resultSet.close();}
			if(statement!=null){statement.close();}
		}
		return cid;
	}


	public int selectMaxGallery = 9;
	public int selectMaxRelatedGallery = 9;
	public int selectMaxRecommendedGallery = 9;
	public ArrayList<CContent> m_vContentList = new ArrayList<>();
	public ArrayList<CContent> m_vRelatedContentList = new ArrayList<>();
	public ArrayList<CContent> m_vRecommendedList = new ArrayList<>();
	public int SELECT_MAX_EMOJI = GridUtil.SELECT_MAX_EMOJI;
	public int latestContentId = -1;
	public CUser m_cUser = new CUser();
	public CContent m_cContent = new CContent();
	public boolean m_bOwner = false;
	public boolean m_bRequestClient = false;
	public boolean m_bFollow = false;
	public boolean m_bBlocking = false;
	public boolean m_bBlocked = false;
	public int m_nContentsNumTotal = 0;
	public Integer m_nNewContentId = null;
	public boolean m_bCheerNg = true;
	private boolean m_bIsBot = false;

	public boolean getResults(CheckLogin checkLogin) {
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		int idx = 1;

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			// owner
			m_bOwner = (ownerUserId == checkLogin.m_nUserId);
			Pin pin = null;
			if (m_bOwner) {
				List<Pin> pins;
				pins = Pin.selectByUserId(checkLogin.m_nUserId);
				if (!pins.isEmpty()) {
					pin = pins.get(0);
				}
			}

			// max(content_id)としていないのは、
			// 特定のuser_idでは、非常に遅い最適化がされてしまうため。
			latestContentId = -1;
			sql = "SELECT content_id FROM contents_0000 WHERE user_id=?"
					+ (!m_bOwner ? " AND open_id<>2" : "");
			statement = connection.prepareStatement(sql);
			statement.setInt(1, ownerUserId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				if (resultSet.getInt(1) > latestContentId) {
					latestContentId = resultSet.getInt(1);
				}
			}

			if (contentId <= 0) contentId = latestContentId;

			if (!m_bOwner) {
				Request poipikuRequest = new Request();
				poipikuRequest.selectByContentId(contentId, connection);
				m_bRequestClient = (poipikuRequest.clientUserId == checkLogin.m_nUserId);
			}

			// content main
			final String strOpenCnd = (!m_bOwner && !m_bRequestClient)?" AND open_id<>2":"";

			sql = "SELECT c.*, r.id request_id FROM contents_0000 c" +
					 " LEFT JOIN requests r ON r.content_id=c.content_id " +
					 " WHERE c.user_id=? AND c.content_id=? " + strOpenCnd;

			statement = connection.prepareStatement(sql);
			idx = 1;
			statement.setInt(idx++, ownerUserId);
			statement.setInt(idx++, contentId);
			resultSet = statement.executeQuery();
			boolean bContentExist = false;
			if(resultSet.next()) {
				m_cContent = new CContent(resultSet);
				final int requestId = resultSet.getInt("request_id");
				if (requestId > 0) m_cContent.m_nRequestId = requestId;
				if (pin != null && m_cContent.m_nContentId == pin.contentId) m_cContent.pinOrder = pin.dispOrder;
				bRtn = true;	// 以下エラーが有ってもOK.表示は行う
				bContentExist = true;
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			if(!bContentExist){
				m_nNewContentId = searchContentIdHistory(connection, contentId);
				return false;
			}

			// author profile
			sql = "SELECT * FROM users_0000 WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			idx = 1;
			statement.setInt(idx++, ownerUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				m_cUser.m_nUserId			= resultSet.getInt("user_id");
				m_cUser.m_strNickName		= Util.toString(resultSet.getString("nickname"));
				m_cUser.m_strProfile		= Util.toString(resultSet.getString("profile"));
				m_cUser.m_strFileName		= Util.toString(resultSet.getString("file_name"));
				m_cUser.m_strHeaderFileName	= Util.toString(resultSet.getString("header_file_name"));
				m_cUser.m_strBgFileName		= Util.toString(resultSet.getString("bg_file_name"));
				m_cUser.m_nReaction			= resultSet.getInt("ng_reaction");
				m_cUser.m_nPassportId	= resultSet.getInt("passport_id");
				m_cUser.m_nAdMode		= resultSet.getInt("ng_ad_mode");
				if(m_cUser.m_strFileName.isEmpty()) m_cUser.m_strFileName="/img/default_user.jpg";
				m_cContent.m_cUser.m_strNickName	= m_cUser.m_strNickName;
				m_cContent.m_cUser.m_strFileName	= m_cUser.m_strFileName;
				m_cContent.m_cUser.m_nReaction		= m_cUser.m_nReaction;
				m_cUser.setRequestEnabled(resultSet);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if(m_cUser.m_strHeaderFileName.isEmpty()) {
				sql = "SELECT file_name FROM contents_0000 WHERE publish_id=0 AND open_id<>2 AND safe_filter=0 AND user_id=? ORDER BY content_id DESC LIMIT 1";
				statement = connection.prepareStatement(sql);
				idx = 1;
				statement.setInt(idx++, ownerUserId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					m_cUser.m_strHeaderFileName	= Util.toString(resultSet.getString("file_name")) + "_640.jpg";
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			} else {
				m_cUser.m_strHeaderFileName += "_640.jpg";
			}

			if(checkLogin.m_bLogin &&  !m_bOwner) {
				// blocking
				sql = "SELECT 1 FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, checkLogin.m_nUserId);
				statement.setInt(2, ownerUserId);
				resultSet = statement.executeQuery();
				m_bBlocking = resultSet.next();
				resultSet.close();resultSet=null;
				statement.close();statement=null;

				// blocked
				sql = "SELECT 1 FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
				statement = connection.prepareStatement(sql);
				idx = 1;
				statement.setInt(1, ownerUserId);
				statement.setInt(2, checkLogin.m_nUserId);
				resultSet = statement.executeQuery();
				m_bBlocked = resultSet.next();
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			// User contents total number
			sql = "SELECT COUNT(*) FROM contents_0000 WHERE user_id=? " + strOpenCnd;
			statement = connection.prepareStatement(sql);
			statement.setInt(1, ownerUserId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				m_nContentsNumTotal = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if(m_bBlocking || m_bBlocked) {
				return false;
			}

			// follow
			int m_nFollow = CUser.FOLLOW_HIDE;
			if(ownerUserId != checkLogin.m_nUserId) {
				sql = "SELECT 1 FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
				statement = connection.prepareStatement(sql);
				idx = 1;
				statement.setInt(idx++, checkLogin.m_nUserId);
				statement.setInt(idx++, ownerUserId);
				resultSet = statement.executeQuery();
				m_bFollow = resultSet.next();
				m_nFollow = (m_bFollow)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				if(m_bFollow) {
					checkLogin.m_nSafeFilter = Math.max(checkLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			} else {	// owner
				checkLogin.m_nSafeFilter = Math.max(checkLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
			}
			m_cContent.m_cUser.m_nFollowing = m_nFollow;

			// Emoji
			if(m_cUser.m_nReaction==CUser.REACTION_SHOW) {
				m_cContent.m_strCommentsListsCache = GridUtil.getComment(connection, m_cContent);
			}

			// Bookmark
			if(checkLogin.m_bLogin) {
				sql = "SELECT 1 FROM bookmarks_0000 WHERE user_id=? AND content_id=?";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, checkLogin.m_nUserId);
				statement.setInt(2, m_cContent.m_nContentId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_cContent.m_nBookmarkState = CContent.BOOKMARK_BOOKMARKING;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			if(!m_bIsBot) {
				// Owner Contents
				if(selectMaxGallery >0) {
					m_vContentList = RelatedContents.getUserContentList(ownerUserId, selectMaxGallery, checkLogin, connection);
				}

				final int h = LocalDateTime.now().getHour();
				if (h != 23 && h != 0 && h != 1) {
					// Related Contents
					if (selectMaxRelatedGallery > 0) {
						m_vRelatedContentList = RelatedContents.getGenreContentList(m_cContent.m_nContentId, selectMaxRelatedGallery, checkLogin, connection);
					}
				}

				if (h != 21 && h != 22 && h != 23 && h != 0 && h != 1){
					// Recommended Contents
					if(selectMaxRecommendedGallery >0) {
						m_vRecommendedList = RecommendedContents.getContents(m_cContent.m_nUserId, m_cContent.m_nContentId, selectMaxRecommendedGallery, checkLogin, connection);
					}
				}
			}

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

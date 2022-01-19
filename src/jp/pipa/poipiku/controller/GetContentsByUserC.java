package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class GetContentsByUserC {
	public int startId = -1;
	public int mode = CCnv.MODE_PC;
	public int viewMode = CCnv.VIEW_LIST;
	public int lastContentId = -1;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			startId = Util.toInt(cRequest.getParameter("SD"));
			mode = Util.toInt(cRequest.getParameter("MD"));
		} catch(Exception e) {
			startId = -1;
		}
	}


	public int selectMaxGallery = 10;
	public boolean isOwner = false;
	public final int SELECT_MAX_RELATED_GALLERY = 9;
	public final int SELECT_MAX_RECOMMENDED_GALLERY = 9;

	public ArrayList<CContent> contentList = new ArrayList<>();
	public ArrayList<CContent> relatedContentList = new ArrayList<>();
	public ArrayList<CContent> recommendedContentList = new ArrayList<>();

	public boolean getResults(CheckLogin checkLogin, boolean needRelatedContents, boolean needRecommendedContents) {
		int ownerUserId = -1;
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";


		try {
			connection = DatabaseUtil.dataSource.getConnection();

			sql = "SELECT user_id FROM contents_0000 WHERE content_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, startId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				ownerUserId = resultSet.getInt(1);
			} else {
				Log.d("record not found");
				return false;
			}

			// owner
			isOwner = (checkLogin.m_bLogin && ownerUserId == checkLogin.m_nUserId);
			Pin pin = null;
			if (isOwner) {
				List<Pin> pins;
				pins = Pin.selectByUserId(checkLogin.m_nUserId);
				if (!pins.isEmpty()) {
					pin = pins.get(0);
				}
			}

			if (!checkLogin.m_bLogin || !isOwner) {
				// blocking
				sql = "SELECT 1 FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, checkLogin.m_nUserId);
				statement.setInt(2, ownerUserId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					Log.d("blocking user");
					return false;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;

				// blocked
				sql = "SELECT 1 FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, ownerUserId);
				statement.setInt(2, checkLogin.m_nUserId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					Log.d("blocked user");
					return false;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			// follow
			int followCode = CUser.FOLLOW_HIDE;
			if(!isOwner) {
				sql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, checkLogin.m_nUserId);
				statement.setInt(2, ownerUserId);
				resultSet = statement.executeQuery();
				boolean bFollow = resultSet.next();
				followCode = (bFollow)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				if(bFollow) {
					checkLogin.m_nSafeFilter = Math.max(checkLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			} else {	// owner
				checkLogin.m_nSafeFilter = Math.max(checkLogin.m_nSafeFilter, Common.SAFE_FILTER_R18);
			}

			// author profile
			CacheUsers0000.User owner = CacheUsers0000.getInstance().getUser(ownerUserId);
			if (owner == null) return false;

			// NEW ARRIVAL
			sql = "SELECT * FROM contents_0000 WHERE user_id=? AND content_id<? AND safe_filter<=?" +
					(!isOwner ? " AND open_id<>2" : "") +
					" ORDER BY content_id DESC LIMIT ?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, ownerUserId);
			statement.setInt(2, startId);
			statement.setInt(3, checkLogin.m_nSafeFilter);
			statement.setInt(4, selectMaxGallery);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent c = new CContent(resultSet);
				c.m_cUser.m_strNickName	= owner.nickName;
				c.m_cUser.m_strFileName	= owner.fileName;
				c.m_cUser.m_nFollowing	= followCode;
				c.m_cUser.m_nReaction	= owner.reaction;
				if (pin != null && pin.contentId == c.m_nContentId) c.pinOrder = pin.dispOrder;
				lastContentId = c.m_nContentId;
				contentList.add(c);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Each Comment
			if(owner.reaction==CUser.REACTION_SHOW) {
				GridUtil.getEachComment(connection, contentList);
			}

			// Bookmark
			GridUtil.getEachBookmark(connection, contentList, checkLogin);

			// Related Contents
			if(needRelatedContents) {
				relatedContentList = RelatedContents.getGenreContentList(startId, SELECT_MAX_RELATED_GALLERY, checkLogin, connection);
			}

			final int h = LocalDateTime.now().getHour();
			if (needRecommendedContents && h != 22 && h != 23 && h != 0){
				// Recommended Contents
				recommendedContentList = RecommendedContents.getContents(ownerUserId, startId, SELECT_MAX_RECOMMENDED_GALLERY, checkLogin, connection);
			}

		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return bRtn;
	}
}

package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

public class MyIllustListC extends IllustListC {

	public static class SwitchUser {
		public CUser user;
		public boolean signInIt;
		public SwitchUser(CUser _user, boolean _signInIt) {
			user = _user;
			signInIt = _signInIt;
		}
	}
	public List<SwitchUser> switchUsers = new ArrayList<>();

	public List<UserWave> myWaves = null;

	public static class ReplyWave {
		public UserWave wave;
		public int replyUserId;
		public String replyUserNickname = "";
		public String replyUserProfImgUrl = "";
		public ReplyWave(UserWave _wave, int _replyUserId, String _replyUserNickname, String profImgPath) {
			wave = _wave;
			replyUserId = _replyUserId;
			replyUserNickname = _replyUserNickname;
			replyUserProfImgUrl = Common.GetUrl(profImgPath);
		}

	}
	public List<ReplyWave> replyWaves = null;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			super.getParam(cRequest);
			final String tz = Util.getCookie(cRequest, Common.CLIENT_TIMEZONE_OFFSET);
			if (tz != null && !tz.isEmpty()) {
				clientTimezoneOffset = Float.parseFloat(tz);
			}
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	private SwitchUser getLinkedUser(int userId, final CheckLogin checkLogin) {
		if (userId<1 || checkLogin==null) return null;

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		SwitchUser switchUser = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "SELECT * FROM users_0000 WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				CUser user = new CUser(resultSet);
				switchUser = new SwitchUser(
						user,
						userId == checkLogin.m_nUserId
				);
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}

		return switchUser;
	}


	public boolean getResults(CheckLogin checkLogin){
		if (!super.getResults(checkLogin)) {
			return false;
		}

		UserGroup userGroup = new UserGroup(checkLogin.m_nUserId);
		SwitchUser switchUser;
		switchUser = getLinkedUser(userGroup.userId1, checkLogin);
		if (switchUser != null) switchUsers.add(switchUser);

		switchUser = getLinkedUser(userGroup.userId2, checkLogin);
		if (switchUser != null) switchUsers.add(switchUser);

		switchUser = getLinkedUser(userGroup.userId3, checkLogin);
		if (switchUser != null) switchUsers.add(switchUser);

		if (switchUsers.isEmpty()) {
			switchUser = new SwitchUser(m_cUser, true);
			switchUsers.add(switchUser);
		}

		UserWaveTemplate waveTemplate = UserWaveTemplate.select(checkLogin.m_nUserId, UserWaveTemplate.DISABLE_WAVE_ORDER);
		if (waveTemplate != null && !waveTemplate.isEnabled()) {
			myWaves = new LinkedList<>();
		} else {
			myWaves = UserWave.selectByToUserId(checkLogin.m_nUserId, 0, 30);
			Collections.reverse(myWaves);

			replyWaves = new LinkedList<>();
			final String strSql = """
                SELECT w.*, u.user_id, u.nickname, u.file_name FROM user_waves w
                INNER JOIN users_0000 u ON w.to_user_id = u.user_id
                WHERE from_user_id=? AND reply_message <> '' ORDER BY reply_at DESC OFFSET ? LIMIT ?
                """;
			try (
					Connection connection = DatabaseUtil.dataSource.getConnection();
					PreparedStatement statement = connection.prepareStatement(strSql);
			) {
				statement.setInt(1, checkLogin.m_nUserId);
				statement.setInt(2, 0);
				statement.setInt(3, 30);
				ResultSet resultSet = statement.executeQuery();
				while (resultSet.next()) {
					replyWaves.add(new ReplyWave(
							new UserWave(resultSet),
							resultSet.getInt("user_id"),
							resultSet.getString("nickname"),
							resultSet.getString("file_name")
					));
				}
				Collections.reverse(replyWaves);
				resultSet.close();
			} catch(Exception e) {
				Log.d(strSql);
				e.printStackTrace();
			}
		}

		return true;
	}
}

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
			myWaves = UserWave.selectByToUserId(checkLogin.m_nUserId, 0, 60);
			Collections.reverse(myWaves);
		}

		return true;
	}
}

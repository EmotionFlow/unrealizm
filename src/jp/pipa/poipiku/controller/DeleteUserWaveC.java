package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public final class DeleteUserWaveC extends Controller{
	public int waveId = -1;
	public int userId = -1;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			waveId = Util.toInt(cRequest.getParameter("WID"));
			userId = Util.toInt(cRequest.getParameter("UID"));
		} catch(Exception e) {
			waveId = -1;
			userId = -1;
		}
	}

	public boolean getResults(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin || checkLogin.m_nUserId != userId || waveId < 0) return false;

		return UserWave.delete(waveId, userId);
	}
}

package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class SendUserWaveReplyC {
	public String replyMessage = "";
	public int waveId = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			replyMessage = Util.toString(request.getParameter("MSG")).trim();
			if (replyMessage.length() > 550) replyMessage = replyMessage.substring(0, 550);
			waveId = Util.toInt(request.getParameter("ID"));
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public String resultMessage = "";
	public boolean getResults(final CheckLogin checkLogin, final ResourceBundleControl _TEX) {
		resultMessage = _TEX.T("IllustV.Wave.SendNG");
		if (waveId < 0) {
			return false;
		}

		UserWave userWave = UserWave.selectById(waveId);
		if (userWave == null || userWave.toUserId != checkLogin.m_nUserId) {
			return false;
		}

		return userWave.updateReply(replyMessage);
	}
}

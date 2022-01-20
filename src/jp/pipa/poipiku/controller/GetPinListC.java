package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Pin;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;

public class GetPinListC {
	public int userId = -1;
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("UID"));
		} catch(Exception e) {
			userId = -1;
		}
	}

	public List<Pin> pins;
	public boolean getResults(CheckLogin checkLogin) {
		if (checkLogin.m_nUserId != userId) return false;
		pins = Pin.selectByUserId(userId);
		return true;
	}
}
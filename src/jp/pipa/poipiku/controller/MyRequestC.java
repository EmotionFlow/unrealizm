package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class MyRequestC {
	public String menuId = "";
	public int statusCode = -1;
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			menuId = Common.TrimAll(Util.toStringHtml(Common.EscapeInjection(Util.toString(request.getParameter("MENUID")))));
			statusCode = Util.toIntN(request.getParameter("ST"), -1, 3);
		} catch(Exception e) {
			;
		}
	}


	public String message = "";
	public boolean getResults() {
		return true;
	}
}

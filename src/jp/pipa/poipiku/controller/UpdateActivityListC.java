package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.Request;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class UpdateActivityListC extends Controller{
	private int userId = -1;
	private int contentId = -1;
	private int infoType = Common.NOTIFICATION_TYPE_REACTION;
	private int requestId = -1;
	public String toUrl = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			infoType = Util.toInt(request.getParameter("TY"));
			userId = Util.toInt(request.getParameter("ID"));
			contentId = Util.toInt(request.getParameter("TD"));
			requestId = Util.toInt(request.getParameter("RID"));
		} catch(Exception e) {
			userId = -1;
		}
	}

	public boolean getResults(CheckLogin checkLogin) {
		if(!checkLogin.m_bLogin || (checkLogin.m_nUserId!= userId)) return false;

		String sql = "";
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "UPDATE info_lists "
					+ "SET had_read=true, badge_num=0 "
					+ "WHERE user_id=? "
					+ "AND content_id=? "
					+ "AND info_type=? "
					+ "AND request_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt(2, contentId);
			statement.setInt(3, infoType);
			statement.setInt(4, requestId);
			statement.executeUpdate();
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.Unknown;
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}

		switch (infoType) {
			case Common.NOTIFICATION_TYPE_REACTION:
				toUrl = String.format("/%d/%d.html", userId, contentId);
				break;
			case Common.NOTIFICATION_TYPE_REQUEST:
				String menuId = "";
				Request poipikuRequest = new Request(requestId);
				switch (poipikuRequest.status) {
					case WaitingApproval:
						menuId = "RECEIVED";
						break;
					case InProgress:
					case Done:
						menuId = "SENT";
						break;
					case Canceled:
						if (poipikuRequest.creatorUserId == checkLogin.m_nUserId) {
							menuId = "RECEIVED";
						} else {
							menuId = "SENT";
						}
						break;
					default:
						menuId = "RECEIVED";
						break;
				}
				toUrl = String.format("/MyRequestListPcV.jsp?MENUID=%s&ST=%d", menuId, poipikuRequest.status.getCode());
				break;
			default:
				errorKind = ErrorKind.Unknown;
				return false;
		}
		errorKind = ErrorKind.None;
		return true;
	}
}

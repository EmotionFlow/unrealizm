package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class GetIllustFileListC {
	public int userId = -1;
	public int contentId = 0;
	public int getParam(HttpServletRequest request) {
		int nRtn = -1;
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("ID"));
			contentId = Util.toInt(request.getParameter("TD"));
			nRtn = 0;
		} catch(Exception e) {
			e.printStackTrace();
			userId = -1;
			nRtn = -99;
		}
		return nRtn;
	}

	public CContent content = new CContent();
	public ArrayList<Object> contentList = new ArrayList<>();

	public int getResults(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin || checkLogin.m_nUserId != userId) {
			return -1;
		}

		int nRtn = -1;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			// append_id,ファイル名を取得
			sql = "(SELECT 0 as append_id, file_name, file_size FROM contents_0000 WHERE user_id=? AND content_id=?) UNION (SELECT append_id, file_name, file_size FROM contents_appends_0000 WHERE content_id=?) ORDER BY append_id";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt(2, contentId);
			statement.setInt(3, contentId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				Map<String, Object> image = new HashMap<String, Object>();
				image.put("append_id", resultSet.getString("append_id"));
				image.put("name", resultSet.getString("file_name"));
				image.put("thumbnailUrl", Common.GetPoipikuUrl(resultSet.getString("file_name")) + "_360.jpg");
				image.put("uuid", UUID.randomUUID().toString());
				image.put("size", resultSet.getInt("file_size"));
				contentList.add(image);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			nRtn = contentId;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return nRtn;
	}
}

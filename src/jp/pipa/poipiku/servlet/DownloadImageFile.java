package jp.pipa.poipiku.servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Objects;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

/**
 * Servlet implementation class DownloadImageFile
 */
//@WebServlet("/DownloadImageFile")
//@WebServlet(urlPatterns = { "/DownloadImageFile" })
@WebServlet(name="DownloadImageFile",urlPatterns={"/DownloadImageFile"})
public final class DownloadImageFile extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public DownloadImageFile() {
		super();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		CheckLogin checkLogin = new CheckLogin(request, response);
		if(!checkLogin.m_bLogin) return;

		CDownloadImageFile results = new CDownloadImageFile();

		if(!results.getParam(request)) return;
		if(!results.getResults(checkLogin)) return;

		String file_name_full = getServletContext().getRealPath(results.fileName);
		File file = new File(file_name_full);
		if(!file.exists()) return;
		String ext = ImageUtil.getExt(file_name_full);
		switch (ext) {
			case "gif" -> response.setContentType("image/gif");
			case "jpeg" -> response.setContentType("image/jpeg");
			case "png" -> response.setContentType("image/png");
			default -> {
				response.setContentType("application/octet-stream");
				response.setHeader("Content-Transfer-Encoding", "binary");
			}
		}
		response.setHeader("Content-Disposition", String.format("attachment;filename=\"%s\"", Util.changeExtension(file.getName(), ext)));
		//response.setStatus(HttpServletResponse.SC_OK);

		OutputStream outStream = null;
		InputStream inStream = null;
		try {
			outStream = response.getOutputStream();
			inStream = new FileInputStream(file);
			IOUtils.copy(inStream, response.getOutputStream());
			outStream.flush();
		} catch (Exception ignored) {
			;
		} finally {
			Objects.requireNonNull(inStream).close();
			Objects.requireNonNull(outStream).close();
		}
	}

	static class CDownloadImageFile {
		public int contentId = 0;
		public int appendId = 0;
		public boolean getParam(HttpServletRequest request) {
			boolean bRtn = false;
			try {
				request.setCharacterEncoding("UTF-8");
				contentId = Util.toInt(request.getParameter("TD"));
				bRtn = true;
				appendId = Util.toInt(request.getParameter("AD"));
			}
			catch(Exception ignored) {
				;
			}
			return bRtn;
		}

		public String fileName = "";
		public boolean getResults(CheckLogin checkLogin) {
			if (contentId < 0) return false;

			boolean result = false;
			Connection connection = null;
			PreparedStatement statement = null;
			ResultSet resultSet = null;
			String sql = "";

			try {
				boolean isOwner = false;
				boolean isRequestClient = false;
				boolean okDownloadOthers = false;
				int publishId = -1;
				int openId = -1;

				connection = DatabaseUtil.dataSource.getConnection();

				// content main
				sql = """
						SELECT c.*, u.ng_download, r.id request_id, r.client_user_id
						FROM contents_0000 c
							INNER JOIN users_0000 u ON u.user_id = c.user_id
							LEFT JOIN requests r ON c.content_id = r.content_id
						WHERE c.content_id = ?
						""";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, contentId);
				resultSet = statement.executeQuery();

				CContent content = null;
				if(resultSet.next()) {
					content = new CContent(resultSet);
					isOwner = checkLogin.m_nUserId == resultSet.getInt("user_id");
					isRequestClient = resultSet.getInt("request_id") > 0 && checkLogin.m_nUserId == resultSet.getInt("client_user_id");
					okDownloadOthers = resultSet.getInt("ng_download") == 1;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;

//				Log.d(String.format("isOwner: %b, isRequestClient: %b, okDownloadOthers: %b", isOwner, isRequestClient, okDownloadOthers));

				if (!(isOwner || isRequestClient)){
					if (!okDownloadOthers) {
						return false;
					} else {
						if (!content.nowAvailable()) return false;
					}
				}

//				Log.d(content.m_strFileName);

				// 存在確認
				if(content.m_strFileName == null || content.m_strFileName.isEmpty()) return false;

				fileName = content.m_strFileName;

				if(appendId>0) {
					fileName = "";
					sql = "SELECT file_name FROM contents_appends_0000 WHERE content_id=? AND append_id=?";
					statement = connection.prepareStatement(sql);
					statement.setInt(1, contentId);
					statement.setInt(2, appendId);
					resultSet = statement.executeQuery();
					if(resultSet.next()) {
						String file_name = Util.toString(resultSet.getString("file_name"));
						if(!file_name.isEmpty()) {
							fileName = file_name;
						}
					}
					resultSet.close();resultSet=null;
					statement.close();statement=null;
					// 存在確認
					if(fileName.isEmpty()) return false;
				}
				result = true;
			} catch(Exception e) {
				Log.d(sql);
				e.printStackTrace();
			} finally {
				try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
				try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
				try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
			}
			return result;
		}
	}
}

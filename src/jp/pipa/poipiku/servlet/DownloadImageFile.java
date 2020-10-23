package jp.pipa.poipiku.servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.apache.commons.io.IOUtils;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

/**
 * Servlet implementation class DownloadImageFile
 */
//@WebServlet("/DownloadImageFile")
//@WebServlet(urlPatterns = { "/DownloadImageFile" })
@WebServlet(name="DownloadImageFile",urlPatterns={"/DownloadImageFile"})
public class DownloadImageFile extends HttpServlet {
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
		CheckLogin cCheckLogin = new CheckLogin(request, response);
		if(!cCheckLogin.m_bLogin) return;

		CDownloadImageFile cResults = new CDownloadImageFile();

		if(!cResults.getParam(request)) return;
		if(!cResults.getResults(cCheckLogin)) return;

		String file_name_full = getServletContext().getRealPath(cResults.m_strFileName);
		File file = new File(file_name_full);
		if(!file.exists()) return;
		String ext = ImageUtil.getExt(file_name_full);
		switch (ext) {
		case "gif":
			response.setContentType("image/gif");
			break;
		case "jpeg":
			response.setContentType("image/jpeg");
			break;
		case "png":
			response.setContentType("image/png");
			break;
		default:
			response.setContentType("application/octet-stream");
			response.setHeader("Content-Transfer-Encoding", "binary");
			break;
		}
		response.setHeader("Content-Disposition", String.format("attachment;filename=\"%s\"", Util.changeExtension(file.getName(), ext)));
		//response.setStatus(HttpServletResponse.SC_OK);

		try {
			OutputStream outStream = response.getOutputStream();
			InputStream inStream = new FileInputStream(file);
			IOUtils.copy(inStream, response.getOutputStream());
			outStream.flush();
			inStream.close();
			outStream.close();
		} catch (Exception e) {
			;
		}
	}

	class CDownloadImageFile {
		public int m_nContentId = 0;
		public int m_nAppendId = 0;
		public boolean getParam(HttpServletRequest request) {
			boolean bRtn = false;
			try {
				request.setCharacterEncoding("UTF-8");
				m_nContentId	= Util.toInt(request.getParameter("TD"));
				bRtn = true;
				m_nAppendId		= Util.toInt(request.getParameter("AD"));
			}
			catch(Exception e) {
				;
			}
			return bRtn;
		}

		public String m_strFileName = "";
		public boolean getResults(CheckLogin cCheckLogin) {
			boolean bResult = false;
			DataSource dsPostgres = null;
			Connection cConn = null;
			PreparedStatement cState = null;
			ResultSet cResSet = null;
			String strSql = "";

			try {
				dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
				cConn = dsPostgres.getConnection();

				// content main
				strSql = "SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cCheckLogin.m_nUserId);
				cState.setInt(2, m_nContentId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					String file_name = Util.toString(cResSet.getString("file_name"));
					if(!file_name.isEmpty()) {
						m_strFileName = file_name;
					}
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
				// 存在確認
				if(m_strFileName.isEmpty()) return false;

				if(m_nAppendId>0) {
					m_strFileName = "";
					strSql = "SELECT * FROM contents_appends_0000 WHERE content_id=? AND append_id=?";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, m_nContentId);
					cState.setInt(2, m_nAppendId);
					cResSet = cState.executeQuery();
					if(cResSet.next()) {
						String file_name = Util.toString(cResSet.getString("file_name"));
						if(!file_name.isEmpty()) {
							m_strFileName = file_name;
						}
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;
					// 存在確認
					if(m_strFileName.isEmpty()) return false;
				}
				bResult = true;
			} catch(Exception e) {
				Log.d(strSql);
				e.printStackTrace();
			} finally {
				try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
				try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
				try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
			}
			return bResult;
		}
	}
}

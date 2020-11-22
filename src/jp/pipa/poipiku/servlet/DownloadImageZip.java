package jp.pipa.poipiku.servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

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
@WebServlet(name="DownloadImageZip",urlPatterns={"/DownloadImageZip"})
public class DownloadImageZip extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public DownloadImageZip() {
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

		CDownloadImageFile cResults = new CDownloadImageFile();

		if(!cResults.getParam(request)) return;
		if(!cResults.getResults(checkLogin)) return;

		response.setContentType("application/zip");
		response.setHeader("Content-Disposition", String.format("attachment;filename=\"%d.zip\"", cResults.m_nContentId));
		response.setHeader("Content-Transfer-Encoding", "binary");

		OutputStream outStream = response.getOutputStream();
		ZipOutputStream zipOutStream = new ZipOutputStream(outStream);
		for(String file_name : cResults.m_vContentList) {
			try {
				String ext = ImageUtil.getExt(getServletContext().getRealPath(file_name));
				File file = new File(getServletContext().getRealPath(file_name));
				FileInputStream in = new FileInputStream(file);
				zipOutStream.putNextEntry(new ZipEntry(changeExtension(file.getName(), ext)));
				IOUtils.copy(in, zipOutStream);
				in.close();
				zipOutStream.closeEntry();
			} catch (Exception e) {
				;
			}
		}
		zipOutStream.close();
		outStream.flush();
		outStream.close();
	}

	private static String changeExtension(String inputData, String extention) {
		String returnVal = null;

		if (inputData == null || extention == null || inputData.isEmpty() || extention.isEmpty()) return "";

		File in = new File(inputData);
		String fileName = in.getName();

		if (fileName.lastIndexOf(".") < 0) {
			returnVal = inputData + "." + extention;
		} else {
			int postionOfFullPath = inputData.lastIndexOf("."); // フルパスの
			String pathWithoutExt = inputData.substring(0, postionOfFullPath);
			returnVal = pathWithoutExt + "." + extention;
		}
		return returnVal;
	}

	class CDownloadImageFile {
		public int m_nContentId = 0;
		public boolean getParam(HttpServletRequest request) {
			boolean bRtn = false;
			try {
				request.setCharacterEncoding("UTF-8");
				m_nContentId	= Util.toInt(request.getParameter("TD"));
				bRtn = true;
			}
			catch(Exception e) {
				;
			}
			return bRtn;
		}

		public ArrayList<String> m_vContentList = new ArrayList<String>();
		public boolean getResults(CheckLogin checkLogin) {
			boolean bResult = false;
			DataSource dsPostgres = null;
			Connection cConn = null;
			PreparedStatement cState = null;
			ResultSet cResSet = null;
			String strSql = "";

			try {
				dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
				cConn = dsPostgres.getConnection();

				// 1つ目のファイル取得
				strSql ="SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, checkLogin.m_nUserId);
				cState.setInt(2, m_nContentId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					String file_name = Util.toString(cResSet.getString("file_name"));
					if(!file_name.isEmpty()) {
						m_vContentList.add(file_name);
					}
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				// 存在確認
				if(m_vContentList.isEmpty()) return false;

				// append image
				strSql = "SELECT * FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id ASC LIMIT 1000";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nContentId);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					String file_name = Util.toString(cResSet.getString("file_name"));
					if(!file_name.isEmpty()) {
						m_vContentList.add(file_name);
					}
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

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

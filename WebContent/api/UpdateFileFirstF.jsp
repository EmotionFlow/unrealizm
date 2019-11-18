<%@page import="org.apache.commons.lang3.RandomStringUtils"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.nio.file.Files"%>
<%@page import="java.io.IOException"%>
<%@page import="javax.imageio.ImageIO"%>
<%@page import="org.apache.commons.fileupload.*"%>
<%@page import="org.apache.commons.fileupload.disk.*"%>
<%@page import="org.apache.commons.fileupload.servlet.*"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.JsonMappingException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UpdateFileFirstCParam {

	public int m_nUserId = -1;
	public int m_nContentId = 0;
	public int m_nOpenId = 0;
	public int m_nFileIndex = 0;
	public int m_nTotalFileNum = 0;
	public String m_strFilename = "";
	FileItem item_file = null;

	public int GetParam(HttpServletRequest request) {
		int nRtn = -1;
		try {
			String strRelativePath = Common.GetUploadPath();
			String strRealPath = getServletContext().getRealPath(strRelativePath);
			DiskFileItemFactory factory = new DiskFileItemFactory();
			factory.setSizeThreshold(40*1024*1024);	// 送信サイズの最大を変えた時は tomcatのmaxPostSizeとnginxのclient_max_body_size、client_body_buffer_sizeも変更すること
			factory.setRepository(new File(strRealPath));
			ServletFileUpload upload = new ServletFileUpload(factory);
			upload.setSizeMax(40*1024*1024);
			upload.setHeaderEncoding("UTF-8");

			List items = upload.parseRequest(request);
			Iterator iter = items.iterator();
			while (iter.hasNext()) {
				FileItem item = (FileItem) iter.next();
				if (item.isFormField()) {
					String strName = item.getFieldName();
					if(strName.equals("UID")) {
						m_nUserId = Common.ToInt(item.getString());
					} else if(strName.equals("IID")) {
						m_nContentId = Common.ToInt(item.getString());
					} else if(strName.equals("REC")) {
						m_nOpenId = Common.ToIntN(item.getString(), 0, 2);
					} else if(strName.equals("NN")) {
						m_nFileIndex = Common.ToInt(item.getString());
					} else if(strName.equals("JIL")) {
						String strJson = item.getString();
						Log.d(strJson);
					}
					item.delete();
				} else {
					item_file = item;
					nRtn = 0;
				}
			}
			//Log.d(Integer.toString(m_nUserId));
			//Log.d(Integer.toString(m_nContentId));
		} catch(FileUploadException e) {
			e.printStackTrace();
			m_nUserId = -1;
			nRtn = -2;
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
			nRtn = -99;
		}
		return nRtn;
	}
}


class UpdateFileFirstC {
	public long m_nFileSize = 0;
	public String m_strFileName = "";

	public int GetResults(UpdateFileFirstCParam cParam, ResourceBundleControl _TEX) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// check ext
			if(cParam.item_file==null) return nRtn;
			String ext = ImageUtil.getExt(ImageIO.createImageInputStream(cParam.item_file.getInputStream()));
			if((!ext.equals("jpeg")) && (!ext.equals("jpg")) && (!ext.equals("gif")) && (!ext.equals("png"))) {
				Log.d("main item type error: " + ext);
				String strFileName = String.format("/error_file/%d_%d.error", cParam.m_nUserId, cParam.m_nContentId);
				String strRealFileName = getServletContext().getRealPath(strFileName);
				cParam.item_file.write(new File(strRealFileName));
				return nRtn;
			}

			// 存在チェック
			String strOldFileName = "";
			strSql ="SELECT file_name FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				strOldFileName = Common.ToString(cResSet.getString("file_name"));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			boolean bReuse = false;
			// 元ファイルが無いので終了
			if(strOldFileName.length() == 0) {
				Log.d("content not exist error : cParam.m_nUserId="+ cParam.m_nUserId + ", cParam.m_nContentId="+cParam.m_nContentId);
				return nRtn;
			// 同じファイルなので終了
			} else if (cParam.m_strFilename.equals(strOldFileName)) {
				Log.d("Same file:" + cParam.m_strFilename);
				return nRtn;
			// 並び替えによって他のファイルを再利用するケース
			} else {
				// 他人のユーザIDフォルダだったらエラー
				String[] strPath = cParam.m_strFilename.split("/", 0);
				if (strPath.length>2 &&  Integer.parseInt(strPath[2])!=cParam.m_nUserId) {
					Log.d("Not file owner:" + cParam.m_strFilename);
					return nRtn;
				}

				// 元のファイルとは異なるが、保存済の場合は再利用する
				File cFile = new File(getServletContext().getRealPath(cParam.m_strFilename));
				if (cFile.exists()) {
					bReuse = true;
					Log.d("Reuse file:" + cParam.m_strFilename);
				}
			}

			// save file
			String strRealFileName = "";
			if (bReuse) {
				m_strFileName = cParam.m_strFilename;
				strRealFileName = getServletContext().getRealPath(m_strFileName);
			} else {
				File cDir = new File(getServletContext().getRealPath(Common.getUploadUserPath(cParam.m_nUserId)));
				if(!cDir.exists()) {
					cDir.mkdirs();
				}
				String strRandom = RandomStringUtils.randomAlphanumeric(9);
				m_strFileName = String.format("%s/%09d_%s.%s", Common.getUploadUserPath(cParam.m_nUserId), cParam.m_nContentId, strRandom, ext);
				strRealFileName = getServletContext().getRealPath(m_strFileName);
				cParam.item_file.write(new File(strRealFileName));
				ImageUtil.createThumbIllust(strRealFileName);
			}

			// ファイルサイズ系情報
			int nWidth = 0;
			int nHeight = 0;
			long nComplexSize = 0;
			try {
				int size[] = ImageUtil.getImageSize(strRealFileName);
				nWidth = size[0];
				nHeight = size[1];
				m_nFileSize = (new File(strRealFileName)).length();
				nComplexSize = ImageUtil.getConplex(strRealFileName);
			} catch(Exception e) {
				nWidth = 0;
				nHeight = 0;
				m_nFileSize = 0;
				nComplexSize=0;
				Log.d("error getImageSize");
			}
			//Log.d(String.format("nWidth=%d, nHeight=%d, nFileSize=%d, nComplexSize=%d", nWidth, nHeight, nFileSize, nComplexSize));

			// update making file_name
			strSql ="UPDATE contents_0000 SET file_name=?, open_id=?, file_width=?, file_height=?, file_size=?, file_complex=?, file_num=1 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, m_strFileName);
			cState.setInt(2, cParam.m_nOpenId);
			cState.setInt(3, nWidth);
			cState.setInt(4, nHeight);
			cState.setLong(5, m_nFileSize);
			cState.setLong(6, nComplexSize);
			cState.setInt(7, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			Log.d(strRealFileName);
			Log.d(cParam.m_nFileIndex + "/" + cParam.m_nTotalFileNum);

			nRtn = cParam.m_nContentId;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
			try{if(cParam.item_file!=null){cParam.item_file.delete();cParam.item_file=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}
%><%
Log.d("UpdateFileFirstC");
CheckLogin cCheckLogin = new CheckLogin(request, response);

int nRtn = 0;
UpdateFileFirstCParam cParam = new UpdateFileFirstCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

//JSON元データを格納する連想配列
Map<String, Object> files = null;
ObjectMapper mapper = null;

if (cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UpdateFileFirstC cResults = new UpdateFileFirstC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%>
{"content_id": <%=cParam.m_nContentId%>}
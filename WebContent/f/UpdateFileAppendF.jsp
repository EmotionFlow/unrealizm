<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="org.apache.commons.lang3.RandomStringUtils"%>
<%@page import="java.nio.file.Files"%>
<%@page import="javax.imageio.ImageIO"%>
<%@page import="org.apache.commons.fileupload.*"%>
<%@page import="org.apache.commons.fileupload.disk.*"%>
<%@page import="org.apache.commons.fileupload.servlet.*"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.JsonMappingException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@include file="/inner/Common.jsp"%>
<%!class UploadFileAppendCParam {

	public int m_nUserId = -1;
	public int m_nContentId = 0;
	FileItem item_file = null;

	public int GetParam(HttpServletRequest request) {
		try {
			String strRelativePath = Common.GetUploadPath();
			String strRealPath = getServletContext().getRealPath(strRelativePath);
			DiskFileItemFactory factory = new DiskFileItemFactory();
			factory.setSizeThreshold(200*1024*1024);	// 送信サイズの最大を変えた時は tomcatのmaxPostSizeとnginxのclient_max_body_size、client_body_buffer_sizeも変更すること
			factory.setRepository(new File(strRealPath));
			ServletFileUpload upload = new ServletFileUpload(factory);
			upload.setSizeMax(200*1024*1024);
			upload.setHeaderEncoding("UTF-8");

			List items = upload.parseRequest(request);
			Iterator iter = items.iterator();
			while (iter.hasNext()) {
				FileItem item = (FileItem) iter.next();
				if (item.isFormField()) {
					String strName = item.getFieldName();
					if(strName.equals("UID")) {
						m_nUserId = Util.toInt(item.getString());
					} else if(strName.equals("IID")) {
						m_nContentId = Util.toInt(item.getString());
					}
					item.delete();
				} else {
					item_file = item;
				}
			}
		} catch(FileUploadException e) {
			e.printStackTrace();
			return -1;
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
			return -99;
		}
		return 0;
	}
}

class UploadFileAppendC {
	public int GetResults(UploadFileAppendCParam cParam, ResourceBundleControl _TEX) {
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
				Log.d("main item type error");
				return Common.UPLOAD_FILE_TYPE_ERROR;
			}

			// get comment id
			int nAppendId = -1;
			strSql ="INSERT INTO contents_appends_0000(content_id) VALUES(?) RETURNING append_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				nAppendId = cResSet.getInt("append_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// save file
			String strFileName = "";
			String strRealFileName = "";
			File cDir = new File(getServletContext().getRealPath(Common.getUploadUserPath(cParam.m_nUserId)));
			if(!cDir.exists()) {
				cDir.mkdirs();
			}

			String strRandom = RandomStringUtils.randomAlphanumeric(9);
			strFileName = String.format("%s/%09d_%09d_%s.%s", Common.getUploadUserPath(cParam.m_nUserId), cParam.m_nContentId, nAppendId, strRandom, ext);
			strRealFileName = getServletContext().getRealPath(strFileName);
			cParam.item_file.write(new File(strRealFileName));
			ImageUtil.createThumbIllust(strRealFileName);

			// ファイルサイズ系情報
			int nWidth = 0;
			int nHeight = 0;
			long nFileSize = 0;
			long nComplexSize = 0;
			try {
				int size[] = ImageUtil.getImageSize(strRealFileName);
				nWidth = size[0];
				nHeight = size[1];
				nFileSize = (new File(strRealFileName)).length();
				nComplexSize = ImageUtil.getConplex(strRealFileName);
			} catch(Exception e) {
				nWidth = 0;
				nHeight = 0;
				nFileSize = 0;
				nComplexSize=0;
				Log.d("error getImageSize");
			}
			//Log.d(String.format("nWidth=%d, nHeight=%d, nFileSize=%d, nComplexSize=%d", nWidth, nHeight, nFileSize, nComplexSize));


			// update file name
			strSql ="UPDATE contents_appends_0000 SET file_name=?, file_width=?, file_height=?, file_size=?, file_complex=? WHERE append_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strFileName);
			cState.setInt(2, nWidth);
			cState.setInt(3, nHeight);
			cState.setLong(4, nFileSize);
			cState.setLong(5, nComplexSize);
			cState.setInt(6, nAppendId);
			cState.executeUpdate();
			cState.close();cState=null;

			// ファイルサイズチェック
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			CacheUsers0000.User user = users.getUser(cParam.m_nUserId);
			// 1枚目
			int fileTotalSize = 0;
			strSql ="SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				fileTotalSize += cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			// 2枚目以降
			strSql ="SELECT SUM(file_size) FROM contents_appends_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				fileTotalSize += cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(nFileSize>Common.UPLOAD_FILE_TOTAL_SIZE[user.passportId]) {
				Util.deleteFile(strRealFileName);
				strSql ="DELETE FROM contents_appends_0000 WHERE append_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, nAppendId);
				cState.executeUpdate();
				cState.close();cState=null;
				return Common.UPLOAD_FILE_TOTAL_ERROR;
			}

			nRtn = nAppendId;
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
}%><%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadFileAppendCParam cParam = new UploadFileAppendCParam();
cParam.m_nUserId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0 ) {
	UploadFileAppendC cResults = new UploadFileAppendC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%>
{"append_id": <%=nRtn%>}
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
<%!class UpdateFileFirstCParam {

	public int m_nUserId = -1;
	public int m_nContentId = 0;
	FileItem item_file = null;

	public int GetParam(HttpServletRequest request) {
		int nRtn = -1;
		try {
			String strRelativePath = Common.GetUploadTemporaryPath();
			String strRealPath = getServletContext().getRealPath(strRelativePath);
			// 送信サイズの最大を変えた時は tomcatのmaxPostSizeとnginxのclient_max_body_size、client_body_buffer_sizeも変更すること
			DiskFileItemFactory factory = new DiskFileItemFactory(40*1024*1024, new File(strRealPath));
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
						m_nUserId = Util.toInt(item.getString());
					} else if(strName.equals("IID")) {
						m_nContentId = Util.toInt(item.getString());
					}
					item.delete();
				} else {
					item_file = item;
					nRtn = 0;
				}
			}
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
				strOldFileName = Util.toString(cResSet.getString("file_name"));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// save file
			File cDir = new File(getServletContext().getRealPath(Common.getUploadContentsPath(cParam.m_nUserId)));
			if(!cDir.exists()) {
				cDir.mkdirs();
			}
			String strRandom = RandomStringUtils.randomAlphanumeric(9);
			String strFileName = String.format("%s/%09d_%s.%s", Common.getUploadContentsPath(cParam.m_nUserId), cParam.m_nContentId, strRandom, ext);
			String strRealFileName = getServletContext().getRealPath(strFileName);
			cParam.item_file.write(new File(strRealFileName));
			ImageUtil.createThumbIllust(strRealFileName);

			//旧ファイル削除
			File cDelete = new File(getServletContext().getRealPath(strOldFileName));
			File cDeleteS = new File(getServletContext().getRealPath(strOldFileName + "_360.jpg"));
			File cDeleteM = new File(getServletContext().getRealPath(strOldFileName + "_640.jpg"));
			if(cDelete.exists()) cDelete.delete();
			if(cDeleteS.exists()) cDeleteS.delete();
			if(cDeleteM.exists()) cDeleteM.delete();

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

			// update making file_name
			strSql ="UPDATE contents_0000 SET file_name=?, file_width=?, file_height=?, file_size=?, file_complex=?, file_num=1 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strFileName);
			cState.setInt(2, nWidth);
			cState.setInt(3, nHeight);
			cState.setLong(4, nFileSize);
			cState.setLong(5, nComplexSize);
			cState.setInt(6, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			//Log.d(cParam.m_nContentId + ": " + strFileName);
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
}%><%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UpdateFileFirstCParam cParam = new UpdateFileFirstCParam();
cParam.m_nUserId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);

//JSON元データを格納する連想配列
Map<String, Object> files = null;
ObjectMapper mapper = null;

if (checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0 ) {
	UpdateFileFirstC cResults = new UpdateFileFirstC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%>
{"content_id":<%=cParam.m_nContentId%>,"success":true,"reset":false}
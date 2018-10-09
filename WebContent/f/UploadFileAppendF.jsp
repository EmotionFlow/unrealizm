<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.nio.file.Files"%>
<%@page import="javax.imageio.ImageIO"%>
<%@page import="org.apache.commons.fileupload.*"%>
<%@page import="org.apache.commons.fileupload.disk.*"%>
<%@page import="org.apache.commons.fileupload.servlet.*"%>
<%@include file="/inner/Common.jsp"%>
<%
class UploadFileAppendCParam {

	public int m_nUserId = -1;
	public int m_nContentId = 0;
	FileItem item_file = null;

	public int GetParam(HttpServletRequest cRequest) {
		try {
			String strRelativePath = Common.GetUploadPath();
			String strRealPath = getServletContext().getRealPath(strRelativePath);
			DiskFileItemFactory factory = new DiskFileItemFactory();
			factory.setSizeThreshold(40*1024*1024);	// 送信サイズの最大を変えた時は tomcatのmaxPostSizeとnginxのclient_max_body_size、client_body_buffer_sizeも変更すること
			factory.setRepository(new File(strRealPath));
			ServletFileUpload upload = new ServletFileUpload(factory);
			upload.setSizeMax(40*1024*1024);
			upload.setHeaderEncoding("UTF-8");

			List items = upload.parseRequest(cRequest);
			Iterator iter = items.iterator();
			while (iter.hasNext()) {
				FileItem item = (FileItem) iter.next();
				if (item.isFormField()) {
					String strName = item.getFieldName();
					if(strName.equals("UID")) {
						m_nUserId = Common.ToInt(item.getString());
					} else if(strName.equals("IID")) {
						m_nContentId = Common.ToInt(item.getString());
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
				return nRtn;
			}

			// 存在チェック
			boolean bExist = false;
			strSql ="SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			bExist = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(!bExist) return nRtn;

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
			File cDir = new File(getServletContext().getRealPath(Common.getUploadUserPath(cParam.m_nUserId)));
			if(!cDir.exists()) {
				cDir.mkdirs();
			}
			String strFileName = String.format("%s/%09d_%09d.jpg", Common.getUploadUserPath(cParam.m_nUserId), cParam.m_nContentId, nAppendId);
			String strRealFileName = getServletContext().getRealPath(strFileName);
			cParam.item_file.write(new File(strRealFileName));
			ImageUtil.createThumbIllust(strRealFileName);
			Log.d(strFileName);

			// ファイルサイズ系情報
			int nWidth = 0;
			int nHeight = 0;
			long nFileSize = 0;
			try {
				int size[] = ImageUtil.getImageSize(strRealFileName);
				nWidth = size[0];
				nHeight = size[1];
				nFileSize = (new File(strRealFileName)).length();
			} catch(IOException e) {
				nWidth = 0;
				nHeight = 0;
				nFileSize = 0;
				Log.d("error getImageSize");
			}
			Log.d(String.format("nWidth=%d, nHeight=%d, nFileSize=%d", nWidth, nHeight, nFileSize));

			// update file name
			strSql ="UPDATE contents_appends_0000 SET file_name=?, file_width=?, file_height=?, file_size=? WHERE append_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strFileName);
			cState.setInt(2, nWidth);
			cState.setInt(3, nHeight);
			cState.setLong(4, nFileSize);
			cState.setInt(5, nAppendId);
			cState.executeUpdate();
			cState.close();cState=null;

			// update comment num
			strSql ="UPDATE contents_0000 SET file_num=file_num+1 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

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
}
%><%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

int nRtn = 0;
UploadFileAppendCParam cParam = new UploadFileAppendCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadFileAppendC cResults = new UploadFileAppendC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%>
{
"append_id":<%=nRtn%>
}
<%@page import="java.awt.image.BufferedImage"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.nio.file.Files"%>
<%@page import="javax.imageio.ImageIO"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UploadFileFirstCParam {

	public int m_nUserId = -1;
	public int m_nContentId = 0;
	public int m_nOpenId = 0;
	String m_strEncodeImg = "";

	public int GetParam(HttpServletRequest request) {
		int nRtn = -1;
		try {
			m_nUserId		= Common.ToInt(request.getParameter("UID"));
			m_nContentId	= Common.ToInt(request.getParameter("IID"));
			m_nOpenId		= Common.ToIntN(request.getParameter("REC"), 0, 2);
			m_strEncodeImg	= Common.ToString(request.getParameter("DATA"));	// 送信サイズの最大を変えた時は tomcatのmaxPostSizeとnginxのclient_max_body_size、client_body_buffer_sizeも変更すること
			nRtn = 0;
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
			nRtn = -99;
		}
		return nRtn;
	}
}


class UploadFileFirstC {
	public int GetResults(UploadFileFirstCParam cParam, ResourceBundleControl _TEX) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";


		try {
			byte[] imageBinary = Base64.decodeBase64(cParam.m_strEncodeImg.getBytes());
			if(imageBinary == null) return nRtn;
			if(imageBinary.length>1024*1024*10) return nRtn;
			BufferedImage cImage = ImageIO.read(new ByteArrayInputStream(imageBinary));
			if(cImage == null) return nRtn;

			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// check ext
			String ext = ImageUtil.getExt(ImageIO.createImageInputStream(new ByteArrayInputStream(imageBinary)));
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
			if(!bExist) {
				Log.d("content not exist error : cParam.m_nUserId="+ cParam.m_nUserId + ", cParam.m_nContentId="+cParam.m_nContentId);
				return nRtn;
			}

			// save file
			File cDir = new File(getServletContext().getRealPath(Common.getUploadUserPath(cParam.m_nUserId)));
			if(!cDir.exists()) {
				cDir.mkdirs();
			}
			String strFileName = String.format("%s/%09d.%s", Common.getUploadUserPath(cParam.m_nUserId), cParam.m_nContentId, ext);
			String strRealFileName = getServletContext().getRealPath(strFileName);
			ImageIO.write(cImage, "png", new File(strRealFileName));
			ImageUtil.createThumbIllust(strRealFileName);
			Log.d(strFileName);

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
			strSql ="UPDATE contents_0000 SET file_name=?, open_id=?, file_width=?, file_height=?, file_size=?, file_complex=?, file_num=1 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strFileName);
			cState.setInt(2, cParam.m_nOpenId);
			cState.setInt(3, nWidth);
			cState.setInt(4, nHeight);
			cState.setLong(5, nFileSize);
			cState.setLong(6, nComplexSize);
			cState.setInt(7, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			nRtn = cParam.m_nContentId;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}
%><%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);
Log.d("UploadPasteFirstF - UserId:"+cCheckLogin.m_nUserId);

int nRtn = 0;
UploadFileFirstCParam cParam = new UploadFileFirstCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadFileFirstC cResults = new UploadFileFirstC();
	nRtn = cResults.GetResults(cParam, _TEX);
	Log.d("UploadPasteFirstF - OK:"+nRtn);
}
%>
{
"content_id":<%=nRtn%>
}
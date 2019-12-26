<%@page import="org.apache.commons.lang3.RandomStringUtils"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.nio.file.Files"%>
<%@page import="javax.imageio.ImageIO"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UploadFileAppendCParam {

	public int m_nUserId = -1;
	public int m_nContentId = 0;
	String m_strEncodeImg = "";

	public int GetParam(HttpServletRequest request) {
		int nRtn = -1;
		try {
			m_nUserId		= Common.ToInt(request.getParameter("UID"));
			m_nContentId		= Common.ToInt(request.getParameter("IID"));
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


class UploadFileAppendC {
	public int GetResults(UploadFileAppendCParam cParam, ResourceBundleControl _TEX) {
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
			String strRandom = RandomStringUtils.randomAlphanumeric(9);
			String strFileName = String.format("%s/%09d_%09d_%s.%s", Common.getUploadUserPath(cParam.m_nUserId), cParam.m_nContentId, nAppendId, strRandom, ext);
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


			nRtn = nAppendId;
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
CheckLogin cCheckLogin = new CheckLogin(request, response);

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
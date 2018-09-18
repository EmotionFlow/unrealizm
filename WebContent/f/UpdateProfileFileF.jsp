<%@page import="javax.imageio.ImageIO"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@include file="/inner/Common.jsp"%>
<%
class UpdateProfileFileCParam {
	public int m_nUserId = -1;
	public String m_strEncodeImg = "";

	public int GetParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId = Common.ToInt(request.getParameter("UID"));
			m_strEncodeImg = Common.TrimAll(Common.CrLfInjection(Common.EscapeInjection(request.getParameter("DATA"))));
		} catch(Exception e) {
			m_nUserId = -1;
			return -99;
		}
		return 0;
	}
}

class UpdateProfileFileC {
	public int GetResults(UpdateProfileFileCParam cParam) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			byte[] imageBinary = Base64.decodeBase64(cParam.m_strEncodeImg.getBytes());
			if(imageBinary == null) return nRtn;
			if(imageBinary.length>1024*1024*5) return nRtn;
			BufferedImage cImage = ImageIO.read(new ByteArrayInputStream(imageBinary));
			if(cImage == null) return nRtn;

			// check ext
			String ext = ImageUtil.getExt(ImageIO.createImageInputStream(new ByteArrayInputStream(imageBinary)));
			if((!ext.equals("jpeg")) && (!ext.equals("jpg")) && (!ext.equals("gif")) && (!ext.equals("png"))) {
				Log.d("main item type error");
				return nRtn;
			}

			// save file
			String strFileName = String.format("%s/profile.jpg", Common.getUploadUserPath(cParam.m_nUserId));
			String strRealFileName = getServletContext().getRealPath(strFileName);
			ImageIO.write(cImage, "png", new File(strRealFileName));
			ImageUtil.createThumbProfile(strRealFileName);
			Log.d(strFileName);

			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// update making last_update
			strSql ="UPDATE users_0000 SET file_name=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strFileName);
			cState.setInt(2, cParam.m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;

			nRtn = 0;
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

int nRtn = 0;
UpdateProfileFileCParam cParam = new UpdateProfileFileCParam();
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UpdateProfileFileC cResults = new UpdateProfileFileC();
	nRtn = cResults.GetResults(cParam);
}
%>{
"result" : <%=nRtn%>
}
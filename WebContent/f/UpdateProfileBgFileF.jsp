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
	public String m_strFileName = "";

	public int GetParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId = Common.ToInt(request.getParameter("UID"));
			String strEncodeImg = Common.TrimAll(Common.CrLfInjection(Common.EscapeInjection(request.getParameter("DATA"))));

			if(strEncodeImg.length() < 1) {
				return -2;
			};
			byte[] imageBinary = Base64.decodeBase64(strEncodeImg.getBytes());
			if(imageBinary.length>1024*1024*2.2){
				return -1;
			}
			BufferedImage cImage = ImageIO.read(new ByteArrayInputStream(imageBinary));
			if(cImage == null) {
				return -2;
			}
			if(cImage.getWidth()<=0) {
				m_nUserId = -1;
			}

			String strRelativePath = Common.GetUploadPath();
			String strRealPath = getServletContext().getRealPath(strRelativePath);
			String strFileName = Long.toString((new java.util.Date()).getTime());
			strFileName += Integer.toString((int)(Math.random()*9999));
			m_strFileName = strRelativePath + "/" + strFileName;
			FileOutputStream fileOutStm = new FileOutputStream(String.format("%s/%s", strRealPath, strFileName));
			fileOutStm.write(imageBinary);
			fileOutStm.flush();
			fileOutStm.close();
		} catch(Exception e) {
			m_nUserId = -1;
			return -99;
		}
		return 0;
	}
}


class UpdateProfileFileC {
	public int GetResults(UpdateProfileFileCParam cParam) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			// check file type
			if(!CImage.checkImage(getServletContext().getRealPath(cParam.m_strFileName))) {
				CImage.DeleteFile(getServletContext().getRealPath(cParam.m_strFileName));
				return -2;
			}

			// save file
			String strFileName = String.format("/user_img01/%09d/bg.jpg", cParam.m_nUserId);
			CImage.saveProfileHeaderImages(getServletContext().getRealPath(cParam.m_strFileName), getServletContext().getRealPath(strFileName));
			CImage.DeleteFile(getServletContext().getRealPath(cParam.m_strFileName));

			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// update making last_update
			strSql ="UPDATE users_0000 SET bg_file_name=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strFileName);
			cState.setInt(2, cParam.m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;

		} catch(Exception e) {
			System.out.println(strSql);
			e.printStackTrace();
			return -99;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return 0;
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
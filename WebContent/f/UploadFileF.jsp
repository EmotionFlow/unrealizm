<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%><%@ page import="javax.sql.*"%><%@ page import="javax.naming.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.nio.file.Files"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%
class UploadFileCParam {

	public int m_nUserId = -1;
	public String m_strFileName = "";
	public String m_strDescription = "";
	public boolean m_bTweet = false;

	public int GetParam(HttpServletRequest cRequest) {
		try {
			String strRelativePath = Common.GetUploadPath();
			String strRealPath = getServletContext().getRealPath(strRelativePath);
			DiskFileItemFactory factory = new DiskFileItemFactory();
			factory.setSizeThreshold(40*1024*1024);
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
					} else if(strName.equals("DES")) {
						m_strDescription = Common.SubStrNum(Common.ToString(item.getString("UTF-8")), 200);
					} else if(strName.equals("TWI")) {
						m_bTweet = (Common.ToInt(item.getString())==1);
					}
				} else {
					String strFileName = Long.toString((new java.util.Date()).getTime());
					strFileName += Integer.toString((int)(Math.random()*9999));
					item.write(new File(strRealPath + "/" + strFileName));
					m_strFileName = strRelativePath + "/" + strFileName;
				}
				item.delete();
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


class UploadFileC {
	public int GetResults(UploadFileCParam cParam) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		int m_nContentId = -99;

		try {
			// check file type
			if(!CImage.checkImage(getServletContext().getRealPath(cParam.m_strFileName))) {
				CImage.DeleteFile(getServletContext().getRealPath(cParam.m_strFileName));
				return -2;
			}

			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// insert file_name
			strSql ="INSERT INTO contents_0000(user_id) VALUES(?) RETURNING content_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_nContentId = cResSet.getInt("content_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// save file
			String strFileName = String.format("/user_img01/%09d/%09d.jpg", cParam.m_nUserId, m_nContentId);
			CImage.saveIllustImages(getServletContext().getRealPath(cParam.m_strFileName), getServletContext().getRealPath(strFileName));
			CImage.DeleteFile(getServletContext().getRealPath(cParam.m_strFileName));

			// update making file_name
			strSql ="UPDATE contents_0000 SET file_name=?, description=?, open_id=0 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strFileName);
			cState.setString(2, Common.SubStrNum(cParam.m_strDescription, 200));
			cState.setInt(3, m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			// Add my tags
			// Pattern ptn = Pattern.compile("#(.*?)[\\s\\r\\n]+", Pattern.MULTILINE);
			Pattern ptn = Pattern.compile("#([\\w|\\p{InHiragana}|\\p{InKatakana}|\\p{InHalfwidthAndFullwidthForms}|\\p{InCJKUnifiedIdeographs}]+)", Pattern.MULTILINE);
			Matcher matcher = ptn.matcher(cParam.m_strDescription.replaceAll("　", " ")+"\n");
			strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type) VALUES(?, ?, 1)";
			cState = cConn.prepareStatement(strSql);
			for (int nNum=0; matcher.find() && nNum<20; nNum++) {
				try {
					cState.setString(1,Common.SubStrNum(matcher.group(1), 64));
					cState.setInt(2, m_nContentId);
					cState.executeUpdate();
				} catch(Exception e) {
					e.printStackTrace();
				}
			}
			cState.close();cState=null;

			if(cParam.m_bTweet) {
				CTweet cTweet = new CTweet();
				if (cTweet.GetResults(cParam.m_nUserId)) {
					String strTweetMsg = cParam.m_strDescription;
					StringBuffer bufMsg = new StringBuffer();
					if (100 < strTweetMsg.length()) {
						bufMsg.append(strTweetMsg.substring(0, 100));
						bufMsg.append("...");
					} else {
						bufMsg.append(strTweetMsg);
					}
					bufMsg.append(String.format(" https://poipiku.com/%d/%d.html", cParam.m_nUserId, m_nContentId));

					if (!cTweet.Tweet(bufMsg.toString(), getServletContext().getRealPath(strFileName))) {
						System.out.println("tweet失敗");
					}
				}
			}

		} catch(Exception e) {
			System.out.println(strSql);
			e.printStackTrace();
			return m_nContentId;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
			CImage.DeleteFile(getServletContext().getRealPath(cParam.m_strFileName));
		}
		return m_nContentId;
	}
}
%><%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);
System.out.println("UploadFileF.jsp:UID:"+cCheckLogin.m_nUserId);

int nRtn = 0;
UploadFileCParam cParam = new UploadFileCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);
System.out.println("UploadFileF.jsp:FILE:"+cParam.m_strFileName);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadFileC cResults = new UploadFileC();
	nRtn = cResults.GetResults(cParam);
	System.out.println("UploadFileF.jsp:DONE");
}
%><%=nRtn%>
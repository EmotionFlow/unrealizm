<%@page import="javax.imageio.ImageIO"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.nio.file.Files"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@include file="/inner/Common.jsp"%>
<%
class UploadPasteCParam {

	public int m_nUserId = -1;
	public String m_strDescription = "";
	public boolean m_bTweet = false;
	public int m_nCategoryId = 0;
	String m_strEncodeImg = "";
	public String m_strFileName = "";

	public int GetParam(HttpServletRequest cRequest) {
		try {
			m_nUserId = Common.ToInt(request.getParameter("UID"));
			m_strDescription = Common.SubStrNum(Common.TrimAll(request.getParameter("DES")), 200);
			m_bTweet = (Common.ToInt(request.getParameter("TWI"))==1);
			m_nCategoryId = Common.ToIntN(request.getParameter("CAT"), 0, 10);
			m_strEncodeImg = Common.ToString(request.getParameter("DATA"));

			String strRelativePath = Common.GetUploadPath();
			String strRealPath = getServletContext().getRealPath(strRelativePath);
			String strFileName = Long.toString((new java.util.Date()).getTime());
			strFileName += Integer.toString((int)(Math.random()*9999));
			m_strFileName = strRelativePath + "/" + strFileName;
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
			return -99;
		}
		return 0;
	}
}


class UploadPasteC {
	public int GetResults(UploadPasteCParam cParam, ResourceBundleControl _TEX) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int m_nContentId = -99;

		try {
			byte[] imageBinary = Base64.decodeBase64(cParam.m_strEncodeImg.getBytes());
			if(imageBinary == null) {throw(new Exception());}
			BufferedImage cImage = ImageIO.read(new ByteArrayInputStream(imageBinary));
			if(cImage == null) {throw(new Exception());}
			ImageIO.write(cImage, "png", new File(getServletContext().getRealPath(cParam.m_strFileName)));

			// check file type
			if(!CImage.checkImage(getServletContext().getRealPath(cParam.m_strFileName))) {
				CImage.DeleteFile(getServletContext().getRealPath(cParam.m_strFileName));
				return -2;
			}

			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// get content id
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
			strSql ="UPDATE contents_0000 SET file_name=?, category_id=?, description=?, open_id=0, comment_num=1 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strFileName);
			cState.setInt(2, cParam.m_nCategoryId);
			cState.setString(3, Common.SubStrNum(cParam.m_strDescription, 200));
			cState.setInt(4, m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			if (!cParam.m_strDescription.isEmpty()) {
				// Add my tags
				Pattern ptn = Pattern.compile("#([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", Pattern.MULTILINE);
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
			}

			if(cParam.m_bTweet) {
				CTweet cTweet = new CTweet();
				if (cTweet.GetResults(cParam.m_nUserId)) {
					String strHeader = String.format("[%s]\n", _TEX.T(String.format("Category.C%d", cParam.m_nCategoryId)));
					String strFooter = String.format(" https://poipiku.com/%d/%d.html", cParam.m_nUserId, m_nContentId);
					int nMessageLength = CTweet.MAX_LENGTH - strHeader.length() - strFooter.length();
					StringBuffer bufMsg = new StringBuffer();
					bufMsg.append(strHeader);
					if (nMessageLength < cParam.m_strDescription.length()) {
						bufMsg.append(cParam.m_strDescription.substring(0, nMessageLength-CTweet.ELLIPSE.length()));
						bufMsg.append(CTweet.ELLIPSE);
					} else {
						bufMsg.append(cParam.m_strDescription);
					}
					bufMsg.append(strFooter);

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
UploadPasteCParam cParam = new UploadPasteCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadPasteC cResults = new UploadPasteC();
	nRtn = cResults.GetResults(cParam, _TEX);
	System.out.println("UploadFileF.jsp:DONE");
}
%>{"result":<%=nRtn%>}
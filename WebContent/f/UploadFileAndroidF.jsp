<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.nio.file.Files"%>
<%@page import="javax.imageio.ImageIO"%>
<%@page import="org.apache.commons.fileupload.*"%>
<%@page import="org.apache.commons.fileupload.disk.*"%>
<%@page import="org.apache.commons.fileupload.servlet.*"%>
<%@include file="/inner/Common.jsp"%>
<%
class UploadFileCParam {
	public int m_nUserId = -1;
	public int m_nCategoryId = 0;
	public String m_strDescription = "";
	public int m_nOpenId = 0;
	public boolean m_bTweet = false;
	FileItem item_file = null;
	public int m_nOptImage = 1;

	public int GetParam(HttpServletRequest cRequest) {
		try {
			String strRelativePath = Common.GetUploadPath();
			String strRealPath = getServletContext().getRealPath(strRelativePath);
			DiskFileItemFactory factory = new DiskFileItemFactory();
			factory.setSizeThreshold(20*1024*1024);
			factory.setRepository(new File(strRealPath));
			ServletFileUpload upload = new ServletFileUpload(factory);
			upload.setSizeMax(20*1024*1024);
			upload.setHeaderEncoding("UTF-8");

			List items = upload.parseRequest(cRequest);
			Iterator iter = items.iterator();
			while (iter.hasNext()) {
				FileItem item = (FileItem) iter.next();

				if (item.isFormField()) {
					String strName = item.getFieldName();
					if(strName.equals("UID")) {
						m_nUserId = Common.ToInt(item.getString());
					} else if(strName.equals("CAT")) {
						m_nCategoryId = Common.ToIntN(item.getString(), 0, 13);
					} else if(strName.equals("DES")) {
						m_strDescription = Common.TrimAll(Common.ToString(item.getString("UTF-8")));
						m_strDescription = m_strDescription.replace("＃", "#").replace("♯", "#").replace("\r\n", "\n").replace("\r", "\n");
						if(m_strDescription.startsWith("#")) m_strDescription=" "+m_strDescription;
					} else if(strName.equals("TWI")) {
						m_bTweet = (Common.ToInt(item.getString())==1);
					} else if(strName.equals("REC")) {
						m_nOpenId = Common.ToIntN(item.getString(), 0, 2);
					} else if(strName.equals("IMG")){
						m_nOptImage = Common.ToIntN(item.getString(), 0, 1);
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


class UploadFileC {
	public int GetResults(UploadFileCParam cParam, ResourceBundleControl _TEX) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		int m_nContentId = -99;

		try {
			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// check ext
			if(cParam.item_file==null) return m_nContentId;
			String ext = ImageUtil.getExt(ImageIO.createImageInputStream(cParam.item_file.getInputStream()));
			if((!ext.equals("jpeg")) && (!ext.equals("jpg")) && (!ext.equals("gif")) && (!ext.equals("png"))) {
				Log.d("main item type error");
				return m_nContentId;
			}

			// insert file_name
			strSql ="INSERT INTO contents_0000(user_id, category_id, description) VALUES(?, ?, ?) RETURNING content_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nCategoryId);
			cState.setString(3, Common.SubStrNum(cParam.m_strDescription, 200));
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_nContentId = cResSet.getInt("content_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(m_nContentId<=0) return m_nContentId;

			// save file
			File cDir = new File(getServletContext().getRealPath(Common.getUploadUserPath(cParam.m_nUserId)));
			if(!cDir.exists()) {
				cDir.mkdirs();
			}
			String strFileName = String.format("%s/%09d.jpg", Common.getUploadUserPath(cParam.m_nUserId), m_nContentId);
			String strRealFileName = getServletContext().getRealPath(strFileName);
			cParam.item_file.write(new File(strRealFileName));
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
			} catch(IOException e) {
				nWidth = 0;
				nHeight = 0;
				nFileSize = 0;
				nComplexSize=0;
				Log.d("error getImageSize");
			}
			//Log.d(String.format("nWidth=%d, nHeight=%d, nFileSize=%d, nComplexSize=%d", nWidth, nHeight, nFileSize, nComplexSize));

			// update making file_name
			strSql ="UPDATE contents_0000 SET file_name=?, open_id=?, file_width=?, file_height=?, file_size=?, file_complex=? WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strFileName);
			cState.setInt(2, cParam.m_nOpenId);
			cState.setInt(3, nWidth);
			cState.setInt(4, nHeight);
			cState.setLong(5, nFileSize);
			cState.setLong(6, nComplexSize);
			cState.setInt(7, m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			// Add my tags
			// Pattern ptn = Pattern.compile("#(.*?)[\\s\\r\\n]+", Pattern.MULTILINE);
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

			CTweet cTweet = new CTweet();
			if (cParam.m_bTweet && cTweet.GetResults(cParam.m_nUserId)) {
				String strHeader = String.format("[%s]\n", _TEX.T(String.format("Category.C%d", cParam.m_nCategoryId)));
				String strFooter = String.format(" https://poipiku.com/%d/%d.html #%s",
						cParam.m_nUserId,
						m_nContentId,
						_TEX.T("THeader.Title"));
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
				Log.d(strFileName, bufMsg.toString());

				if(cParam.m_nOptImage==0) {	// text only
					boolean bRsultTweet = cTweet.Tweet(bufMsg.toString());
					if(!bRsultTweet) Log.d("tweet失敗");
				} else { // with image
					boolean bRsultTweet = cTweet.Tweet(bufMsg.toString(), strRealFileName);
					if(!bRsultTweet) Log.d("tweet失敗");
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
			cParam.item_file.delete();
		}
		return m_nContentId;
	}
}
%><%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);
System.out.println("UploadFileAndroidF.jsp:UID:"+cCheckLogin.m_nUserId);

int nRtn = 0;
UploadFileCParam cParam = new UploadFileCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadFileC cResults = new UploadFileC();
	nRtn = cResults.GetResults(cParam, _TEX);
	System.out.println("UploadFileAndroidF.jsp:DONE");
}
%><%=nRtn%>
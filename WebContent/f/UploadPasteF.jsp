<%@page import="javax.imageio.ImageIO"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.nio.file.Files"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UploadPasteCParam {

	public int m_nUserId = -1;
	public String m_strDescription = "";
	public int m_nOpenId = 0;
	public boolean m_bTweet = false;
	public int m_nCategoryId = 0;
	public int m_nSafeFilter = 0;
	String m_strEncodeImg = "";
	public int m_nOptImage = 1;

	public int GetParam(HttpServletRequest request) {
		try {
			m_nUserId			= Common.ToInt(request.getParameter("UID"));
			m_strDescription	= Common.SubStrNum(Common.TrimAll(request.getParameter("DES")), 200);
			m_nOpenId			= Common.ToIntN(request.getParameter("REC"), 0, 2);
			m_bTweet			= (Common.ToInt(request.getParameter("TWI"))==1);
			m_nOptImage			= Common.ToIntN(request.getParameter("IMG"), 0, 1);
			m_nCategoryId		= Common.ToIntN(request.getParameter("CAT"), 0, Common.CATEGORY_ID_MAX);
			m_nSafeFilter		= Common.ToIntN(request.getParameter("SAF"), Common.SAFE_FILTER_ALL, Common.SAFE_FILTER_R18G);
			m_strEncodeImg		= Common.ToString(request.getParameter("DATA"));	// 送信サイズの最大を変えた時は tomcatのmaxPostSizeとnginxのclient_max_body_size、client_body_buffer_sizeも変更すること
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
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int m_nContentId = -99;

		try {
			byte[] imageBinary = Base64.decodeBase64(cParam.m_strEncodeImg.getBytes());
			if(imageBinary == null) return nRtn;
			if(imageBinary.length>1024*1024*30) return nRtn;
			BufferedImage cImage = ImageIO.read(new ByteArrayInputStream(imageBinary));
			if(cImage == null) return nRtn;

			// check ext
			String ext = ImageUtil.getExt(ImageIO.createImageInputStream(new ByteArrayInputStream(imageBinary)));
			if((!ext.equals("jpeg")) && (!ext.equals("jpg")) && (!ext.equals("gif")) && (!ext.equals("png"))) {
				Log.d("main item type error");
				return nRtn;
			}

			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// get content id
			strSql ="INSERT INTO contents_0000(user_id, category_id, safe_filter, description) VALUES(?, ?, ?, ?) RETURNING content_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nCategoryId);
			cState.setInt(3, cParam.m_nSafeFilter);
			cState.setString(4, Common.SubStrNum(cParam.m_strDescription, 200));
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_nContentId = cResSet.getInt("content_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// save file
			File cDir = new File(getServletContext().getRealPath(Common.getUploadUserPath(cParam.m_nUserId)));
			if(!cDir.exists()) {
				cDir.mkdirs();
			}
			String strFileName = String.format("%s/%09d.%s", Common.getUploadUserPath(cParam.m_nUserId), m_nContentId, ext);
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
			CContent cContent = null;
			strSql ="UPDATE contents_0000 SET file_name=?, open_id=?, file_width=?, file_height=?, file_size=?, file_complex=?, file_num=1 WHERE content_id=? RETURNING *";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strFileName);
			cState.setInt(2, cParam.m_nOpenId);
			cState.setInt(3, nWidth);
			cState.setInt(4, nHeight);
			cState.setLong(5, nFileSize);
			cState.setLong(6, nComplexSize);
			cState.setInt(7, m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				cContent = new CContent(cResSet);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			if (!cParam.m_strDescription.isEmpty()) {
				// Add my tags
				Pattern ptn = Pattern.compile(Common.TAG_PATTERN, Pattern.MULTILINE);
				Matcher matcher = ptn.matcher(cParam.m_strDescription.replaceAll("　", " ")+"\n");
				strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type, tag_kana_txt) VALUES(?, ?, 1, ?) ON CONFLICT DO NOTHING;";
				cState = cConn.prepareStatement(strSql);
				for (int nNum=0; matcher.find() && nNum<20; nNum++) {
					try {
						cState.setString(1,Common.SubStrNum(matcher.group(1), 64));
						cState.setInt(2, m_nContentId);
						cState.setString(3, Util.getKana(Common.SubStrNum(matcher.group(1), 64)));
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
					// 本文作成
					String strTwitterMsg = CTweet.generateIllustMsgFull(cContent, _TEX);
					Log.d(strFileName, strTwitterMsg);

					// ツイート
					if(cParam.m_nOptImage==0) {	// text only
						boolean bRsultTweet = cTweet.Tweet(strTwitterMsg);
						if(!bRsultTweet) Log.d("tweet失敗");
					} else { // with image
						String strTweetFile = strFileName;
						if(cParam.m_nSafeFilter<Common.SAFE_FILTER_R15) {
							;
						} else if(cParam.m_nSafeFilter<Common.SAFE_FILTER_R18) {
							strTweetFile = "/img/warning.png";
						} else {
							strTweetFile = "/img/R-18.png";
						}
						boolean bRsultTweet = cTweet.Tweet(strTwitterMsg, getServletContext().getRealPath(strTweetFile));
						if(!bRsultTweet) Log.d("tweet失敗");
					}
				}
			}
			nRtn = m_nContentId;
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
UploadPasteCParam cParam = new UploadPasteCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadPasteC cResults = new UploadPasteC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%>{"result":<%=nRtn%>}
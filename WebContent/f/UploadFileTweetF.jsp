<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
class UploadFileTweetCParam {

	public int m_nUserId = -1;
	public int m_nContentId = 0;
	public int m_nOptImage = 1;

	public int GetParam(HttpServletRequest cRequest) {
		try {
			m_nUserId		= Common.ToInt(request.getParameter("UID"));
			m_nContentId	= Common.ToInt(request.getParameter("IID"));
			m_nOptImage		= Common.ToIntN(request.getParameter("IMG"), 0, 1);
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
			return -99;
		}
		return 0;
	}
}


class UploadFileTweetC {
	public int GetResults(UploadFileTweetCParam cParam, ResourceBundleControl _TEX) {
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

			// 存在チェック
			CContent cContent = null;
			strSql ="SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				cContent = new CContent(cResSet);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(cContent == null) return nRtn;

			// Tweet
			CTweet cTweet = new CTweet();
			if (cTweet.GetResults(cParam.m_nUserId)) {
				String strHeader = String.format("[%s]\n", _TEX.T(String.format("Category.C%d", cContent.m_nCategoryId)));
				String strFooter = String.format(" https://poipiku.com/%d/%d.html #%s",
						cParam.m_nUserId,
						cContent.m_nContentId,
						_TEX.T("THeader.Title"));
				if(cContent.m_nFileNum>1) {
					strFooter = strFooter + " " + String.format(_TEX.T("UploadFileTweet.FileNum"), cContent.m_nFileNum);
				}
				int nMessageLength = CTweet.MAX_LENGTH - strHeader.length() - strFooter.length();
				StringBuffer bufMsg = new StringBuffer();
				bufMsg.append(strHeader);
				if (nMessageLength < cContent.m_strDescription.length()) {
					bufMsg.append(cContent.m_strDescription.substring(0, nMessageLength-CTweet.ELLIPSE.length()));
					bufMsg.append(CTweet.ELLIPSE);
				} else {
					bufMsg.append(cContent.m_strDescription);
				}
				bufMsg.append(strFooter);
				Log.d(cContent.m_strFileName, bufMsg.toString());

				if(cParam.m_nOptImage==0) {	// text only
					boolean bRsultTweet = cTweet.Tweet(bufMsg.toString());
					if(!bRsultTweet) Log.d("tweet失敗");
				} else { // with image
					String strTweetFile = cContent.m_strFileName;
					if(cContent.m_nSafeFilter>=2) {
						strTweetFile = "/img/warning.png";
					}
					boolean bRsultTweet = cTweet.Tweet(bufMsg.toString(), getServletContext().getRealPath(strTweetFile));
					if(!bRsultTweet) Log.d("tweet失敗");
				}
			}
			nRtn = cContent.m_nContentId;
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
UploadFileTweetCParam cParam = new UploadFileTweetCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadFileTweetC cResults = new UploadFileTweetC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%><%=nRtn%>
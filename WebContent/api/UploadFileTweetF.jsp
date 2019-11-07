<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UploadFileTweetCParam {

	public int m_nUserId = -1;
	public int m_nContentId = 0;
	public int m_nOptImage = 1;

	public int GetParam(HttpServletRequest request) {
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

			// 存在チェック & 本文 & 1枚目取得
			CContent cContent = null;
			ArrayList<String> vFileList = new ArrayList<String>();
			strSql ="SELECT contents_0000.*, nickname FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE contents_0000.user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				cContent = new CContent(cResSet);
				cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				String strFileName = cContent.m_strFileName;
				if(!strFileName.isEmpty()) {
					switch(cContent.m_nPublishId) {
					case Common.PUBLISH_ID_R15:
					case Common.PUBLISH_ID_R18:
					case Common.PUBLISH_ID_R18G:
					case Common.PUBLISH_ID_PASS:
					case Common.PUBLISH_ID_LOGIN:
					case Common.PUBLISH_ID_FOLLOWER:
					case Common.PUBLISH_ID_T_FOLLOWER:
					case Common.PUBLISH_ID_T_FOLLOW:
					case Common.PUBLISH_ID_T_EACH:
					case Common.PUBLISH_ID_T_LIST:
						strFileName = Common.PUBLISH_ID_FILE[cContent.m_nPublishId];
						break;
					case Common.PUBLISH_ID_ALL:
					case Common.PUBLISH_ID_HIDDEN:
					default:
						strFileName = cContent.m_strFileName;
						break;
					}
					vFileList.add(getServletContext().getRealPath(strFileName));
				}
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(cContent == null) return nRtn;

			// 2枚目以降取得
			if(cContent.m_nPublishId==Common.PUBLISH_ID_ALL && cContent.m_nSafeFilter<Common.SAFE_FILTER_R15 && cContent.m_nFileNum>1) {
				strSql = "SELECT * FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id ASC LIMIT 3";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nContentId);
				cResSet = cState.executeQuery();
				while(cResSet.next()) {
					String strFileName = Common.ToString(cResSet.getString("file_name"));
					if(!strFileName.isEmpty()) {
						vFileList.add(getServletContext().getRealPath(strFileName));
					}
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			// Tweet
			CTweet cTweet = new CTweet();
			if (!cTweet.GetResults(cParam.m_nUserId)) return nRtn;

			// 本文作成
			String strTwitterMsg = CTweet.generateIllustMsgFull(cContent, _TEX);
			Log.d(cContent.m_strFileName, strTwitterMsg);

			// ツイート
			if(cParam.m_nOptImage==0 || vFileList.size()<=0) {	// text only
				boolean bRsultTweet = cTweet.Tweet(strTwitterMsg);
				if(!bRsultTweet) Log.d("tweet失敗");
			} else { // with image
				boolean bRsultTweet = cTweet.Tweet(strTwitterMsg, vFileList);
				if(!bRsultTweet) Log.d("tweet失敗");
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
CheckLogin cCheckLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadFileTweetCParam cParam = new UploadFileTweetCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadFileTweetC cResults = new UploadFileTweetC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%><%=nRtn%>
<%@page import="com.emotionflow.poipiku.ResourceBundleControl.CResourceBundleUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class SendCommentCParam {
	public int m_nContentId = -1;
	public int m_nCategory = 0;
	public int m_nPos = 0;
	public int m_nUserId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nContentId	= Common.ToInt(cRequest.getParameter("IID"));
			m_nCategory		= Common.ToInt(cRequest.getParameter("CAT"));
			m_nPos			= Common.ToInt(cRequest.getParameter("POS"));
			m_nUserId		= Common.ToInt(cRequest.getParameter("UID"));
		} catch(Exception e) {
			m_nContentId = -1;
			m_nUserId = -1;
		}
	}
}

class SendCommentC {
	public String m_strEmoji = "";
	public boolean GetResults(SendCommentCParam cParam, ResourceBundleControl _TEX) {
		if(cParam.m_nCategory<0 || cParam.m_nCategory>=Common.CATEGORY_EMOJI.length) return false;
		if(cParam.m_nPos<0 || cParam.m_nPos>=Common.CATEGORY_EMOJI[cParam.m_nCategory].length) return false;

		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// 投稿存在確認(不正アクセス対策)
			boolean bExist = false;
			int nMakingUserId = 0;
			strSql = "SELECT * FROM contents_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				bExist = true;
				nMakingUserId = cResSet.getInt("user_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(!bExist) {
				return false;
			}

			// max 5 emoji
			strSql = "SELECT COUNT(*) FROM comments_0000 WHERE content_id=? AND user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.setInt(2, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			int nEmojiNum = 0;
			if(cResSet.next()) {
				nEmojiNum = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(nEmojiNum>=5) {
				return false;
			}

			// add new comment
			strSql = "INSERT INTO comments_0000(content_id, description, user_id) VALUES(?, ?, ?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.setString(2, Common.CATEGORY_EMOJI[cParam.m_nCategory][cParam.m_nPos]);
			cState.setInt(3, cParam.m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;

			// update making comment num
			strSql ="UPDATE contents_0000 SET comment_num=(SELECT COUNT(*) FROM comments_0000 WHERE content_id=?) WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.setInt(2, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			bRtn = true; // 以下実行されなくてもOKを返す
			m_strEmoji = Common.CATEGORY_EMOJI[cParam.m_nCategory][cParam.m_nPos];

		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}
%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

SendCommentCParam cParam = new SendCommentCParam();
cParam.GetParam(request);
boolean bRtn = false;
SendCommentC cResults = new SendCommentC();
if( cCheckLogin.m_bLogin && cParam.m_nUserId == cCheckLogin.m_nUserId ) {
	bRtn = cResults.GetResults(cParam, _TEX);
}
%>{
"result_num" : <%=(bRtn)?1:0%>,
"result" : "<%=cResults.m_strEmoji%>"
}
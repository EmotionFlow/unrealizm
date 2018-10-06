<%@page import="jp.pipa.poipiku.ResourceBundleControl.CResourceBundleUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class SendEmojiC {
	public int EMOJI_MAX = 10;

	public int m_nContentId = -1;
	public String m_strEmoji = "";
	public int m_nUserId = -1;
	public String m_strIpAddress = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nContentId	= Common.ToInt(request.getParameter("IID"));
			m_strEmoji		= Common.ToString(request.getParameter("EMJ")).trim();
			m_nUserId		= Common.ToInt(request.getParameter("UID"));
			m_strIpAddress	= request.getRemoteAddr();
		} catch(Exception e) {
			m_nContentId = -1;
			m_nUserId = -1;
		}
	}

	public boolean getResults(CheckLogin checkLogin) {
		if(!Arrays.asList(Common.EMOJI_LIST[Common.EMOJI_CAT_ALL]).contains(m_strEmoji)) {
			Log.d("Invalid Emoji : "+ m_strEmoji);
			return false;
		}
		if(checkLogin.m_bLogin && (m_nUserId != checkLogin.m_nUserId)) return false;	// ログインしてるのにIDが異なる

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
			strSql = "SELECT * FROM contents_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cResSet = cState.executeQuery();
			bExist = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(!bExist) {
				return false;
			}

			// max 5 emoji
			int nEmojiNum = 0;
			if(checkLogin.m_bLogin) {
				strSql = "SELECT COUNT(*) FROM comments_0000 WHERE content_id=? AND user_id=? AND upload_date > CURRENT_TIMESTAMP-interval'1day'";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nContentId);
				cState.setInt(2, m_nUserId);
				cResSet = cState.executeQuery();
			} else {
				strSql = "SELECT COUNT(*) FROM comments_0000 WHERE content_id=? AND ip_address=? AND upload_date > CURRENT_TIMESTAMP-interval'1day'";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nContentId);
				cState.setString(2, m_strIpAddress);
				cResSet = cState.executeQuery();
			}
			if(cResSet.next()) {
				nEmojiNum = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(nEmojiNum>=EMOJI_MAX) {
				return false;
			}

			// add new comment
			strSql = "INSERT INTO comments_0000(content_id, description, user_id, ip_address) VALUES(?, ?, ?, ?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cState.setString(2, m_strEmoji);
			cState.setInt(3, m_nUserId);
			cState.setString(4, m_strIpAddress);
			cState.executeUpdate();
			cState.close();cState=null;

			// update making comment num
			strSql ="UPDATE contents_0000 SET comment_num=(SELECT COUNT(*) FROM comments_0000 WHERE content_id=?) WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cState.setInt(2, m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			bRtn = true; // 以下実行されなくてもOKを返す

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

SendEmojiC cResults = new SendEmojiC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
%>{
"result_num" : <%=(bRtn)?1:0%>,
"result" : "<%=CEnc.E(CEmoji.parse(cResults.m_strEmoji))%>"
}
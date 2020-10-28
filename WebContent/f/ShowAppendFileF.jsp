<%@page import="jp.pipa.poipiku.ResourceBundleControl.CResourceBundleUtil"%>
<%@page import="jp.pipa.poipiku.util.CTweet"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!class ShowAppendFileC {
	public static final int OK = 0;
	public static final int ERR_NOT_FOUND = -1;
	public static final int ERR_PASS = -2;
	public static final int ERR_LOGIN = -3;
	public static final int ERR_FOLLOWER = -4;
	public static final int ERR_T_FOLLOWER = -5;
	public static final int ERR_T_FOLLOW = -6;
	public static final int ERR_T_EACH = -7;
	public static final int ERR_T_LIST = -8;
	public static final int ERR_T_RATE_LIMIT_EXCEEDED = -429088;
	public static final int ERR_T_INVALID_OR_EXPIRED_TOKEN = -404089;
	public static final int ERR_HIDDEN = -9;
	public static final int ERR_UNKNOWN = -99;

	public int m_nUserId = -1;
	public int m_nContentId = -1;
	public String m_strPassword = "";
	public int m_nMode = 0;
	public int m_nTwFriendship = CTweet.FRIENDSHIP_UNDEF;

	public void getParam(HttpServletRequest request) {
		try {
			m_nUserId	= Util.toInt(request.getParameter("UID"));
			m_nContentId	= Util.toInt(request.getParameter("IID"));
			m_strPassword = request.getParameter("PAS");
			m_nMode = Util.toInt(request.getParameter("MD"));
			m_nTwFriendship = Util.toInt(request.getParameter("TWF"));
			request.setCharacterEncoding("UTF-8");
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}

	CContent m_cContent = null;
	public int getResults(CheckLogin checkLogin) {
		int nRtn = OK;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.setInt(2, m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cContent = new CContent(cResSet);
				m_cContent.m_strPassword = Util.toString(cResSet.getString("password"));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(m_cContent==null) return ERR_NOT_FOUND;
			if(m_cContent.m_nPublishId==Common.PUBLISH_ID_PASS && !m_cContent.m_strPassword.equals(m_strPassword)) return ERR_PASS;
			if(m_cContent.m_nPublishId==Common.PUBLISH_ID_LOGIN && !checkLogin.m_bLogin) return ERR_LOGIN;
			if(m_cContent.m_nPublishId==Common.PUBLISH_ID_FOLLOWER) {
				boolean bFollow = (m_nUserId==checkLogin.m_nUserId);
				if(!bFollow) {
					strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, checkLogin.m_nUserId);
					cState.setInt(2, m_nUserId);
					cResSet = cState.executeQuery();
					if(cResSet.next()) {
						bFollow = true;
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;
				}
				if(!bFollow) return ERR_FOLLOWER;
			}
			if(m_cContent.m_nPublishId==Common.PUBLISH_ID_HIDDEN && m_cContent.m_nUserId!=checkLogin.m_nUserId) return ERR_HIDDEN;

			// twitter friendship
			if(m_cContent.m_nUserId!=checkLogin.m_nUserId && (m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER || m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE || m_cContent.m_nPublishId==Common.PUBLISH_ID_T_EACH)){
				CTweet cTweet = new CTweet();
				if(cTweet.GetResults(checkLogin.m_nUserId)){
					if(!cTweet.m_bIsTweetEnable){return ERR_T_FOLLOWER;}
					if(m_nTwFriendship==CTweet.FRIENDSHIP_UNDEF
						|| (m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER && (m_nTwFriendship==CTweet.FRIENDSHIP_NONE || m_nTwFriendship==CTweet.FRIENDSHIP_FOLLOWER))
						|| (m_cContent.m_nPublishId==Common.PUBLISH_ID_T_EACH     && (m_nTwFriendship==CTweet.FRIENDSHIP_NONE || m_nTwFriendship==CTweet.FRIENDSHIP_FOLLOWER))
						){
						m_nTwFriendship = cTweet.LookupFriendship(m_nUserId);
						if(m_nTwFriendship==CTweet.ERR_RATE_LIMIT_EXCEEDED){
							return ERR_T_RATE_LIMIT_EXCEEDED;
						}else if(m_nTwFriendship==CTweet.ERR_INVALID_OR_EXPIRED_TOKEN){
							return ERR_T_INVALID_OR_EXPIRED_TOKEN;
						}else if(m_nTwFriendship==CTweet.ERR_OTHER){
							return ERR_UNKNOWN;
						}
					}
					if(m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER && !(m_nTwFriendship==CTweet.FRIENDSHIP_FOLLOWEE || m_nTwFriendship==CTweet.FRIENDSHIP_EACH)){return ERR_T_FOLLOWER;}
					if(m_cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE && !(m_nTwFriendship==CTweet.FRIENDSHIP_FOLLOWER || m_nTwFriendship==CTweet.FRIENDSHIP_EACH)){return ERR_T_FOLLOW;}
					if(m_cContent.m_nPublishId==Common.PUBLISH_ID_T_EACH && !(m_nTwFriendship==CTweet.FRIENDSHIP_EACH)){return ERR_T_EACH;}
				}
			}

			// twitter openlist
			if(m_cContent.m_nUserId!=checkLogin.m_nUserId && m_cContent.m_nPublishId==Common.PUBLISH_ID_T_LIST){
				CTweet cTweet = new CTweet();
				if(cTweet.GetResults(checkLogin.m_nUserId)){
					if(!cTweet.m_bIsTweetEnable){return ERR_T_LIST;}
					int nRet = cTweet.LookupListMember(m_cContent);
					if(nRet==CTweet.ERR_NOT_FOUND) return ERR_T_LIST;
					if(nRet==CTweet.ERR_INVALID_OR_EXPIRED_TOKEN) return ERR_T_INVALID_OR_EXPIRED_TOKEN;
					if(nRet==CTweet.ERR_RATE_LIMIT_EXCEEDED) return ERR_T_RATE_LIMIT_EXCEEDED;
					if(nRet<0) return ERR_UNKNOWN;
				} else {
					return ERR_UNKNOWN;
				}
			}

			// Each append image
			strSql = "SELECT * FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id ASC LIMIT 1000";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_cContent.m_vContentAppend.add(new CContentAppend(cResSet));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			nRtn = m_cContent.m_vContentAppend.size();
		} catch(Exception e) {
			e.printStackTrace();
			nRtn = ERR_UNKNOWN;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}%>
<%
	CheckLogin checkLogin = new CheckLogin(request, response);
int nRtn = 0;
StringBuilder strHtml = new StringBuilder();
ShowAppendFileC cResults = new ShowAppendFileC();
cResults.getParam(request);
nRtn = cResults.getResults(checkLogin);
if(nRtn<ShowAppendFileC.OK) {
	switch(nRtn) {
	case ShowAppendFileC.ERR_PASS:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_PASS"));
		break;
	case ShowAppendFileC.ERR_LOGIN:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_LOGIN"));
		break;
	case ShowAppendFileC.ERR_FOLLOWER:
		strHtml.append((checkLogin.m_bLogin)?_TEX.T("ShowAppendFileC.ERR_FOLLOWER"):_TEX.T("ShowAppendFileC.ERR_FOLLOWER.NeedLogin"));
		break;
	case ShowAppendFileC.ERR_T_FOLLOWER:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_FOLLOWER"));
		break;
	case ShowAppendFileC.ERR_T_FOLLOW:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_FOLLOW"));
		break;
	case ShowAppendFileC.ERR_T_EACH:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_EACH"));
		break;
	case ShowAppendFileC.ERR_T_LIST:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_LIST"));
		break;
	case ShowAppendFileC.ERR_T_RATE_LIMIT_EXCEEDED:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_RATE_LIMIT_EXCEEDED"));
		break;
	case ShowAppendFileC.ERR_T_INVALID_OR_EXPIRED_TOKEN:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_INVALID_OR_EXPIRED_TOKEN"));
		break;
	case ShowAppendFileC.ERR_NOT_FOUND:
	case ShowAppendFileC.ERR_HIDDEN :
	case ShowAppendFileC.ERR_UNKNOWN:
	default:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_UNKNOWN"));
		break;
	}
} else {
	String ILLUST_DETAIL = (cResults.m_nMode==CCnv.MODE_SP)?"/IllustDetailV.jsp":"/IllustDetailPcV.jsp";
	switch(cResults.m_cContent.m_nPublishId) {
	case Common.PUBLISH_ID_R15:
	case Common.PUBLISH_ID_R18:
	case Common.PUBLISH_ID_R18G:
	case Common.PUBLISH_ID_PASS:
	case Common.PUBLISH_ID_LOGIN:
	case Common.PUBLISH_ID_FOLLOWER:
	case Common.PUBLISH_ID_T_FOLLOWER:
	case Common.PUBLISH_ID_T_FOLLOWEE:
	case Common.PUBLISH_ID_T_EACH:
	case Common.PUBLISH_ID_T_LIST:
		if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {
	// 2枚目の場所に本文を表示する
	nRtn=2;
	strHtml.append(String.format("<a class=\"IllustItemText\" style=\"max-height:none;\" href=\"%s?ID=%d&TD=%d\">", ILLUST_DETAIL, cResults.m_cContent.m_nUserId, cResults.m_cContent.m_nContentId));
	strHtml.append(String.format("<span class=\"IllustItemThumbText\">%s</span>", Util.toStringHtml(cResults.m_cContent.m_strTextBody)));
	strHtml.append("</a>");
		} else {
	// 2枚目の場所に1枚目を表示する
	nRtn++;
	strHtml.append(String.format("<a class=\"IllustItemThumb\" href=\"%s?ID=%d&TD=%d\">", ILLUST_DETAIL, cResults.m_cContent.m_nUserId, cResults.m_cContent.m_nContentId));
	strHtml.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", Common.GetUrl(cResults.m_cContent.m_strFileName)));
	strHtml.append("</a>");
		}
		break;
	case Common.PUBLISH_ID_ALL:
	case Common.PUBLISH_ID_HIDDEN:
	default:
		if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {nRtn=1;}
		break;
	}
	// 以降の画像・文章を表示
	for(CContentAppend cContentAppend : cResults.m_cContent.m_vContentAppend) {
		if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {
	// 2枚目の場所に本文に表示する
	strHtml.append(String.format("<a class=\"IllustItemText\" style=\"max-height:none;\" href=\"%s?ID=%d&TD=%d&AD=%d\">", ILLUST_DETAIL, cResults.m_cContent.m_nUserId, cResults.m_cContent.m_nContentId, cContentAppend.m_nAppendId));
	strHtml.append(String.format("<span class=\"IllustItemThumbText\">%s</span>", Util.toStringHtml(cResults.m_cContent.m_strTextBody)));
	strHtml.append("</a>");
		} else {
	strHtml.append(String.format("<a class=\"IllustItemThumb\" href=\"%s?ID=%d&TD=%d&AD=%d\">", ILLUST_DETAIL, cResults.m_cContent.m_nUserId, cResults.m_cContent.m_nContentId, cContentAppend.m_nAppendId));
	strHtml.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", Common.GetUrl(cContentAppend.m_strFileName)));
	strHtml.append("</a>");
		}
	}
}
%>{
"result_num" : <%=nRtn%>,
"html" : "<%=CEnc.E(strHtml.toString())%>",
"tw_friendship" : "<%=cResults.m_nTwFriendship%>"
}
<%@page import="jp.pipa.poipiku.ResourceBundleControl.CResourceBundleUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class GetEmojiListC {
	public int EMOJI_MAX = 5;

	public int m_nContentId = -1;
	public int m_nCategoryId = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nContentId	= Common.ToInt(request.getParameter("IID"));
			m_nCategoryId	= Common.ToIntN(request.getParameter("CAT"), 0, Common.EMOJI_CAT_CHEER);
		} catch(Exception e) {
			;
		}
	}

	public String[] getResults(CheckLogin cCheckLogin) {
		String EMOJI_LIST[] = Common.EMOJI_LIST[m_nCategoryId];
		if(m_nCategoryId!=Common.EMOJI_CAT_POPULAR && (m_nCategoryId!=Common.EMOJI_CAT_RECENT || !cCheckLogin.m_bLogin)) return EMOJI_LIST;

		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// Follow
			ArrayList<String> vEmoji = new ArrayList<String>();
			if(m_nCategoryId==Common.EMOJI_CAT_RECENT) {
				vEmoji = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
			} else {
				vEmoji = Util.getDefaultEmoji(-1, Common.EMOJI_KEYBORD_MAX);
			}
			EMOJI_LIST = vEmoji.toArray(new String[vEmoji.size()]);
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return EMOJI_LIST;
	}
}
%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
StringBuilder sbResult = new StringBuilder();
GetEmojiListC cResults = new GetEmojiListC();
cResults.getParam(request);
if(!cCheckLogin.m_bLogin && cResults.m_nCategoryId==Common.EMOJI_CAT_RECENT) {
	sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("IllustV.Emoji.Recent.NeedLogin")));
} else if(!cCheckLogin.m_bLogin && cResults.m_nCategoryId==Common.EMOJI_CAT_ALL) {
	sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("IllustV.Emoji.All.NeedLogin")));
} else {
	String EMOJI_LIST[] = cResults.getResults(cCheckLogin);
	if(Common.EMOJI_EVENT) {
		EMOJI_LIST = Common.EMOJI_EVENT_LIST;
	}
	for(String emoji : EMOJI_LIST) {
		sbResult.append(
				String.format("<span class=\"ResEmojiBtn\" onclick=\"SendEmoji(%d, '%s', %d, this)\">%s</span>",
						cResults.m_nContentId,
						emoji,
						cCheckLogin.m_nUserId,
						CEmoji.parse(emoji))
				);
	}
}
%>
<%=sbResult.toString()%>

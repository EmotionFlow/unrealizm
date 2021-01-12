<%@page import="jp.pipa.poipiku.ResourceBundleControl.CResourceBundleUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!class GetEmojiListC {
	public int m_nContentId = -1;
	public int m_nCategoryId = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nContentId	= Util.toInt(request.getParameter("IID"));
			m_nCategoryId	= Util.toIntN(request.getParameter("CAT"), 0, Emoji.EMOJI_CAT_CHEER);
		} catch(Exception e) {
			;
		}
	}

	public boolean m_bCheerNG = false;

	/*
					RECENT  POPULAR  FOOD    OTHER   CHEER
		notLogin    []      static   static  static  []
		Login       vEmoji  static   static  static  static
	 */
	public String[] getResults(CheckLogin checkLogin) {
		String EMOJI_LIST[] = Emoji.getInstance().EMOJI_LIST[m_nCategoryId];

		if(m_nCategoryId==Emoji.EMOJI_CAT_RECENT && !checkLogin.m_bLogin) return EMOJI_LIST;
		if(m_nCategoryId==Emoji.EMOJI_CAT_POPULAR) return EMOJI_LIST;
		if(m_nCategoryId==Emoji.EMOJI_CAT_FOOD) return EMOJI_LIST;
		if(m_nCategoryId==Emoji.EMOJI_CAT_OTHER) return EMOJI_LIST;

		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			if(m_nCategoryId==Emoji.EMOJI_CAT_CHEER) {
				if(checkLogin.m_bLogin){
					strSql = "SELECT cheer_ng FROM contents_0000 WHERE content_id=?";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, m_nContentId);
					cResSet = cState.executeQuery();
					if(cResSet.next()) {
						m_bCheerNG = cResSet.getBoolean("cheer_ng");
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;
				} else {
					m_bCheerNG = true;
				}
			} else {
				// Follow
				ArrayList<String> vEmoji;
				if(m_nCategoryId==Emoji.EMOJI_CAT_RECENT) {
					vEmoji = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
				} else {
					vEmoji = Emoji.getDefaultEmoji(-1);
				}
				EMOJI_LIST = vEmoji.toArray(new String[vEmoji.size()]);
			}
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
}%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
StringBuilder sbResult = new StringBuilder();
GetEmojiListC cResults = new GetEmojiListC();
cResults.getParam(request);
if(!checkLogin.m_bLogin && cResults.m_nCategoryId==Emoji.EMOJI_CAT_RECENT) {
	sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("IllustV.Emoji.Recent.NeedLogin")));
} else if(!checkLogin.m_bLogin && cResults.m_nCategoryId==Emoji.EMOJI_CAT_OTHER) {
	sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("IllustV.Emoji.All.NeedLogin")));
} else if(!checkLogin.m_bLogin && cResults.m_nCategoryId==Emoji.EMOJI_CAT_CHEER) {
	sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("Cheer.NeedLogin")));
} else {
	String EMOJI_LIST[] = cResults.getResults(checkLogin);
	if(Emoji.EMOJI_EVENT) {
		EMOJI_LIST = Emoji.EMOJI_EVENT_LIST;
	}
	if(cResults.m_nCategoryId==Emoji.EMOJI_CAT_CHEER && cResults.m_bCheerNG) {
		sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("Cheer.Ng")));
	} else {
		for(String emoji : EMOJI_LIST) {
			sbResult.append(
					String.format("<span class=\"ResEmojiBtn\" onclick=\"SendEmoji(%d, '%s', %d, this)\">%s</span>",
							cResults.m_nContentId,
							emoji,
							checkLogin.m_nUserId,
							CEmoji.parse(emoji))
					);
		}
	}
}
%>
<%=sbResult.toString()%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
public class NewArrivalC {

	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Common.ToInt(cRequest.getParameter("PG")), 0);
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 36;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	int m_nEndId = -1;
	public int m_nContentsNum = 0;

	public boolean getResults(CheckLogin cCheckLogin) {
		return getResults(cCheckLogin, false);
	}

	public boolean getResults(CheckLogin cCheckLogin, boolean bContentOnly) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 1;

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();


			String strMuteKeyword = "";
			String strCond = "";
			strSql = "SELECT mute_keyword_list FROM users_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cCheckLogin.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				strMuteKeyword = Common.ToString(cResSet.getString(1)).trim();
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(!strMuteKeyword.isEmpty()) {
				strCond = "AND description &@~ ?";
			}


			// NEW ARRIVAL
			if(!bContentOnly) {
				strSql = String.format("SELECT count(*) FROM contents_0000 WHERE open_id<>2 AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND user_id=155 %s", strCond);
				cState = cConn.prepareStatement(strSql);
				idx = 1;
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					cState.setString(idx++, strMuteKeyword);
				}
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			strSql = String.format("SELECT * FROM contents_0000 WHERE open_id<>2 AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND user_id=155 %s ORDER BY content_id DESC OFFSET ? LIMIT ?", strCond);
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			if(!strMuteKeyword.isEmpty()) {
				cState.setString(idx++, strMuteKeyword);
			}
			cState.setInt(idx++, m_nPage * SELECT_MAX_GALLERY);
			cState.setInt(idx++, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				m_nEndId = cContent.m_nContentId;
				m_vContentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bResult = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bResult;
	}
}
%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

NewArrivalC cResults = new NewArrivalC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin, true);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX)%>
	<%if(nCnt==17) {%>
	<%@ include file="/inner/TAdPc300x250_bottom_right.jsp"%>
	<%}%>
<%}%>

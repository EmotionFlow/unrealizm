<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
class UpdateTagCParam {
	public int GetParam(HttpServletRequest cRequest) {
		try {
			;
		} catch(Exception e) {
			return -99;
		}
		return 0;
	}
}

class UpdateTagC {
	public ArrayList<CTag> m_vContentList = new ArrayList<CTag>();

	public int GetResults(UpdateTagCParam cParam) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";


		try {
			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// Get description data

			//CContent
			strSql = "SELECT * FROM tags_0000 WHERE tag_kana_txt isNull";
			cState = cConn.prepareStatement(strSql);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CTag cTag = new CTag(cResSet);
				cTag.m_nTagId = cResSet.getInt("tag_id");
				m_vContentList.add(cTag);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Update Kana
			strSql ="UPDATE tags_0000 SET tag_kana_txt=? WHERE tag_id=?;";
			cState = cConn.prepareStatement(strSql);
			for(CTag cTag : m_vContentList) {
				try {
					cState.setString(1, Util.getKana(cTag.m_strTagTxt));
					cState.setInt(2, cTag.m_nTagId);
					cState.executeUpdate();
				} catch(Exception e) {
					e.printStackTrace();
				}
			}
			cState.close();cState=null;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return 1;
	}
}
%><%
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(cCheckLogin.m_nUserId != 1) {
	return;
}

int nRtn = 0;
UpdateTagCParam cParam = new UpdateTagCParam();
nRtn = cParam.GetParam(request);

UpdateTagC cResults = new UpdateTagC();
nRtn = cResults.GetResults(cParam);
%><%=nRtn%>
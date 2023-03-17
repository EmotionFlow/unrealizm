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
	public int m_nCountNum = 0;
	public int m_nCountNumEnd = 0;

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

			// Get count
			strSql = "SELECT COUNT(*) FROM tags_0000 WHERE tag_kana_txt IS NULL";
			cState = cConn.prepareStatement(strSql);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nCountNum = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			Log.d("m_nCountNum:" + m_nCountNum);

			for(int i=0; i<15; i++) {
				//CContent
				CTag cTag = null;
				strSql = "SELECT COUNT(*), tag_txt FROM tags_0000 WHERE tag_kana_txt IS NULL GROUP BY tag_txt ORDER BY COUNT(*) DESC LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					cTag = new CTag();
					cTag.m_nTagId = cResSet.getInt(1);
					cTag.m_strTagTxt = Common.TrimAll(cResSet.getString("tag_txt"));
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
				if(cTag==null) break;

				// Update Kana
				strSql ="UPDATE tags_0000 SET tag_kana_txt=? WHERE tag_txt=? AND tag_kana_txt IS NULL;";
				cState = cConn.prepareStatement(strSql);
				try {
					String strKana = "";//Util.getKana(cTag.m_strTagTxt);
					cState.setString(1, strKana);
					cState.setString(2, cTag.m_strTagTxt);
					cState.executeUpdate();
					Log.d("i:" + (i+1));
					Log.d("cTag.m_strTagTxt:" + cTag.m_strTagTxt + ":" +strKana+" : "+cTag.m_nTagId);
				} catch(Exception e) {
					e.printStackTrace();
				}
				cState.close();cState=null;
			}

			// Get count
			strSql = "SELECT COUNT(*) FROM tags_0000 WHERE tag_kana_txt IS NULL";
			cState = cConn.prepareStatement(strSql);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nCountNumEnd = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			Log.d("m_nCountNumEnd:" + m_nCountNumEnd);
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		Log.d("end");
		return m_nCountNumEnd;
	}
}
%><%
CheckLogin checkLogin = new CheckLogin(request, response);

if(checkLogin.m_nUserId != 1) {
	return;
}

int nRtn = 0;
UpdateTagCParam cParam = new UpdateTagCParam();
nRtn = cParam.GetParam(request);

UpdateTagC results = new UpdateTagC();
nRtn = results.GetResults(cParam);
%><%=results.m_nCountNum%>, <%=results.m_nCountNumEnd%>
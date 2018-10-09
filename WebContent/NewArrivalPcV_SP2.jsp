<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
public class CContentComlex extends CContent {
	public int m_nFileComplex = 0;

	public CContentComlex(ResultSet resultSet) throws SQLException {
		m_nContentId		= resultSet.getInt("content_id");
		m_nCategoryId		= resultSet.getInt("category_id");
		m_strDescription	= Common.ToString(resultSet.getString("description"));
		m_timeUploadDate	= resultSet.getTimestamp("upload_date");
		m_nUserId			= resultSet.getInt("user_id");
		//m_nOpenId			= resultSet.getInt("open_id");
		m_strFileName		= Common.ToString(resultSet.getString("file_name"));
		m_nFileNum			= resultSet.getInt("file_num");
		m_nBookmarkNum		= resultSet.getInt("bookmark_num");
		m_nCommentNum		= resultSet.getInt("comment_num");
		m_nSafeFilter		= resultSet.getInt("safe_filter");
		m_cUser.m_nUserId	= resultSet.getInt("user_id");
		m_nFileComplex		= resultSet.getInt("file_complex");
	}
}

public class NewArrivalC {

	public ArrayList<CContentComlex> m_vContentList = new ArrayList<CContentComlex>();

	public boolean getResults(CheckLogin cCheckLogin) {
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

			strSql = String.format("SELECT * FROM contents_0000 WHERE open_id=0 AND file_complex>0 AND file_complex<=40000 ORDER BY content_id DESC LIMIT 200");
			cState = cConn.prepareStatement(strSql);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_vContentList.add(new CContentComlex(cResSet));
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
}%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

NewArrivalC cResults = new NewArrivalC();
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<style>
		.IllustThumb {margin: 6px !important;}
		</style>
	</head>

	<body>
		<div class="Wrapper ThumbList">
			<div id="IllustThumbList" class="IllustThumbList">
				<%for(CContentComlex cContent : cResults.m_vContentList) {%>
					<div style="float: left; width: 192px;">
						<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_NEWARRIVAL_ILLUST, CCnv.MODE_PC, _TEX)%>
						<div style="width: 100%; float: left; font-weight: bold;"><%=String.format("%,d", cContent.m_nFileComplex)%></div>
					</div>
				<%}%>
			</div>
		</div>
	</body>
</html>
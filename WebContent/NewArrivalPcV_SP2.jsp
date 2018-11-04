<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
public class CContentComlex extends CContent {
	public int m_nFileComplex = 0;
	public String m_strEmoji = "";

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
			int BASE = 1;
			int nNowHour = (new java.util.Date()).getHours();
			switch(nNowHour) {
			case 0:
				BASE = 5;
				break;
			case 1:
				BASE = 4;
				break;
			case 2:
				BASE = 3;
				break;
			case 3:
				BASE = 2;
				break;
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
				BASE = 1;
				break;
			case 18:
				BASE = 2;
				break;
			case 19:
				BASE = 3;
				break;
			case 20:
				BASE = 4;
				break;
			case 21:
				BASE = 5;
				break;
			case 22:
				BASE = 6;
				break;
			case 23:
				BASE = 7;
				break;
			default:
				BASE = 1;
				break;
			}

			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();


			strSql = "SELECT * FROM (SELECT * FROM contents_0000 WHERE open_id=0 AND file_complex>70000 ORDER BY content_id DESC OFFSET 10 LIMIT 100) as T1 ORDER BY random() LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, BASE);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_vContentList.add(new CContentComlex(cResSet));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			strSql = "SELECT description FROM (SELECT * FROM vw_rank_emoji_daily WHERE description<>'🎃' ORDER BY rank DESC LIMIT 40) as T2 ORDER BY random() LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			for(CContentComlex contentComlex : m_vContentList) {
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					contentComlex.m_strEmoji = cResSet.getString(1);
				}
				cResSet.close();cResSet=null;
			}
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
				<a style="float: left; width: 192px;" href="/f/SendEmojiF.jsp?IID=<%=cContent.m_nContentId%>&EMJ=<%=URLEncoder.encode(cContent.m_strEmoji, "UTF-8")%>&UID=0">
					<img src="<%=Common.GetUrl(cContent.m_strFileName)%>_360.jpg" style="width:180px;" />
					<div style="width: 100%; float: left; font-weight: bold;"><%=cContent.m_strEmoji%> <%=String.format("%,d", cContent.m_nFileComplex)%></div>
				</a>
				<%}%>
			</div>
		</div>
	</body>
</html>
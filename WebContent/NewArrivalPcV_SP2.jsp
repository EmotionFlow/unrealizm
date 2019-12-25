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
		//m_nCommentNum		= resultSet.getInt("comment_num");
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
			boolean USER = false;
			int CONTENT = 0;
			int nNowHour = (new java.util.Date()).getHours();
			switch(nNowHour) {
			case 0:
				BASE = 10;
				USER = true;
				CONTENT = 2;
				break;
			case 1:
				BASE = 8;
				USER = false;
				CONTENT = 2;
				break;
			case 2:
				BASE = 4;
				USER = false;
				CONTENT = 1;
				break;
			case 3:
				BASE = 3;
				USER = false;
				CONTENT = 1;
				break;
			case 4:
				BASE = 2;
				USER = false;
				CONTENT = 0;
				break;
			case 5:
			case 6:
				BASE = 1;
				USER = false;
				CONTENT = 0;
				break;
			case 7:
			case 8:
				BASE = 2;
				USER = false;
				CONTENT = 0;
				break;
			case 9:
			case 10:
			case 11:
			case 12:
				BASE = 3;
				USER = false;
				CONTENT = 0;
				break;
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
				BASE = 4;
				USER = false;
				CONTENT = 1;
				break;
			case 18:
				BASE = 5;
				USER = false;
				CONTENT = 1;
				break;
			case 19:
				BASE = 6;
				USER = false;
				CONTENT = 1;
				break;
			case 20:
				BASE = 7;
				USER = false;
				CONTENT = 1;
				break;
			case 21:
				BASE = 8;
				USER = false;
				CONTENT = 1;
				break;
			case 22:
				BASE = 10;
				USER = true;
				CONTENT = 2;
				break;
			case 23:
				BASE = 12;
				USER = true;
				CONTENT = 3;
				break;
			default:
				BASE = 1;
				USER = false;
				CONTENT = 0;
				break;
			}

			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			if(USER) {
				int user_id = 0;
				strSql = "SELECT nextval('users_0000_user_id_seq')";
				cState = cConn.prepareStatement(strSql);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					user_id = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
				Log.d("user_id:"+user_id);
			}
			if(CONTENT>0) {
				int content_id = 0;
				int append_id = 0;
				for(int nCnt=0; nCnt<CONTENT; nCnt++) {
					strSql = "SELECT nextval('contents_0000_content_id_seq')";
					cState = cConn.prepareStatement(strSql);
					cResSet = cState.executeQuery();
					if (cResSet.next()) {
						content_id = cResSet.getInt(1);
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;

					strSql = "SELECT nextval('contents_appends_0000_append_id_seq')";
					cState = cConn.prepareStatement(strSql);
					cResSet = cState.executeQuery();
					cResSet.close();cResSet=null;
					cResSet = cState.executeQuery();	// 繰り返し
					if (cResSet.next()) {
						append_id = cResSet.getInt(1);
					}
					cResSet.close();cResSet=null;
					cState.close();cState=null;
				}
				Log.d("content_id:"+content_id);
				Log.d("append_id:"+append_id);
			}

			strSql = "SELECT * FROM (SELECT contents_0000.* FROM contents_0000 inner join users_0000 on contents_0000.user_id=users_0000.user_id WHERE ng_reaction=0 AND open_id=0 AND publish_id<4 AND file_complex>70000 ORDER BY content_id DESC LIMIT 300) as T1 ORDER BY random() LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, BASE);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_vContentList.add(new CContentComlex(cResSet));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			strSql = "SELECT description FROM (SELECT * FROM vw_rank_emoji_daily WHERE description NOT IN('🎃', '💯', '🍓', '💒', '🐙', '❄', '🐗', '🎍') ORDER BY rank DESC LIMIT 20) as T2 ORDER BY random() LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			for(CContentComlex contentComlex : m_vContentList) {
				if(Common.EMOJI_EVENT) {
					contentComlex.m_strEmoji = Common.EMOJI_EVENT_CHAR;
				} else {
					cResSet = cState.executeQuery();
					if (cResSet.next()) {
						contentComlex.m_strEmoji = cResSet.getString(1);
					}
					cResSet.close();cResSet=null;
				}
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
CheckLogin cCheckLogin = new CheckLogin(request, response);

NewArrivalC cResults = new NewArrivalC();
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<style>
		.IllustThumb {margin: 6px !important;}
		</style>
	</head>

	<body>
		<article class="Wrapper ThumbList">
			<div id="IllustThumbList" class="IllustThumbList">
				<%for(CContentComlex cContent : cResults.m_vContentList) {%>
				<a style="float: left; width: 192px;" href="/f/SendEmojiF.jsp?IID=<%=cContent.m_nContentId%>&EMJ=<%=URLEncoder.encode(cContent.m_strEmoji, "UTF-8")%>&UID=0">
					<img src="<%=Common.GetUrl(cContent.m_strFileName)%>_360.jpg" style="width:180px;" />
					<div style="width: 100%; float: left; font-weight: bold;"><%=cContent.m_strEmoji%> <%=String.format("%,d", cContent.m_nFileComplex)%></div>
				</a>
				<%}%>
			</div>
		</article>
	</body>
</html>
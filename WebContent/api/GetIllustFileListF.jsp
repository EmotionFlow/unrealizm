<%@page import="org.apache.commons.lang3.RandomStringUtils"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.nio.file.Files"%>
<%@page import="java.util.UUID"%>
<%@page import="javax.imageio.ImageIO"%>
<%@page import="org.apache.commons.fileupload.*"%>
<%@page import="org.apache.commons.fileupload.disk.*"%>
<%@page import="org.apache.commons.fileupload.servlet.*"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.JsonMappingException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@include file="/inner/Common.jsp"%>
<%!class GetIllustFileListCParam {
	public int m_nUserId = -1;
	public int m_nContentId = 0;

	public int GetParam(HttpServletRequest request) {
		int nRtn = -1;
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId		= Util.toInt(request.getParameter("ID"));
			m_nContentId	= Util.toInt(request.getParameter("TD"));
			nRtn = 0;
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
			nRtn = -99;
		}
		return nRtn;
	}
}

class GetIllustFileListC {
	public CContent content = new CContent();
	public ArrayList<Object> m_vContent = new ArrayList<Object>();

	public int GetResults(GetIllustFileListCParam cParam, ResourceBundleControl _TEX) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// append_id,ファイル名を取得
			strSql = "(SELECT 0 as append_id,file_name FROM contents_0000 WHERE user_id=? AND content_id=?) UNION (SELECT append_id,file_name FROM contents_appends_0000 WHERE content_id=?) ORDER BY append_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cState.setInt(3, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				Map<String, Object> image = new HashMap<String, Object>();
				image.put("append_id", cResSet.getString("append_id"));
				image.put("name", Common.GetUnrealizmUrl(cResSet.getString("file_name")));
				image.put("thumbnailUrl", Common.GetUnrealizmUrl(cResSet.getString("file_name")) + "_360.jpg");
				m_vContent.add(image);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// メタデータを取得
			strSql = "SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?;";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				content.m_nCategoryId = cResSet.getInt("category_id");
				content.m_nOpenId = cResSet.getInt("open_id");
				content.m_nPublishId = cResSet.getInt("publish_id");
				content.m_strTagList = cResSet.getString("tag_list");
				content.m_strDescription = cResSet.getString("description");
				content.m_strPassword = cResSet.getString("password");
				content.m_nTweetWhenPublished = cResSet.getInt("tweet_when_published");
				content.m_strListId = cResSet.getString("list_id");
				content.m_bLimitedTimePublish = cResSet.getBoolean("limited_time_publish");
				content.m_timeUploadDate = cResSet.getTimestamp("upload_date");
				content.m_timeEndDate = cResSet.getTimestamp("end_date");
				content.m_bNotRecently = cResSet.getBoolean("not_recently");
				content.m_strTweetId = cResSet.getString("tweet_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			nRtn = cParam.m_nContentId;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}%><%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
GetIllustFileListCParam cParam = new GetIllustFileListCParam();
cParam.m_nUserId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);

GetIllustFileListC results = new GetIllustFileListC();
if (checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0) {
	nRtn = results.GetResults(cParam, _TEX);
}

//オブジェクト配列をJSONに変換
ObjectMapper mapper = null;
try {
	HashMap<String, Object> content = new HashMap<String, Object>();
	content.put("result", (nRtn > 0)?1:0);

	if (nRtn > 0) {
		CTweet cTweet = new CTweet();
		if (cTweet.GetResults(cParam.m_nUserId)) {
			content.put("tweet_flag", cTweet.m_bIsTweetEnable);
		}
		content.put("user_id", cParam.m_nUserId);
		content.put("content_id", cParam.m_nContentId);
		content.put("category", results.content.m_nCategoryId);
		content.put("description", Util.toString(results.content.m_strDescription));
		content.put("password", Util.toString(results.content.m_strPassword));
		content.put("tag_list", Util.toString(results.content.m_strTagList));
		content.put("open_id", results.content.m_nOpenId);
		content.put("publish_id", results.content.m_nPublishId);
		content.put("not_recently", results.content.m_bNotRecently);
		content.put("limited_time_publish", results.content.m_bLimitedTimePublish);
		content.put("start_date", Util.toYMDHMString(results.content.m_timeUploadDate));
		content.put("end_date", Util.toYMDHMString(results.content.m_timeEndDate));
		content.put("tweet_when_published", results.content.m_nTweetWhenPublished);
		content.put("twitter_list_id", Util.toString(results.content.m_strListId));
		content.put("tweeted", results.content.m_strTweetId!=null && !results.content.m_strTweetId.isEmpty());
		content.put("files", results.m_vContent);
	}
	mapper = new ObjectMapper();
	String json = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(content);
	out.print(json);
} catch(JsonGenerationException e) {
	e.printStackTrace();
} finally {
	mapper = null;
}

%>

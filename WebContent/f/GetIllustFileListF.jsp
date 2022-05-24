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
	public CContent m_cContent = new CContent();
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
			strSql = "(SELECT 0 as append_id, file_name, file_size FROM contents_0000 WHERE user_id=? AND content_id=?) UNION (SELECT append_id, file_name, file_size FROM contents_appends_0000 WHERE content_id=?) ORDER BY append_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cState.setInt(3, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				Map<String, Object> image = new HashMap<String, Object>();
				image.put("append_id", cResSet.getString("append_id"));
				image.put("name", cResSet.getString("file_name"));
				image.put("thumbnailUrl", Common.GetPoipikuUrl(cResSet.getString("file_name")) + "_360.jpg");
				image.put("uuid", UUID.randomUUID().toString());
				image.put("size", cResSet.getInt("file_size"));
				m_vContent.add(image);
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

GetIllustFileListC cResults = new GetIllustFileListC();
if (checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0) {
	nRtn = cResults.GetResults(cParam, _TEX);
}

if (nRtn > 0) {
	response.setHeader("Access-Control-Allow-Origin", "https://img.poipiku.com");

//オブジェクト配列をJSONに変換
	ObjectMapper mapper = null;
	try {
		mapper = new ObjectMapper();
		out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(cResults.m_vContent));
	} catch(JsonGenerationException e) {
		e.printStackTrace();
	} finally {
		mapper = null;
	}
}
%>

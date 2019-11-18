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
<%!
class GetIllustFileListCParam {
	public int m_nUserId = -1;
	public int m_nContentId = 0;

	public int GetParam(HttpServletRequest request) {
		int nRtn = -1;
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId		= Common.ToInt(request.getParameter("ID"));
			m_nContentId	= Common.ToInt(request.getParameter("TD"));
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

	public int GetResults(GetIllustFileListCParam cParam, ResourceBundleControl _TEX) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// 1枚目
			strSql ="SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_cContent.m_strFileName = Common.ToString(cResSet.getString("file_name"));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Each append image
			strSql = "SELECT * FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id ASC LIMIT 1000";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_cContent.m_vContentAppend.add(new CContentAppend(cResSet));
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
}
%><%
Log.d("GetIllustFileListC");
CheckLogin cCheckLogin = new CheckLogin(request, response);

int nRtn = 0;
GetIllustFileListCParam cParam = new GetIllustFileListCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

//Log.d(Integer.toString(nRtn));
//Log.d(Integer.toString(cParam.m_nUserId));
//Log.d(Integer.toString(cParam.m_nContentId));

GetIllustFileListC cResults = new GetIllustFileListC();
if (cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0) {
	nRtn = cResults.GetResults(cParam, _TEX);
}

if (nRtn > 0) {
	//JSON元データを格納する連想配列
	ArrayList<Object> imglist = new ArrayList<Object>();
	ObjectMapper mapper = null;
	try {
		Map<String, Object> first = new HashMap<String, Object>();

		//1枚目
		first.put("append_id", 0);
		first.put("name", cResults.m_cContent.m_strFileName);
		//first.put("size", 0);
		first.put("thumbnailUrl", "http://localhost" + cResults.m_cContent.m_strFileName + "_360.jpg");
		first.put("deleteUrl", cResults.m_cContent.m_strFileName);
		first.put("deleteType", "DELETE");
		first.put("uuid", UUID.randomUUID().toString());
		imglist.add(first);

		//2枚目以降
		for (CContentAppend cContent : cResults.m_cContent.m_vContentAppend) {
			Map<String, Object> append = new HashMap<String, Object>();
			append.put("append_id", cContent.m_nAppendId);
			append.put("name", cContent.m_strFileName);
			//append.put("size", 0);
			append.put("thumbnailUrl", "http://localhost" + cContent.m_strFileName + "_360.jpg");
			append.put("deleteUrl", cContent.m_strFileName);
			append.put("deleteType", "DELETE");
			append.put("uuid", UUID.randomUUID().toString());
			imglist.add(append);
		}

		mapper = new ObjectMapper();
		out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(imglist));
	} catch(JsonGenerationException e) {
		e.printStackTrace();
	} finally {
		mapper = null;
	}
}
%>

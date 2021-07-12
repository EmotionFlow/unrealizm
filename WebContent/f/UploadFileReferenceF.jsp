<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@include file="/inner/Common.jsp"%>
<%!class UploadReferenceCParam {
	public int m_nUserId = -1;
	public int m_nCategoryId = 0;
	public int m_nSafeFilter = 0;
	public String m_strDescription = "";
	public String m_strTagList = "";

	public int GetParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId			= Util.toInt(request.getParameter("UID"));
			m_nCategoryId		= Util.toIntN(request.getParameter("CAT"), 0, Common.CATEGORY_ID_MAX);
			m_nSafeFilter		= Util.toIntN(request.getParameter("SAF"), Common.SAFE_FILTER_ALL, Common.SAFE_FILTER_R18G);
			m_strDescription	= Common.TrimAll(Util.toString(request.getParameter("DES")));
			m_strTagList		= Common.SubStrNum(Common.TrimAll(Util.toString(request.getParameter("TAG"))), 100);
			m_strDescription	= m_strDescription.replace("＃", "#").replace("♯", "#").replace("\r\n", "\n").replace("\r", "\n");
			if(m_strDescription.startsWith("#")) m_strDescription=" "+m_strDescription;
			m_strTagList		= m_strTagList.replace("＃", "#").replace("♯", "#").replace("\r\n", " ").replace("\r", " ").replace("　", " ");
			// format tag list
			if(!m_strTagList.isEmpty()) {
				ArrayList<String> listTag = new ArrayList<String>();
				String tags[] = m_strTagList.split(" ");
				for(String tag : tags) {
					tag = tag.trim();
					if(tag.isEmpty()) continue;
					if(!tag.startsWith("#")) {
						tag = "#"+tag;
					}
					listTag.add(tag);
				}
				m_strTagList = "";
				if(listTag.size()>0) {
					List<String> listTagUnique = new ArrayList<String>(new LinkedHashSet<String>(listTag));
					if(listTagUnique.size()>0) {
						m_strTagList = " " + String.join(" ", listTagUnique);
					}
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
			return -99;
		}
		return 0;
	}
}


class UploadReferenceC extends UpC {
	int m_nContentId = -99;
	public int GetResults(UploadReferenceCParam cParam, ResourceBundleControl _TEX, CheckLogin checkLogin) {
		// TODO おそらくこのファイルは使われていない。このログが出てこないようなら、ファイルごと削除する。
		Log.d("UploadReferenceC.GetResults");
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// get content id
			strSql ="INSERT INTO contents_0000(user_id, category_id, safe_filter, description, tag_list, updated_at) VALUES(?, ?, ?, ?, ?, now()) RETURNING content_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nCategoryId);
			cState.setInt(3, cParam.m_nSafeFilter);
			cState.setString(4, Common.SubStrNum(cParam.m_strDescription, Common.EDITOR_DESC_MAX[Common.EDITOR_UPLOAD][checkLogin.m_nPassportId]));
			cState.setString(5, cParam.m_strTagList);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_nContentId = cResSet.getInt("content_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Add tags
			AddTags(cParam.m_strDescription, cParam.m_strTagList, m_nContentId, cConn);
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return m_nContentId;
	}
}%><%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadReferenceCParam cParam = new UploadReferenceCParam();
cParam.m_nUserId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);
//Log.d("UploadReferenceCParam:"+nRtn);
//Log.d("UploadReferenceCParam.m_nUserId:"+cParam.m_nUserId);
//Log.d("UploadReferenceCParam.m_nCategoryId:"+cParam.m_nCategoryId);
//Log.d("UploadReferenceCParam.m_strDescription:"+cParam.m_strDescription);

if( checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0 ) {
	UploadReferenceC cResults = new UploadReferenceC();
	nRtn = cResults.GetResults(cParam, _TEX, checkLogin);
}
%>
{
"content_id":<%=nRtn%>
}

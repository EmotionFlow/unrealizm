<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@include file="/inner/Common.jsp"%>
<%
class UploadReferenceCParam {
	public int m_nUserId = -1;
	public int m_nCategoryId = 0;
	public String m_strDescription = "";

	public int GetParam(HttpServletRequest cRequest) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId			= Common.ToInt(request.getParameter("UID"));
			m_nCategoryId		= Common.ToIntN(request.getParameter("CAT"), 0, 12);
			m_strDescription	= Common.TrimAll(Common.ToString(request.getParameter("DES")));
			m_strDescription = m_strDescription.replace("＃", "#").replace("♯", "#").replace("\r\n", "\n").replace("\r", "\n");
			if(m_strDescription.startsWith("#")) m_strDescription=" "+m_strDescription;
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
			return -99;
		}
		return 0;
	}
}


class UploadReferenceC {
	int m_nContentId = -99;
	public int GetResults(UploadReferenceCParam cParam, ResourceBundleControl _TEX) {
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
			strSql ="INSERT INTO contents_0000(user_id, category_id, description) VALUES(?, ?, ?) RETURNING content_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nCategoryId);
			cState.setString(3, Common.SubStrNum(cParam.m_strDescription, 200));
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_nContentId = cResSet.getInt("content_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			if (!cParam.m_strDescription.isEmpty()) {
				// Add my tags
				Pattern ptn = Pattern.compile("#([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}一-龠々ー!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", Pattern.MULTILINE);
				Matcher matcher = ptn.matcher(cParam.m_strDescription.replaceAll("　", " ")+"\n");
				strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type) VALUES(?, ?, 1)";
				cState = cConn.prepareStatement(strSql);
				for (int nNum=0; matcher.find() && nNum<20; nNum++) {
					try {
						cState.setString(1,Common.SubStrNum(matcher.group(1), 64));
						cState.setInt(2, m_nContentId);
						cState.executeUpdate();
					} catch(Exception e) {
						e.printStackTrace();
					}
				}
				cState.close();cState=null;
			}
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
}
%><%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

int nRtn = 0;
UploadReferenceCParam cParam = new UploadReferenceCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadReferenceC cResults = new UploadReferenceC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%>
{
"content_id":<%=nRtn%>
}

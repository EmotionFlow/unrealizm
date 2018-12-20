<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UploadReferenceCParam {
	public int m_nUserId = -1;
	public int m_nCategoryId = 0;
	public int m_nSafeFilter = 0;
	public String m_strDescription = "";
	public String m_strTagList = "";

	public int GetParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId			= Common.ToInt(request.getParameter("UID"));
			m_nCategoryId		= Common.ToIntN(request.getParameter("CAT"), 0, Common.CATEGORY_ID_MAX);
			m_nSafeFilter		= Common.ToIntN(request.getParameter("SAF"), Common.SAFE_FILTER_ALL, Common.SAFE_FILTER_R18G);
			m_strDescription	= Common.SubStrNum(Common.TrimAll(Common.ToString(request.getParameter("DES"))), 200);
			m_strTagList		= Common.SubStrNum(Common.TrimAll(Common.ToString(request.getParameter("TAG"))), 100);
			m_strDescription	= m_strDescription.replace("＃", "#").replace("♯", "#").replace("\r\n", "\n").replace("\r", "\n");
			if(m_strDescription.startsWith("#")) m_strDescription=" "+m_strDescription;
			m_strTagList		= m_strTagList.replace("＃", "#").replace("♯", "#").replace("\r\n", "\n").replace("\r", "\n");
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
			strSql ="INSERT INTO contents_0000(user_id, category_id, safe_filter, description, tag_list) VALUES(?, ?, ?, ?, ?) RETURNING content_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nCategoryId);
			cState.setInt(3, cParam.m_nSafeFilter);
			cState.setString(4, Common.SubStrNum(cParam.m_strDescription, 200));
			cState.setString(5, cParam.m_strTagList);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_nContentId = cResSet.getInt("content_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Add tags
			// from description
			if (!cParam.m_strDescription.isEmpty()) {
				// hush tag
				Pattern ptn = Pattern.compile(Common.HUSH_TAG_PATTERN, Pattern.MULTILINE);
				Matcher matcher = ptn.matcher(cParam.m_strDescription.replaceAll("　", " ")+"\n");
				strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type) VALUES(?, ?, 1) ON CONFLICT DO NOTHING;";
				cState = cConn.prepareStatement(strSql);
				for (int nNum=0; matcher.find() && nNum<20; nNum++) {
					try {
						cState.setString(1,Common.SubStrNum(matcher.group(1), 64));
						cState.setInt(2, m_nContentId);
						cState.executeUpdate();
					} catch(Exception e) {
						Log.d("tag duplicate:"+matcher.group(1));
					}
				}
				cState.close();cState=null;
				// my tag
				ptn = Pattern.compile(Common.MY_TAG_PATTERN, Pattern.MULTILINE);
				matcher = ptn.matcher(cParam.m_strDescription.replaceAll("　", " ")+"\n");
				strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type) VALUES(?, ?, 3) ON CONFLICT DO NOTHING;";
				cState = cConn.prepareStatement(strSql);
				for (int nNum=0; matcher.find() && nNum<20; nNum++) {
					try {
						cState.setString(1,Common.SubStrNum(matcher.group(1), 64));
						cState.setInt(2, m_nContentId);
						cState.executeUpdate();
					} catch(Exception e) {
						Log.d("tag duplicate:"+matcher.group(1));
					}
				}
				cState.close();cState=null;
			}
			// from tag list
			if (!cParam.m_strTagList.isEmpty()) {
				// normal tag
				Pattern ptn = Pattern.compile(Common.NORMAL_TAG_PATTERN, Pattern.MULTILINE);
				Matcher matcher = ptn.matcher(" "+cParam.m_strTagList.replaceAll("　", " ")+"\n");
				strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type) VALUES(?, ?, 1) ON CONFLICT DO NOTHING;";
				cState = cConn.prepareStatement(strSql);
				for (int nNum=0; matcher.find() && nNum<20; nNum++) {
					try {
						cState.setString(1,Common.SubStrNum(matcher.group(1), 64));
						cState.setInt(2, m_nContentId);
						cState.executeUpdate();
					} catch(Exception e) {
						Log.d("tag duplicate:"+matcher.group(1));
					}
				}
				cState.close();cState=null;
				// hush tag
				ptn = Pattern.compile(Common.HUSH_TAG_PATTERN, Pattern.MULTILINE);
				matcher = ptn.matcher(" "+cParam.m_strTagList.replaceAll("　", " ")+"\n");
				strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type) VALUES(?, ?, 1) ON CONFLICT DO NOTHING;";
				cState = cConn.prepareStatement(strSql);
				for (int nNum=0; matcher.find() && nNum<20; nNum++) {
					try {
						cState.setString(1,Common.SubStrNum(matcher.group(1), 64));
						cState.setInt(2, m_nContentId);
						cState.executeUpdate();
					} catch(Exception e) {
						Log.d("tag duplicate:"+matcher.group(1));
					}
				}
				cState.close();cState=null;
				// my tag
				ptn = Pattern.compile(Common.MY_TAG_PATTERN, Pattern.MULTILINE);
				matcher = ptn.matcher(" "+cParam.m_strTagList.replaceAll("　", " ")+"\n");
				strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type) VALUES(?, ?, 3) ON CONFLICT DO NOTHING;";
				cState = cConn.prepareStatement(strSql);
				for (int nNum=0; matcher.find() && nNum<20; nNum++) {
					try {
						cState.setString(1,Common.SubStrNum(matcher.group(1), 64));
						cState.setInt(2, m_nContentId);
						cState.executeUpdate();
					} catch(Exception e) {
						Log.d("tag duplicate:"+matcher.group(1));
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
CheckLogin cCheckLogin = new CheckLogin(request, response);
Log.d("UploadReferenceF - UserId:"+cCheckLogin.m_nUserId);

int nRtn = 0;
UploadReferenceCParam cParam = new UploadReferenceCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);
//Log.d("UploadReferenceCParam:"+nRtn);
//Log.d("UploadReferenceCParam.m_nUserId:"+cParam.m_nUserId);
//Log.d("UploadReferenceCParam.m_nCategoryId:"+cParam.m_nCategoryId);
//Log.d("UploadReferenceCParam.m_strDescription:"+cParam.m_strDescription);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadReferenceC cResults = new UploadReferenceC();
	nRtn = cResults.GetResults(cParam, _TEX);
	Log.d("UploadReferenceF - OK:"+nRtn);
}
%>
{
"content_id":<%=nRtn%>
}

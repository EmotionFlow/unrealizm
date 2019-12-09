<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.JsonMappingException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@include file="/inner/Common.jsp"%>
<%!class UpdateFileRefTwitterCParam {
	public int m_nUserId = -1;
	public int m_nContentId = -1;
	public int m_nCategoryId = 0;
	public int m_nOpenId = 0;
	public int m_nEditorId = 0;
	public String m_strDescription = "";
	public String m_strTagList = "";
	public int m_nPublishId = 0;
	public String m_strPassword = "";
	public String m_strListId = "";

	public int GetParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId			= Common.ToInt(request.getParameter("UID"));
			m_nContentId		= Common.ToInt(request.getParameter("IID"));
			m_nEditorId			= Common.ToInt(request.getParameter("ED"));
			m_nCategoryId		= Common.ToIntN(request.getParameter("CAT"), 0, Common.CATEGORY_ID_MAX);
			m_nOpenId			= Common.ToInt(request.getParameter("REC"));
			m_strDescription	= Common.SubStrNum(Common.TrimAll(request.getParameter("DES")), 200);
			m_strTagList		= Common.SubStrNum(Common.TrimAll(request.getParameter("TAG")), 100);
			m_nPublishId		= Common.ToIntN(request.getParameter("PID"), 0, Common.PUBLISH_ID_MAX);
			m_strPassword		= Common.SubStrNum(Common.TrimAll(request.getParameter("PPW")), 16);
			m_strListId			= Common.TrimAll(request.getParameter("PLD"));
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

class UpdateFileRefTwitterC {
	int m_nContentId = -99;
	public int GetResults(UpdateFileRefTwitterCParam cParam, ResourceBundleControl _TEX) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int safe_filter = Common.SAFE_FILTER_ALL;
		int idx = 0;

		try {
			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			switch(cParam.m_nPublishId) {
				case Common.PUBLISH_ID_R15:
					safe_filter = Common.SAFE_FILTER_R15;
					break;
				case Common.PUBLISH_ID_R18:
					safe_filter = Common.SAFE_FILTER_R18;
					break;
				case Common.PUBLISH_ID_R18G:
					safe_filter = Common.SAFE_FILTER_R18G;
					break;
			}
		} catch(Exception e) {
			e.printStackTrace();
		}

		try {
			// get content id
			strSql = "UPDATE contents_0000 SET category_id=?, open_id=?, description=?, tag_list=?, publish_id=?, password=?, list_id=?, safe_filter=?, upload_date=current_timestamp WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			try {
				idx = 1;
				cState.setInt(idx++, cParam.m_nCategoryId);
				cState.setInt(idx++, cParam.m_nOpenId);
				cState.setString(idx++, Common.SubStrNum(cParam.m_strDescription, 200));
				cState.setString(idx++, cParam.m_strTagList);
				cState.setInt(idx++, cParam.m_nPublishId);
				cState.setString(idx++, cParam.m_strPassword);
				cState.setString(idx++, cParam.m_strListId);
				cState.setInt(idx++, safe_filter);
				cState.setInt(idx++, cParam.m_nUserId);
				cState.setInt(idx++, cParam.m_nContentId);
				cState.executeUpdate();
			} catch(Exception e) {
				e.printStackTrace();
			}
			cState.close();cState=null;

			// Delete old tags
			if (!cParam.m_strDescription.isEmpty() || !cParam.m_strTagList.isEmpty()) {
				strSql = "DELETE FROM tags_0000 WHERE content_id=?;";
				cState = cConn.prepareStatement(strSql);
				try {
					cState.setInt(1, cParam.m_nContentId);
					cState.executeUpdate();
				} catch(Exception e) {
					e.printStackTrace();
				}
				cState.close();cState=null;
			}

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
						cState.setInt(2, cParam.m_nContentId);
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
						cState.setInt(2, cParam.m_nContentId);
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
						cState.setInt(2, cParam.m_nContentId);
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
						cState.setInt(2, cParam.m_nContentId);
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
						cState.setInt(2, cParam.m_nContentId);
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
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return cParam.m_nContentId;
	}
}
%><%
CheckLogin cCheckLogin = new CheckLogin(request, response);
Log.d("UpdateFileRefTwitterF - UserId:"+cCheckLogin.m_nUserId);

int nRtn = 0;
UpdateFileRefTwitterCParam cParam = new UpdateFileRefTwitterCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

Log.d("UpdateFileRefTwitterCParam:"+nRtn);
Log.d("UpdateFileRefTwitterCParam.m_nUserId:"+cParam.m_nUserId);
Log.d("UpdateFileRefTwitterCParam.m_nContentId:"+cParam.m_nContentId);
Log.d("UpdateFileRefTwitterCParam.m_nCategoryId:"+cParam.m_nCategoryId);
Log.d("UpdateFileRefTwitterCParam.m_strDescription:"+cParam.m_strDescription);
Log.d("UpdateFileRefTwitterCParam.m_strTagList:"+cParam.m_strTagList);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UpdateFileRefTwitterC cResults = new UpdateFileRefTwitterC();
	nRtn = cResults.GetResults(cParam, _TEX);
	Log.d("UpdateFileRefTwitterF - OK:"+nRtn);
}
%>
{
"content_id":<%=nRtn%>
}

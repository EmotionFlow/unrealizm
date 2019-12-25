<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@ page import="java.sql.Timestamp"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UploadReferenceCParam {
	public int m_nUserId = -1;
	public int m_nCategoryId = 0;
	public String m_strDescription = "";
	public String m_strTagList = "";
	public int m_nPublishId = 0;
	public String m_strPassword = "";
	public String m_strListId = "";
	public int m_nEditorId = 0;
	public Timestamp m_tsPublishStart = null;
	public Timestamp m_tsPublishEnd = null;

	public int GetParam(HttpServletRequest request) {
		String strPublishStart = "";
		String strPublishEnd = "";
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId			= Common.ToInt(request.getParameter("UID"));
			m_nCategoryId		= Common.ToIntN(request.getParameter("CAT"), 0, Common.CATEGORY_ID_MAX);
			m_strDescription	= Common.SubStrNum(Common.TrimAll(request.getParameter("DES")), 200);
			m_strTagList		= Common.SubStrNum(Common.TrimAll(request.getParameter("TAG")), 100);
			m_nPublishId		= Common.ToIntN(request.getParameter("PID"), 0, Common.PUBLISH_ID_MAX);
			m_strPassword		= Common.SubStrNum(Common.TrimAll(request.getParameter("PPW")), 16);
			m_strListId			= Common.TrimAll(request.getParameter("PLD"));
			m_nEditorId			= Common.ToIntN(request.getParameter("ED"), 0, Common.PUBLISH_ID_MAX);
			strPublishStart		= Common.SubStrNum(Common.TrimAll(request.getParameter("PST")), 16).replace("/", "-");
			strPublishEnd		= Common.SubStrNum(Common.TrimAll(request.getParameter("PED")), 16).replace("/", "-");
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
			if(!strPublishStart.isEmpty()){m_tsPublishStart = Timestamp.valueOf(strPublishStart);};
			if(!strPublishEnd.isEmpty()){m_tsPublishEnd = Timestamp.valueOf(strPublishEnd);};
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
		int idx = 0;

		try {
			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			int safe_filter = Common.SAFE_FILTER_ALL;
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

			// get content id
			ArrayList<String> lColumns = new ArrayList<String>();
			lColumns.addAll(Arrays.asList("user_id", "category_id", "description", "tag_list", "publish_id", "password", "list_id", "safe_filter", "editor_id"));

			/*
			if(cParam.m_nPublishId == Common.PUBLISH_ID_LIMITED_TIME){
				if(cParam.m_tsPublishStart == null && cParam.m_tsPublishEnd == null){throw new Exception("m_nPublishId is 'limited time', but start and end is null.");};

				Timestamp tsNow = new Timestamp(System.currentTimeMillis());
				if(cParam.m_tsPublishStart != null ){
					lColumns.add("upload_date");
					if(cParam.m_tsPublishStart>tsNow){
						cParam.m_nOpenId = 0;
					} else {
						cParam.m_nOpenId = 3;
					}
				}
				if(cParam.m_tsPublishEnd != null ){
					lColumns.add("end_date");
				}
			}
			*/

			ArrayList<String> lVals = new ArrayList<String>();
			lColumns.forEach(c -> lVals.add("?"));
			strSql = String.format("INSERT INTO contents_0000(%s) VALUES(%s) RETURNING content_id", String.join(",", lColumns), String.join(",", lVals));

			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, cParam.m_nUserId);
			cState.setInt(idx++, cParam.m_nCategoryId);
			cState.setString(idx++, Common.SubStrNum(cParam.m_strDescription, 200));
			cState.setString(idx++, cParam.m_strTagList);
			cState.setInt(idx++, cParam.m_nPublishId);
			cState.setString(idx++, cParam.m_strPassword);
			cState.setString(idx++, cParam.m_strListId);
			cState.setInt(idx++, safe_filter);
			cState.setInt(idx++, cParam.m_nEditorId);
			if(cParam.m_tsPublishStart != null ){
				cState.setTimestamp(idx++, cParam.m_tsPublishStart);
			}
			if(cParam.m_tsPublishEnd != null ){
				cState.setTimestamp(idx++, cParam.m_tsPublishEnd);
			}

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

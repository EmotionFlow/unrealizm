<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

int nRtn = 0;

//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);

int m_nUserId = Common.ToInt(request.getParameter("UID"));
int m_nContentId = Common.ToInt(request.getParameter("IID"));
int m_nCategoryId = Common.ToIntN(request.getParameter("CAT"), 0, Common.CATEGORY_ID_MAX);
String m_strDescription = Common.TrimAll(Common.ToString(request.getParameter("DES")));
String m_strTagList = Common.SubStrNum(Common.TrimAll(Common.ToString(request.getParameter("TAG"))), 100);
int m_nMode = Common.ToInt(request.getParameter("MOD"));
m_strDescription = m_strDescription.replace("＃", "#").replace("♯", "#").replace("\r\n", "\n").replace("\r", "\n");
if(m_strDescription.startsWith("#")) m_strDescription=" "+m_strDescription;
m_strTagList = m_strTagList.replace("＃", "#").replace("♯", "#").replace("\r\n", " ").replace("\r", " ").replace("　", " ");
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

if(cCheckLogin.m_bLogin && (cCheckLogin.m_nUserId == m_nUserId)) {
	DataSource dsPostgres = null;
	Connection cConn = null;
	PreparedStatement cState = null;
	ResultSet cResSet = null;
	String strSql = "";

	try {
		dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
		cConn = dsPostgres.getConnection();

		// get Editor ID
		int editor_id = Common.EDITOR_UPLOAD;
		strSql = "SELECT editor_id FROM contents_0000 WHERE user_id=? AND content_id=?";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, m_nUserId);
		cState.setInt(2, m_nContentId);
		cResSet = cState.executeQuery();
		if(cResSet.next()) {
			editor_id = cResSet.getInt("editor_id");
		}
		cResSet.close();cResSet=null;
		cState.close();cState=null;


		// Update Description
		strSql = "UPDATE contents_0000 SET category_id=?, description=?, tag_list=? WHERE user_id=? AND content_id=? RETURNING content_id";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, m_nCategoryId);
		cState.setString(2, Common.SubStrNum(m_strDescription, Common.EDITOR_DESC_MAX[editor_id][cCheckLogin.m_nPremiumId]));
		cState.setString(3, m_strTagList);
		cState.setInt(4, m_nUserId);
		cState.setInt(5, m_nContentId);
		cResSet = cState.executeQuery();
		if(cResSet.next()) {
			nRtn = cResSet.getInt("content_id");
		}
		cResSet.close();cResSet=null;
		cState.close();cState=null;

		// 存在確認
		if(nRtn>0) {
			// delete all tag
			strSql ="DELETE FROM tags_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			// Add tags
			// from description
			if (!m_strDescription.isEmpty()) {
				// hush tag
				Pattern ptn = Pattern.compile(Common.HUSH_TAG_PATTERN, Pattern.MULTILINE);
				Matcher matcher = ptn.matcher(m_strDescription.replaceAll("　", " ")+"\n");
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
				matcher = ptn.matcher(m_strDescription.replaceAll("　", " ")+"\n");
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
			if (!m_strTagList.isEmpty()) {
				// normal tag
				Pattern ptn = Pattern.compile(Common.NORMAL_TAG_PATTERN, Pattern.MULTILINE);
				Matcher matcher = ptn.matcher(" "+m_strTagList.replaceAll("　", " ")+"\n");
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
				matcher = ptn.matcher(" "+m_strTagList.replaceAll("　", " ")+"\n");
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
				matcher = ptn.matcher(" "+m_strTagList.replaceAll("　", " ")+"\n");
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
			nRtn = 1;
		}
	} catch(Exception e) {
		Log.d(strSql);
		e.printStackTrace();
	} finally {
		try{if(cState != null) cState.close();cState=null;} catch(Exception e) {;}
		try{if(cConn != null) cConn.close();cConn=null;} catch(Exception e) {;}
		try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
	}
}
%>
{
"result": <%=nRtn%>,
"html" : "<%=CEnc.E(Common.AutoLink(Common.ToStringHtml(m_strDescription), m_nUserId, m_nMode))%>",
"text" : "<%=CEnc.E(m_strDescription)%>",
"htmlTag" : "<%=CEnc.E(Common.AutoLink(Common.ToStringHtml(m_strTagList), m_nUserId, m_nMode))%>",
"textTag" : "<%=CEnc.E(m_strTagList)%>",
"category_name" : "<%=CEnc.E(_TEX.T(String.format("Category.C%d", m_nCategoryId)))%>"
}

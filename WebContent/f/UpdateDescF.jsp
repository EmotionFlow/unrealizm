<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

int nRtn = 0;

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

int m_nUserId = Common.ToInt(request.getParameter("UID"));
int m_nContentId = Common.ToInt(request.getParameter("IID"));
int m_nCategoryId = Common.ToIntN(request.getParameter("CAT"), 0, 16);
String m_strDesc = Common.SubStrNum(Common.TrimAll(Common.ToString(request.getParameter("DES"))), 200);
int m_nMode = Common.ToInt(request.getParameter("MOD"));
m_strDesc = m_strDesc.replace("＃", "#").replace("♯", "#").replace("\r\n", "\n").replace("\r", "\n");
if(m_strDesc.startsWith("#")) m_strDesc=" "+m_strDesc;

if(cCheckLogin.m_bLogin && (cCheckLogin.m_nUserId == m_nUserId)) {
	DataSource dsPostgres = null;
	Connection cConn = null;
	PreparedStatement cState = null;
	ResultSet cResSet = null;
	String strSql = "";

	try {
		dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
		cConn = dsPostgres.getConnection();

		// Update Description
		strSql = "UPDATE contents_0000 SET category_id=?, description=? WHERE user_id=? AND content_id=? RETURNING content_id";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, m_nCategoryId);
		cState.setString(2, m_strDesc);
		cState.setInt(3, m_nUserId);
		cState.setInt(4, m_nContentId);
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

			if (!m_strDesc.isEmpty()) {
				// Add my tags
				Pattern ptn = Pattern.compile(Common.TAG_PATTERN, Pattern.MULTILINE);
				Matcher matcher = ptn.matcher(m_strDesc.replaceAll("　", " ")+"\n");
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
"html" : "<%=CEnc.E(Common.AutoLink(Common.ToStringHtml(m_strDesc), m_nMode))%>",
"text" : "<%=CEnc.E(m_strDesc)%>",
"category_name" : "<%=CEnc.E(_TEX.T(String.format("Category.C%d", m_nCategoryId)))%>"
}

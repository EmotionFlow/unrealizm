<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
class UpdateTagCParam {
	public int GetParam(HttpServletRequest cRequest) {
		try {
			;
		} catch(Exception e) {
			return -99;
		}
		return 0;
	}
}

class UpdateTagC {
	public Vector<CContent> m_vContentList = new Vector<CContent>();

	public int GetResults(UpdateTagCParam cParam) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";


		try {
			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// Get description data

			//CContent
			strSql = "SELECT * FROM contents_0000 WHERE description!=''";
			cState = cConn.prepareStatement(strSql);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent();
				cContent.m_nContentId		= cResSet.getInt("content_id");
				cContent.m_strDescription	= Common.ToString(cResSet.getString("description"));
				m_vContentList.addElement(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Clean all tags
			strSql ="TRUNCATE tags_0000";
			cState = cConn.prepareStatement(strSql);
			cState.executeUpdate();
			cState.close();cState=null;

			// Add my tags
			for(CContent cContent : m_vContentList) {
				Pattern ptn = Pattern.compile("#([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", Pattern.MULTILINE);
				Matcher matcher = ptn.matcher(cContent.m_strDescription.replaceAll("　", " ")+"\n");
				strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type) VALUES(?, ?, 1)";
				cState = cConn.prepareStatement(strSql);
				for (int nNum=0; matcher.find() && nNum<20; nNum++) {
					try {
						cState.setString(1,Common.SubStrNum(matcher.group(1), 64));
						cState.setInt(2, cContent.m_nContentId);
						cState.executeUpdate();
					} catch(Exception e) {
						e.printStackTrace();
					}
				}
				cState.close();cState=null;
			}

		} catch(Exception e) {
			System.out.println(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return 1;
	}
}
%><%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(cCheckLogin.m_nUserId != 1) {
	return;
}

int nRtn = 0;
UpdateTagCParam cParam = new UpdateTagCParam();
nRtn = cParam.GetParam(request);

UpdateTagC cResults = new UpdateTagC();
nRtn = cResults.GetResults(cParam);
%><%=nRtn%>
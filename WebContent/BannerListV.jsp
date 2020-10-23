<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class BannerListC {
	public Vector<CContent> m_vContentList = new Vector<CContent>();
	int m_nEndId = -1;
	public int SELECT_MAX_GALLERY = 0;

	public boolean GetResults() {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		DatabaseMetaData meta = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();
			meta = cConn.getMetaData();

			// NEW ARRIVAL
			if(SELECT_MAX_GALLERY>0) {
				strSql = "SELECT * FROM contents_0000 WHERE open_id==0 AND bookmark_num>10 ORDER BY RANDOM() LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, SELECT_MAX_GALLERY);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CContent cContent = new CContent(cResSet);
					m_nEndId = cContent.m_nContentId;
					m_vContentList.addElement(cContent);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			bResult = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bResult;
	}
}
%>
<%
	request.setCharacterEncoding("UTF-8");
int nBodyWidth = Util.toInt(request.getParameter("BWDT"));
if(nBodyWidth<0) nBodyWidth=320;
int nImgWidth = Util.toInt(request.getParameter("IWDT"));
if(nImgWidth<0) nImgWidth=80;
int nImgNum = Util.toInt(request.getParameter("INUM"));
if(nImgNum<0) nImgNum=4;

CheckLogin cCheckLogin = new CheckLogin(request, response);

BannerListC cResults = new BannerListC();
cResults.SELECT_MAX_GALLERY = nImgNum;
boolean bRtn = cResults.GetResults();
%>
<!DOCTYPE html>
<html style="height: <%=nImgWidth%>px;">
	<body style="margin:0; padding:0; width: <%=nBodyWidth%>px;">
		<%for(CContent cContent : cResults.m_vContentList) {%>
		<a style="display: block; float: left;" href="https://poipiku.com/<%=cContent.m_nUserId%>/<%=cContent.m_nContentId%>.html" target="_blank">
			<img style="display: block; float: left; width: <%=nImgWidth%>px; height: <%=nImgWidth%>px;" src="<%=Common.GetUrl(cContent.m_strFileName)%>_360.jpg">
		</a>
		<%}%>
	</body>
</html>
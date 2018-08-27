<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/TopC.jsp"%>
<%
request.setCharacterEncoding("UTF-8");
int nBodyWidth = Common.ToInt(request.getParameter("BWDT"));
if(nBodyWidth<0) nBodyWidth=320;
int nImgWidth = Common.ToInt(request.getParameter("IWDT"));
if(nImgWidth<0) nImgWidth=80;
int nImgNum = Common.ToInt(request.getParameter("INUM"));
if(nImgNum<0) nImgNum=4;

CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

TopCParam cParam = new TopCParam();
cParam.GetParam(request);

TopC cResults = new TopC();
cResults.SELECT_MAX_GALLERY = nImgNum;
boolean bRtn = cResults.GetResults(cParam);
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
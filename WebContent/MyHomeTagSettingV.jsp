<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(!cCheckLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

MyHomeTagSettingC cResults = new MyHomeTagSettingC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("MyHomeTagSetting.Title")%></title>
	</head>

	<body>
		<div id="DispMsg"></div>
		<div class="Wrapper ItemList">
			<div id="IllustThumbList" class="IllustThumbList">
				<%if(cResults.m_vContentList.size()<=0) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 160px 0; text-align: center; background-color: #fff;">
					<%=_TEX.T("MyHomeTag.FirstMsg")%>
				</div>
				<%}%>

				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CTag cTag = cResults.m_vContentList.get(nCnt);%>
					<%if(cTag.m_nTypeId==Common.FOVO_KEYWORD_TYPE_TAG) {%>
					<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX)%>
					<%} else {%>
					<%=CCnv.toHtmlKeyword(cTag, CCnv.MODE_SP, _TEX)%>
					<%}%>
					<%if((nCnt+1)%10==0) {%>
					<%@ include file="/inner/TAdMid.jsp"%>
					<%}%>
				<%}%>
			</div>
		</div>
	</body>
</html>
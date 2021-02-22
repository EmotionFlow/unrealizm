<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

MyHomeTagSettingC cResults = new MyHomeTagSettingC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("MyHomeTagSetting.Title")%></title>
	</head>

	<body>
		<div id="DispMsg"></div>
		<article class="Wrapper ItemList">
			<div id="IllustThumbList" class="IllustThumbList">
				<%if(cResults.m_vContentList.size()<=0) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 160px 0; text-align: center; background-color: #fff;">
					<%=_TEX.T("MyHomeTag.FirstMsg")%>
				</div>
				<%}%>

				<%
				int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
				for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CTag cTag = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX, nSpMode)%>
					<%if((nCnt+1)%9==0) {%><%@ include file="/inner/TAd336x280_mid.jsp"%><%}
				}%>
			</div>
		</article>
	</body>
</html>
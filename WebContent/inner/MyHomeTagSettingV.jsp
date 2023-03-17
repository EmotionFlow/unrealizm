<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

MyHomeTagSettingC results = new MyHomeTagSettingC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("MyHomeTagSetting.Title")%></title>
	</head>

	<body>
		<div id="DispMsg"></div>
		<article class="Wrapper ItemList">
			<div id="IllustThumbList" class="IllustThumbList">
				<%if(results.tagList.size()<=0) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 160px 0; text-align: center; background-color: #ffffff;">
					<%=_TEX.T("MyHomeTag.FirstMsg")%>
				</div>
				<%}%>

				<%
				int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
				for(int nCnt = 0; nCnt<results.tagList.size(); nCnt++) {
					CTag cTag = results.tagList.get(nCnt);%>
					<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX, nSpMode)%>
					<%if((nCnt+1)%9==0) {%><%@ include file="/inner/TAd336x280_mid.jsp"%><%}
				}%>
			</div>
		</article>
	</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

MyHomeTagSettingC cResults = new MyHomeTagSettingC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(checkLogin);
int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

for(int nCnt = 0; nCnt<cResults.tagList.size(); nCnt++) {
	CTag cTag = cResults.tagList.get(nCnt);
%>
<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX, nSpMode)%>
<%
	if((nCnt+1)%9==0) {
%>
<%@ include file="/inner/TAd336x280_mid.jsp"%>
<%
	}
}
%>

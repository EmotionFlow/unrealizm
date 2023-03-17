<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

MyHomeTagSettingC results = new MyHomeTagSettingC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin);
int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

for(int nCnt = 0; nCnt<results.tagList.size(); nCnt++) {
	CTag cTag = results.tagList.get(nCnt);
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

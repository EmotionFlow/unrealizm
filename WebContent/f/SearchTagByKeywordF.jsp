<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

SearchTagByKeywordC results = new SearchTagByKeywordC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin);

for(int nCnt = 0; nCnt<results.tagList.size(); nCnt++) {
	CTag cTag = results.tagList.get(nCnt);%>
	<%=CCnv.toHtmlTag(cTag, results.sampleContentFile.get(nCnt), checkLogin.m_nUserId)%>
<%}%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) return;
%>
{
"result": <%=Common.CATEGORY_ID.length%>,
"user_id": <%=cCheckLogin.m_nUserId%>,
"category_id" : [
<%for(int nCnt=0; nCnt<Common.CATEGORY_ID.length; nCnt++) {%>
"<%=CEnc.E(String.valueOf(Common.CATEGORY_ID[nCnt]))%>"<%if(nCnt<Common.CATEGORY_ID.length-1){%>,<%}%>
<%}%>
],
"category_name" : [
<%for(int nCnt=0; nCnt<Common.CATEGORY_ID.length; nCnt++) {%>
"<%=CEnc.E(_TEX.T(String.format("Category.C%d", Common.CATEGORY_ID[nCnt])))%>"<%if(nCnt<Common.CATEGORY_ID.length-1){%>,<%}%>
<%}%>
]
}

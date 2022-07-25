<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;
GetSearchLogC cResults = new GetSearchLogC();
cResults.getParam(request);
int nResult = cResults.getResults(checkLogin);
%>
{
"result": <%=nResult%>,
"keywords": [
  <%for(int i=0; i<nResult; i++) {%>
    "<%=cResults.keywords.get(i)%>"<%if(i<nResult-1){%>,<%}%>
  <%}%>
]
}
